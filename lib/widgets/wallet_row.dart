import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../wallets/lumen_scope.dart';
import 'amount.dart';
import 'tappable.dart';
import 'wallet_kind_style.dart';

class WalletRow extends StatelessWidget {
  const WalletRow({super.key, required this.wallet, required this.onTap});

  final Wallet wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final balance = BalanceValue(
      LumenScope.walletsOf(context).balanceOf(wallet),
    );
    final stacked = MediaQuery.textScalerOf(context).scale(15) > 24;
    final meta = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          wallet.name,
          style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 3),
        Text(wallet.kind.subtitle(l), style: theme.bodySmall),
      ],
    );

    return MergeSemantics(
      child: Tappable(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SourceBadge(wallet.kind),
                const SizedBox(width: 14),
                if (stacked)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        meta,
                        const SizedBox(height: 6),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: balance,
                        ),
                      ],
                    ),
                  )
                else ...[
                  Expanded(child: meta),
                  const SizedBox(width: 12),
                  balance,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
