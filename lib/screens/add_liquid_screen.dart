import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import '../wallets/lumen_scope.dart';
import '../widgets/flow_parts.dart';
import '../widgets/phrase_word_field.dart';
import '../widgets/screen_parts.dart';
import '../widgets/switch_row.dart';
import '../widgets/wallet_kind_style.dart';

class LiquidStartScreen extends StatelessWidget {
  const LiquidStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return NarrowPage(
      title: l.liquidStartTitle,
      content: [
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: SourceBadge(WalletKind.liquid, size: BadgeSize.large),
        ),
        const SizedBox(height: 16),
        _Lead(l.liquidStartLead),
        const SizedBox(height: 8),
        CheckLine(l.liquidPointFast),
        CheckLine(l.liquidPointConfidential),
        CheckLine(l.liquidPointKeys),
      ],
      bottom: [
        FilledButton(
          onPressed: () => context.push('/add/liquid/new'),
          child: Text(l.createLiquidWallet),
        ),
      ],
    );
  }
}

/// Explains the recovery phrase, then shows it and checks it was written
/// down. Nothing is saved before the check passes.
class CreateLiquidScreen extends StatefulWidget {
  const CreateLiquidScreen({super.key});

  @override
  State<CreateLiquidScreen> createState() => _CreateLiquidScreenState();
}

class _CreateLiquidScreenState extends State<CreateLiquidScreen> {
  /// Kept when coming back here, as it may be written down already.
  String? _phrase;
  var _busy = false;
  var _failed = false;

  Future<void> _show() async {
    if (_busy) return;
    final liquid = LumenScope.sourcesOf(context).liquid;
    setState(() {
      _busy = true;
      _failed = false;
    });
    String? phrase;
    try {
      phrase = _phrase ??= await liquid.newPhrase();
    } on LiquidChainException {
      // Shown below.
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _failed = phrase == null;
    });
    if (phrase == null) {
      _announce(context, AppLocalizations.of(context).liquidUnavailable);
      return;
    }
    await pushStep<void>(context, (_) => _PhraseScreen(phrase!));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return NarrowPage(
      title: l.newLiquidTitle,
      content: [
        Semantics(
          header: true,
          child: Text(
            l.phraseIntroHeading,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 12),
        _Lead(l.phraseIntroBody),
        const SizedBox(height: 8),
        CheckLine(l.phrasePointPaper),
        CheckLine(l.phrasePointOffline),
        CheckLine(l.phrasePointNeverAsked),
        if (_failed) ...[
          const SizedBox(height: 20),
          ErrorNote(l.liquidUnavailable),
        ],
      ],
      bottom: [
        FilledButton(
          onPressed: _busy ? null : _show,
          child: Text(l.showPhrase),
        ),
      ],
    );
  }
}

class _PhraseScreen extends StatelessWidget {
  const _PhraseScreen(this.phrase);

  final String phrase;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return NarrowPage(
      title: l.phraseTitle,
      backButton: true,
      content: [
        _Lead(l.phraseLead),
        const SizedBox(height: 20),
        _PhraseWords(phrase.split(' ')),
      ],
      bottom: [
        FilledButton(
          onPressed: () => pushStep<void>(context, (_) => _CheckScreen(phrase)),
          child: Text(l.phraseWrittenDown),
        ),
      ],
    );
  }
}

/// The words in order, down the first column then the second, and read in
/// that order.
class _PhraseWords extends StatelessWidget {
  const _PhraseWords(this.words);

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

class _CheckScreen extends StatefulWidget {
  const _CheckScreen(this.phrase);

  final String phrase;

