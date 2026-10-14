import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:serverpod_argon2/serverpod_argon2.dart';

import 'lock_store.dart';

typedef KdfCost = ({int memoryKiB, int iterations});

abstract interface class PassphraseKdf {
  Future<List<int>> derive(String passphrase, List<int> salt, KdfCost cost);
}

/// Argon2id. [compute] keeps it off the UI isolate, except on the web, which
/// has no isolates.
final class Argon2Kdf implements PassphraseKdf {
  const Argon2Kdf();

  @override
  Future<List<int>> derive(String passphrase, List<int> salt, KdfCost cost) =>
      compute(_derive, (passphrase, salt, cost));

  static Future<List<int>> _derive((String, List<int>, KdfCost) input) async {
    final (passphrase, salt, cost) = input;
    return (await Argon2.load()).deriveKey(
      password: utf8.encode(passphrase),
      salt: salt,
      parameters: Argon2Parameters(
        memoryKiB: cost.memoryKiB,
        iterations: cost.iterations,
      ),
    );
  }
}

enum PassphraseCheck { correct, wrong, wait }

/// App lock asks for the Lumen passphrase when Lumen opens and after Lock now.
///
/// The passphrase never unlocks anything by itself: it opens a random data
/// key, and the wallets are encrypted with that key.
class AppLock extends ChangeNotifier {
  AppLock(this._store, {this._kdf = const Argon2Kdf()});

  static const minLength = 12;

  /// RFC 9106's second recommended setting, with one lane since the library
  /// computes lanes one after another.
  static const cost = (memoryKiB: 64 * 1024, iterations: 3);

  static const freeAttempts = 5;

  /// The wait after the [failures]th wrong passphrase in a row: none for the
  /// first [freeAttempts], then 30 seconds, doubling up to about an hour.
  static Duration? waitAfter(int failures) => failures < freeAttempts
      ? null
      : Duration(seconds: 30 << min(failures - freeAttempts, 7));

  static bool isLongEnough(String passphrase) =>
      passphrase.runes.length >= minLength;

  static final _cipher = AesGcm.with256bits();
  static final _random = Random.secure();

  final LockStore _store;
  final PassphraseKdf _kdf;
  LockRecord? _record;
  SecretKey? _key;

  bool get enabled => _record != null;

  bool get locked => enabled && _key == null;

  /// The data key, while App lock is on and Lumen is unlocked.
  SecretKey? get key => _key;

  /// When the next passphrase can be checked, while the user has to wait.
  DateTime? get retryAt {
    final at = _record?.retryAt;
    return at != null && at.isAfter(clock.now()) ? at : null;
  }

  Future<void> load() async {
    _record = await _store.read();
    _key = null;
    notifyListeners();
  }

  /// Saves the lock before the data is sealed with [key], so a sealing cut
  /// short can finish at the next unlock instead of losing the key.
  Future<void> enable(String passphrase) async {
    assert(isLongEnough(passphrase));
    final key = await _cipher.newSecretKey();
    final record = await _wrap(key, passphrase);
    _key = key;
    await _save(record);
  }

  Future<PassphraseCheck> unlock(String passphrase) async {
    final (result, key) = await _open(passphrase);
    if (key != null) {
      _key = key;
      notifyListeners();
    }
    return result;
  }

  /// Confirms the passphrase before a sensitive action, with the same tries
  /// and waits as [unlock].
  Future<PassphraseCheck> check(String passphrase) async =>
      (await _open(passphrase)).$1;

  /// [decrypt] copies the saved data out of the key before App lock is off.
  Future<PassphraseCheck> disable(
    String passphrase, {
    Future<void> Function(SecretKey key)? decrypt,
  }) async {
    final (result, key) = await _open(passphrase);
    if (key != null) {
      await decrypt?.call(key);
      _key = null;
      await _save(null);
    }
    return result;
  }

  Future<PassphraseCheck> changePassphrase(String current, String next) async {
    assert(isLongEnough(next));
    final (result, key) = await _open(current);
    if (key != null) await _save(await _wrap(key, next));
    return result;
  }

  void lock() {
    if (locked || !enabled) return;
    _key = null;
    notifyListeners();
  }

  /// Turns App lock off without the passphrase, when Lumen is reset. The data
  /// encrypted with the old key can no longer be read.
  Future<void> reset() async {
    _key = null;
    await _save(null);
  }

  Future<LockRecord> _wrap(SecretKey key, String passphrase) async {
    final salt = List.generate(16, (_) => _random.nextInt(256));
    final box = await _cipher.encrypt(
      await key.extractBytes(),
      secretKey: SecretKey(await _kdf.derive(passphrase, salt, cost)),
    );
    return LockRecord(
      salt: salt,
      memoryKiB: cost.memoryKiB,
      iterations: cost.iterations,
      wrappedKey: box.concatenation(),
    );
  }

  Future<(PassphraseCheck, SecretKey?)> _open(String passphrase) async {
    final record = _record!;
    if (retryAt != null) return (PassphraseCheck.wait, null);
    final box = SecretBox.fromConcatenation(
      record.wrappedKey,
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    final kek = await _kdf.derive(passphrase, record.salt, (
      memoryKiB: record.memoryKiB,
      iterations: record.iterations,
    ));
    try {
      final key = SecretKey(
        await _cipher.decrypt(box, secretKey: SecretKey(kek)),
      );
      if (record.failures > 0) {
        await _save(record.copyWith(failures: 0, retryAt: () => null));
      }
      return (PassphraseCheck.correct, key);
    } on SecretBoxAuthenticationError {
      final failures = record.failures + 1;
      final wait = waitAfter(failures);
      await _save(
        record.copyWith(
          failures: failures,
          retryAt: () => wait == null ? null : clock.now().add(wait),
        ),
      );
      return (PassphraseCheck.wrong, null);
    }
  }

  Future<void> _save(LockRecord? record) async {
    await _store.write(record);
    _record = record;
    notifyListeners();
  }
}
