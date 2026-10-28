import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import '../widgets/activity.dart';
import '../widgets/amount.dart';
import '../widgets/details.dart';
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

  @override
  void initState() {
    super.initState();
    final wallets = LumenScope.readWallets(context);
    final wallet = wallets.walletById(widget.walletId);
    _transaction = wallet == null
        ? Future.value()
        : wallets.transaction(wallet, widget.transactionId);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wallet = LumenScope.walletsOf(context).walletById(widget.walletId);

    return FutureBuilder(
      future: _transaction,
      builder: (context, snapshot) {
        final transaction = snapshot.data;
        final share = transaction == null
            ? null
            : Builder(
                builder: (button) => IconButton(
                  tooltip: l.shareReceipt,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () =>
                      shareText(button, _receipt(context, transaction)),
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
                          _PaymentDetails(transaction, wallet),
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
  const _PaymentDetails(this.transaction, this.wallet);

  final Transaction transaction;
  final Wallet wallet;

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
        const SizedBox(height: 24),
        DetailsCard([
          (l.detailDate, Text(formatDateTime(context, t.at))),
          (l.columnWallet, Text(wallet.name)),
          (l.detailNetwork, Text(wallet.kind.label(l))),
          if (t.feeSats case final fee? when !t.isIncoming)
            (l.detailFeePaid, Text(l.amountSats(formatSats(context, fee)))),
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
      ],
    );
  }
}

/// A plain text receipt, without the wallet name, which is private.
String _receipt(BuildContext context, Transaction t) {
  final l = AppLocalizations.of(context);
  return [
    t.isIncoming ? l.paymentReceived : l.paymentSent,
    l.amountSats(formatSats(context, t.sats)),
    ?t.description,
    l.receiptLine(l.detailDate, formatDateTime(context, t.at)),
    if (t.feeSats case final fee? when !t.isIncoming)
      l.receiptLine(l.detailFeePaid, l.amountSats(formatSats(context, fee))),
    if (t.paymentHash case final hash?)
      l.receiptLine(l.detailPaymentHash, hash),
    if (t.preimage case final preimage?)
      l.receiptLine(l.receiptPreimage, preimage),
  ].join('\n');
}
