import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'layout/app_shell.dart';
import 'layout/layout.dart';
import 'screens/connect_nwc_screen.dart';
import 'screens/home_screen.dart';
import 'screens/receive_screen.dart';
import 'screens/send_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/welcome_screen.dart';
import 'wallets/wallets_controller.dart';

GoRouter createRouter(WalletsController wallets) {
  return GoRouter(
    refreshListenable: wallets.listChanges,
    redirect: (context, state) {
      final path = state.uri.path;
      final empty = wallets.wallets.isEmpty;
      if (empty &&
          (path == '/' ||
              path == '/send' ||
              path == '/receive' ||
              path.startsWith('/wallet/'))) {
        return '/welcome';
      }
      if (!empty && path == '/welcome') return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) =>
            _page(context, state, const WelcomeScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                _page(context, state, const HomeScreen()),
          ),
          GoRoute(
            path: '/connect',
            pageBuilder: (context, state) =>
                _page(context, state, const ConnectNwcScreen()),
          ),
          GoRoute(
            path: '/send',
            pageBuilder: (context, state) => _page(
              context,
              state,
              SendScreen(walletId: state.uri.queryParameters['wallet']),
            ),
          ),
          GoRoute(
            path: '/receive',
            pageBuilder: (context, state) => _page(
              context,
              state,
              ReceiveScreen(walletId: state.uri.queryParameters['wallet']),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _page(context, state, const SettingsScreen()),
          ),
          GoRoute(
            path: '/settings/lock',
            pageBuilder: (context, state) =>
                _page(context, state, const TurnOnScreen()),
          ),
          GoRoute(
            path: '/settings/passphrase',
            pageBuilder: (context, state) =>
                _page(context, state, const ChangePassphraseScreen()),
          ),
          GoRoute(
            path: '/wallet/:id',
            redirect: (context, state) =>
                wallets.walletById(state.pathParameters['id']!) == null
                ? '/'
                : null,
            pageBuilder: (context, state) => _page(
              context,
              state,
              WalletScreen(walletId: state.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
}

/// Desktop swaps pages in place, as the sidebar does not slide.
Page<void> _page(BuildContext context, GoRouterState state, Widget child) {
  final instant =
      MediaQuery.disableAnimationsOf(context) ||
      LayoutSize.of(context) == LayoutSize.desktop;
  return instant
      ? NoTransitionPage(key: state.pageKey, child: child)
      : MaterialPage(key: state.pageKey, child: child);
}
