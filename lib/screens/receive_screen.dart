import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import '../wallets/lumen_scope.dart';
import '../wallets/wallets_controller.dart';
import '../widgets/amount.dart';
import '../widgets/copy_button.dart';
import '../widgets/flow_parts.dart';
import '../widgets/qr_code_view.dart';
import '../widgets/screen_parts.dart';
import '../widgets/share_text.dart';
import '../widgets/wallet_picker.dart';

Future<void> openReceive(BuildContext context, {Wallet? wallet}) => openFlow(
  context,
  location: wallet == null ? '/receive' : '/receive?wallet=${wallet.id}',
  title: AppLocalizations.of(context).receive,
  builder: (frame) => _ReceiveFlow(frame: frame, walletId: wallet?.id),
);

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key, this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context) => FlowScreen(
    title: AppLocalizations.of(context).receive,
    builder: (frame) => _ReceiveFlow(frame: frame, walletId: walletId),
  );
}

class _ReceiveFlow extends StatefulWidget {
  const _ReceiveFlow({required this.frame, this.walletId});

  final FlowFrame frame;
  final String? walletId;

  @override
  State<_ReceiveFlow> createState() => _ReceiveFlowState();
}

class _ReceiveFlowState extends State<_ReceiveFlow> {
  final _amount = TextEditingController();
  final _amountFocus = FocusNode();
  final _resultFocus = FocusNode();

  late String? _walletId = widget.walletId;
  var _amountMissing = false;
  var _creating = false;
  ReceiveError? _error;

  Invoice? _invoice;
  Wallet? _invoiceWallet;
  var _expired = false;
  var _paid = false;
  StreamSubscription<void>? _payment;

  @override
  void dispose() {
    _payment?.cancel();
    _amount.dispose();
    _amountFocus.dispose();
    _resultFocus.dispose();
    super.dispose();
  }

  Wallet? _walletIn(WalletsController wallets) =>
      wallets.walletById(_walletId ?? '') ?? wallets.wallets.firstOrNull;

  Future<void> _create() async {
    final l = AppLocalizations.of(context);
    final sats = int.tryParse(_amount.text) ?? 0;
    if (sats <= 0) {
      setState(() => _amountMissing = true);
      _announce(l.errorAmountEmpty, assertive: true);
      _amountFocus.requestFocus();
      return;
    }
    final wallet = _walletIn(LumenScope.readWallets(context));
    if (wallet == null || _creating) return;

    _payment?.cancel();
    setState(() {
      _creating = true;
      _error = null;
      _invoice = null;
      _expired = false;
    });
    ReceiveError? error;
    try {
      final invoice = await wallet.createInvoice(sats);
      if (!mounted) return;
      setState(() {
        _invoice = invoice;
        _invoiceWallet = wallet;
      });
      _payment = wallet.watchPayment(invoice).listen((_) => _onPaid());
      _focusResult();
    } on ReceiveException catch (e) {
      error = e.error;
    } catch (_) {
      error = ReceiveError.unreachable;
    } finally {
      if (mounted) setState(() => _creating = false);
    }
    if (error != null && mounted) {
      setState(() => _error = error);
      _announce(error.message(l), assertive: true);
    }
  }

  void _onPaid() {
    final invoice = _invoice;
    final wallet = _invoiceWallet;
    if (!mounted || invoice == null || wallet == null) return;
    setState(() => _paid = true);
    LumenScope.readWallets(context).refresh(wallet);
    _announce(
      AppLocalizations.of(context)
          .receivedAnnouncement(formatSats(context, invoice.sats), wallet.name),
    );
    _focusResult();
  }

  void _onExpired() {
    setState(() => _expired = true);
    _announce(AppLocalizations.of(context).invoiceExpired);
    _focusResult();
  }

  void _chooseWallet(String id) {
    if (id == _walletId) return;
    setState(() => _walletId = id);
    if (_invoice != null) _create();
  }

  void _editAmount() {
    _payment?.cancel();
    setState(() {
      _invoice = null;
      _expired = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _amountFocus.requestFocus();
    });
  }

