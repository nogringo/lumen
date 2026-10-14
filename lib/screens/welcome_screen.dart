import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../widgets/amount.dart';
import '../widgets/brand.dart';
import '../widgets/screen_parts.dart';
import '../widgets/wallet_kind_style.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _kinds = [WalletKind.lightning];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final text = Theme.of(context).textTheme;
    final phone = LayoutSize.of(context) == LayoutSize.phone;
    final addButton = FilledButton(
      onPressed: () => context.push('/connect'),
      child: Text(l.addAWallet),
    );

    return Scaffold(
      body: SafeArea(
        child: FillScroll(
          padding: LayoutSize.of(context).screenPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const Spacer(),
                  const LogoMark(),
                  const SizedBox(height: 24),
                  ScreenTitle(
                    child: Text(
                      'Lumen',
                      style: text.displayLarge,
                      textScaler: dampedTextScaler(context, 0.35),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.tagline,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: text.bodySmall?.color,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    label: l.supportedWallets,
                    container: true,
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 24,
                      runSpacing: 16,
                      children: [for (final kind in _kinds) _KindItem(kind)],
                    ),
                  ),
                  if (phone) ...[
                    const Spacer(),
                    addButton,
                  ] else ...[
                    const SizedBox(height: 40),
                    addButton,
                    const Spacer(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KindItem extends StatelessWidget {
  const _KindItem(this.kind);

  final WalletKind kind;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SourceBadge(kind),
        const SizedBox(height: 8),
        Text(
          kind.label(AppLocalizations.of(context)),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