  @override
  State<_CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<_CheckScreen> {
  static const _asked = 3;

  late final List<String> _words = widget.phrase.split(' ');

  /// Indexes of the words asked back, in order.
  late final List<int> _positions = (List.generate(
    _words.length,
    (i) => i,
  )..shuffle(Random.secure())).take(_asked).toList()..sort();
  late final _controllers = [
    for (var i = 0; i < _asked; i++) TextEditingController(),
  ];
  late final _focusNodes = [for (var i = 0; i < _asked; i++) FocusNode()];
  late final _errors = List<String?>.filled(_asked, null);
  late final _name = TextEditingController(
    text: AppLocalizations.of(context).kindLiquid,
  );
  final _nameFocus = FocusNode();
  var _nameMissing = false;
  var _testnet = false;
  var _saving = false;
  var _failed = false;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  String? _errorFor(int field, AppLocalizations l) {
    final typed = _controllers[field].text.trim().toLowerCase();
    final number = _positions[field] + 1;
    if (typed.isEmpty) return l.errorWordEmpty(number);
    if (typed != _words[_positions[field]]) return l.errorWordMismatch(number);
    return null;
  }

  Future<void> _create() async {
    if (_saving) return;
    final l = AppLocalizations.of(context);
    setState(() {
      for (var i = 0; i < _asked; i++) {
        _errors[i] = _errorFor(i, l);
      }
      _nameMissing = _name.text.trim().isEmpty;
      _failed = false;
    });
    final wrong = _errors.indexWhere((error) => error != null);
    if (wrong >= 0) {
      _focusNodes[wrong].requestFocus();
      _announce(context, _errors[wrong]!);
      return;
    }
    if (_nameMissing) {
      _nameFocus.requestFocus();
      _announce(context, l.errorNameEmpty);
      return;
    }

    setState(() => _saving = true);
    try {
      final wallet = await LumenScope.sourcesOf(context).liquid.add(
        phrase: widget.phrase,
        name: _name.text,
        network: _testnet ? ChainNetwork.liquidTestnet : ChainNetwork.liquid,
      );
      if (!mounted) return;
      LumenScope.readWallets(context).added(wallet);
      context.go('/');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failed = true;
      });
      _announce(context, l.errorSaveWallet);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final testnetAvailable =
        kDebugMode &&
        LumenScope.sourcesOf(context).liquid.networks
            .contains(ChainNetwork.liquidTestnet);
    return NarrowPage(
      title: l.checkPhraseTitle,
      backButton: true,
      content: [
        _Lead(l.checkPhraseLead),
        for (var i = 0; i < _asked; i++) ...[
          const SizedBox(height: 20),
          PhraseWordField(
            number: _positions[i] + 1,
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            errorText: _errors[i],
            onChanged: (_) {
              if (_errors[i] != null) setState(() => _errors[i] = null);
            },
            onDone: () => i + 1 < _asked
                ? _focusNodes[i + 1].requestFocus()
                : _nameFocus.requestFocus(),
          ),
        ],
        const SizedBox(height: 20),
        LabeledField(
          label: l.nameLabel,
          child: TextField(
            controller: _name,
            focusNode: _nameFocus,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _create(),
            onChanged: (_) {
              if (_nameMissing) setState(() => _nameMissing = false);
            },
            decoration: InputDecoration(
              errorText: _nameMissing ? l.errorNameEmpty : null,
            ),
          ),
        ),
        if (testnetAvailable) ...[
          const SizedBox(height: 12),
          SwitchRow(
            title: l.testnet,
            hint: l.testnetHint,
            value: _testnet,
            onChanged: () => setState(() => _testnet = !_testnet),
          ),
        ],
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.showWordsAgain),
          ),
        ),
        if (_failed) ...[
          const SizedBox(height: 12),
          ErrorNote(l.errorSaveWallet),
        ],
      ],
      bottom: [
        FilledButton(
          onPressed: _saving ? null : _create,
          child: Text(l.createWallet),
        ),
      ],
    );
  }
}

class _Lead extends StatelessWidget {
  const _Lead(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: LumenColors.of(context).text2, height: 1.5),
  );
}

void _announce(BuildContext context, String message) =>
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
      assertiveness: Assertiveness.assertive,
    );
