import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../wallets/wallets_controller.dart';
import '../widgets/amount.dart';
import '../widgets/brand.dart';
import '../widgets/screen_parts.dart';
import '../widgets/wallet_row.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wallets = LumenScope.walletsOf(context);
    final sidebar = hasSidebar(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: wallets.refreshAll,
          child: ListView(
            padding: LayoutSize.of(context).screenPadding,
            children: [
              if (sidebar)
                PageTitle(l.overview)
              else
                const SizedBox(height: 48, child: Brand.title()),
              const SizedBox(height: 24),
              _TotalBalance(wallets),
              if (!sidebar) ...[
                const SizedBox(height: 24),
                SectionHead(
                  title: l.wallets,
                  action: TextButton.icon(
                    onPressed: () => context.push('/connect'),
                    icon: const Icon(LucideIcons.plus),
                    label: Text(l.add, semanticsLabel: l.addWallet),
                  ),
                ),
                Semantics(
                  role: SemanticsRole.list,
                  container: true,
                  explicitChildNodes: true,
                  child: Column(
                    children: [
                      for (final (i, wallet) in wallets.wallets.indexed) ...[
                        if (i > 0) const Divider(),
                        Semantics(
                          role: SemanticsRole.listItem,
                          container: true,
                          child: WalletRow(
                            wallet: wallet,
                            onTap: () => context.push('/wallet/${wallet.id}'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalBalance extends StatelessWidget {
  const _TotalBalance(this.wallets);

  final WalletsController wallets;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final unavailable = wallets.unavailableCount;
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.totalBalance, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 10),
        if (wallets.hasKnownBalance || !wallets.isRefreshing)
          AmountText(wallets.totalSats)
        else
          const LoadingAmount(),
        if (unavailable > 0) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(LucideIcons.circleAlert, size: 16, color: c.text2),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l.walletsNotCounted(unavailable),
                  style: TextStyle(fontSize: 15, color: c.text2),
                ),
              ),
            ],
          ),
        ],
      ],
    );
    return MergeSemantics(
      child: Semantics(
        liveRegion: true,
        customSemanticsActions: {
          CustomSemanticsAction(label: l.refreshBalances): wallets.refreshAll,
        },
        child: column,
      ),
    );
  }
}
