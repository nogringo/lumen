import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

import 'app.dart';
import 'lock/app_gate.dart';
import 'lock/app_lock.dart';
import 'lock/lock_store.dart';
import 'lock/sealed_storage.dart';
import 'settings/language.dart';
import 'wallets/history_store.dart';
import 'wallets/wallet_cache.dart';
import 'wallets/wallets_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Flutter web builds no accessibility tree until a hidden button is pressed.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  final storage = SealedStorage();
  final gate = AppGate(
    lock: AppLock(SecureLockStore()),
    storage: storage,
    openSession: () async {
      final sources = WalletSources.create(
        repo: FlutterSecureStorageWalletsRepo(storage: storage),
        eventVerifier: NdkEventVerifier(),
      );
      final wallets = WalletsController(
        sources.all,
        cache: SecureWalletCache(storage: storage),
        // Without a history on disk, Lumen still works for this session.
        history: await HistoryStore.open(storage)
            .catchError((Object _) => HistoryStore.memory()),
      );
      await wallets.load();
      return LumenSession(sources, wallets);
    },
  );
  final language = LanguageSetting(PrefsLanguageStore());
  await Future.wait([language.load(), gate.start()]);
  runApp(LumenApp(gate: gate, language: language));
}
