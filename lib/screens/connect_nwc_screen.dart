import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import '../wallets/lumen_scope.dart';
import '../widgets/screen_parts.dart';

class ConnectNwcScreen extends StatefulWidget {
  const ConnectNwcScreen({super.key});

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

  @override
  void dispose() {
    _uri.dispose();
    _name.dispose();
    _uriFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _uriError = checkNwcUri(_uri.text);
      _nameMissing = _name.text.trim().isEmpty;
    });
    if (_uriError != null) {
      _reportError(_uriError!.message(l), _uriFocus);
      return;
    }
    if (_nameMissing) {
      _reportError(l.errorNameEmpty, _nameFocus);
      return;
    }

    if (_saving) return;
    _saving = true;
    try {
      final wallet = await LumenScope.sourcesOf(context).nwc
          .add(uri: _uri.text, name: _name.text);
      if (!mounted) return;
      LumenScope.readWallets(context).added(wallet);
      context.go('/');
    } on NwcConnectException catch (e) {
      if (!mounted) return;
      setState(() => _uriError = e.error);
      _reportError(e.error.message(l), _uriFocus);
    } finally {
      _saving = false;
    }
  }

  void _reportError(String message, FocusNode field) {
    field.requestFocus();
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
                      onChanged: (_) {
                        if (_uriError != null) setState(() => _uriError = null);
                      },
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
