import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../lock/gate_scope.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../wallets/wallets_controller.dart';
import '../widgets/activity.dart';
import '../widgets/address_card.dart';
import '../widgets/amount.dart';
import '../widgets/passphrase_field.dart';
import '../widgets/screen_parts.dart';
import '../widgets/wallet_actions.dart';
import '../widgets/wallet_kind_style.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, required this.walletId});

  final String walletId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final wallets = LumenScope.walletsOf(context);
    final wallet = wallets.walletById(walletId);
    if (wallet == null) return const Scaffold();
    final menu = _WalletMenu(wallet);
    final balance = wallets.balanceOf(wallet);
    final refresh = RefreshButton(
      label: l.refreshBalance,
      loading: balance.loading,
      onPressed: () => wallets.refresh(wallet),
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => wallets.refresh(wallet),
          child: ListView(
            padding: LayoutSize.of(context).screenPadding,
            children: [
              if (hasSidebar(context))
                PageTitle(
                  wallet.name,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [refresh, menu],
                  ),
                )
              else
                TopBar(
                  title: wallet.name,
                  actions: [if (isDesktopPlatform(context)) refresh, menu],
                ),
              const SizedBox(height: 24),
              MergeSemantics(
                child: Semantics(
                  liveRegion: true,
                  customSemanticsActions: {
                    CustomSemanticsAction(label: l.refreshBalance): () =>
                        wallets.refresh(wallet),
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SourceBadge(
                        wallet.kind,
                        size: BadgeSize.large,
                        semanticLabel: wallet.kind.subtitle(l),
                      ),
                      const SizedBox(height: 10),
                      _Balance(balance),
                    ],
                  ),
                ),
              ),
              if (balance.error == BalanceError.unreachable) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilledButton.icon(
                    onPressed: () => wallets.refresh(wallet),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.surface2,
                      foregroundColor: c.text,
                      minimumSize: const Size(0, 48),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(l.tryAgain),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              WalletActions(wallet: wallet),
              if (wallet.lightningAddress case final address?) ...[
                const SizedBox(height: 24),
                AddressCard(address),
              ],
              const SizedBox(height: 24),
              RecentActivity(wallet: wallet),
            ],
          ),
        ),
      ),
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance(this.state);

  final BalanceState state;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final sats = state.sats;
    if (sats != null) return AmountText(sats);
    if (state.error case final error?) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          switch (error) {
            BalanceError.unreachable => l.walletUnreachable,
            BalanceError.noPermission => l.balanceNoPermission,
          },
          style: TextStyle(fontSize: 15, color: LumenColors.of(context).text2),
        ),
      );
    }
    return const LoadingAmount();
  }
}

enum _Action { rename, copyConnection, remove }

class _WalletMenu extends StatelessWidget {
  const _WalletMenu(this.wallet);

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<_Action>(
      tooltip: l.walletOptions(wallet.name),
      icon: const Icon(Icons.more_horiz),
      onSelected: (action) => switch (action) {
        _Action.rename => _rename(context),
        _Action.copyConnection => _copyConnection(context),
        _Action.remove => _remove(context),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _Action.rename,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 12),
              Flexible(child: Text(l.rename)),
            ],
          ),
        ),
        if (wallet.kind == WalletKind.lightning)
          PopupMenuItem(
            value: _Action.copyConnection,
            child: Row(
              children: [
                const Icon(Icons.key_outlined, size: 18),
                const SizedBox(width: 12),
                Flexible(child: Text(l.copyConnection)),
              ],
            ),
          ),
        PopupMenuItem(
          value: _Action.remove,
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18),
              const SizedBox(width: 12),
              Flexible(child: Text(l.remove)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _rename(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: wallet.name),
    );
    if (name == null || !context.mounted) return;
    await LumenScope.readWallets(context).rename(wallet, name);
  }

  Future<void> _copyConnection(BuildContext context) async {
    final connection = await wallet.connectionString();
    if (connection == null || !context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _CopyConnectionDialog(connection),
    );
  }

  Future<void> _remove(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.removeTitle(wallet.name)),
        content: Text(l.removeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: c.danger),
            child: Text(l.remove),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final wallets = LumenScope.readWallets(context);
    context.go('/');
    await wallets.remove(wallet);
  }
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final _name = TextEditingController(text: widget.initial)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initial.length,
    );
  var _empty = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _empty = true);
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l.renameTitle),
      content: TextField(
        controller: _name,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        onChanged: (_) {
          if (_empty) setState(() => _empty = false);
        },
        decoration: InputDecoration(
          labelText: l.nameLabel,
          errorText: _empty ? l.errorNameEmpty : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(onPressed: _save, child: Text(l.save)),
      ],
    );
  }
}

/// Warns before the connection string reaches the clipboard, and asks for the
/// passphrase first while App lock is on.
class _CopyConnectionDialog extends StatefulWidget {
  const _CopyConnectionDialog(this.connection);

  final String connection;

  @override
  State<_CopyConnectionDialog> createState() => _CopyConnectionDialogState();
}

class _CopyConnectionDialogState extends State<_CopyConnectionDialog> {
  final _passphrase = TextEditingController();
  final _focus = FocusNode();
  String? _error;
  var _checking = false;
  var _copied = false;

  @override
  void dispose() {
    _passphrase.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _copy() async {
    final l = AppLocalizations.of(context);
    final lock = GateScope.of(context).lock;
    if (_checking) return;
    if (lock.enabled) {
      if (_passphrase.text.isEmpty) {
        setState(() => _error = l.errorPassphraseEmpty);
        return reportFieldError(context, l.errorPassphraseEmpty, _focus);
      }
      _checking = true;
      final check = await lock.check(_passphrase.text);
      _checking = false;
      if (!mounted) return;
      final message = refusalMessage(l, check, lock.retryAt);
      if (message != null) {
        setState(() => _error = message);
        return reportFieldError(context, message, _focus);
      }
    }
    await Clipboard.setData(ClipboardData(text: widget.connection));
    if (!mounted) return;
    setState(() => _copied = true);
    SemanticsService.sendAnnouncement(
      View.of(context),
      l.connectionCopied,
      Directionality.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final locked = GateScope.of(context).lock.enabled;
    return AlertDialog(
      scrollable: true,
      title: Text(l.copyConnectionTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.copyConnectionBody),
          if (_copied) ...[
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.check, size: 18, color: c.positive),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(l.connectionCopied)),
              ],
            ),
          ] else if (locked) ...[
            const SizedBox(height: 20),
            PassphraseField(
              label: l.passphraseLabel,
              controller: _passphrase,
              focusNode: _focus,
              errorText: _error,
              autofillHints: const [AutofillHints.password],
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _copy(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
            ),
          ],
        ],
      ),
      actions: _copied
          ? [
              TextButton(
                autofocus: true,
                onPressed: () => Navigator.pop(context),
                child: Text(l.done),
              ),
            ]
          : [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.cancel),
              ),
              TextButton(onPressed: _copy, child: Text(l.copy)),
            ],
    );
  }
}
