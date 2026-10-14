import 'package:clock/clock.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/lock/app_lock.dart';
import 'package:lumen/lock/lock_store.dart';

import 'fakes.dart';

void main() {
  const passphrase = 'correct horse battery';
  const wrong = 'wrong horse battery';

  AppLock appLock(MemoryLockStore store) =>
      AppLock(store, kdf: const FastKdf());

  Future<AppLock> enabledLock(MemoryLockStore store) async {
    final lock = appLock(store);
    await lock.enable(passphrase);
    return lock;
  }

  test('App lock is off and unlocked until a passphrase is set', () async {
    final lock = appLock(MemoryLockStore());
    await lock.load();

    expect((lock.enabled, lock.locked, lock.key), (false, false, null));
  });

  test('Lumen opens locked once a passphrase is set', () async {
    final store = MemoryLockStore();
    await enabledLock(store);

    final relaunched = appLock(store);
    await relaunched.load();

    expect((relaunched.enabled, relaunched.locked), (true, true));
    expect(relaunched.key, isNull);
  });

  test('the right passphrase opens the same data key', () async {
    final store = MemoryLockStore();
    final lock = await enabledLock(store);
    final key = await lock.key!.extractBytes();

    final relaunched = appLock(store);
    await relaunched.load();

    expect(await relaunched.unlock(wrong), PassphraseCheck.wrong);
    expect(relaunched.locked, isTrue);
    expect(await relaunched.unlock(passphrase), PassphraseCheck.correct);
    expect(relaunched.locked, isFalse);
    expect(await relaunched.key!.extractBytes(), key);
  });

  test('the saved record holds neither the passphrase nor the key', () async {
    final store = MemoryLockStore();
    final lock = await enabledLock(store);
    final key = await lock.key!.extractBytes();
    final record = store.record!;

    expect(String.fromCharCodes(record.wrappedKey), isNot(contains('horse')));
    expect(record.wrappedKey, isNot(containsAllInOrder(key)));
    expect((record.memoryKiB, record.iterations), (65536, 3));
  });

  test('Lock now forgets the key', () async {
    final lock = await enabledLock(MemoryLockStore());

    lock.lock();

    expect((lock.locked, lock.key), (true, null));
  });

  test('Lock now does nothing while App lock is off', () async {
    final lock = appLock(MemoryLockStore());
    await lock.load();

    lock.lock();

    expect(lock.locked, isFalse);
  });

  test(
    'repeated wrong passphrases make the user wait, even after a relaunch',
    () {
      var now = DateTime(2026, 10, 14, 12);
      withClock(Clock(() => now), () async {
        final store = MemoryLockStore();
        final lock = await enabledLock(store);
        lock.lock();

        for (var i = 1; i < AppLock.freeAttempts; i++) {
          expect(await lock.unlock(wrong), PassphraseCheck.wrong);
          expect(lock.retryAt, isNull);
        }
        expect(await lock.unlock(wrong), PassphraseCheck.wrong);
        expect(lock.retryAt, now.add(const Duration(seconds: 30)));

        final relaunched = appLock(store);
        await relaunched.load();
        expect(await relaunched.unlock(passphrase), PassphraseCheck.wait);

        now = now.add(const Duration(seconds: 30));
        expect(await relaunched.unlock(wrong), PassphraseCheck.wrong);
        expect(relaunched.retryAt, now.add(const Duration(minutes: 1)));
      });
    },
  );

  test('the right passphrase clears the wrong ones counted before', () async {
    final store = MemoryLockStore();
    final lock = await enabledLock(store);
    await lock.unlock(wrong);

    await lock.unlock(passphrase);

    expect(store.record!.failures, 0);
  });

  test('the wait doubles up to about an hour', () {
    expect(AppLock.waitAfter(AppLock.freeAttempts - 1), isNull);
    expect(
      AppLock.waitAfter(AppLock.freeAttempts),
      const Duration(seconds: 30),
    );
    expect(
      AppLock.waitAfter(AppLock.freeAttempts + 1),
      const Duration(minutes: 1),
    );
    expect(AppLock.waitAfter(1000), const Duration(seconds: 30 << 7));
  });

  test('a passphrase needs 12 characters, counted as typed', () {
    expect(AppLock.isLongEnough('a' * 11), isFalse);
    expect(AppLock.isLongEnough('a' * 12), isTrue);
    expect(AppLock.isLongEnough('é' * 12), isTrue);
  });

  test('turning App lock off needs the passphrase', () async {
    final store = MemoryLockStore();
    final lock = await enabledLock(store);
    var copied = false;

    expect(await lock.disable(wrong), PassphraseCheck.wrong);
    expect(lock.enabled, isTrue);
    expect(
      await lock.disable(passphrase, decrypt: (_) async => copied = true),
      PassphraseCheck.correct,
    );
    expect(
      (copied, lock.enabled, lock.key, store.record),
      (true, false, null, null),
    );
  });

  test('a new passphrase opens the same key, the old one no longer', () async {
    final store = MemoryLockStore();
    final lock = await enabledLock(store);
    final key = await lock.key!.extractBytes();
    const next = 'a much longer passphrase';

    expect(
      await lock.changePassphrase(passphrase, next),
      PassphraseCheck.correct,
    );

    final relaunched = appLock(store);
    await relaunched.load();
    expect(await relaunched.unlock(passphrase), PassphraseCheck.wrong);
    expect(await relaunched.unlock(next), PassphraseCheck.correct);
    expect(await relaunched.key!.extractBytes(), key);
  });

  test('reset turns App lock off without the passphrase', () async {
    final store = MemoryLockStore();
    final lock = await enabledLock(store);
    lock.lock();

    await lock.reset();

    expect((lock.enabled, lock.locked, store.record), (false, false, null));
  });

  test('Argon2id derives the key from the passphrase and the salt', () async {
    const kdf = Argon2Kdf();
    final salt = List.filled(16, 1);
    const cost = (memoryKiB: 64, iterations: 1);

    final key = await kdf.derive(passphrase, salt, cost);

    expect(key, hasLength(32));
    expect(await kdf.derive(passphrase, salt, cost), key);
    expect(await kdf.derive(wrong, salt, cost), isNot(key));
    expect(await kdf.derive(passphrase, List.filled(16, 2), cost), isNot(key));
  });

  test('the saved record reads back the same', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final at = DateTime.fromMillisecondsSinceEpoch(1760000000000);
    await SecureLockStore().write(
      LockRecord(
        salt: [1, 2],
        memoryKiB: 65536,
        iterations: 3,
        wrappedKey: [3, 4, 5],
        failures: 5,
        retryAt: at,
      ),
    );

    final r = (await SecureLockStore().read())!;
    expect(r.salt, [1, 2]);
    expect(r.wrappedKey, [3, 4, 5]);
    expect(
      (r.memoryKiB, r.iterations, r.failures, r.retryAt),
      (65536, 3, 5, at),
    );

    await SecureLockStore().write(null);
    expect(await SecureLockStore().read(), isNull);
  });
}
