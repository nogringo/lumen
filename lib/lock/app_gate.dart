import 'package:flutter/foundation.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

import '../wallets/wallets_controller.dart';
import 'app_lock.dart';
import 'sealed_storage.dart';

/// What Lumen holds open while it is unlocked: the wallets and their
/// connections. Locking closes it, so no connection secret stays in memory.
class LumenSession {
  LumenSession(this.sources, this.wallets);

  final WalletSources sources;
  final WalletsController wallets;

  Future<void> close() async {
    wallets.dispose();
    await sources.dispose();
  }
}

/// Opens a session when Lumen is unlocked and closes it when Lumen locks.
class AppGate extends ChangeNotifier {
  AppGate({
    required this.lock,
    required this.storage,
    required this._openSession,
  });

  final AppLock lock;
  final SealedStorage storage;
  final Future<LumenSession> Function() _openSession;
  LumenSession? _session;

  /// Null while Lumen is locked, or while it opens.
  LumenSession? get session => _session;

  Future<void> start() async {
    await lock.load();
    if (!lock.locked) await _open();
  }

  Future<PassphraseCheck> unlock(String passphrase) async {
    final result = await lock.unlock(passphrase);
    if (result == PassphraseCheck.correct) await _open();
    return result;
  }

  Future<void> lockNow() async {
    if (!lock.enabled) return;
    lock.lock();
    await _close();
  }

  Future<void> enableLock(String passphrase) async {
    await lock.enable(passphrase);
    await storage.sealAll(lock.key!);
  }

  Future<PassphraseCheck> disableLock(String passphrase) =>
      lock.disable(passphrase, decrypt: storage.unsealAll);

  /// Forgets every wallet and App lock, for a forgotten passphrase.
  Future<void> reset() async {
    await _close();
    await storage.deleteAll();
    await lock.reset();
    await _open();
  }

  Future<void> _open() async {
    // Also finishes sealing that an earlier run left half done.
    if (lock.key case final key?) await storage.sealAll(key);
    _session = await _openSession();
    notifyListeners();
  }

  Future<void> _close() async {
    final session = _session;
    _session = null;
    storage.dataKey = null;
    notifyListeners();
    await session?.close();
  }
}
