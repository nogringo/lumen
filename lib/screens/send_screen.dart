import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../scan/qr_scanner.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import '../wallets/lumen_scope.dart';
import '../wallets/wallets_controller.dart';
import '../widgets/activity.dart';
import '../widgets/amount.dart';
import '../widgets/details.dart';
import '../widgets/flow_parts.dart';
import '../widgets/screen_parts.dart';
import '../widgets/share_text.dart';
import '../widgets/switch_row.dart';
import '../widgets/wallet_picker.dart';

/// [to] fills in the recipient, as read from a QR code.
Future<void> openSend(BuildContext context, {Wallet? wallet, String? to}) =>
    openFlow(
      context,
      location: wallet == null ? '/send' : '/send?wallet=${wallet.id}',
      extra: to,
      title: AppLocalizations.of(context).send,
      builder: (frame) =>
          _SendFlow(frame: frame, walletId: wallet?.id, initialTo: to),
    );

class SendScreen extends StatelessWidget {
  const SendScreen({super.key, this.walletId, this.initialTo});

  final String? walletId;
  final String? initialTo;

  @override
  Widget build(BuildContext context) => FlowScreen(
    title: AppLocalizations.of(context).send,
    builder: (frame) =>
        _SendFlow(frame: frame, walletId: walletId, initialTo: initialTo),
  );
}

enum _Step { form, review, sent }

class _SendFlow extends StatefulWidget {
  const _SendFlow({required this.frame, this.walletId, this.initialTo});

  final FlowFrame frame;
  final String? walletId;
  final String? initialTo;

  @override
  State<_SendFlow> createState() => _SendFlowState();
}

class _SendFlowState extends State<_SendFlow> {
  final _to = TextEditingController();
  final _amount = TextEditingController();
  final _toFocus = FocusNode();
  final _amountFocus = FocusNode();
  final _stepFocus = FocusNode();

  late String? _walletId = widget.walletId;

  /// Send everything is on, which only counts where [_canSendAll].
  var _all = false;
  var _step = _Step.form;
  var _busy = false;

  /// Read from the To field as the user types, null when it cannot be paid.
  Recipient? _typed;
  String? _toError;
  String? _amountError;

  /// Shown above the main button.
  String? _error;

  /// The wallet may have paid, so Lumen offers no retry.
  var _unconfirmed = false;

  // Fixed once the payment is reviewed.
  Recipient? _recipient;
  PayTerms? _terms;

