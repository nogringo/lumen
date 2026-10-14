// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:math';

import 'package:ndk/domain_layer/repositories/wallets_repo.dart';
import 'package:ndk/entities.dart' as ndk show NwcWallet, WalletType;
import 'package:ndk/ndk.dart' show Ndk, NwcMethod;

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
