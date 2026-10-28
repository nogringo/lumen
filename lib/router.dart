import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'layout/app_shell.dart';
import 'layout/layout.dart';
import 'screens/activity_screen.dart';
import 'screens/add_liquid_screen.dart';
import 'screens/add_wallet_screen.dart';
import 'screens/connect_nwc_screen.dart';
import 'screens/home_screen.dart';
import 'screens/liquid_servers_screen.dart';
import 'screens/payment_screen.dart';
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
              path == '/activity' ||
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
            path: '/activity',
            pageBuilder: (context, state) => _page(
              context,
              state,
              ActivityScreen(walletId: state.uri.queryParameters['wallet']),
            ),
          ),
          GoRoute(
            path: '/payment/:wallet/:id',
            redirect: (context, state) =>
                wallets.walletById(state.pathParameters['wallet']!) == null
                ? '/'
                : null,
            pageBuilder: (context, state) => _page(
              context,
              state,
              PaymentScreen(
                walletId: state.pathParameters['wallet']!,
                transactionId: state.pathParameters['id']!,
              ),
            ),
          ),
          GoRoute(
            path: '/add',
            pageBuilder: (context, state) =>
                _page(context, state, const AddWalletScreen()),
          ),
          GoRoute(
            path: '/add/liquid',
            pageBuilder: (context, state) =>
                _page(context, state, const LiquidStartScreen()),
          ),
          GoRoute(
            path: '/add/liquid/new',
            pageBuilder: (context, state) =>
                _page(context, state, const CreateLiquidScreen()),
          ),
          GoRoute(
            path: '/add/liquid/restore',
            pageBuilder: (context, state) =>
                _page(context, state, const RestoreLiquidScreen()),
          ),
          GoRoute(
            path: '/connect',
            pageBuilder: (context, state) => _page(
              context,
              state,
              ConnectNwcScreen(initialUri: _text(state.extra)),
            ),
          ),
          GoRoute(
            path: '/send',
            pageBuilder: (context, state) => _page(
              context,
              state,
              SendScreen(
                walletId: state.uri.queryParameters['wallet'],
                initialTo: _text(state.extra),
              ),
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
            path: '/settings/liquid',
            pageBuilder: (context, state) => _page(
              context,
              state,
              LiquidServersScreen(
                network:
                    ChainNetwork.values
                        .asNameMap()[state.uri.queryParameters['network']] ??
                    ChainNetwork.liquid,
              ),
            ),
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

String? _text(Object? extra) => extra is String ? extra : null;

/// Desktop swaps pages in place, as the sidebar does not slide.
Page<void> _page(BuildContext context, GoRouterState state, Widget child) {
  final instant =
      MediaQuery.disableAnimationsOf(context) ||
      LayoutSize.of(context) == LayoutSize.desktop;
  return instant
      ? NoTransitionPage(key: state.pageKey, child: child)
      : MaterialPage(key: state.pageKey, child: child);
}