  /// The previous content is gone, so focus what replaced it.
  void _focusResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resultFocus.requestFocus();
    });
  }

  void _announce(String message, {bool assertive = false}) {
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      Directionality.of(context),
      assertiveness: assertive ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallets = LumenScope.walletsOf(context);
    final wallet = _walletIn(wallets);
    if (wallet == null) return const SizedBox.shrink();
    final invoice = _invoice;

    final List<Widget> body;
    if (invoice != null && _paid) {
      body = _paidView(invoice, _invoiceWallet ?? wallet);
    } else {
      body = [
        WalletPicker(
          label: AppLocalizations.of(context).receiveInto,
          hint: AppLocalizations.of(context).chooseWallet,
          selected: wallet,
          wallets: wallets.wallets,
          enabled: !_creating,
          onChanged: _chooseWallet,
        ),
        const SizedBox(height: 20),
        ...switch (invoice) {
          null => _amountForm(wallet),
          _ when _expired => _expiredView(),
          _ => _invoiceView(invoice),
        },
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [widget.frame.header, const SizedBox(height: 20), ...body],
    );
  }

  Widget get _bottomGap => widget.frame.bottomGap;

  List<Widget> _amountForm(Wallet wallet) {
    final l = AppLocalizations.of(context);
    return [
      if (wallet.lightningAddress case final address?) ...[
        _AddressCard(address),
        const SizedBox(height: 20),
      ],
      LabeledField(
        label: l.amountLabel,
        child: TextField(
          controller: _amount,
          focusNode: _amountFocus,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(12),
          ],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _create(),
          onChanged: (_) {
            if (_amountMissing) setState(() => _amountMissing = false);
          },
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            // Inside LabeledField's merged node, a suffix with semantics
            // trips a framework assertion when the text changes.
            suffixIcon: ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 8, end: 16),
                child: Text(
                  l.satsUnit,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: LumenColors.of(context).text2,
                  ),
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(),
            errorText: _amountMissing ? l.errorAmountEmpty : null,
          ),
        ),
      ),
      if (_error case final error?) ...[
        const SizedBox(height: 16),
        ErrorNote(error.message(l)),
      ],
      _bottomGap,
      FilledButton(
        onPressed: _creating ? null : _create,
        child: Text(_creating ? l.creatingInvoice : l.createInvoice),
      ),
    ];
  }

  List<Widget> _invoiceView(Invoice invoice) {
    final l = AppLocalizations.of(context);
    return [
      Center(
        child: Focus(
          focusNode: _resultFocus,
          child: QrCodeView(
            data: 'lightning:${invoice.request}',
            semanticLabel: l.invoiceQrLabel(formatSats(context, invoice.sats)),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Center(child: AmountText(invoice.sats, fontSize: 32)),
      Center(
        child: TextButton.icon(
          onPressed: _editAmount,
          icon: const Icon(Icons.edit_outlined),
          label: Text(l.editAmount),
        ),
      ),
      const SizedBox(height: 8),
      _CopyLine(invoice.request),
      const SizedBox(height: 16),
      _InvoiceStatus(invoice: invoice, onExpired: _onExpired),
    ];
  }

  List<Widget> _expiredView() {
    final l = AppLocalizations.of(context);
    return [
      Focus(focusNode: _resultFocus, child: ErrorNote(l.invoiceExpired)),
      _bottomGap,
      FilledButton(
        onPressed: _creating ? null : _create,
        child: Text(l.newInvoice),
      ),
    ];
  }

  List<Widget> _paidView(Invoice invoice, Wallet wallet) {
    final l = AppLocalizations.of(context);
    return [
      const SizedBox(height: 16),
      const SuccessMark(),
      const SizedBox(height: 16),
      Focus(
        focusNode: _resultFocus,
        child: Semantics(
          header: true,
          child: Text(
            l.paymentReceived,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Center(child: AmountText(invoice.sats, fontSize: 44)),
      const SizedBox(height: 8),
      Text(
        l.receivedInto(wallet.name),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, color: LumenColors.of(context).text2),
      ),
      _bottomGap,
      FilledButton(
        onPressed: widget.frame.onDone,
        style: quietButtonStyle(context),
        child: Text(l.done),
      ),
    ];
  }
}

class _CopyLine extends StatelessWidget {
  const _CopyLine(this.request);

  final String request;

  String get _short => shortInvoice(request);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final raised = IconButton.styleFrom(backgroundColor: c.surface3);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 6, 6),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _short,
              semanticsLabel: l.invoiceText(_short),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: monoFamily,
                fontSize: 13,
                color: c.text2,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CopyButton(
            text: request,
            tooltip: l.copyInvoice,
            copied: l.invoiceCopied,
            style: raised,
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: l.shareInvoice,
              style: raised,
              icon: const Icon(Icons.share_outlined),
              onPressed: () => shareText(buttonContext, request),
            ),
          ),
        ],
      ),
    );
  }
}

