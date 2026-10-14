import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../wallets/wallets_controller.dart';
import 'amount.dart';
import 'screen_parts.dart';
import 'wallet_kind_style.dart';

/// "2 min ago", "Yesterday", "Oct 12": how long ago [at] was, as of [now].
String formatWhen(BuildContext context, DateTime at, DateTime now) {
  final l = AppLocalizations.of(context);
  final local = at.toLocal();
  final elapsed = now.difference(local);
  if (elapsed.inMinutes < 1) return l.justNow;
  if (elapsed.inHours < 1) return l.minutesAgo(elapsed.inMinutes);
  final today = DateUtils.dateOnly(now);
  final day = DateUtils.dateOnly(local);
  if (day == today) return l.hoursAgo(elapsed.inHours);
  if (today.difference(day).inDays == 1) return l.yesterday;
  final format = local.year == now.year
      ? DateFormat.MMMd(l.localeName)
      : DateFormat.yMMMd(l.localeName);
  return format.format(local);
}

/// The latest transactions of every wallet, or only of [wallet].
class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key, this.wallet});

  final Wallet? wallet;

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> {
  static const _shown = 5;

  var _now = clock.now();

  /// Keeps "5 min ago" current while the screen stays open.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 10),
      (_) => setState(() => _now = clock.now()),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final wallets = LumenScope.walletsOf(context);
    final wallet = widget.wallet;

    final List<WalletTransaction> items;
    final bool loading;
    final String? note;
    if (wallet == null) {
      items = wallets.recentActivity;
      loading = wallets.isLoadingActivity;
      final missing = wallets.activityUnavailableCount;
      note = missing > 0 ? l.activityNotShown(missing) : null;
    } else {
      final state = wallets.activityOf(wallet);
      items = [
        for (final transaction in state.transactions ?? const <Transaction>[])
          (wallet: wallet, transaction: transaction),
      ];
      loading = state.loading;
      note = switch (state.error) {
        ActivityError.unreachable => l.activityUnreachable,
        ActivityError.noPermission => l.activityNoPermission,
        null => null,
      };
    }
    final shown = items.take(_shown).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(title: l.recentActivity),
        if (note != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(Icons.error_outline, size: 16, color: c.text2),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: TextStyle(fontSize: 15, color: c.text2),
                  ),
                ),
              ],
            ),
          ),
        if (shown.isNotEmpty)
          LayoutSize.of(context) == LayoutSize.desktop
              ? ActivityTable(shown, now: _now, showWallet: wallet == null)
              : ActivityList(shown, now: _now, showWallet: wallet == null)
        else if (loading)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Semantics(
              label: l.activityLoading,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          )
        else if (note == null)
          Text(l.noActivity, style: TextStyle(fontSize: 15, color: c.text2)),
      ],
    );
  }
}

class ActivityList extends StatelessWidget {
  const ActivityList(
    this.items, {
    super.key,
    required this.now,
    required this.showWallet,
  });

  final List<WalletTransaction> items;
  final DateTime now;
  final bool showWallet;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      role: SemanticsRole.list,
      container: true,
      explicitChildNodes: true,
      child: Column(
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0) const Divider(),
            Semantics(
              role: SemanticsRole.listItem,
              container: true,
              child: _ActivityRow(item, now: now, showWallet: showWallet),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow(this.item, {required this.now, required this.showWallet});

  final WalletTransaction item;
  final DateTime now;
  final bool showWallet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context).textTheme;
    final transaction = item.transaction;
    final when = formatWhen(context, transaction.at, now);
    final stacked = MediaQuery.textScalerOf(context).scale(15) > 24;
    final meta = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title(l, transaction),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 3),
        Text(
          showWallet ? l.transactionWalletWhen(item.wallet.name, when) : when,
          style: theme.bodySmall,
        ),
      ],
    );
    final amount = _SignedAmount(transaction);

    return MergeSemantics(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              _DirectionBadge(transaction),
              const SizedBox(width: 14),
              if (stacked)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      meta,
                      const SizedBox(height: 6),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: amount,
                      ),
                    ],
                  ),
                )
              else ...[
                Expanded(child: meta),
                const SizedBox(width: 12),
                amount,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Desktop activity: a real table, so screen readers read it cell by cell
/// with its column headers.
class ActivityTable extends StatelessWidget {
  const ActivityTable(
    this.items, {
    super.key,
    required this.now,
    required this.showWallet,
  });

  final List<WalletTransaction> items;
  final DateTime now;
  final bool showWallet;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final border = BoxDecoration(
      border: Border(bottom: BorderSide(color: c.line)),
    );

    Widget header(String text, {bool end = false}) => Semantics(
      role: SemanticsRole.columnHeader,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Text(
          text,
          textAlign: end ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: c.text2,
          ),
        ),
      ),
    );

    Widget cell(Widget child, {bool end = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Align(
        alignment: end
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: child,
      ),
    );

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        0: const FlexColumnWidth(3),
        if (showWallet) 1: const FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: border,
          children: [
            header(l.columnDescription),
            if (showWallet) header(l.columnWallet),
            header(l.columnDate),
            header(l.columnAmount, end: true),
          ],
        ),
        for (final item in items)
          TableRow(
            decoration: border,
            children: [
              cell(
                Row(
                  children: [
                    _DirectionBadge(item.transaction, small: true),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _title(l, item.transaction),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showWallet)
                cell(
                  Row(
                    children: [
                      SourceBadge(item.wallet.kind, size: BadgeSize.small),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          item.wallet.name,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              cell(
                Text(
                  formatWhen(context, item.transaction.at, now),
                  style: TextStyle(fontSize: 15, color: c.text2),
                ),
              ),
              cell(_SignedAmount(item.transaction), end: true),
            ],
          ),
      ],
    );
  }
}

String _title(AppLocalizations l, Transaction transaction) =>
    transaction.description ??
    (transaction.isIncoming ? l.transactionReceived : l.transactionSent);

/// "+40,000" or "-5,400" on screen, "received 40,000 sats" when read aloud.
class _SignedAmount extends StatelessWidget {
  const _SignedAmount(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final amount = formatSats(context, transaction.sats);
    final incoming = transaction.isIncoming;
    return Semantics(
      label: incoming ? l.amountReceived(amount) : l.amountSent(amount),
      excludeSemantics: true,
      child: Text(
        '${incoming ? '+' : '-'}$amount',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: incoming ? c.positive : c.text,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _DirectionBadge extends StatelessWidget {
  const _DirectionBadge(this.transaction, {this.small = false});

  final Transaction transaction;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    final box = small ? 28.0 : 40.0;
    return ExcludeSemantics(
      child: Container(
        width: box,
        height: box,
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(small ? 9 : 13),
        ),
        child: Icon(
          transaction.isIncoming ? Icons.south : Icons.north,
          size: small ? 16 : 20,
          color: c.text2,
        ),
      ),
    );
  }
}
