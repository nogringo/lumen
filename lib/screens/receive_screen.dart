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
import '../widgets/address_card.dart';
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

  /// The invoice or address on screen, and the wallet it pays into.
  PaymentRequest? _request;
  Wallet? _requestWallet;

  /// The wallet an address is being asked from.
  Wallet? _gettingAddress;
  var _editingAmount = false;
  var _expired = false;
  Transaction? _received;
  StreamSubscription<Transaction>? _payment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wallet = _walletIn(LumenScope.readWallets(context));
      if (wallet != null && _receivesByAddress(wallet)) _getAddress(wallet);
    });
  }

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

  /// Wallets that create invoices receive by invoice, even when they also
  /// have an address.
  static bool _receivesByAddress(Wallet wallet) =>
      wallet.capabilities.contains(WalletCapability.receiveAddress) &&
      !wallet.capabilities.contains(WalletCapability.receiveInvoice);

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
      _request = null;
      _expired = false;
    });
    ReceiveError? error;
    try {
      final invoice = await wallet.createInvoice(sats);
      if (!mounted) return;
      setState(() {
        _request = invoice;
        _requestWallet = wallet;
      });
      _payment = wallet.watchPayment(invoice).listen(_onPaid);
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

  /// An address can wait on a slow sync, so the picker stays enabled
  /// meanwhile and an answer for a wallet no longer chosen is dropped.
  Future<void> _getAddress(Wallet wallet) async {
    final sats = switch (_request) {
      ChainAddress(:final sats) => sats,
      _ => null,
    };
    _payment?.cancel();
    setState(() {
      _gettingAddress = wallet;
      _request = null;
      _error = null;
      _editingAmount = false;
      _amountMissing = false;
    });
    ReceiveError? error;
    try {
      final address = await wallet.nextAddress();
      if (!mounted || _gettingAddress != wallet) return;
      setState(() {
        _request = ChainAddress(
          address.address,
          network: address.network,
          sats: sats,
        );
        _requestWallet = wallet;
      });
      _payment = wallet.watchPayment(address).listen(_onPaid);
    } on ReceiveException catch (e) {
      error = e.error;
    } catch (_) {
      error = ReceiveError.unreachable;
    }
    if (!mounted || _gettingAddress != wallet) return;
    setState(() {
      _gettingAddress = null;
      _error = error;
    });
    if (error != null) {
      _announce(
        AppLocalizations.of(context).addressUnavailable,
        assertive: true,
      );
    }
  }

  void _setAddressAmount() {
    final address = _request;
    if (address is! ChainAddress) return;
    final sats = int.tryParse(_amount.text) ?? 0;
    setState(() {
      _request = ChainAddress(
        address.address,
        network: address.network,
        sats: sats > 0 ? sats : null,
      );
      _editingAmount = false;
    });
    _focusResult();
  }

  /// Called again when a pending payment confirms.
  void _onPaid(Transaction payment) {
    final wallet = _requestWallet;
    if (!mounted || wallet == null) return;
    final l = AppLocalizations.of(context);
    final first = _received == null;
    setState(() => _received = payment);
    LumenScope.readWallets(context).refresh(wallet);
    if (first) {
      HapticFeedback.successNotification();
      _announce(
        l.receivedAnnouncement(formatSats(context, payment.sats), wallet.name),
      );
      _focusResult();
    } else if (!payment.isPending) {
      _announce(l.paymentConfirmedAnnouncement);
    }
  }

  void _onExpired() {
    setState(() => _expired = true);
    _announce(AppLocalizations.of(context).invoiceExpired);
    _focusResult();
  }

  void _chooseWallet(String id) {
    if (id == _walletId) return;
    setState(() => _walletId = id);
    final wallet = _walletIn(LumenScope.readWallets(context));
    if (wallet == null) return;
    if (_receivesByAddress(wallet)) {
      _getAddress(wallet);
      return;
    }
    final hadInvoice = _request is Invoice;
    _payment?.cancel();
    setState(() {
      _request = null;
      _gettingAddress = null;
      _editingAmount = false;
      _error = null;
    });
    if (hadInvoice) _create();
  }

  void _editAmount() {
    if (_request case ChainAddress(:final sats)) {
      _amount.text = sats?.toString() ?? '';
      setState(() => _editingAmount = true);
    } else {
      _payment?.cancel();
      setState(() {
        _request = null;
        _expired = false;
      });
    }
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

    final List<Widget> body;
    if (_received case final received?) {
      body = _paidView(received, _requestWallet ?? wallet);
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
        ...switch (_request) {
          ChainAddress() when _editingAmount => _amountForm(wallet),
          final ChainAddress address => _addressView(address),
          Invoice() when _expired => _expiredView(),
          final Invoice invoice => _invoiceView(invoice),
          null when _receivesByAddress(wallet) => _addressMissing(wallet),
          null => _amountForm(wallet),
        },
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [widget.frame.header, const SizedBox(height: 20), ...body],
    );
  }

  Widget get _bottomGap => widget.frame.bottomGap;

  /// The amount of a new invoice, or the optional amount of an address.
  List<Widget> _amountForm(Wallet wallet) {
    final l = AppLocalizations.of(context);
    final byAddress = _receivesByAddress(wallet);
    return [
      if (wallet.lightningAddress case final address?) ...[
        AddressCard(address),
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
          onSubmitted: (_) => byAddress ? _setAddressAmount() : _create(),
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
            helperText: byAddress ? l.amountOptional : null,
            helperMaxLines: 3,
            errorText: _amountMissing ? l.errorAmountEmpty : null,
          ),
        ),
      ),
      if (_error case final error?) ...[
        const SizedBox(height: 16),
        ErrorNote(error.message(l)),
      ],
      _bottomGap,
      if (byAddress)
        FilledButton(onPressed: _setAddressAmount, child: Text(l.showQrCode))
      else
        FilledButton(
          onPressed: _creating ? null : _create,
          child: Text(_creating ? l.creatingInvoice : l.createInvoice),
        ),
    ];
  }

  /// While the wallet gives an address, or after it could not.
  List<Widget> _addressMissing(Wallet wallet) {
    final l = AppLocalizations.of(context);
    if (_error == null) {
      return [
        MergeSemantics(
          child: Row(
            children: [
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l.gettingAddress,
                  style: TextStyle(
                    fontSize: 15,
                    color: LumenColors.of(context).text2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ];
    }
    return [
      ErrorNote(l.addressUnavailable),
      _bottomGap,
      FilledButton(
        onPressed: () => _getAddress(wallet),
        child: Text(l.tryAgain),
      ),
    ];
  }

  List<Widget> _addressView(ChainAddress address) {
    final l = AppLocalizations.of(context);
    final sats = address.sats;
    return [
      Center(
        child: Focus(
          focusNode: _resultFocus,
          child: QrCodeView(
            data: liquidRequest(address),
            semanticLabel: sats == null
                ? l.liquidQrLabel
                : l.liquidAmountQrLabel(formatSats(context, sats)),
          ),
        ),
      ),
      const SizedBox(height: 16),
      if (sats != null) Center(child: AmountText(sats, fontSize: 32)),
      Center(
        child: TextButton.icon(
          onPressed: _editAmount,
          icon: Icon(sats == null ? Icons.add : Icons.edit_outlined),
          label: Text(sats == null ? l.addAmount : l.editAmount),
        ),
      ),
      const SizedBox(height: 8),
      _AddressLine(address),
      const SizedBox(height: 16),
      StatusLine(icon: Icons.schedule, title: l.waitingForPayment),
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

  List<Widget> _paidView(Transaction payment, Wallet wallet) {
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
      Center(child: AmountText(payment.sats, fontSize: 44)),
      const SizedBox(height: 8),
      Text(
        l.receivedInto(wallet.name),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, color: LumenColors.of(context).text2),
      ),
      if (payment.confirmations != null) ...[
        const SizedBox(height: 20),
        if (payment.isPending)
          StatusLine(
            icon: Icons.schedule,
            title: l.waitingForConfirmation,
            detail: l.confirmsSoon,
          )
        else
          StatusLine(
            icon: Icons.check_circle_outline,
            title: l.paymentConfirmed,
          ),
      ],
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

/// The whole address, with buttons to copy and share it.
class _AddressLine extends StatelessWidget {
  const _AddressLine(this.address);

  final ChainAddress address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final raised = IconButton.styleFrom(backgroundColor: c.surface3);
    final request = liquidRequest(address);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 6, 6),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: GroupedAddress(
              address.address,
              style: TextStyle(fontSize: 14, height: 1.5, color: c.text),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CopyButton(
                text: request,
                tooltip: l.copyAddress,
                copied: l.addressCopied,
                style: raised,
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (buttonContext) => IconButton(
                  tooltip: l.shareAddress,
                  style: raised,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => shareText(buttonContext, request),
                ),
              ),
            ],
          ),
        ],
      ),
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
    return StatusLine(
      icon: Icons.schedule,
      title: l.waitingForPayment,
      detail: _timeLeft(l),
    );
  }
}

extension on ReceiveError {
  String message(AppLocalizations l) => switch (this) {
    ReceiveError.unreachable => l.receiveUnreachable,
    ReceiveError.noPermission => l.receiveNoPermission,
  };
}
