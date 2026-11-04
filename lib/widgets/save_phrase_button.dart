import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import 'flow_parts.dart';

/// Saves a recovery phrase to a text file at a place the user picks, then
/// says under the button how it went.
class SavePhraseButton extends StatefulWidget {
  const SavePhraseButton({super.key, required this.name, required this.phrase});

  /// The wallet's name, for the file name.
  final String name;
  final String phrase;

  @override
  State<SavePhraseButton> createState() => _SavePhraseButtonState();
}

class _SavePhraseButtonState extends State<SavePhraseButton> {
  bool? _saved;
  var _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _saved = null;
    });
    bool? saved;
    try {
      final uri = await FilePicker.saveFile(
        dialogTitle: l.phraseTitle,
        fileName: phraseFileName(l.phraseFileName(widget.name)),
        // One line, so it pastes whole into a restore screen.
        bytes: utf8.encode('${widget.phrase}\n'),
        mimeType: 'text/plain',
      );
      // The web only starts a download, and never says where it went.
      if (uri != null || kIsWeb) saved = true;
    } catch (_) {
      saved = false;
    } finally {
      await _clearTemporaryCopy();
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = saved;
    });
    if (saved == null) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      _message(l, saved),
      Directionality.of(context),
      assertiveness: saved ? Assertiveness.polite : Assertiveness.assertive,
    );
  }

  String _message(AppLocalizations l, bool saved) => saved
      ? (kIsWeb ? l.phraseFileDownloaded : l.phraseFileSaved)
      : l.errorPhraseFile;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          style: quietButtonStyle(context),
          icon: const Icon(Icons.save_alt),
          label: Text(l.savePhraseFile),
        ),
        if (_saved case final saved?) ...[
          const SizedBox(height: 12),
          if (saved)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check, size: 18, color: c.positive),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _message(l, saved),
                    style: TextStyle(fontSize: 15, height: 1.4, color: c.text),
                  ),
                ),
              ],
            )
          else
            ErrorNote(l.errorPhraseFile),
        ],
      ],
    );
  }
}

/// [name] with what file systems refuse taken out, and a `.txt` extension.
@visibleForTesting
String phraseFileName(String name) {
  final safe = name
      .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1f]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceFirst(RegExp(r'^[\s.]+'), '')
      .trim();
  return '$safe.txt';
}

/// iOS exports a copy written to the app's temporary folder, and leaves it
/// there.
Future<void> _clearTemporaryCopy() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
  try {
    await FilePicker.clearTemporaryFiles();
  } catch (_) {
    // The copy stays in the app's own sandbox, where the phrase already is.
  }
}
