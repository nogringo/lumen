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

  static const _timeout = Duration(seconds: 15);

  @override
  Future<List<Wallet>> load() async => [
    for (final wallet in await _ndkWallets())
      _NwcWallet(this, wallet.id, wallet.name),
  ];

  /// Checks [uri] against the wallet, then saves it as [name].
  ///
  /// Returns the new wallet with the balance read during the check. Throws a
  /// [NwcConnectException] when the connection cannot be used.
  Future<(Wallet, int)> add({required String uri, required String name}) async {
    final value = uri.trim();
    final formatError = checkNwcUri(value);
    if (formatError != null) throw NwcConnectException(formatError);

    final existing = await _ndkWallets();
    if (existing.any((wallet) => sameNwcConnection(wallet.nwcUrl, value))) {
      throw const NwcConnectException(NwcConnectError.duplicate);
    }

    final balance = await _probeBalance(value);
    final id = _randomId();
    await _ndk.wallets.addWallet(
      _ndk.wallets.createWallet(
        id: id,
        name: name.trim(),
        type: ndk.WalletType.NWC,
        supportedUnits: const {'sat'},
        metadata: {'nwcUrl': value},
      ),
    );
    return (_NwcWallet(this, id, name.trim()), balance);
  }

  Future<int> _probeBalance(String uri) async {
    NwcConnection? connection;
    try {
      var infoFound = true;
      connection = await _ndk.nwc.connect(
        uri,
        timeout: _timeout,
        onError: (_) => infoFound = false,
      );
      if (!infoFound || connection.permissions.isEmpty) {
        throw const NwcConnectException(NwcConnectError.unreachable);
      }
      if (!connection.permissions.contains(NwcMethod.GET_BALANCE.name)) {
        throw const NwcConnectException(NwcConnectError.cannotReadBalance);
      }
      final response = await _ndk.nwc.getBalance(connection, timeout: _timeout);
      return response.balanceSats;
    } on NwcConnectException {
      rethrow;
    } catch (_) {
      throw const NwcConnectException(NwcConnectError.unreachable);
    } finally {
      if (connection != null) await _ndk.nwc.disconnect(connection);
    }
  }

  Future<int> _fetchBalance(String id) async {
    try {
      final balances = await _ndk.wallets
          .refreshBalance(id)
          .timeout(_timeout * 2);
      return balances.firstWhere((balance) => balance.unit == 'sat').amount;
    } catch (_) {
      await _dropConnection(id);
      rethrow;
    }
  }

  /// ndk never reconnects a wallet that holds a connection, even a dead one,
  /// so drop it to let the next refresh connect again.
  Future<void> _dropConnection(String id) async {
    final wallet = await _ndkWallet(id);
    final connection = wallet?.connection;
    if (wallet == null || connection == null) return;
    wallet.connection = null;
    await _ndk.nwc.disconnect(connection);
  }

  Future<void> _rename(String id, String name) async {
    final wallet = await _ndkWallet(id);
    if (wallet == null) throw StateError('No NWC wallet $id');
    wallet.name = name;
    await _repo.storeWallet(wallet);
  }

  Future<void> _remove(String id) => _ndk.wallets.removeWallet(id);

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
