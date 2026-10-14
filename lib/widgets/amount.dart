import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import '../wallets/wallets_controller.dart';

String formatSats(BuildContext context, int sats) =>
    NumberFormat.decimalPattern(AppLocalizations.of(context).localeName)
        .format(sats);

/// Large amounts grow slower than body text with the system text scale, like
/// Android's nonlinear font scaling.
TextScaler dampedTextScaler(BuildContext context, double factor) {
  final scale = MediaQuery.textScalerOf(context).scale(16) / 16;
  return TextScaler.linear(1 + (scale - 1) * factor);
}

const _tabular = [FontFeature.tabularFigures()];

class AmountText extends StatelessWidget {
  const AmountText(this.sats, {super.key, this.fontSize = 56});

  final int sats;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final amount = formatSats(context, sats);
    return Semantics(
      label: l.amountSats(amount),
      excludeSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerStart,
        child: Text.rich(
          TextSpan(
            text: amount,
            children: [
              TextSpan(
                text: ' ${l.satsUnit}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                  color: c.text2,
                ),
              ),
            ],
          ),
          textScaler: dampedTextScaler(context, 0.35),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -fontSize * 0.03,
            height: 1.05,
            color: c.text,
            fontFeatures: _tabular,
          ),
        ),
      ),
    );
  }
}

/// A wallet balance in a list: the amount, a spinner, or "Unavailable".
class BalanceValue extends StatelessWidget {
  const BalanceValue(this.state, {super.key, this.fontSize = 15});

  final BalanceState state;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final sats = state.sats;
    if (sats != null) {
      final amount = formatSats(context, sats);
      return Semantics(
        label: l.amountSats(amount),
        excludeSemantics: true,
        child: Text(
          amount,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            fontFeatures: _tabular,
          ),
        ),
      );
    }
    if (state.failed) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.circleAlert, size: 16, color: c.text2),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l.balanceUnavailable,
              style: TextStyle(fontSize: fontSize, color: c.text2),
            ),
          ),
        ],
      );
    }
    return Semantics(
      label: l.balanceLoading,
      child: const SizedBox.square(
        dimension: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// Stands in for an [AmountText] while the first balance loads.
class LoadingAmount extends StatelessWidget {
  const LoadingAmount({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).balanceLoading,
      child: const SizedBox(
        height: 59,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}
