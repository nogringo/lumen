import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../screens/receive_screen.dart';
import '../screens/send_screen.dart';
import '../theme/lumen_colors.dart';
import 'tappable.dart';

/// The actions under a balance. On a wallet screen they preselect [wallet].
class WalletActions extends StatelessWidget {
  const WalletActions({super.key, this.wallet});

  final Wallet? wallet;

  /// Scan will join Send and Receive.
  static const _slots = 3;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final actions = [
      _Action(
        icon: Icons.north,
        label: l.send,
        primary: true,
        onTap: () => openSend(context, wallet: wallet),
      ),
      _Action(
        icon: Icons.south,
        label: l.receive,
        onTap: () => openReceive(context, wallet: wallet),
      ),
    ];

    if (LayoutSize.of(context) == LayoutSize.desktop) {
      return Wrap(spacing: 12, runSpacing: 12, children: actions);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _slots; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: i < actions.length ? actions[i] : const SizedBox()),
          ],
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    final desktop = LayoutSize.of(context) == LayoutSize.desktop;
    final foreground = primary ? c.onAccent : c.text;
    final iconWidget = Icon(icon, color: foreground);
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: desktop ? 15 : 13,
        fontWeight: FontWeight.w500,
        color: foreground,
      ),
    );

    return Material(
      color: primary ? c.accent : c.surface2,
      borderRadius: BorderRadius.circular(desktop ? 14 : 20),
      child: Tappable(
        onTap: onTap,
        borderRadius: desktop ? 14 : 20,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: desktop ? 48 : 76),
          child: Padding(
            padding: desktop
                ? const EdgeInsets.symmetric(horizontal: 22, vertical: 12)
                : const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            child: desktop
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      iconWidget,
                      const SizedBox(width: 10),
                      Flexible(child: text),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [iconWidget, const SizedBox(height: 8), text],
                  ),
          ),
        ),
      ),
    );
  }
}
