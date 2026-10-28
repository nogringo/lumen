import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';

/// The words of a recovery phrase in order, down the first column then the
/// second, and read in that order.
class PhraseWords extends StatelessWidget {
  const PhraseWords(this.words, {super.key});

  final List<String> words;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final scaler = MediaQuery.textScalerOf(context);

    Widget word(int i) => Semantics(
      label: l.phraseWord(i + 1, words.length, words[i]),
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: scaler.scale(22)),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontFamily: monoFamily,
                  fontSize: 13,
                  color: c.text2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                words[i],
                style: TextStyle(
                  fontFamily: monoFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: c.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Each column is its own node, so screen readers finish one before the
    // next instead of reading across.
    Widget column(int from, int to) => Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = from; i < to; i++) ...[
            if (i > from) const SizedBox(height: 8),
            word(i),
          ],
        ],
      ),
    );

    if (scaler.scale(17) > 26) return column(0, words.length);
    final half = (words.length + 1) ~/ 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: column(0, half)),
        const SizedBox(width: 12),
        Expanded(child: column(half, words.length)),
      ],
    );
  }
}
