import 'package:flutter/semantics.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import '../wallets/lumen_scope.dart';
import '../widgets/flow_parts.dart';
import '../widgets/passphrase_field.dart';
import '../widgets/screen_parts.dart';

Future<void> openLiquidServers(BuildContext context, ChainNetwork network) =>
    openFlow(
      context,
      location: '/settings/liquid?network=${network.name}',
      title: liquidServersTitle(AppLocalizations.of(context), network),
      builder: (frame) => LiquidServersFlow(frame: frame, network: network),
    );

String liquidServersTitle(AppLocalizations l, ChainNetwork network) =>
    switch (network) {
      ChainNetwork.liquid => l.liquidServersTitle,
      ChainNetwork.liquidTestnet => l.liquidTestnetServersTitle,
    };

class LiquidServersScreen extends StatelessWidget {
  const LiquidServersScreen({super.key, required this.network});

  final ChainNetwork network;

  @override
  Widget build(BuildContext context) => FlowScreen(
    title: liquidServersTitle(AppLocalizations.of(context), network),
    builder: (frame) => LiquidServersFlow(frame: frame, network: network),
  );
}

/// The Waterfalls and Esplora URLs every Liquid wallet on [network] uses.
class LiquidServersFlow extends StatefulWidget {
  const LiquidServersFlow({
    super.key,
    required this.frame,
    required this.network,
  });

  final FlowFrame frame;
  final ChainNetwork network;

  @override
  State<LiquidServersFlow> createState() => _LiquidServersFlowState();
}

class _LiquidServersFlowState extends State<LiquidServersFlow> {
  final _waterfalls = TextEditingController();
  final _esplora = TextEditingController();
  final _waterfallsFocus = FocusNode();
  final _esploraFocus = FocusNode();
  String? _waterfallsError;
  String? _esploraError;
  var _loaded = false;
  var _saving = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _waterfalls.dispose();
    _esplora.dispose();
    _waterfallsFocus.dispose();
    _esploraFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final servers = await LumenScope.sourcesOf(context).liquid
        .servers(widget.network);
    if (!mounted) return;
    setState(() {
      _fill(servers);
      _loaded = true;
    });
  }

  void _fill(LiquidServers servers) {
    _waterfalls.text = servers.waterfalls ?? '';
    _esplora.text = servers.esplora;
    _waterfallsError = null;
    _esploraError = null;
  }

  void _useDefaults() {
    final liquid = LumenScope.sourcesOf(context).liquid;
    setState(() => _fill(liquid.defaultServersFor(widget.network)));
    SemanticsService.sendAnnouncement(
      View.of(context),
      AppLocalizations.of(context).defaultServersFilled,
      Directionality.of(context),
    );
  }

  /// [text] as a server's base URL, without the trailing slash LWK would
  /// double, or null when it is not a web address that paths can follow.
  static String? _url(String text) {
    final url = text.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !(uri.isScheme('https') || uri.isScheme('http')) ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return null;
    }
    return url;
  }

  Future<void> _save() async {
    if (_saving) return;
    final l = AppLocalizations.of(context);
    final waterfallsText = _waterfalls.text.trim();
    final waterfalls = waterfallsText.isEmpty ? null : _url(waterfallsText);
    final esplora = _url(_esplora.text);
    setState(() {
      _waterfallsError = waterfallsText.isNotEmpty && waterfalls == null
          ? l.errorServerUrl
          : null;
      _esploraError = _esplora.text.trim().isEmpty
          ? l.errorEsploraEmpty
          : esplora == null
          ? l.errorServerUrl
          : null;
      _failed = false;
    });
    for (final (error, field) in [
      (_waterfallsError, _waterfallsFocus),
      (_esploraError, _esploraFocus),
    ]) {
      if (error != null) return reportFieldError(context, error, field);
    }

    setState(() => _saving = true);
    final liquid = LumenScope.sourcesOf(context).liquid;
    final wallets = LumenScope.readWallets(context);
    try {
      await liquid.setServers(
        widget.network,
        LiquidServers(waterfalls: waterfalls, esplora: esplora!),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failed = true;
      });
      SemanticsService.sendAnnouncement(
        View.of(context),
        l.errorServersSave,
        Directionality.of(context),
        assertiveness: Assertiveness.assertive,
      );
      return;
    }
    for (final wallet in wallets.wallets) {
      if (wallet.network == widget.network) wallets.refresh(wallet);
    }
    if (mounted) widget.frame.onDone();
  }

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? error,
    required TextInputAction action,
    required VoidCallback onSubmitted,
    required VoidCallback onChanged,
  }) => LabeledField(
    label: label,
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: _loaded,
      keyboardType: TextInputType.url,
      textInputAction: action,
      autocorrect: false,
      enableSuggestions: false,
      onSubmitted: (_) => onSubmitted(),
      onChanged: (_) => onChanged(),
      style: const TextStyle(fontFamily: monoFamily),
      decoration: InputDecoration(
        helperText: hint,
        helperMaxLines: 3,
        errorText: error,
        errorMaxLines: 3,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        widget.frame.header,
        const SizedBox(height: 20),
        Text(
          l.serversLead,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: c.text2, height: 1.5),
        ),
        const SizedBox(height: 20),
        _field(
          label: l.waterfallsLabel,
          hint: l.waterfallsHint,
          controller: _waterfalls,
          focusNode: _waterfallsFocus,
          error: _waterfallsError,
          action: TextInputAction.next,
          onSubmitted: _esploraFocus.requestFocus,
          onChanged: () {
            if (_waterfallsError != null) {
              setState(() => _waterfallsError = null);
            }
          },
        ),
        const SizedBox(height: 20),
        _field(
          label: l.esploraLabel,
          hint: l.esploraHint,
          controller: _esplora,
          focusNode: _esploraFocus,
          error: _esploraError,
          action: TextInputAction.done,
          onSubmitted: _save,
          onChanged: () {
            if (_esploraError != null) setState(() => _esploraError = null);
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            onPressed: _loaded ? _useDefaults : null,
            child: Text(l.useDefaultServers),
          ),
        ),
        if (_failed) ...[
          const SizedBox(height: 12),
          ErrorNote(l.errorServersSave),
        ],
        widget.frame.bottomGap,
        FilledButton(
          onPressed: _loaded ? _save : null,
          child: _saving
              ? SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: c.onAccent,
                  ),
                )
              : Text(l.save),
        ),
      ],
    );
  }
}
