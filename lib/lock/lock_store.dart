import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// What App lock keeps between launches. No record means App lock is off.
@immutable
class LockRecord {
  const LockRecord({
    required this.salt,
    required this.memoryKiB,
    required this.iterations,
    required this.wrappedKey,
    this.failures = 0,
    this.retryAt,
  });

  /// Argon2id inputs that turn the passphrase into the key that opens
  /// [wrappedKey]. The cost is saved so a later version can raise it.
  final List<int> salt;
  final int memoryKiB;
  final int iterations;

  /// The data key, encrypted with AES-256-GCM: nonce, cipher text and MAC.
  final List<int> wrappedKey;

  /// Wrong passphrases entered in a row.
  final int failures;

  /// No passphrase is checked before this time.
  final DateTime? retryAt;

  LockRecord copyWith({int? failures, DateTime? Function()? retryAt}) =>
      LockRecord(
        salt: salt,
        memoryKiB: memoryKiB,
        iterations: iterations,
        wrappedKey: wrappedKey,
        failures: failures ?? this.failures,
        retryAt: retryAt == null ? this.retryAt : retryAt(),
      );
}

abstract interface class LockStore {
  Future<LockRecord?> read();

  /// Saves [record], or forgets it when null.
  Future<void> write(LockRecord? record);
}

final class SecureLockStore implements LockStore {
  SecureLockStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _key = 'lumen.lock';

  @override
  Future<LockRecord?> read() async {
    final saved = await _storage.read(key: _key);
    if (saved == null) return null;
    final json = jsonDecode(saved) as Map<String, dynamic>;
    final retryAt = json['retryAt'] as int?;
    return LockRecord(
      salt: base64.decode(json['salt'] as String),
      memoryKiB: json['memoryKiB'] as int,
      iterations: json['iterations'] as int,
      wrappedKey: base64.decode(json['wrappedKey'] as String),
      failures: json['failures'] as int,
      retryAt: retryAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(retryAt),
    );
  }

  @override
  Future<void> write(LockRecord? record) => record == null
      ? _storage.delete(key: _key)
      : _storage.write(
          key: _key,
          value: jsonEncode({
            'salt': base64.encode(record.salt),
            'memoryKiB': record.memoryKiB,
            'iterations': record.iterations,
            'wrappedKey': base64.encode(record.wrappedKey),
            'failures': record.failures,
            'retryAt': record.retryAt?.millisecondsSinceEpoch,
          }),
        );
}

final class MemoryLockStore implements LockStore {
  MemoryLockStore([this.record]);

  LockRecord? record;

  @override
  Future<LockRecord?> read() async => record;

  @override
  Future<void> write(LockRecord? record) async => this.record = record;
}
