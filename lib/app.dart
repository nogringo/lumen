import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/generated/app_localizations.dart';
import 'lock/app_gate.dart';
import 'lock/gate_scope.dart';
import 'router.dart';
import 'screens/lock_screen.dart';
import 'settings/language.dart';
import 'theme/lumen_theme.dart';
import 'wallets/lumen_scope.dart';

class LumenApp extends StatefulWidget {
  const LumenApp({super.key, required this.gate, required this.language});

  final AppGate gate;
  final LanguageSetting language;

  @override
  State<LumenApp> createState() => _LumenAppState();
}

class _LumenAppState extends State<LumenApp> {
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => widget.gate.session?.wallets.refreshStale(),
  );
  LumenSession? _routedSession;
  GoRouter? _router;

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  void _refresh() => widget.gate.session?.wallets.refreshAll();

  /// One router per session. The old one is disposed once the frame that
  /// replaces it is built.
  GoRouter? _routerFor(LumenSession? session) {
    if (identical(session, _routedSession)) return _router;
    final old = _router;
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    _routedSession = session;
    return _router = session == null ? null : createRouter(session.wallets);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GateScope(
      gate: widget.gate,
      child: LanguageScope(
        language: widget.language,
        child: ListenableBuilder(
          listenable: Listenable.merge([widget.gate, widget.language]),
          builder: (context, _) {
            final session = widget.gate.session;
            final router = _routerFor(session);
            if (session == null || router == null) {
              return MaterialApp(
                title: 'Lumen',
                debugShowCheckedModeBanner: false,
                theme: lumenTheme(Brightness.light),
                darkTheme: lumenTheme(Brightness.dark),
                highContrastTheme: lumenTheme(
                  Brightness.light,
                  highContrast: true,
                ),
                highContrastDarkTheme: lumenTheme(
                  Brightness.dark,
                  highContrast: true,
                ),
                locale: widget.language.locale,
                localizationsDelegates: _localizations,
                supportedLocales: AppLocalizations.supportedLocales,
                home: widget.gate.lock.locked
                    ? const LockScreen()
                    : const Scaffold(),
              );
            }
            return LumenScope(
              sources: session.sources,
              wallets: session.wallets,
              child: MaterialApp.router(
                title: 'Lumen',
                debugShowCheckedModeBanner: false,
                theme: lumenTheme(Brightness.light),
                darkTheme: lumenTheme(Brightness.dark),
                highContrastTheme: lumenTheme(
                  Brightness.light,
                  highContrast: true,
                ),
                highContrastDarkTheme: lumenTheme(
                  Brightness.dark,
                  highContrast: true,
                ),
                locale: widget.language.locale,
                localizationsDelegates: _localizations,
                supportedLocales: AppLocalizations.supportedLocales,
                routerConfig: router,
                // Here rather than in the builder, so a text field gets
                // ⌘← and Alt+← first to move its cursor.
                shortcuts: {
                  ...WidgetsApp.defaultShortcuts,
                  const SingleActivator(
                    LogicalKeyboardKey.bracketLeft,
                    meta: true,
                  ): const _BackIntent(),
                  const SingleActivator(
                    LogicalKeyboardKey.arrowLeft,
                    meta: true,
                  ): const _BackIntent(),
                  const SingleActivator(
                    LogicalKeyboardKey.arrowLeft,
                    alt: true,
                  ): const _BackIntent(),
                },
                builder: (context, child) => Actions(
                  actions: {_BackIntent: _BackAction(router)},
                  child: Listener(
                    onPointerDown: (event) {
                      // Browsers already go back with it.
                      if (!kIsWeb &&
                          (event.buttons & kBackMouseButton) != 0 &&
                          router.canPop()) {
                        router.routerDelegate.popRoute();
                      }
                    },
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(
                          LogicalKeyboardKey.keyR,
                          meta: true,
                        ): _refresh,
                        const SingleActivator(
                          LogicalKeyboardKey.keyR,
                          control: true,
                        ): _refresh,
                        const SingleActivator(LogicalKeyboardKey.f5): _refresh,
                        const SingleActivator(
                          LogicalKeyboardKey.keyL,
                          meta: true,
                        ): widget.gate.lockNow,
                        const SingleActivator(
                          LogicalKeyboardKey.keyL,
                          control: true,
                        ): widget.gate.lockNow,
                      },
                      child: child!,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackIntent extends Intent {
  const _BackIntent();
}

/// Goes back as Android's back button does, which also closes a dialog.
/// Disabled with nowhere to go back to, so a browser can take the keys.
class _BackAction extends Action<_BackIntent> {
  _BackAction(this.router);

  final GoRouter router;

  @override
  bool isEnabled(_BackIntent intent) => router.canPop();

  @override
  Future<bool> invoke(_BackIntent intent) => router.routerDelegate.popRoute();
}

const _localizations = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
