import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/semantics.dart';
import 'package:go_router/go_router.dart';
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
import 'tappable.dart';
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

/// "Oct 15, 2026, 9:30 AM", in the app language.
String formatDateTime(BuildContext context, DateTime at) =>
    DateFormat.yMMMd(AppLocalizations.of(context).localeName)
        .add_jm()
        .format(at.toLocal());

void openPayment(BuildContext context, WalletTransaction item) => context.push(
  '/payment/${item.wallet.id}/${Uri.encodeComponent(item.transaction.id)}',
);

/// Keeps "5 min ago" current while the screen stays open.
mixin TickingNow<T extends StatefulWidget> on State<T> {
  var timeNow = clock.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 10),
      (_) => setState(() => timeNow = clock.now()),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

/// Why some activity of [wallet], or of every wallet, is missing, or null.
String? activityNote(
  AppLocalizations l,
  WalletsController wallets,
  Wallet? wallet,
) {
  if (wallet == null) {
    final missing = wallets.activityUnavailableCount;
    return missing > 0 ? l.activityNotShown(missing) : null;
  }
  return switch (wallets.activityOf(wallet).error) {
    ActivityError.unreachable => l.activityUnreachable,
    ActivityError.noPermission => l.activityNoPermission,
    null => null,
  };
}

class ActivityNote extends StatelessWidget {
  const ActivityNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return Padding(
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
            child: Text(text, style: TextStyle(fontSize: 15, color: c.text2)),
          ),
        ],
      ),
    );
  }
}

class ActivityLoading extends StatelessWidget {
  const ActivityLoading({super.key, required this.label, this.visible = false});

  final String label;

  /// Shows [label] next to the spinner instead of only reading it aloud.
  final bool visible;

  @override
  Widget build(BuildContext context) {
    const spinner = SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: visible
          ? MergeSemantics(
              child: Row(
                children: [
                  spinner,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        color: LumenColors.of(context).text2,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: Semantics(label: label, child: spinner),
            ),
    );
  }
}

/// The latest transactions of every wallet, or only of [wallet].
class RecentActivity extends StatefulWidget {
  const RecentActivity({super.key, this.wallet});

  final Wallet? wallet;

  @override
  State<RecentActivity> createState() => _RecentActivityState();
}

class _RecentActivityState extends State<RecentActivity> with TickingNow {
  static const _shown = 5;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final wallets = LumenScope.walletsOf(context);
    final wallet = widget.wallet;

    final List<WalletTransaction> items;
    final bool loading;
    if (wallet == null) {
      items = wallets.recentActivity;
      loading = wallets.isLoadingActivity;
    } else {
      final state = wallets.activityOf(wallet);
      items = [
        for (final transaction in state.transactions ?? const <Transaction>[])
          (wallet: wallet, transaction: transaction),
      ];
      loading = state.loading;
    }
    final note = activityNote(l, wallets, wallet);
    final shown = items.take(_shown).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(
          title: l.recentActivity,
          action: shown.isEmpty
              ? null
              : TextButton(
                  onPressed: () => context.push(
                    wallet == null
                        ? '/activity'
                        : '/activity?wallet=${wallet.id}',
                  ),
                  child: Text(l.seeAll, semanticsLabel: l.seeAllActivity),
                ),
        ),
        if (note != null) ActivityNote(note),
        if (shown.isNotEmpty)
          ActivityItems(shown, now: timeNow, showWallet: wallet == null)
        else if (loading)
          ActivityLoading(label: l.activityLoading)
        else if (note == null)
          Text(l.noActivity, style: TextStyle(fontSize: 15, color: c.text2)),
      ],
    );
  }
}

/// A table on desktop, a list otherwise.
class ActivityItems extends StatelessWidget {
  const ActivityItems(
    this.items, {
    super.key,
    required this.now,
    required this.showWallet,
  });

  final List<WalletTransaction> items;
  final DateTime now;
  final bool showWallet;

