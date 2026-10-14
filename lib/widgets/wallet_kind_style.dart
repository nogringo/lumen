import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';

extension WalletKindStyle on WalletKind {
  IconData get icon => switch (this) {
    WalletKind.lightning => Icons.bolt,
    WalletKind.ecash => Icons.toll_outlined,
    WalletKind.onchain => Icons.inventory_2_outlined,
    WalletKind.liquid => Icons.water_drop_outlined,
  };

  Color color(LumenColors c) => switch (this) {
    WalletKind.lightning => c.nwc,
    WalletKind.ecash => c.cashu,
    WalletKind.onchain => c.chain,
    WalletKind.liquid => c.liquid,
  };

  String label(AppLocalizations l) => switch (this) {
    WalletKind.lightning => l.kindLightning,
    WalletKind.ecash => l.kindEcash,
    WalletKind.onchain => l.kindOnchain,
    WalletKind.liquid => l.kindLiquid,
  };

  /// How the wallet connects, under its name in lists.
  String subtitle(AppLocalizations l) => switch (this) {
    WalletKind.lightning => l.lightningViaNwc,
    _ => label(l),
  };
}

enum BadgeSize { small, medium, large }

class SourceBadge extends StatelessWidget {
  const SourceBadge(
    this.kind, {
    super.key,
    this.size = BadgeSize.medium,
    this.semanticLabel,
  });

  final WalletKind kind;
  final BadgeSize size;

  /// Read by screen readers where nothing else on screen names the kind.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final color = kind.color(LumenColors.of(context));
    final (box, radius, icon) = switch (size) {
      BadgeSize.small => (28.0, 9.0, 16.0),
      BadgeSize.medium => (40.0, 13.0, 20.0),
      BadgeSize.large => (56.0, 18.0, 28.0),
    };
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Container(
        width: box,
        height: box,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(kind.icon, size: icon, color: color),
      ),
    );
  }
}
