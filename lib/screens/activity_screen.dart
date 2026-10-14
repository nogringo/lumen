import 'package:flutter/semantics.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../wallets/wallets_controller.dart';
import '../widgets/activity.dart';
import '../widgets/screen_parts.dart';

/// Every saved payment of one wallet, or of all of them. It reads the history
/// on the device, so it works offline.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, this.walletId});

  final String? walletId;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with TickingNow {
  static const _step = 50;

  final _end = FocusNode();
  WalletsController? _wallets;
  List<WalletTransaction>? _items;
  var _limit = _step;
  var _more = false;
  var _reads = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallets = LumenScope.readWallets(context);
    if (identical(wallets, _wallets)) return;
    _wallets?.historyChanges.removeListener(_read);
    _wallets = wallets..historyChanges.addListener(_read);
    _read();
  }

  @override
  void dispose() {
    _wallets?.historyChanges.removeListener(_read);
    _end.dispose();
    super.dispose();
  }

  Future<void> _read() async {
    final wallets = _wallets!;
    final read = ++_reads;
    // One more than shown tells whether Show more has anything to show.
    final items = await wallets.history(
      wallet: _wallet(wallets),
      limit: _limit + 1,
    );
    if (!mounted || read != _reads) return;
    setState(() {
      _more = items.length > _limit;
      _items = items.take(_limit).toList();
    });
  }

  Future<void> _showMore() async {
    final l = AppLocalizations.of(context);
    _limit += _step;
    await _read();
    if (!mounted) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      l.activityShownCount(_items!.length),
      Directionality.of(context),
    );
    // The button is gone, so focus would fall back to the top of the page.
    if (!_more) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_end.context != null) _end.requestFocus();
      });
    }
  }

  Wallet? _wallet(WalletsController wallets) =>
      widget.walletId == null ? null : wallets.walletById(widget.walletId!);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final wallets = LumenScope.walletsOf(context);
    final wallet = _wallet(wallets);
    final title = wallet == null
        ? l.activityTitle
        : l.walletActivityTitle(wallet.name);
    final note = activityNote(l, wallets, wallet);
    final items = _items;
    final loadingOlder = wallets.isLoadingOlder(wallet);
    final loading = wallet == null
        ? wallets.isLoadingActivity
        : wallets.activityOf(wallet).loading;
    final textStyle = TextStyle(fontSize: 15, color: c.text2);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              wallet == null ? wallets.refreshAll() : wallets.refresh(wallet),
          child: ListView(
            padding: LayoutSize.of(context).screenPadding,
            children: [
              if (hasSidebar(context))
                PageTitle(title)
              else
                TopBar(title: title),
              const SizedBox(height: 24),
              if (note != null) ActivityNote(note),
              if (items == null)
                ActivityLoading(label: l.activityLoading)
              else if (items.isEmpty)
                if (loading || loadingOlder)
                  ActivityLoading(label: l.activityLoading)
                else if (note == null)
                  Text(l.noActivity, style: textStyle)
                else
                  const SizedBox.shrink()
              else ...[
                ActivityItems(items, now: timeNow, showWallet: wallet == null),
                const SizedBox(height: 16),
                if (_more)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton(
                      onPressed: _showMore,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      child: Text(l.showMore),
                    ),
                  )
                else
                  Focus(
                    focusNode: _end,
                    child: loadingOlder
                        ? ActivityLoading(label: l.loadingOlder, visible: true)
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(l.activityEnd, style: textStyle),
                          ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