/// The wallet's Lightning address, which receives any amount without an
/// invoice.
class _AddressCard extends StatelessWidget {
  const _AddressCard(this.address);

  final String address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final raised = IconButton.styleFrom(backgroundColor: c.surface3);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 6, 10),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.lightningAddress,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: TextStyle(fontSize: 15, height: 1.3, color: c.text),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l.showAddressQr,
            style: raised,
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => FlowDialog(
                title: l.lightningAddress,
                builder: (frame) => _AddressQr(frame: frame, address: address),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CopyButton(
            text: address,
            tooltip: l.copyAddress,
            copied: l.addressCopied,
            style: raised,
          ),
        ],
      ),
    );
  }
}

class _AddressQr extends StatelessWidget {
  const _AddressQr({required this.frame, required this.address});

  final FlowFrame frame;
  final String address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        frame.header,
        const SizedBox(height: 20),
        Center(
          child: QrCodeView(
            data: 'lightning:$address',
            semanticLabel: l.addressQrLabel(address),
          ),
        ),
        const SizedBox(height: 16),
        ExcludeSemantics(
          child: Text(
            address,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: LumenColors.of(context).text,
            ),
          ),
        ),
        frame.bottomGap,
        Builder(
          builder: (buttonContext) => FilledButton.icon(
            onPressed: () => shareText(buttonContext, address),
            style: quietButtonStyle(context),
            icon: const Icon(Icons.share_outlined),
            label: Text(l.shareAddress),
          ),
        ),
      ],
    );
  }
}

/// "Waiting for payment" and the time left, updated without announcing it.
class _InvoiceStatus extends StatefulWidget {
  const _InvoiceStatus({required this.invoice, required this.onExpired});

  final Invoice invoice;
  final VoidCallback onExpired;

  @override
  State<_InvoiceStatus> createState() => _InvoiceStatusState();
}

class _InvoiceStatusState extends State<_InvoiceStatus> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    if (widget.invoice.expiresAt == null) return;
    _tick = Timer.periodic(const Duration(seconds: 5), (_) => _check());
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!mounted) return;
    if (widget.invoice.isExpiredAt(DateTime.now())) {
      _tick?.cancel();
      widget.onExpired();
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String? _timeLeft(AppLocalizations l) {
    final expiresAt = widget.invoice.expiresAt;
    if (expiresAt == null) return null;
    final left = expiresAt.difference(DateTime.now());
    if (left.inSeconds < 60) return l.expiresSoon;
    if (left.inMinutes < 90) {
      return l.expiresInMinutes((left.inSeconds / 60).ceil());
    }
    return l.expiresInHours((left.inMinutes / 60).round());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final timeLeft = _timeLeft(l);
    return MergeSemantics(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.schedule, size: 16, color: c.text2),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.waitingForPayment,
                  style: TextStyle(fontSize: 15, color: c.text),
                ),
                if (timeLeft != null)
                  Text(
                    timeLeft,
                    style: TextStyle(fontSize: 13, color: c.text2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension on ReceiveError {
  String message(AppLocalizations l) => switch (this) {
    ReceiveError.unreachable => l.receiveUnreachable,
    ReceiveError.noPermission => l.receiveNoPermission,
  };
}