  /// Null for a Lightning address, whose invoice is asked for on sending.
  SendQuote? _quote;
  var _sats = 0;
  Wallet? _payer;
  Payment? _payment;
  Invoice? _paid;
  DateTime? _sentAt;
  StreamSubscription<Transaction>? _confirmation;
  var _confirmed = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialTo case final text?) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fill(text, scanned: true);
      });
    }
  }

  @override
  void dispose() {
    _confirmation?.cancel();
    _to.dispose();
    _amount.dispose();
    _toFocus.dispose();
    _amountFocus.dispose();
    _stepFocus.dispose();
    super.dispose();
  }

  /// The amount set by the typed invoice or link, which the user cannot
  /// change.
  int? get _fixedSats => switch (_typed) {
    InvoiceRecipient(:final invoice) => invoice.sats,
    AddressRecipient(:final address) => address.sats,
    _ => null,
  };

  int get _typedSats => _fixedSats ?? int.tryParse(_amount.text) ?? 0;

  /// Whether [wallet] can send its whole balance to what is typed: an
  /// address that leaves the amount open.
  bool _canSendAll(Wallet wallet) =>
      _typed is AddressRecipient &&
      _fixedSats == null &&
      wallet.capabilities.contains(WalletCapability.payAll);

  /// The wallets that can pay [recipient], or all of them when none can, so
  /// that the picker still shows one while the error says why.
  List<Wallet> _payersOf(Recipient? recipient, WalletsController wallets) {
    if (recipient == null) return wallets.wallets;
    final payers = [
      for (final wallet in wallets.wallets)
        if (_pays(wallet, recipient)) wallet,
    ];
    return payers.isEmpty ? wallets.wallets : payers;
  }

  /// Among the wallets that can pay what is typed: the chosen one, or the
  /// first whose known balance covers the amount, or the one with the most
  /// sats.
  Wallet? _walletIn(WalletsController wallets) {
    final payers = _payersOf(_typed, wallets);
    if (payers.isEmpty) return null;
    if (payers.where((w) => w.id == _walletId).firstOrNull case final chosen?) {
      return chosen;
    }
    int known(Wallet wallet) => wallets.balanceOf(wallet).sats ?? -1;
    final sats = _typedSats;
    return payers.where((wallet) => known(wallet) >= sats).firstOrNull ??
        payers.reduce((a, b) => known(b) > known(a) ? b : a);
  }

  /// Why no wallet can pay [recipient], or null when one can.
  String? _unpayable(Recipient recipient, AppLocalizations l) {
    final wallets = LumenScope.readWallets(context).wallets;
    if (wallets.any((wallet) => _pays(wallet, recipient))) return null;
    return switch (recipient) {
      AddressRecipient(
        address: ChainAddress(network: ChainNetwork.liquidTestnet),
      ) =>
        l.errorWrongNetwork,
      AddressRecipient() => l.errorNoWalletPaysAddress,
      InvoiceRecipient() || LnurlRecipient() => l.errorNoWalletPaysInvoice,
    };
  }

  /// What the To field's hint and errors offer to pay.
  _Pays get _payable => _paysOf(LumenScope.readWallets(context).wallets);

  /// Testnet addresses are read where testnet wallets are enabled.
  Recipient _parse(String text) => parseRecipient(
    text,
    networks: LumenScope.sourcesOf(context).liquid.networks,
  );

  void _onToChanged(String text) {
    Recipient? typed;
    try {
      typed = _parse(text);
    } on RecipientException {
      typed = null;
    }
    setState(() {
      _typed = typed;
      _toError = null;
      _error = null;
    });
  }

  Future<void> _paste() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text?.trim();
    if (!mounted || text == null || text.isEmpty) return;
    _fill(text);
  }

  Future<void> _scan() async {
    final text = await scanQrCode(context);
    if (!mounted || text == null) return;
    _fill(text, scanned: true);
  }

  /// A scanned text is flagged at once, as the user did not see it go in.
  void _fill(String text, {bool scanned = false}) {
    _to.text = text;
    _onToChanged(text);
    final l = AppLocalizations.of(context);
    final typed = _typed;
    final unpayable = typed == null ? null : _unpayable(typed, l);
    if (_fixedSats case final sats?) {
      final kind = typed is AddressRecipient
          ? l.liquidAddress
          : l.lightningInvoice;
      _announce('$kind, ${l.amountSats(formatSats(context, sats))}');
    } else if (scanned && typed == null) {
      try {
        _parse(text);
      } on RecipientException catch (e) {
        _fieldError(to: _recipientMessage(l, e.error, '', _payable));
      }
    } else if (scanned && unpayable != null) {
      _fieldError(to: unpayable);
    } else {
      _amountFocus.requestFocus();
    }
  }

  Future<void> _review() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final payable = _payable;
    final input = _to.text.trim();
    if (input.isEmpty) {
      return _fieldError(
        to: switch (payable) {
          _Pays.lightning => l.errorToEmpty,
          _Pays.liquid => l.errorToEmptyLiquid,
          _Pays.both => l.errorToEmptyAll,
        },
      );
    }

    final Recipient recipient;
    try {
      recipient = _parse(input);
    } on RecipientException catch (e) {
      return _fieldError(to: _recipientMessage(l, e.error, '', payable));
    }
    if (_unpayable(recipient, l) case final error?) {
      return _fieldError(to: error);
    }
    final wallets = LumenScope.readWallets(context);
    final wallet = _walletIn(wallets);
    if (wallet == null) return;
    final all = _all && _canSendAll(wallet);

    // Sending everything learns its amount from the quote.
    var sats = 0;
    switch (recipient) {
      case InvoiceRecipient(:final invoice):
        if (invoice.isExpiredAt(DateTime.now())) {
          return _fieldError(to: l.errorInvoiceExpired);
        }
        sats = invoice.sats;
      case LnurlRecipient():
        sats = int.tryParse(_amount.text) ?? 0;
        if (sats <= 0) return _fieldError(amount: l.errorAmountEmpty);
      case AddressRecipient(:final address) when !all:
        sats = address.sats ?? int.tryParse(_amount.text) ?? 0;
        if (sats <= 0) return _fieldError(amount: l.errorAmountEmpty);
      case AddressRecipient():
    }

    final balance = wallets.balanceOf(wallet).sats;
    if (!all && balance != null && balance < sats) {
      return _showError(
        l.notEnoughSats(wallet.name, formatSats(context, balance)),
      );
    }

    final lnurlPay = LumenScope.sourcesOf(context).lnurlPay;
    final onChain = recipient is AddressRecipient;
    setState(() {
      _busy = true;
      _error = null;
    });
    PayTerms? terms;
    SendQuote? quote;
    String? error;
    try {
      switch (recipient) {
        case LnurlRecipient():
          terms = await lnurlPay.terms(recipient);
        case InvoiceRecipient(:final invoice):
          quote = await wallet.prepareSend(invoice);
        case AddressRecipient(:final address) when all:
          quote = await wallet.prepareSendAll(address);
        case AddressRecipient(:final address):
          quote = await wallet.prepareSend(address, sats: sats);
      }
    } on RecipientException catch (e) {
      error = _recipientMessage(l, e.error, _label(recipient), payable);
    } on SendException catch (e) {
      error = _sendMessage(l, e.error, wallet.name, onChain: onChain);
    } catch (_) {
      error = _sendMessage(l, SendError.failed, wallet.name, onChain: onChain);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) return _showError(error);
    if (recipient case LnurlRecipient(:final label)
        when !terms!.accepts(sats)) {
      return _fieldError(
        amount: l.errorAmountRange(
          label,
          formatSats(context, terms.minSats),
          formatSats(context, terms.maxSats),
        ),
      );
    }

    setState(() {
      _recipient = recipient;
      _terms = terms;
      _quote = quote;
      _sats = quote?.sats ?? sats;
      _payer = wallet;
      _error = null;
      _step = _Step.review;
    });
    _focusStep();
  }

  Future<void> _send() async {
    final recipient = _recipient;
    final wallet = _payer;
    if (_busy || recipient == null || wallet == null) return;
    final l = AppLocalizations.of(context);
    final lnurlPay = LumenScope.sourcesOf(context).lnurlPay;
    final wallets = LumenScope.readWallets(context);
    final payable = _payable;
    final onChain = recipient is AddressRecipient;
    setState(() {
      _busy = true;
      _error = null;
    });

    String? error;
    var attempted = false;
    try {
      final quote =
          _quote ??
          await wallet.prepareSend(await lnurlPay.invoice(_terms!, _sats));
      final request = quote.request;
      if (request is Invoice && request.isExpiredAt(DateTime.now())) {
        error = l.errorInvoiceExpired;
      } else {
        attempted = true;
        _payment = await wallet.confirmSend(quote);
        _paid = request is Invoice ? request : null;
        _sentAt = DateTime.now();
      }
    } on RecipientException catch (e) {
      error = _recipientMessage(l, e.error, _label(recipient), payable);
    } on SendException catch (e) {
      error = _sendMessage(l, e.error, wallet.name, onChain: onChain);
      _unconfirmed = e.error == SendError.unconfirmed;
    } catch (_) {
      error = _sendMessage(
        l,
        SendError.unconfirmed,
        wallet.name,
        onChain: onChain,
      );
      _unconfirmed = true;
    }
    if (attempted) wallets.refresh(wallet);
    if (!mounted) return;

    setState(() {
      _busy = false;
      _error = error;
      if (error == null) _step = _Step.sent;
    });
    if (error != null) {
      _unconfirmed
          ? HapticFeedback.warningNotification()
          : HapticFeedback.errorNotification();
      _announce(error, assertive: true);
    } else {
      HapticFeedback.successNotification();
      _announce(l.sentAnnouncement(formatSats(context, _sats), wallet.name));
      _focusStep();
      if (_payment?.txid case final txid?) {
        _confirmation = wallet
            .watchConfirmation(txid)
            .listen((_) => _onConfirmed(wallet));
      }
    }
  }

  void _onConfirmed(Wallet wallet) {
    if (!mounted) return;
    setState(() => _confirmed = true);
    LumenScope.readWallets(context).refresh(wallet);
    _announce(AppLocalizations.of(context).paymentConfirmedAnnouncement);
  }

  void _edit() {
    setState(() {
      _step = _Step.form;
      _error = null;
    });
    final field = _fixedSats == null && !_all ? _amountFocus : _toFocus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) field.requestFocus();
    });
  }

  void _fieldError({String? to, String? amount}) {
    setState(() {
      _toError = to;
      _amountError = amount;
    });
    _announce((to ?? amount)!, assertive: true);
    (to != null ? _toFocus : _amountFocus).requestFocus();
  }

  void _showError(String message) {
    setState(() => _error = message);
    _announce(message, assertive: true);
  }

  /// The previous content is gone, so focus what replaced it.
  void _focusStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _stepFocus.requestFocus();
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
    final wallet = _step == _Step.form ? _walletIn(wallets) : _payer;
    final recipient = _recipient;
    if (wallet == null) return const SizedBox.shrink();

    return PopScope(
      // Closing mid-payment would hide how it ended.
      canPop: !(_busy && _step == _Step.review),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_step == _Step.sent)
            widget.frame.headerWith(
              action: Builder(
                builder: (button) => IconButton(
                  tooltip: AppLocalizations.of(context).shareReceipt,
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () => shareText(button, _receipt(recipient!)),
                ),
              ),
            )
          else
            widget.frame.header,
          const SizedBox(height: 20),
          ...switch (_step) {
            _Step.form => _form(wallets, wallet),
            _Step.review => _reviewView(recipient!, wallet),
            _Step.sent => _sentView(recipient!, wallet),
          },
        ],
      ),
    );
  }

  List<Widget> _form(WalletsController wallets, Wallet wallet) {
    final l = AppLocalizations.of(context);
    final fixedSats = _fixedSats;
    return [
      LabeledField(
        label: l.sendTo,
        child: TextField(
          controller: _to,
          focusNode: _toFocus,
          keyboardType: TextInputType.url,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: fixedSats == null
              ? TextInputAction.next
              : TextInputAction.done,
          onChanged: _onToChanged,
          onSubmitted: (_) =>
              fixedSats == null ? _amountFocus.requestFocus() : _review(),
          decoration: InputDecoration(
            helperText: switch (_paysOf(wallets.wallets)) {
              _Pays.lightning => l.sendToHint,
              _Pays.liquid => l.sendToHintLiquid,
              _Pays.both => l.sendToHintAll,
            },
            helperMaxLines: 2,
            errorText: _toError,
            errorMaxLines: 4,
          ),
        ),
      ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
          spacing: 8,
          children: [
            TextButton.icon(
              onPressed: _busy ? null : _paste,
              icon: const Icon(Icons.content_paste),
              label: Text(l.paste),
            ),
            if (canScanQrCodes)
              TextButton.icon(
                onPressed: _busy ? null : _scan,
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l.scan, semanticsLabel: l.scanQrCode),
              ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      switch (_typed) {
        InvoiceRecipient(:final invoice) => _FixedAmount(
          label: l.amountSetByInvoice,
          sats: invoice.sats,
          description: invoice.description,
        ),
        AddressRecipient(address: ChainAddress(:final sats?)) => _FixedAmount(
          label: l.amountSetByLink,
          sats: sats,
        ),
        _ when _all && _canSendAll(wallet) => const SizedBox.shrink(),
        _ => _amountField(l),
      },
      if (_canSendAll(wallet)) ...[
        const SizedBox(height: 8),
        SwitchRow(
          title: l.sendEverything,
          hint: l.sendEverythingHint(wallet.name),
          value: _all,
          onChanged: () => setState(() {
            _all = !_all;
            _amountError = null;
            _error = null;
          }),
        ),
      ],
      const SizedBox(height: 20),
      WalletPicker(
        label: l.payFrom,
        hint: l.chooseWalletThatPays,
        showBalance: true,
        selected: wallet,
        wallets: _payersOf(_typed, wallets),
        enabled: !_busy,
        onChanged: (id) => setState(() {
          _walletId = id;
          _error = null;
        }),
      ),
      if (_error case final error?) ...[
        const SizedBox(height: 16),
        ErrorNote(error),
      ],
      widget.frame.bottomGap,
      FilledButton(
        onPressed: _busy ? null : _review,
        child: Text(_busy ? l.checkingPayment : l.reviewPayment),
      ),
    ];
  }

  Widget _amountField(AppLocalizations l) {
    return LabeledField(
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
        onSubmitted: (_) => _review(),
        onChanged: (_) => setState(() {
          _amountError = null;
          _error = null;
        }),
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
          errorText: _amountError,
          errorMaxLines: 4,
        ),
      ),
    );
  }

  List<Widget> _reviewView(Recipient recipient, Wallet wallet) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final note = switch (recipient) {
      InvoiceRecipient(:final invoice) => invoice.description,
      LnurlRecipient() || AddressRecipient() => null,
    };
    return [
      const SizedBox(height: 8),
      Focus(
        focusNode: _stepFocus,
        child: MergeSemantics(
          child: Column(
            children: [
              Semantics(
                header: true,
                child: Text(
                  l.youAreSending,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: c.text2),
                ),
              ),
              const SizedBox(height: 8),
              Center(child: AmountText(_sats, fontSize: 44)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      DetailsCard([
        (l.detailTo, _RecipientText(recipient)),
        if (note != null) (l.detailNote, Text(note)),
        (l.detailFrom, Text(wallet.name)),
        (
          l.detailNetwork,
          Text(recipient is AddressRecipient ? l.kindLiquid : l.kindLightning),
        ),
        if (_quote?.feeSats case final fee?)
          (l.detailFee, Text(l.amountSats(formatSats(context, fee)))),
      ]),
      if (_error case final error?) ...[
        const SizedBox(height: 16),
        ErrorNote(error),
      ],
      widget.frame.bottomGap,
      if (_unconfirmed)
        FilledButton(
          onPressed: widget.frame.onDone,
          style: quietButtonStyle(context),
          child: Text(l.done),
        )
      else ...[
        FilledButton(
          onPressed: _busy ? null : _send,
          child: Text(
            _busy ? l.sendingPayment : l.sendAmount(formatSats(context, _sats)),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _busy ? null : _edit, child: Text(l.editPayment)),
      ],
    ];
  }

  List<Widget> _sentView(Recipient recipient, Wallet wallet) {
    final l = AppLocalizations.of(context);
    final subtitle = switch (recipient) {
      LnurlRecipient(:final label) => l.sentTo(label),
      InvoiceRecipient(:final invoice) => invoice.description,
      AddressRecipient() => null,
    };
    return [
      const SizedBox(height: 16),
      const SuccessMark(),
      const SizedBox(height: 16),
      Focus(
        focusNode: _stepFocus,
        child: Semantics(
          header: true,
          child: Text(
            l.paymentSent,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Center(child: AmountText(_sats, fontSize: 44)),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: LumenColors.of(context).text2),
        ),
      ],
      if (_payment?.txid != null) ...[
        const SizedBox(height: 20),
        if (_confirmed)
          StatusLine(
            icon: Icons.check_circle_outline,
            title: l.paymentConfirmed,
          )
        else
          StatusLine(
            icon: Icons.schedule,
            title: l.waitingForConfirmation,
            detail: l.confirmsSoon,
          ),
      ],
      const SizedBox(height: 24),
      DetailsCard([
        if (_sentAt case final at?)
          (l.detailDate, Text(formatDateTime(context, at))),
        (l.detailFrom, Text(wallet.name)),
        if (_payment case final payment?)
          (
            l.detailFeePaid,
            Text(l.amountSats(formatSats(context, payment.feeSats))),
          ),
        if (_paid?.paymentHash case final hash?)
          (
            l.detailPaymentHash,
            CopyableValue(
              hash,
              tooltip: l.copyPaymentHash,
              copied: l.paymentHashCopied,
            ),
          ),
        if (_payment?.txid case final txid?)
          (
            l.detailTxid,
            CopyableValue(txid, tooltip: l.copyTxid, copied: l.txidCopied),
          ),
      ]),
      widget.frame.bottomGap,
      FilledButton(
        onPressed: widget.frame.onDone,
        style: quietButtonStyle(context),
        child: Text(l.done),
      ),
    ];
  }

  /// A plain text receipt, without the wallet name, which is private.
  String _receipt(Recipient recipient) {
    final l = AppLocalizations.of(context);
    final to = switch (recipient) {
      LnurlRecipient(:final label) => l.sentTo(label),
      InvoiceRecipient(:final invoice) => invoice.description,
      AddressRecipient() => null,
    };
    return [
      l.paymentSent,
      l.amountSats(formatSats(context, _sats)),
      ?to,
      if (_sentAt case final at?)
        l.receiptLine(l.detailDate, formatDateTime(context, at)),
      if (_payment case final payment?)
        l.receiptLine(
          l.detailFeePaid,
          l.amountSats(formatSats(context, payment.feeSats)),
        ),
      if (_paid?.paymentHash case final hash?)
        l.receiptLine(l.detailPaymentHash, hash),
      if (_payment?.txid case final txid?) l.receiptLine(l.detailTxid, txid),
      if (_payment?.preimage case final preimage? when preimage.isNotEmpty)
        l.receiptLine(l.receiptPreimage, preimage),
    ].join('\n');
  }
}

/// Whether [wallet] can pay [recipient]: an invoice, or an address on the
/// wallet's own network.
bool _pays(Wallet wallet, Recipient recipient) => switch (recipient) {
  AddressRecipient(:final address) =>
    wallet.capabilities.contains(WalletCapability.payAddress) &&
        wallet.network == address.network,
  InvoiceRecipient() ||
  LnurlRecipient() => wallet.capabilities.contains(WalletCapability.payInvoice),
};

/// What the user's wallets can pay, all networks together.
enum _Pays { lightning, liquid, both }

_Pays _paysOf(List<Wallet> wallets) {
  bool any(WalletCapability capability) =>
      wallets.any((wallet) => wallet.capabilities.contains(capability));
  if (!any(WalletCapability.payAddress)) return _Pays.lightning;
  return any(WalletCapability.payInvoice) ? _Pays.both : _Pays.liquid;
}

String _label(Recipient recipient) => switch (recipient) {
  LnurlRecipient(:final label) => label,
  InvoiceRecipient() || AddressRecipient() => '',
};

String _recipientMessage(
  AppLocalizations l,
  RecipientError error,
  String label,
  _Pays payable,
) => switch (error) {
  RecipientError.unrecognized => switch (payable) {
    _Pays.lightning => l.errorToUnrecognized,
    _Pays.liquid => l.errorToUnrecognizedLiquid,
    _Pays.both => l.errorToUnrecognizedAll,
  },
  RecipientError.invoiceWithoutAmount => l.errorInvoiceNoAmount,
  RecipientError.unreachable => l.recipientUnreachable(label),
  RecipientError.refused => l.recipientRefused(label),
  RecipientError.wrongInvoice => l.recipientWrongInvoice(label),
  RecipientError.wrongNetwork => l.errorWrongNetwork,
  RecipientError.unsupportedAsset => l.errorUnsupportedAsset,
};

/// [onChain] for a payment to an address, which a chain server relays.
String _sendMessage(
  AppLocalizations l,
  SendError error,
  String name, {
  bool onChain = false,
}) => switch (error) {
  SendError.unreachable when onChain => l.sendChainUnreachable,
  SendError.failed when onChain => l.sendChainFailed,
  SendError.unconfirmed when onChain => l.sendChainUnconfirmed(name),
  SendError.unreachable => l.sendUnreachable(name),
  SendError.noPermission => l.sendNoPermission,
  SendError.insufficientBalance => l.sendInsufficientBalance(name),
  SendError.budgetExceeded => l.sendBudgetExceeded,
  SendError.failed => l.sendFailed,
  SendError.unconfirmed => l.sendUnconfirmed(name),
  SendError.wrongNetwork => l.errorWrongNetwork,
};

/// The amount set by a pasted invoice or link, in place of the amount field.
class _FixedAmount extends StatelessWidget {
  const _FixedAmount({
    required this.label,
    required this.sats,
    this.description,
  });

  final String label;
  final int sats;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          AmountText(sats, fontSize: 32),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: LumenColors.of(context).text2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipientText extends StatelessWidget {
  const _RecipientText(this.recipient);

  final Recipient recipient;

  @override
  Widget build(BuildContext context) {
    return switch (recipient) {
      LnurlRecipient(:final label) => Text(label),
      InvoiceRecipient(:final invoice) => Text(
        shortInvoice(invoice.request),
        semanticsLabel: AppLocalizations.of(context).lightningInvoice,
        style: const TextStyle(fontFamily: monoFamily, fontSize: 13),
      ),
      // Whole, in columns, so it can be checked against the recipient's copy.
      AddressRecipient(:final address) => GroupedAddress(
        address.address,
        style: const TextStyle(fontSize: 13),
        textAlign: TextAlign.start,
      ),
    };
  }
}
