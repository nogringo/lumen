import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/generated/app_localizations.dart';
import 'router.dart';
import 'theme/lumen_theme.dart';
import 'wallets/lumen_scope.dart';
import 'wallets/wallets_controller.dart';

class LumenApp extends StatefulWidget {
  const LumenApp({super.key, required this.sources, required this.wallets});

  final WalletSources sources;
  final WalletsController wallets;

  @override
  State<LumenApp> createState() => _LumenAppState();
}

class _LumenAppState extends State<LumenApp> {
  late final GoRouter _router = createRouter(widget.wallets);
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: widget.wallets.refreshAll,
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  void _refresh() => widget.wallets.refreshAll();

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LumenScope(
      sources: widget.sources,
      wallets: widget.wallets,
      child: MaterialApp.router(
        title: 'Lumen',
        debugShowCheckedModeBanner: false,
        theme: lumenTheme(Brightness.light),
        darkTheme: lumenTheme(Brightness.dark),
        highContrastTheme: lumenTheme(Brightness.light, highContrast: true),
        highContrastDarkTheme: lumenTheme(Brightness.dark, highContrast: true),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: _router,
        builder: (context, child) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.keyR, meta: true):
                _refresh,
            const SingleActivator(LogicalKeyboardKey.keyR, control: true):
                _refresh,
            const SingleActivator(LogicalKeyboardKey.f5): _refresh,
          },
          child: child!,
        ),
      ),
    );
  }
}