  @override
  Widget build(BuildContext context) =>
      LayoutSize.of(context) == LayoutSize.desktop
      ? ActivityTable(items, now: now, showWallet: showWallet)
      : ActivityList(items, now: now, showWallet: showWallet);
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
      child: Tappable(
        onTap: () => openPayment(context, item),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                DirectionBadge(transaction),
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
      ),
    );
  }
}

/// Desktop activity: a real table, so screen readers read it cell by cell
/// with its column headers.
class ActivityTable extends StatefulWidget {
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
  State<ActivityTable> createState() => _ActivityTableState();
}

class _ActivityTableState extends State<ActivityTable> {
  String? _hovered;
  String? _focused;

  static String _key(WalletTransaction item) =>
      '${item.wallet.id}/${item.transaction.id}';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final line = BoxDecoration(
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

    // The description is the row's one focus stop. The other cells only take
    // pointer taps, and every cell tracks the pointer, so the whole row
    // highlights and clicks as one.
    Widget cell(
      WalletTransaction item,
      Widget child, {
      bool end = false,
      bool focusable = false,
    }) {
      final key = _key(item);
      final content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Align(
          alignment: end
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: child,
        ),
      );
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = key),
        onExit: (_) {
          if (_hovered == key) setState(() => _hovered = null);
        },
        child: focusable
            ? Tappable(
                onTap: () => openPayment(context, item),
                decorated: false,
                onFocusChange: (focused) => setState(
                  () => _focused = focused
                      ? key
                      : (_focused == key ? null : _focused),
                ),
                child: content,
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                excludeFromSemantics: true,
                onTap: () => openPayment(context, item),
                child: content,
              ),
      );
    }

    BoxDecoration rowDecoration(WalletTransaction item) {
      final key = _key(item);
      final focused = _focused == key;
      final hovered = _hovered == key;
      if (!focused && !hovered) return line;
      return BoxDecoration(
        color: hovered ? c.surface2 : null,
        borderRadius: BorderRadius.circular(12),
        border: focused ? Border.all(color: c.focus, width: 3) : null,
      );
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
      // Dates and amounts keep their words whole, the description gives way.
      columnWidths: {
        0: const FlexColumnWidth(3),
        if (widget.showWallet) 1: const FlexColumnWidth(2),
        widget.showWallet ? 2 : 1: const IntrinsicColumnWidth(),
        widget.showWallet ? 3 : 2: const IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          decoration: line,
          children: [
            header(l.columnDescription),
            if (widget.showWallet) header(l.columnWallet),
            header(l.columnDate),
            header(l.columnAmount, end: true),
          ],
        ),
        for (final item in widget.items)
          TableRow(
            decoration: rowDecoration(item),
            children: [
              cell(
                item,
                focusable: true,
                Row(
                  children: [
                    DirectionBadge(item.transaction, size: BadgeSize.small),
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
              if (widget.showWallet)
                cell(
                  item,
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
                item,
                Text(
                  formatWhen(context, item.transaction.at, widget.now),
                  style: TextStyle(fontSize: 15, color: c.text2),
                ),
              ),
              cell(item, _SignedAmount(item.transaction), end: true),
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

class DirectionBadge extends StatelessWidget {
  const DirectionBadge(
    this.transaction, {
    super.key,
    this.size = BadgeSize.medium,
  });

  final Transaction transaction;
  final BadgeSize size;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    final (box, radius, icon) = switch (size) {
      BadgeSize.small => (28.0, 9.0, 16.0),
      BadgeSize.medium => (40.0, 13.0, 20.0),
      BadgeSize.large => (56.0, 18.0, 28.0),
    };
    return ExcludeSemantics(
      child: Container(
        width: box,
        height: box,
        decoration: BoxDecoration(
          color: c.surface2,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(
          transaction.isIncoming ? Icons.south : Icons.north,
          size: icon,
          color: c.text2,
        ),
      ),
    );
  }
}
