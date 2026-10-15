import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../scan/qr_scanner.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import '../wallets/lumen_scope.dart';
import '../widgets/nwc_grant_card.dart';
import '../widgets/screen_parts.dart';

class ConnectNwcScreen extends StatefulWidget {
  const ConnectNwcScreen({super.key, this.initialUri});

  /// A connection string read from a QR code.
  final String? initialUri;

  @override
  State<ConnectNwcScreen> createState() => _ConnectNwcScreenState();
}

class _ConnectNwcScreenState extends State<ConnectNwcScreen> {
  final _uri = TextEditingController();
  final _name = TextEditingController();
  final _uriFocus = FocusNode();
  final _nameFocus = FocusNode();

  NwcConnectError? _uriError;
  var _nameMissing = false;
  var _saving = false;

  /// The valid connection string whose permissions the card shows.
  String? _inspected;
  NwcGrant? _grant;
  var _checking = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialUri case final uri?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fill(uri);
      });
    }
  }

  @override
  void dispose() {
    _uri.dispose();
    _name.dispose();
    _uriFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    _saving = true;
    try {
      await _save();
    } finally {
      _saving = false;
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final nwc = LumenScope.sourcesOf(context).nwc;
    var uriError = checkNwcUri(_uri.text);
    if (uriError == null && await nwc.isSaved(_uri.text)) {
      uriError = NwcConnectError.duplicate;
    }
    if (!mounted) return;
    setState(() {
      _uriError = uriError;
      _nameMissing = uriError == null && _name.text.trim().isEmpty;
    });
    if (uriError != null) {
      _reportError(uriError.message(l), _uriFocus);
      return;
    }
    if (_nameMissing) {
      _reportError(l.errorNameEmpty, _nameFocus);
      return;
    }

    try {
      final wallet = await nwc.add(uri: _uri.text, name: _name.text);
      if (!mounted) return;
      LumenScope.readWallets(context).added(wallet);
      context.go('/');
    } on NwcConnectException catch (e) {
      if (!mounted) return;
      setState(() => _uriError = e.error);
      _reportError(e.error.message(l), _uriFocus);
    }
  }

  void _uriChanged(String text) {
    if (_uriError != null) setState(() => _uriError = null);
    final value = text.trim();
    if (value == _inspected) return;
    if (checkNwcUri(value) != null) {
      if (_inspected != null) setState(() => _inspected = null);
      return;
    }
    _inspect(value);
  }

  Future<void> _scan() async {
    final text = await scanQrCode(context);
    if (!mounted || text == null) return;
    _fill(text);
  }

  void _fill(String uri) {
    _uri.text = uri;
    _uriChanged(uri);
    final error = checkNwcUri(uri);
    if (error != null) {
      setState(() => _uriError = error);
      _reportError(error.message(AppLocalizations.of(context)), _uriFocus);
    } else {
      _nameFocus.requestFocus();
    }
  }

  /// Flags a connection that is already saved, or else shows what it allows.
  Future<void> _inspect(String value) async {
    final nwc = LumenScope.sourcesOf(context).nwc;
    final saved = await nwc.isSaved(value);
    if (!mounted || _uri.text.trim() != value) return;
    if (saved) {
      setState(() {
        _inspected = null;
        _uriError = NwcConnectError.duplicate;
      });
      _announce(
        NwcConnectError.duplicate.message(AppLocalizations.of(context)),
      );
      return;
    }

    setState(() {
      _inspected = value;
      _grant = null;
      _checking = true;
    });
    final grant = await nwc.inspect(value);
    if (!mounted || _inspected != value) return;
    setState(() {
      _grant = grant;
      _checking = false;
    });
  }

  void _reportError(String message, FocusNode field) {
    field.requestFocus();
    _announce(message);
  }

  void _announce(String message) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
      assertiveness: Assertiveness.assertive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final text = Theme.of(context).textTheme;
    final sidebar = hasSidebar(context);

    return Scaffold(
      body: SafeArea(
        child: FillScroll(
          padding: LayoutSize.of(context).screenPadding,
          child: Align(
            alignment: sidebar
                ? AlignmentDirectional.topStart
                : Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sidebar)
                    PageTitle(l.connectNwcTitle)
                  else
                    TopBar(title: l.connectNwcTitle),
                  const SizedBox(height: 20),
                  Text(
                    l.connectNwcLead,
                    style: text.bodyMedium?.copyWith(
                      color: c.text2,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: l.connectionStringLabel,
                    child: TextField(
                      controller: _uri,
                      focusNode: _uriFocus,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.url,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enableSuggestions: false,
                      onSubmitted: (_) => _nameFocus.requestFocus(),
                      onChanged: _uriChanged,
                      style: TextStyle(
                        fontFamily: monoFamily,
                        fontSize: 13,
                        height: 1.5,
                        color: c.text,
                      ),
                      decoration: InputDecoration(
                        helperText: l.connectionStringHint,
                        errorText: _uriError?.message(l),
                      ),
                    ),
                  ),
                  if (canScanQrCodes)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: _scan,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(l.scan, semanticsLabel: l.scanQrCode),
                      ),
                    ),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: l.nameLabel,
                    child: TextField(
                      controller: _name,
                      focusNode: _nameFocus,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      onChanged: (_) {
                        if (_nameMissing) setState(() => _nameMissing = false);
                      },
                      decoration: InputDecoration(
                        errorText: _nameMissing ? l.errorNameEmpty : null,
                      ),
                    ),
                  ),
                  if (_inspected != null) ...[
                    const SizedBox(height: 20),
                    NwcGrantCard(checking: _checking, grant: _grant),
                  ],
                  const SizedBox(height: 32),
                  if (LayoutSize.of(context) == LayoutSize.phone)
                    const Spacer(),
                  FilledButton(onPressed: _submit, child: Text(l.connect)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension on NwcConnectError {
  String message(AppLocalizations l) => switch (this) {
    NwcConnectError.empty => l.errorUriEmpty,
    NwcConnectError.notNwc => l.errorUriNotNwc,
    NwcConnectError.incomplete => l.errorUriIncomplete,
    NwcConnectError.duplicate => l.errorUriDuplicate,
  };
}
