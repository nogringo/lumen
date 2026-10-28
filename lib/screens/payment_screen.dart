import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../widgets/activity.dart';
import '../widgets/amount.dart';
import '../widgets/details.dart';
import '../widgets/flow_parts.dart';
import '../widgets/screen_parts.dart';
import '../widgets/share_text.dart';
import '../widgets/wallet_kind_style.dart';

/// One payment from the activity, read from the history on the device.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.walletId,
    required this.transactionId,
  });

  final String walletId;
  final String transactionId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final Future<Transaction?> _transaction;

  /// A chain payment read live from its wallet, since the history keeps the
  /// confirmations it had when saved.
  ChainDetails? _live;

  @override
  void initState() {
    super.initState();
    final wallets = LumenScope.readWallets(context);
    final wallet = wallets.walletById(widget.walletId);
    _transaction = wallet == null
        ? Future.value()
        : wallets.transaction(wallet, widget.transactionId);
    if (wallet != null && wallet.network != null) _readLive(wallet);
  }

  Future<void> _readLive(Wallet wallet) async {
    final saved = await _transaction;
    final txid = saved?.txid;
    if (txid == null) return;
    final ChainDetails? live;
    try {
      live = await wallet.chainDetails(txid);
    } on ActivityException {
      return;
    }
    if (live == null || !mounted) return;
    setState(() => _live = live);
    if (saved!.isPending && !live.transaction.isPending) {
      _announce(
        context,
        AppLocalizations.of(context).paymentConfirmedAnnouncement,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wallet = LumenScope.walletsOf(context).walletById(widget.walletId);

    return FutureBuilder(
      future: _transaction,
      builder: (context, snapshot) {
        final transaction = _live?.transaction ?? snapshot.data;
        final share = transaction == null || wallet == null
            ? null
            : Builder(
                builder: (button) => IconButton(
                  tooltip: l.shareReceipt,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () =>
                      shareText(button, _receipt(context, transaction, wallet)),
                ),
              );
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: LayoutSize.of(context).screenPadding,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hasSidebar(context))
                          PageTitle(
                            l.paymentTitle,
                            backButton: true,
                            trailing: share,
                          )
                        else
                          TopBar(title: l.paymentTitle, actions: [?share]),
                        const SizedBox(height: 24),
                        if (snapshot.connectionState != ConnectionState.done)
                          ActivityLoading(label: l.activityLoading)
                        else if (transaction == null || wallet == null)
                          Text(
                            l.paymentNotFound,
                            style: TextStyle(
                              fontSize: 15,
                              color: LumenColors.of(context).text2,
                            ),
                          )
                        else
                          _PaymentDetails(
                            transaction,
                            wallet,
                            explorer: _live?.explorer,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails(this.transaction, this.wallet, {this.explorer});

  final Transaction transaction;
  final Wallet wallet;
  final Uri? explorer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final t = transaction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: DirectionBadge(t, size: BadgeSize.large)),
        const SizedBox(height: 16),
        Semantics(
          header: true,
          child: Text(
            t.isIncoming ? l.paymentReceived : l.paymentSent,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: c.text2),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: AmountText(t.sats, fontSize: 44)),
        if (t.description case final description?) ...[
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: c.text2),
          ),
        ],
        if (t.txid != null) ...[
          const SizedBox(height: 20),
          if (t.isPending)
            StatusLine(icon: Icons.schedule, title: l.waitingForConfirmation)
          else
            StatusLine(
              icon: Icons.check_circle_outline,
              title: l.paymentConfirmed,
            ),
        ],
        const SizedBox(height: 24),
        DetailsCard([
          (l.detailDate, Text(formatDateTime(context, t.at))),
          (l.columnWallet, Text(wallet.name)),
          (l.detailNetwork, Text(wallet.kind.label(l))),
          if (t.confirmations case final count?)
            (l.detailConfirmations, Text(_formatCount(l, count))),
          if (t.feeSats case final fee? when !t.isIncoming)
            (l.detailFeePaid, Text(l.amountSats(formatSats(context, fee)))),
          if (t.txid case final txid?)
            (
              l.detailTxid,
              CopyableValue(txid, tooltip: l.copyTxid, copied: l.txidCopied),
            ),
          if (t.paymentHash case final hash?)
            (
              l.detailPaymentHash,
              CopyableValue(
                hash,
                tooltip: l.copyPaymentHash,
                copied: l.paymentHashCopied,
              ),
            ),
          if (t.preimage case final preimage?)
            (
              l.receiptPreimage,
              CopyableValue(
                preimage,
                tooltip: l.copyPreimage,
                copied: l.preimageCopied,
              ),
            ),
          if (t.invoice case final invoice?)
            (
              l.lightningInvoice,
              CopyableValue(
                invoice,
                tooltip: l.copyInvoice,
                copied: l.invoiceCopied,
              ),
            ),
        ]),
        if (explorer case final explorer?) ...[
          const SizedBox(height: 16),
          _ExplorerLink(explorer),
        ],
      ],
    );
  }
}

class _ExplorerLink extends StatefulWidget {
  const _ExplorerLink(this.url);

  final Uri url;

  @override
  State<_ExplorerLink> createState() => _ExplorerLinkState();
}

class _ExplorerLinkState extends State<_ExplorerLink> {
  var _failed = false;

  Future<void> _open() async {
    bool opened;
    try {
      opened = await launchUrl(
        widget.url,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!mounted) return;
    setState(() => _failed = !opened);
    if (!opened) {
      _announce(
        context,
        AppLocalizations.of(context).explorerFailed(widget.url.host),
        assertive: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _open,
          style: quietButtonStyle(context),
          icon: const Icon(Icons.open_in_new),
          label: Text(l.viewOnExplorer(widget.url.host)),
        ),
        if (_failed) ...[
          const SizedBox(height: 12),
          ErrorNote(l.explorerFailed(widget.url.host)),
        ],
      ],
    );
  }
}

String _formatCount(AppLocalizations l, int count) =>
    NumberFormat.decimalPattern(l.localeName).format(count);

void _announce(
  BuildContext context,
  String message, {
  bool assertive = false,
}) => SemanticsService.sendAnnouncement(
  View.of(context),
  message,
  Directionality.of(context),
  assertiveness: assertive ? Assertiveness.assertive : Assertiveness.polite,
);

/// A plain text receipt, without the wallet name, which is private, or the
/// explorer link, which unblinds every amount of the wallet's in the
/// transaction, change included.
String _receipt(BuildContext context, Transaction t, Wallet wallet) {
  final l = AppLocalizations.of(context);
  return [
    t.isIncoming ? l.paymentReceived : l.paymentSent,
    l.amountSats(formatSats(context, t.sats)),
    ?t.description,
    l.receiptLine(l.detailDate, formatDateTime(context, t.at)),
    l.receiptLine(l.detailNetwork, wallet.kind.label(l)),
    if (t.confirmations case final count?)
      l.receiptLine(l.detailConfirmations, _formatCount(l, count)),
    if (t.feeSats case final fee? when !t.isIncoming)
      l.receiptLine(l.detailFeePaid, l.amountSats(formatSats(context, fee))),
    if (t.txid case final txid?) l.receiptLine(l.detailTxid, txid),
    if (t.paymentHash case final hash?)
      l.receiptLine(l.detailPaymentHash, hash),
    if (t.preimage case final preimage?)
      l.receiptLine(l.receiptPreimage, preimage),
  ].join('\n');
}
