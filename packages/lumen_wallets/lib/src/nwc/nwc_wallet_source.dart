// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:math';

import 'package:ndk/domain_layer/repositories/wallets_repo.dart';
import 'package:ndk/entities.dart' as ndk show NwcWallet, WalletType;
import 'package:ndk/ndk.dart' show Ndk, NwcConnection, NwcMethod;

import '../wallet.dart';
import 'nwc_uri.dart';

/// Lightning wallets connected over Nostr Wallet Connect (NIP-47).
final class NwcWalletSource implements WalletSource {
  NwcWalletSource({required this._ndk, required this._repo});

  final Ndk _ndk;
  final WalletsRepo _repo;

  /// Wallets saved by [add] that ndk is still connecting in the background.
  final Map<String, ndk.NwcWallet> _adding = {};
  final Map<String, Future<void>> _registering = {};

  static const _timeout = Duration(seconds: 30);
  static const _paymentCheckInterval = Duration(seconds: 5);

  @override
  Future<List<Wallet>> load() async => [
    for (final wallet in await _ndkWallets())
      _NwcWallet(this, wallet.id, wallet.name),
  ];

  /// Saves [uri] as [name] right away, after checking its format and that it
  /// is not saved already. The wallet itself is only contacted when its
  /// balance is fetched.
  ///
  /// Throws a [NwcConnectException] when the string cannot be saved.
  Future<Wallet> add({required String uri, required String name}) async {
    final value = uri.trim();
    final formatError = checkNwcUri(value);
    if (formatError != null) throw NwcConnectException(formatError);

    final saved = (await _repo.getWallets()).whereType<ndk.NwcWallet>();
    if (saved.any((wallet) => sameNwcConnection(wallet.nwcUrl, value))) {
      throw const NwcConnectException(NwcConnectError.duplicate);
    }

    final id = _randomId();
    final wallet = _ndk.wallets.createWallet(
      id: id,
      name: name.trim(),
      type: ndk.WalletType.NWC,
      supportedUnits: const {'sat'},
      metadata: {'nwcUrl': value},
    );
    // ndk connects before it saves, so save first to return at once.
    await _repo.storeWallet(wallet);
    _adding[id] = wallet as ndk.NwcWallet;
    _registering[id] = _ndk.wallets
        .addWallet(wallet)
        .catchError((Object _) {})
        .whenComplete(() {
          _adding.remove(id);
          _registering.remove(id);
        });
    return _NwcWallet(this, id, name.trim());
  }

  /// Waits for a background registration, and retries one that failed.
  Future<ndk.NwcWallet> _registered(String id) async {
    await _registering[id];
    final known = await _ndkWallet(id);
    if (known != null) return known;

    final stored = (await _repo.getWallets(ids: [id]))
        .whereType<ndk.NwcWallet>()
        .firstOrNull;
    if (stored == null) throw StateError('No NWC wallet $id');
    await _ndk.wallets.addWallet(stored);
    return (await _ndkWallet(id))!;
  }

  Future<int> _fetchBalance(String id) async {
    final ndk.NwcWallet wallet;
    try {
      wallet = await _registered(id).timeout(_timeout);
    } catch (_) {
      throw const BalanceException(BalanceError.unreachable);
    }

    try {
      final balances = await _ndk.wallets.refreshBalance(id).timeout(_timeout);
      return balances.firstWhere((balance) => balance.unit == 'sat').amount;
    } catch (_) {
      final current = await _ndkWallet(id) ?? wallet;
      final permissions = current.connection?.permissions ?? const <String>{};
      if (permissions.isNotEmpty &&
          !permissions.contains(NwcMethod.GET_BALANCE.name)) {
        throw const BalanceException(BalanceError.noPermission);
      }
      await _dropConnection(current);
      throw const BalanceException(BalanceError.unreachable);
    }
  }

  /// The registered wallet with a live connection, reconnecting if needed.
  Future<ndk.NwcWallet> _connected(String id) async {
    await _registered(id);
    final wallet = await _ndk.wallets.reconnectWallet(id) as ndk.NwcWallet;
    if (wallet.connection == null) throw StateError('NWC wallet $id offline');
    return wallet;
  }

