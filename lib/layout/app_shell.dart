import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../lock/gate_scope.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../widgets/amount.dart';
import '../widgets/brand.dart';
import '../widgets/screen_parts.dart';
import '../widgets/tappable.dart';
import '../widgets/wallet_kind_style.dart';
import 'layout.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!hasSidebar(context)) return child;
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 280,
            child: Semantics(
              role: SemanticsRole.navigation,
              container: true,
              explicitChildNodes: true,
              child: _Sidebar(location: location),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Semantics(
              role: SemanticsRole.main,
              container: true,
              explicitChildNodes: true,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wallets = LumenScope.walletsOf(context);
    final gate = GateScope.of(context);
    final lockKeys = shortcutKeys(context, 'L');
    return SafeArea(
      right: false,
      child: FillScroll(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Brand.logo(),
            ),
            const SizedBox(height: 24),
            _NavItem(
              leading: const Icon(Icons.home_outlined),
              label: l.overview,
              selected: location == '/',
              onTap: () => context.go('/'),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              child: Semantics(
                header: true,
                child: Text(
                  l.wallets,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ),
            Semantics(
              role: SemanticsRole.list,
              container: true,
              explicitChildNodes: true,
              child: Column(
                children: [
                  for (final wallet in wallets.wallets)
                    Semantics(
                      role: SemanticsRole.listItem,
                      container: true,
                      child: _NavItem(
                        leading: SourceBadge(
                          wallet.kind,
                          size: BadgeSize.small,
                        ),
                        label: wallet.name,
                        description: wallet.kind.subtitle(l),
                        trailing: BalanceValue(
                          wallets.balanceOf(wallet),
                          fontSize: 14,
                        ),
                        selected: location == '/wallet/${wallet.id}',
                        onTap: () => context.go('/wallet/${wallet.id}'),
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: () => context.go('/add'),
                icon: const Icon(Icons.add),
                label: Text(l.addWallet),
              ),
            ),
            const Spacer(),
            const SizedBox(height: 20),
            _NavItem(
              leading: const Icon(Icons.tune),
              label: l.settings,
              selected: location == '/settings',
              onTap: () => context.go('/settings'),
            ),
            ListenableBuilder(
              listenable: gate.lock,
              builder: (context, _) => gate.lock.enabled
                  ? _NavItem(
                      leading: const Icon(Icons.lock_outline),
                      label: l.lockNow,
                      description: l.keyboardShortcut(lockKeys),
                      trailing: ExcludeSemantics(
                        child: Text(
                          lockKeys,
                          style: TextStyle(
                            fontSize: 13,
                            color: LumenColors.of(context).text2,
                          ),
                        ),
                      ),
                      selected: false,
                      onTap: gate.lockNow,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.leading,
    required this.label,
    required this.selected,
    required this.onTap,
    this.description,
    this.trailing,
  });

  final Widget leading;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Read after [label] by screen readers, for what the icon shows.
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    final color = selected ? c.text : c.text2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MergeSemantics(
        child: Tappable(
          onTap: onTap,
          selected: selected,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: IconTheme.merge(
                data: IconThemeData(color: color),
                child: Row(
                  children: [
                    leading,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            label,
                            semanticsLabel: description == null
                                ? null
                                : '$label, $description',
                            style: TextStyle(
                              fontSize: 15,
                              color: color,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          ?trailing,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
