import 'package:clock/clock.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../lock/app_lock.dart';

/// A hidden passphrase field with a button that shows it. The label sits
/// above, as in [LabeledField], but outside a merge so the button stays
/// reachable on its own.
class PassphraseField extends StatefulWidget {
  const PassphraseField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.errorText,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? errorText;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<PassphraseField> createState() => _PassphraseFieldState();
}

class _PassphraseFieldState extends State<PassphraseField> {
  var _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: widget.label,
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: _hidden,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            autofillHints: widget.autofillHints,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              errorText: widget.errorText,
              suffixIcon: IconButton(
                tooltip: _hidden ? l.showPassphrase : l.hidePassphrase,
                icon: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// What to say under the field after a passphrase was refused, or null when
/// it was accepted.
String? refusalMessage(
  AppLocalizations l,
  PassphraseCheck check,
  DateTime? retryAt,
) {
  switch (check) {
    case PassphraseCheck.correct:
      return null;
    case PassphraseCheck.wrong when retryAt == null:
      return l.errorPassphraseWrong;
    case PassphraseCheck.wrong || PassphraseCheck.wait:
      final left = (retryAt ?? clock.now()).difference(clock.now());
      final seconds = (left.inMilliseconds / 1000).ceil().clamp(1, 1 << 30);
      return seconds < 60
          ? l.errorWaitSeconds(seconds)
          : l.errorWaitMinutes((seconds / 60).ceil());
  }
}

/// Moves focus to the field with the error and reads the error out.
void reportFieldError(BuildContext context, String message, FocusNode field) {
  field.requestFocus();
  SemanticsService.sendAnnouncement(
    View.of(context),
    message,
    Directionality.of(context),
    assertiveness: Assertiveness.assertive,
  );
}
