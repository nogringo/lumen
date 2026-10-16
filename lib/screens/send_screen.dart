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
  var _sats = 0;
  Wallet? _payer;
  Payment? _payment;
  Invoice? _paid;
  DateTime? _sentAt;

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

  /// The wallets that can pay [recipient], or all of them when none can, so
  /// that the picker still shows one while the error says why.
  List<Wallet> _payersOf(Recipient? recipient, WalletsController wallets) {
    final needed = _neededFor(recipient);
    if (needed == null) return wallets.wallets;
    final payers = [
      for (final wallet in wallets.wallets)
        if (wallet.capabilities.contains(needed)) wallet,
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
    final needed = _neededFor(recipient)!;
    final wallets = LumenScope.readWallets(context).wallets;
    if (wallets.any((wallet) => wallet.capabilities.contains(needed))) {
      return null;
    }
    return switch (needed) {
      WalletCapability.payAddress => l.errorNoWalletPaysAddress,
      _ => l.errorNoWalletPaysInvoice,
    };
  }

  void _onToChanged(String text) {
    Recipient? typed;
    try {
      typed = parseRecipient(text);
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
        parseRecipient(text);
      } on RecipientException catch (e) {
        _fieldError(to: _recipientMessage(l, e.error, ''));
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
    final input = _to.text.trim();
    if (input.isEmpty) return _fieldError(to: l.errorToEmpty);

    final Recipient recipient;
    try {
      recipient = parseRecipient(input);
    } on RecipientException catch (e) {
      return _fieldError(to: _recipientMessage(l, e.error, ''));
    }
    if (_unpayable(recipient, l) case final error?) {
      return _fieldError(to: error);
    }
    final int sats;
    switch (recipient) {
      case InvoiceRecipient(:final invoice):
        if (invoice.isExpiredAt(DateTime.now())) {
          return _fieldError(to: l.errorInvoiceExpired);
        }
        sats = invoice.sats;
      case LnurlRecipient():
        sats = int.tryParse(_amount.text) ?? 0;
        if (sats <= 0) return _fieldError(amount: l.errorAmountEmpty);
      case AddressRecipient(:final address):
        sats = address.sats ?? int.tryParse(_amount.text) ?? 0;
        if (sats <= 0) return _fieldError(amount: l.errorAmountEmpty);
    }

    final wallets = LumenScope.readWallets(context);
    final wallet = _walletIn(wallets);
    if (wallet == null) return;
    final balance = wallets.balanceOf(wallet).sats;
    if (balance != null && balance < sats) {
      return _showError(
        l.notEnoughSats(wallet.name, formatSats(context, balance)),
      );
    }

    PayTerms? terms;
    if (recipient is LnurlRecipient) {
      final lnurlPay = LumenScope.sourcesOf(context).lnurlPay;
      setState(() {
        _busy = true;
        _error = null;
      });
      try {
        terms = await lnurlPay.terms(recipient);
      } on RecipientException catch (e) {
        if (!mounted) return;
        setState(() => _busy = false);
        return _showError(_recipientMessage(l, e.error, recipient.label));
      }
      if (!mounted) return;
      setState(() => _busy = false);
      if (!terms.accepts(sats)) {
        return _fieldError(
          amount: l.errorAmountRange(
            recipient.label,
            formatSats(context, terms.minSats),
            formatSats(context, terms.maxSats),
          ),
        );
      }
    }

    setState(() {
      _recipient = recipient;
      _terms = terms;
      _sats = sats;
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
    setState(() {
      _busy = true;
      _error = null;
    });

    String? error;
    var attempted = false;
    try {
      final PaymentRequest request = switch (recipient) {
        InvoiceRecipient(:final invoice) => invoice,
        LnurlRecipient() => await lnurlPay.invoice(_terms!, _sats),
        AddressRecipient(:final address) => address,
      };
      if (request is Invoice && request.isExpiredAt(DateTime.now())) {
        error = l.errorInvoiceExpired;
      } else {
        final quote = await wallet.prepareSend(request, sats: _sats);
        attempted = true;
        _payment = await wallet.confirmSend(quote);
        _paid = request is Invoice ? request : null;
        _sentAt = DateTime.now();
      }
    } on RecipientException catch (e) {
      error = _recipientMessage(l, e.error, _label(recipient));
    } on SendException catch (e) {
      error = _sendMessage(l, e.error, wallet.name);
      _unconfirmed = e.error == SendError.unconfirmed;
    } catch (_) {
      error = l.sendUnconfirmed(wallet.name);
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
    }
  }

  void _edit() {
    setState(() {
      _step = _Step.form;
      _error = null;
    });
    final field = _fixedSats == null ? _amountFocus : _toFocus;
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
            helperText: l.sendToHint,
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
        _ => _amountField(l),
      },
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
      if (_payment?.preimage case final preimage? when preimage.isNotEmpty)
        l.receiptLine(l.receiptPreimage, preimage),
    ].join('\n');
  }
}

/// What a wallet must do to pay [recipient], or null before one is typed.
WalletCapability? _neededFor(Recipient? recipient) => switch (recipient) {
  null => null,
  AddressRecipient() => WalletCapability.payAddress,
  InvoiceRecipient() || LnurlRecipient() => WalletCapability.payInvoice,
};

String _label(Recipient recipient) => switch (recipient) {
  LnurlRecipient(:final label) => label,
  InvoiceRecipient() || AddressRecipient() => '',
};

String _recipientMessage(
  AppLocalizations l,
  RecipientError error,
  String label,
) => switch (error) {
  RecipientError.unrecognized => l.errorToUnrecognized,
  RecipientError.invoiceWithoutAmount => l.errorInvoiceNoAmount,
  RecipientError.unreachable => l.recipientUnreachable(label),
  RecipientError.refused => l.recipientRefused(label),
  RecipientError.wrongInvoice => l.recipientWrongInvoice(label),
  RecipientError.wrongNetwork => l.errorWrongNetwork,
  RecipientError.unsupportedAsset => l.errorUnsupportedAsset,
};

String _sendMessage(AppLocalizations l, SendError error, String name) =>
    switch (error) {
      SendError.unreachable => l.sendUnreachable(name),
      SendError.noPermission => l.sendNoPermission,
      SendError.insufficientBalance => l.sendInsufficientBalance(name),
      SendError.budgetExceeded => l.sendBudgetExceeded,
      SendError.failed => l.sendFailed,
      SendError.unconfirmed => l.sendUnconfirmed(name),
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
      AddressRecipient(:final address) => Text(
        shortInvoice(address.address),
        semanticsLabel: AppLocalizations.of(context).liquidAddress,
        style: const TextStyle(fontFamily: monoFamily, fontSize: 13),
      ),
    };
  }
}
