import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Remembers the last balance read from each wallet, to show it at launch.
abstract interface class BalanceStore {
  Future<int?> read(String walletId);
  Future<void> write(String walletId, int sats);
  Future<void> delete(String walletId);
}

final class SecureBalanceStore implements BalanceStore {
  SecureBalanceStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String _key(String walletId) => 'lumen.balance.$walletId';

  @override
  Future<int?> read(String walletId) async {
    try {
      return int.tryParse(await _storage.read(key: _key(walletId)) ?? '');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String walletId, int sats) =>
      _storage.write(key: _key(walletId), value: '$sats');

  @override
  Future<void> delete(String walletId) => _storage.delete(key: _key(walletId));
}

final class MemoryBalanceStore implements BalanceStore {
  final Map<String, int> _sats = {};

  @override
  Future<int?> read(String walletId) async => _sats[walletId];

  @override
  Future<void> write(String walletId, int sats) async => _sats[walletId] = sats;

  @override
  Future<void> delete(String walletId) async => _sats.remove(walletId);
}