  Future<Invoice> _createInvoice(String id, int sats) async {
    final ndk.NwcWallet wallet;
    try {
      wallet = await _connected(id).timeout(_timeout);
    } catch (_) {
      throw const ReceiveException(ReceiveError.unreachable);
    }
    final connection = wallet.connection!;
    final permissions = connection.permissions;
    if (permissions.isNotEmpty &&
        !permissions.contains(NwcMethod.MAKE_INVOICE.name)) {
      throw const ReceiveException(ReceiveError.noPermission);
    }

    try {
      final response = await _ndk.nwc
          .makeInvoice(connection, amountSats: sats)
          .timeout(_timeout);
      final expiresAt = response.expiresAt;
      return Invoice(
        request: response.invoice,
        sats: response.amountSat,
        paymentHash: response.paymentHash.isEmpty ? null : response.paymentHash,
        expiresAt: expiresAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000),
      );
    } catch (_) {
      await _dropConnection(wallet);
      throw const ReceiveException(ReceiveError.unreachable);
    }
  }

  /// Listens for the wallet's payment notifications, and also looks the
  /// invoice up regularly since not every wallet sends them.
  Stream<void> _watchPayment(String id, Invoice invoice) {
    final controller = StreamController<void>();
    StreamSubscription<void>? notifications;
    NwcConnection? listening;
    Timer? timer;
    var checking = false;
    var stopped = false;

    bool matches(String request, String paymentHash) =>
        request == invoice.request || paymentHash == invoice.paymentHash;

    void paid() {
      if (stopped || controller.isClosed) return;
      controller.add(null);
      controller.close();
    }

    Future<void> check() async {
      if (checking || stopped || controller.isClosed) return;
      checking = true;
      try {
        final connection = (await _connected(id).timeout(_timeout)).connection!;
        if (stopped) return;
        if (!identical(connection, listening)) {
          await notifications?.cancel();
          listening = connection;
          notifications = connection.paymentsReceivedStream
              .where((n) => matches(n.invoice, n.paymentHash))
              .listen((_) => paid());
        }
        if (connection.permissions.contains(NwcMethod.LOOKUP_INVOICE.name)) {
          final hash = invoice.paymentHash;
          final found = await _ndk.nwc
              .lookupInvoice(
                connection,
                paymentHash: hash,
                invoice: hash == null ? invoice.request : null,
              )
              .timeout(_timeout);
          if (found.settledAt != null || found.state == 'settled') paid();
        }
      } catch (_) {
        // Tried again on the next tick.
      } finally {
        checking = false;
      }
    }

    controller
      ..onListen = () {
        check();
        timer = Timer.periodic(_paymentCheckInterval, (_) => check());
      }
      ..onCancel = () {
        stopped = true;
        timer?.cancel();
        return notifications?.cancel();
      };
    return controller.stream;
  }

  /// ndk never reconnects a wallet that holds a connection, even a dead one,
  /// so drop it to let the next refresh connect again.
  Future<void> _dropConnection(ndk.NwcWallet wallet) async {
    final connection = wallet.connection;
    if (connection == null) return;
    wallet.connection = null;
    await _ndk.nwc.disconnect(connection);
  }

  Future<void> _rename(String id, String name) async {
    final wallet =
        _adding[id] ??
        await _ndkWallet(id) ??
        (await _repo.getWallets(ids: [id]))
            .whereType<ndk.NwcWallet>()
            .firstOrNull;
    if (wallet == null) throw StateError('No NWC wallet $id');
    wallet.name = name;
    await _repo.storeWallet(wallet);
  }

  Future<void> _remove(String id) async {
    final registering = _registering[id];
    if (registering == null) return _ndk.wallets.removeWallet(id);

    await _repo.removeWallet(id);
    // ndk saves the wallet again once connected, so remove it from there too.
    unawaited(
      registering
          .then((_) => _ndk.wallets.removeWallet(id))
          .catchError((Object _) {}),
    );
  }

  Future<List<ndk.NwcWallet>> _ndkWallets() async =>
      (await _ndk.wallets.getWallets()).whereType<ndk.NwcWallet>().toList();

  Future<ndk.NwcWallet?> _ndkWallet(String id) async {
    for (final wallet in await _ndkWallets()) {
      if (wallet.id == id) return wallet;
    }
    return null;
  }
}

final class _NwcWallet implements Wallet {
  _NwcWallet(this._source, this.id, this._name);

  final NwcWalletSource _source;
  String _name;

  @override
  final String id;

  @override
  String get name => _name;

  @override
  WalletKind get kind => WalletKind.lightning;

  @override
  Future<int> fetchBalance() => _source._fetchBalance(id);

  @override
  Future<Invoice> createInvoice(int sats) => _source._createInvoice(id, sats);

  @override
  Stream<void> watchPayment(Invoice invoice) =>
      _source._watchPayment(id, invoice);

  @override
  Future<void> rename(String name) async {
    await _source._rename(id, name.trim());
    _name = name.trim();
  }

  @override
  Future<void> remove() => _source._remove(id);
}

String _randomId() {
  final random = Random.secure();
  return [
    for (var i = 0; i < 16; i++)
      random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}
