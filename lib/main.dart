import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

import 'app.dart';
import 'wallets/wallet_cache.dart';
import 'wallets/wallets_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Flutter web builds no accessibility tree until a hidden button is pressed.
  if (kIsWeb) SemanticsBinding.instance.ensureSemantics();
  final sources = WalletSources.create(
    repo: FlutterSecureStorageWalletsRepo(),
    eventVerifier: NdkEventVerifier(),
  );
  final wallets = WalletsController(sources.all, cache: SecureWalletCache());
  await wallets.load();
  runApp(LumenApp(sources: sources, wallets: wallets));
}
