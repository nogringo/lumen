import 'package:flutter/semantics.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../lock/app_lock.dart';
import '../lock/gate_scope.dart';
import '../settings/language.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../widgets/flow_parts.dart';
import '../widgets/passphrase_field.dart';
import '../widgets/screen_parts.dart';
import '../widgets/switch_row.dart';
import '../widgets/tappable.dart';
import 'liquid_servers_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final gate = GateScope.of(context);
    final sidebar = hasSidebar(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: LayoutSize.of(context).screenPadding,
          children: [
            if (sidebar) PageTitle(l.settings) else TopBar(title: l.settings),
            const SizedBox(height: 24),
            Align(
              alignment: sidebar
                  ? AlignmentDirectional.topStart
                  : Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Group(
                      title: l.general,
                      children: [
                        _LinkRow(
                          icon: Icons.language,
                          title: l.language,
                          value: _languageName(context),
                          onTap: () => _pickLanguage(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ListenableBuilder(
                      listenable: gate.lock,
                      builder: (context, _) {
                        final on = gate.lock.enabled;
                        return _Group(
                          title: l.security,
                          children: [
                            SwitchRow(
                              title: l.appLock,
                              hint: l.appLockHint,
                              value: on,
                              onChanged: () =>
                                  on ? _turnOff(context) : openTurnOn(context),
                            ),
                            if (on) ...[
                              _LinkRow(
                                icon: Icons.password,
                                title: l.changePassphrase,
                                onTap: () => openChangePassphrase(context),
                              ),
                              _LinkRow(
                                icon: Icons.lock_outline,
                                title: l.lockNow,
                                onTap: gate.lockNow,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _Group(
                      title: l.kindLiquid,
                      children: [
                        for (final network in ChainNetwork.values)
                          if (LumenScope.sourcesOf(context).liquid.networks
                              .contains(network))
                            _ServersRow(network),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _turnOff(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => const _TurnOffDialog(),
  );

  InlineSpan _languageName(BuildContext context) {
    final locale = LanguageScope.of(context).locale;
    return locale == null
        ? TextSpan(text: AppLocalizations.of(context).deviceLanguage)
        : languageSpan(locale);
  }

  Future<void> _pickLanguage(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => const _LanguageDialog(),
  );
}

/// A language name tagged with its locale, so screen readers pronounce it in
/// that language.
TextSpan languageSpan(Locale locale) =>
    TextSpan(text: languageNames[locale], locale: locale);

Future<void> openTurnOn(BuildContext context) => openFlow(
  context,
  location: '/settings/lock',
  title: AppLocalizations.of(context).turnOnAppLock,
  builder: (frame) => PassphraseFlow(frame: frame),
);

Future<void> openChangePassphrase(BuildContext context) => openFlow(
  context,
  location: '/settings/passphrase',
  title: AppLocalizations.of(context).changePassphrase,
  builder: (frame) => PassphraseFlow(frame: frame, change: true),
);

class TurnOnScreen extends StatelessWidget {
  const TurnOnScreen({super.key});

  @override
  Widget build(BuildContext context) => FlowScreen(
    title: AppLocalizations.of(context).turnOnAppLock,
    builder: (frame) => PassphraseFlow(frame: frame),
  );
}

class ChangePassphraseScreen extends StatelessWidget {
  const ChangePassphraseScreen({super.key});

  @override
  Widget build(BuildContext context) => FlowScreen(
    title: AppLocalizations.of(context).changePassphrase,
    builder: (frame) => PassphraseFlow(frame: frame, change: true),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: c.text2,
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (final (i, child) in children.indexed) ...[
                if (i > 0) const Divider(indent: 16, endIndent: 16),
                child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// The current choice, under the title.
  final InlineSpan? value;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return MergeSemantics(
      child: Tappable(
        onTap: onTap,
        borderRadius: 20,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: c.text2),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: c.text,
                        ),
                      ),
                      if (value case final value?) ...[
                        const SizedBox(height: 3),
                        Text.rich(
                          value,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: c.text2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the servers of [network], and says whether they are the defaults.
class _ServersRow extends StatefulWidget {
  const _ServersRow(this.network);

  final ChainNetwork network;

  @override
  State<_ServersRow> createState() => _ServersRowState();
}

class _ServersRowState extends State<_ServersRow> {
  bool? _custom;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final liquid = LumenScope.sourcesOf(context).liquid;
    final servers = await liquid.servers(widget.network);
    if (!mounted) return;
    setState(
      () => _custom = servers != liquid.defaultServersFor(widget.network),
    );
  }

  Future<void> _open() async {
    await openLiquidServers(context, widget.network);
    if (mounted) await _check();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _LinkRow(
      icon: Icons.dns_outlined,
      title: switch (widget.network) {
        ChainNetwork.liquid => l.servers,
        ChainNetwork.liquidTestnet => l.testnetServers,
      },
      value: switch (_custom) {
        null => null,
        true => TextSpan(text: l.serversCustom),
        false => TextSpan(text: l.serversDefault),
      },
      onTap: _open,
    );
  }
}

class _LanguageDialog extends StatelessWidget {
  const _LanguageDialog();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final setting = LanguageScope.of(context);

    void choose(Locale? locale) {
      setting.choose(locale);
      Navigator.pop(context);
    }

    return AlertDialog(
      title: Text(l.language),
      scrollable: true,
      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LanguageOption(
            name: TextSpan(text: l.deviceLanguage),
            picked: setting.locale == null,
            onTap: () => choose(null),
          ),
          for (final locale in languageNames.keys)
            _LanguageOption(
              name: languageSpan(locale),
              picked: setting.locale == locale,
              onTap: () => choose(locale),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.name,
    required this.picked,
    required this.onTap,
  });

  final InlineSpan name;
  final bool picked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return MergeSemantics(
      child: Tappable(
        onTap: onTap,
        checked: picked,
        selected: picked,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    name,
                    style: TextStyle(fontSize: 16, color: c.text),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox.square(
                  dimension: 20,
                  child: picked
                      ? Icon(Icons.check, size: 20, color: c.text)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Sets the passphrase that turns App lock on, or replaces it with [change].
class PassphraseFlow extends StatefulWidget {
  const PassphraseFlow({super.key, required this.frame, this.change = false});

  final FlowFrame frame;
  final bool change;

  @override
  State<PassphraseFlow> createState() => _PassphraseFlowState();
}

class _PassphraseFlowState extends State<PassphraseFlow> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  final _currentFocus = FocusNode();
  final _nextFocus = FocusNode();
  final _confirmFocus = FocusNode();

  String? _currentError;
  String? _nextError;
  String? _confirmError;
  String? _saveError;
  var _saving = false;

  @override
  void dispose() {
    for (final controller in [_current, _next, _confirm]) {
      controller.dispose();
    }
    for (final node in [_currentFocus, _nextFocus, _confirmFocus]) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _currentError = widget.change && _current.text.isEmpty
          ? l.errorPassphraseEmpty
          : null;
      _nextError = AppLock.isLongEnough(_next.text)
          ? null
          : l.errorPassphraseShort;
      _confirmError = _nextError == null && _confirm.text != _next.text
          ? l.errorPassphraseMismatch
          : null;
      _saveError = null;
    });
    for (final (error, field) in [
      (_currentError, _currentFocus),
      (_nextError, _nextFocus),
      (_confirmError, _confirmFocus),
    ]) {
      if (error != null) return reportFieldError(context, error, field);
    }

    if (_saving) return;
    setState(() => _saving = true);
    final gate = GateScope.of(context);
    try {
      if (widget.change) {
        final check = await gate.lock.changePassphrase(
          _current.text,
          _next.text,
        );
        if (!mounted) return;
        final message = refusalMessage(l, check, gate.lock.retryAt);
        if (message != null) {
          setState(() => _currentError = message);
          return reportFieldError(context, message, _currentFocus);
        }
      } else {
        await gate.enableLock(_next.text);
        if (!mounted) return;
      }
      widget.frame.onDone();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saveError = l.errorLockSave);
      SemanticsService.sendAnnouncement(
        View.of(context),
        l.errorLockSave,
        Directionality.of(context),
        assertiveness: Assertiveness.assertive,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final lead = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: c.text2, height: 1.5);

    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.frame.header,
          const SizedBox(height: 20),
          Text(l.passphraseLead, style: lead),
          const SizedBox(height: 12),
          Text(l.passphraseWarning, style: lead),
          if (widget.change) ...[
            const SizedBox(height: 20),
            PassphraseField(
              label: l.currentPassphraseLabel,
              controller: _current,
              focusNode: _currentFocus,
              errorText: _currentError,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _nextFocus.requestFocus(),
              onChanged: (_) {
                if (_currentError != null) {
                  setState(() => _currentError = null);
                }
              },
            ),
          ],
          const SizedBox(height: 20),
          PassphraseField(
            label: widget.change ? l.newPassphraseLabel : l.passphraseLabel,
            controller: _next,
            focusNode: _nextFocus,
            errorText: _nextError,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _confirmFocus.requestFocus(),
            onChanged: (_) {
              if (_nextError != null) setState(() => _nextError = null);
            },
          ),
          const SizedBox(height: 20),
          PassphraseField(
            label: l.confirmPassphraseLabel,
            controller: _confirm,
            focusNode: _confirmFocus,
            errorText: _confirmError,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_confirmError != null) setState(() => _confirmError = null);
            },
          ),
          if (_saveError case final error?) ...[
            const SizedBox(height: 20),
            ErrorNote(error),
          ],
          widget.frame.bottomGap,
          FilledButton(
            onPressed: _submit,
            child: _saving
                ? SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.onAccent,
                    ),
                  )
                : Text(widget.change ? l.save : l.turnOn),
          ),
        ],
      ),
    );
  }
}

class _TurnOffDialog extends StatefulWidget {
  const _TurnOffDialog();

  @override
  State<_TurnOffDialog> createState() => _TurnOffDialogState();
}

class _TurnOffDialogState extends State<_TurnOffDialog> {
  final _passphrase = TextEditingController();
  final _focus = FocusNode();
  String? _error;
  var _checking = false;

  @override
  void dispose() {
    _passphrase.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _turnOff() async {
    final l = AppLocalizations.of(context);
    if (_passphrase.text.isEmpty) {
      setState(() => _error = l.errorPassphraseEmpty);
      return reportFieldError(context, l.errorPassphraseEmpty, _focus);
    }
    if (_checking) return;
    _checking = true;
    final gate = GateScope.of(context);
    final check = await gate.disableLock(_passphrase.text);
    _checking = false;
    if (!mounted) return;
    final message = refusalMessage(l, check, gate.lock.retryAt);
    if (message == null) return Navigator.pop(context);
    setState(() => _error = message);
    reportFieldError(context, message, _focus);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    return AlertDialog(
      title: Text(l.turnOffTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.turnOffBody),
          const SizedBox(height: 20),
          PassphraseField(
            label: l.passphraseLabel,
            controller: _passphrase,
            focusNode: _focus,
            errorText: _error,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _turnOff(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: _turnOff,
          style: TextButton.styleFrom(foregroundColor: c.danger),
          child: Text(l.turnOff),
        ),
      ],
    );
  }
}
