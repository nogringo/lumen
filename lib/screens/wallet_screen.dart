import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../wallets/wallets_controller.dart';
import '../widgets/activity.dart';
import '../widgets/amount.dart';
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

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => wallets.refresh(wallet),
          child: ListView(
            padding: LayoutSize.of(context).screenPadding,
            children: [
              if (hasSidebar(context))
                PageTitle(wallet.name, trailing: menu)
              else
                TopBar(title: wallet.name, trailing: menu),
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

enum _Action { rename, remove }

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
        _Action.remove => _remove(context),
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _Action.rename,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 12),
              Text(l.rename),
            ],
          ),
        ),
        PopupMenuItem(
          value: _Action.remove,
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 18),
              const SizedBox(width: 12),
              Text(l.remove),
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
