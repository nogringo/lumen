import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import '../widgets/screen_parts.dart';
import '../widgets/tappable.dart';
import '../widgets/wallet_kind_style.dart';

/// The one way in to every wallet type, each offering to create or restore.
class AddWalletScreen extends StatelessWidget {
  const AddWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    return NarrowPage(
      title: l.addAWallet,
      content: [
        Text(
          l.addWalletLead,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: c.text2, height: 1.5),
        ),
        const SizedBox(height: 20),
        _KindOption(
          kind: WalletKind.lightning,
          title: l.addLightningTitle,
          body: l.addLightningBody,
          onTap: () => context.push('/connect'),
        ),
        const SizedBox(height: 12),
        _KindOption(
          kind: WalletKind.liquid,
          title: l.kindLiquid,
          body: l.addLiquidBody,
          onTap: () => context.push('/add/liquid'),
        ),
      ],
    );
  }
}

class _KindOption extends StatelessWidget {
  const _KindOption({
    required this.kind,
    required this.title,
    required this.body,
    required this.onTap,
  });

  final WalletKind kind;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    final text = Theme.of(context).textTheme;
    return MergeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: c.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Tappable(
          onTap: onTap,
          borderRadius: 16,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SourceBadge(kind),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(body, style: text.bodySmall?.copyWith(height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: Icon(Icons.chevron_right, color: c.text3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
