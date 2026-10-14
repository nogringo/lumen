import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/app.dart';
import 'package:lumen/lock/app_gate.dart';
import 'package:lumen/lock/app_lock.dart';
import 'package:lumen/lock/lock_store.dart';
import 'package:lumen/lock/sealed_storage.dart';
import 'package:lumen/wallets/wallet_cache.dart';
import 'package:lumen/wallets/wallets_controller.dart';

import 'fakes.dart';

class _Session extends LumenSession {
  _Session()
    : super(memorySources(), WalletsController([], cache: MemoryWalletCache()));

  bool closed = false;

  @override
  Future<void> close() {
    closed = true;
    return super.close();
  }
}

void main() {
  const passphrase = 'correct horse battery';
  late LockStore lockStore;
  late SealedStorage storage;
  late List<_Session> sessions;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    lockStore = MemoryLockStore();
    storage = SealedStorage();
    sessions = [];
  });

  AppGate gate() => AppGate(
    lock: AppLock(lockStore, kdf: const FastKdf()),
    storage: storage,
    openSession: () async {
      final session = _Session();
      sessions.add(session);
      return session;
    },
  );

  Future<String?> raw(String key) =>
      const FlutterSecureStorage().read(key: key);

  test('without App lock, Lumen opens straight away', () async {
    final g = gate();
    await g.start();

    expect(g.session, same(sessions.single));
  });

  test('turning App lock on seals what is already saved', () async {
    await storage.write(key: 'wallets', value: 'nwc secret');
    final g = gate();
    await g.start();

    await g.enableLock(passphrase);

    expect(await raw('wallets'), startsWith('sealed:'));
    expect(await storage.read(key: 'wallets'), 'nwc secret');
  });

  test('Lock now closes the session and forgets the key', () async {
    final g = gate();
    await g.start();
    await g.enableLock(passphrase);
    await storage.write(key: 'wallets', value: 'nwc secret');

    await g.lockNow();

    expect((g.session, sessions.single.closed), (null, true));
    await expectLater(storage.read(key: 'wallets'), throwsStateError);
  });

  test('Lumen opens locked, and only the passphrase opens it', () async {
    final first = gate();
    await first.start();
    await first.enableLock(passphrase);
    await storage.write(key: 'wallets', value: 'nwc secret');

    storage = SealedStorage();
    final relaunched = gate();
    await relaunched.start();
    expect((relaunched.session, sessions.length), (null, 1));

    expect(
      await relaunched.unlock('wrong horse battery'),
      PassphraseCheck.wrong,
    );
    expect(relaunched.session, isNull);
    expect(await relaunched.unlock(passphrase), PassphraseCheck.correct);
    expect(relaunched.session, same(sessions.last));
    expect(await storage.read(key: 'wallets'), 'nwc secret');
  });

  test('unlocking finishes sealing that was cut short', () async {
    final first = gate();
    await first.start();
    await first.lock.enable(passphrase);
    await storage.write(key: 'wallets', value: 'nwc secret');

    storage = SealedStorage();
    final relaunched = gate();
    await relaunched.start();
    await relaunched.unlock(passphrase);

    expect(await raw('wallets'), startsWith('sealed:'));
  });

  test('Lock now does nothing while App lock is off', () async {
    final g = gate();
    await g.start();

    await g.lockNow();

    expect(g.session, isNotNull);
  });

  test('turning App lock off unseals the data', () async {
    final g = gate();
    await g.start();
    await g.enableLock(passphrase);
    await storage.write(key: 'wallets', value: 'nwc secret');

    expect(await g.disableLock(passphrase), PassphraseCheck.correct);

    expect(await raw('wallets'), 'nwc secret');
    expect(g.lock.enabled, isFalse);
  });

  test('reset forgets the wallets and App lock', () async {
    final g = gate();
    await g.start();
    await g.enableLock(passphrase);
    await storage.write(key: 'wallets', value: 'nwc secret');
    await g.lockNow();

    await g.reset();

    expect(await const FlutterSecureStorage().readAll(), isEmpty);
    expect((g.lock.enabled, g.lock.locked), (false, false));
    expect(g.session, same(sessions.last));
  });

  testWidgets('locking hides the wallets until Lumen is unlocked', (
    tester,
  ) async {
    final g = AppGate(
      lock: AppLock(lockStore, kdf: const FastKdf()),
      storage: storage,
      openSession: () async {
        final wallets = await loadedController([
          FakeWallet('home', 'Home node', balance: 21),
        ]);
        await wallets.refreshAll();
        return LumenSession(memorySources(), wallets);
      },
    );
    await tester.runAsync(() async {
      await g.start();
      await g.enableLock(passphrase);
    });
    await tester.pumpWidget(LumenApp(gate: g));
    await tester.pumpAndSettle();
    expect(find.text('Home node'), findsOneWidget);

    await tester.runAsync(g.lockNow);
    await tester.pumpAndSettle();
    expect(find.text('Home node'), findsNothing);

    await tester.runAsync(() => g.unlock(passphrase));
    await tester.pumpAndSettle();
    expect(find.text('Home node'), findsOneWidget);
    await tester.runAsync(g.lockNow);
  });
}
