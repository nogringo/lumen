import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import 'screen_parts.dart';

/// One word of a recovery phrase, with the list words that start with what
/// is typed offered below it while it has focus.
class PhraseWordField extends StatefulWidget {
  const PhraseWordField({
    super.key,
    required this.number,
    required this.controller,
    required this.focusNode,
    this.errorText,
    this.onChanged,
    this.onDone,
    this.last = false,
  });

  /// From 1 to 12.
  final int number;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  /// Called when a suggestion is picked or the keyboard's action pressed.
  final VoidCallback? onDone;

  /// Whether the keyboard's action ends the form instead of moving on.
  final bool last;

  static const total = 12;

  @override
  State<PhraseWordField> createState() => _PhraseWordFieldState();
}

class _PhraseWordFieldState extends State<PhraseWordField> {
  List<String> _suggestions = const [];

  /// Whether focus is on the field or one of its suggestions.
  var _focused = false;

  List<String> _current() {
    if (!_focused) return const [];
    final typed = widget.controller.text.trim().toLowerCase();
    final words = phraseWordsStartingWith(typed);
    if (words.length == 1 && words.single == typed) return const [];
    return words;
  }

  void _update() {
    final next = _current();
    if (listEquals(next, _suggestions)) return;
    setState(() => _suggestions = next);
    if (next.isNotEmpty) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        AppLocalizations.of(context).wordSuggestions(next.length),
        Directionality.of(context),
      );
    }
  }

  void _pick(String word) {
    widget.controller.text = word;
    widget.controller.selection = TextSelection.collapsed(offset: word.length);
    widget.onChanged?.call(word);
    setState(() => _suggestions = const []);
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) {
        _focused = focused;
        _update();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledField(
            label: l.wordLabel(widget.number, PhraseWordField.total),
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              // Keeps keyboards from learning or suggesting the words.
              keyboardType: TextInputType.visiblePassword,
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              textInputAction: widget.last
                  ? TextInputAction.done
                  : TextInputAction.next,
              style: const TextStyle(fontFamily: monoFamily, fontSize: 16),
              onChanged: (text) {
                widget.onChanged?.call(text);
                _update();
              },
              onSubmitted: (_) => widget.onDone?.call(),
              decoration: InputDecoration(errorText: widget.errorText),
            ),
          ),
          if (_suggestions.isNotEmpty)
            // Part of the field, so a click on desktop does not unfocus it
            // and take the suggestions away before the click lands.
            TextFieldTapRegion(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final word in _suggestions)
                      OutlinedButton(
                        onPressed: () => _pick(word),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          foregroundColor: c.text,
                          side: BorderSide(color: c.fieldBorder),
                        ),
                        child: Text(
                          word,
                          style: const TextStyle(fontFamily: monoFamily),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
