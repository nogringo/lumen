import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

/// Remembers the last balance and activity read from each wallet, to show
/// them at launch.
abstract interface class WalletCache {
  Future<int?> readBalance(String walletId);
  Future<void> writeBalance(String walletId, int sats);
  Future<List<Transaction>?> readActivity(String walletId);
  Future<void> writeActivity(String walletId, List<Transaction> transactions);

  /// Forgets everything saved for [walletId].
  Future<void> delete(String walletId);
}

/// Payment history is as private as the balance, so both stay encrypted.
final class SecureWalletCache implements WalletCache {
  SecureWalletCache({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static String _balanceKey(String walletId) => 'lumen.balance.$walletId';
  static String _activityKey(String walletId) => 'lumen.activity.$walletId';

  @override
  Future<int?> readBalance(String walletId) async {
    try {
      return int.tryParse(
        await _storage.read(key: _balanceKey(walletId)) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeBalance(String walletId, int sats) =>
      _storage.write(key: _balanceKey(walletId), value: '$sats');

  @override
  Future<List<Transaction>?> readActivity(String walletId) async {
    try {
      final saved = await _storage.read(key: _activityKey(walletId));
      if (saved == null) return null;
      return [
        for (final item in jsonDecode(saved) as List)
          _decode(item as Map<String, dynamic>),
      ];
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeActivity(String walletId, List<Transaction> transactions) =>
      _storage.write(
        key: _activityKey(walletId),
        value: jsonEncode([for (final t in transactions) _encode(t)]),
      );

  @override
  Future<void> delete(String walletId) async {
    await _storage.delete(key: _balanceKey(walletId));
    await _storage.delete(key: _activityKey(walletId));
  }

  static Map<String, Object?> _encode(Transaction t) => {
    'id': t.id,
    'incoming': t.isIncoming,
    'sats': t.sats,
    'at': t.at.millisecondsSinceEpoch,
    'description': t.description,
    'txid': t.txid,
    'confirmations': t.confirmations,
  };

  static Transaction _decode(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    direction: json['incoming'] as bool
        ? TransactionDirection.incoming
        : TransactionDirection.outgoing,
    sats: json['sats'] as int,
    at: DateTime.fromMillisecondsSinceEpoch(json['at'] as int),
    description: json['description'] as String?,
    txid: json['txid'] as String?,
    confirmations: json['confirmations'] as int?,
  );
}

final class MemoryWalletCache implements WalletCache {
  final Map<String, int> _sats = {};
  final Map<String, List<Transaction>> _activity = {};

  @override
  Future<int?> readBalance(String walletId) async => _sats[walletId];

  @override
  Future<void> writeBalance(String walletId, int sats) async =>
      _sats[walletId] = sats;

  @override
  Future<List<Transaction>?> readActivity(String walletId) async =>
      _activity[walletId];

  @override
  Future<void> writeActivity(
    String walletId,
    List<Transaction> transactions,
  ) async => _activity[walletId] = transactions;

  @override
  Future<void> delete(String walletId) async {
    _sats.remove(walletId);
    _activity.remove(walletId);
  }
}
