import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
import '../widgets/screen_parts.dart';
import '../widgets/share_text.dart';
import '../widgets/wallet_picker.dart';

Future<void> openSend(BuildContext context, {Wallet? wallet}) => openFlow(
  context,
  location: wallet == null ? '/send' : '/send?wallet=${wallet.id}',
  title: AppLocalizations.of(context).send,
  builder: (frame) => _SendFlow(frame: frame, walletId: wallet?.id),
);

class SendScreen extends StatelessWidget {
  const SendScreen({super.key, this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context) => FlowScreen(
    title: AppLocalizations.of(context).send,
    builder: (frame) => _SendFlow(frame: frame, walletId: walletId),
  );
}

enum _Step { form, review, sent }

class _SendFlow extends StatefulWidget {
  const _SendFlow({required this.frame, this.walletId});

  final FlowFrame frame;
  final String? walletId;

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
  void dispose() {
    _to.dispose();
    _amount.dispose();
    _toFocus.dispose();
    _amountFocus.dispose();
    _stepFocus.dispose();
    super.dispose();
  }

  Invoice? get _typedInvoice => switch (_typed) {
    InvoiceRecipient(:final invoice) => invoice,
    _ => null,
  };

  int get _typedSats => _typedInvoice?.sats ?? int.tryParse(_amount.text) ?? 0;

  /// The chosen wallet, or the first whose known balance covers the amount,
  /// or the one with the most sats.
  Wallet? _walletIn(WalletsController wallets) {
    if (wallets.walletById(_walletId ?? '') case final chosen?) return chosen;
    final all = wallets.wallets;
    if (all.isEmpty) return null;
    int known(Wallet wallet) => wallets.balanceOf(wallet).sats ?? -1;
    final sats = _typedSats;
    return all.where((wallet) => known(wallet) >= sats).firstOrNull ??
        all.reduce((a, b) => known(b) > known(a) ? b : a);
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
    _to.text = text;
    _onToChanged(text);
    if (_typedInvoice case final invoice?) {
      final l = AppLocalizations.of(context);
      _announce(
        '${l.lightningInvoice}, ${l.amountSats(formatSats(context, invoice.sats))}',
      );
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
      final invoice = switch (recipient) {
        InvoiceRecipient(:final invoice) => invoice,
        LnurlRecipient() => await lnurlPay.invoice(_terms!, _sats),
      };
      if (invoice.isExpiredAt(DateTime.now())) {
        error = l.errorInvoiceExpired;
      } else {
        attempted = true;
        _payment = await wallet.payInvoice(invoice);
        _paid = invoice;
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
      _announce(error, assertive: true);
    } else {
      _announce(l.sentAnnouncement(formatSats(context, _sats), wallet.name));
      _focusStep();
    }
  }

  void _edit() {
    setState(() {
      _step = _Step.form;
      _error = null;
    });
    final field = _typedInvoice == null ? _amountFocus : _toFocus;
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
    final invoice = _typedInvoice;
    return [
      LabeledField(
        label: l.sendTo,
        child: TextField(
          controller: _to,
          focusNode: _toFocus,
          keyboardType: TextInputType.url,
          autocorrect: false,
          enableSuggestions: false,
          textInputAction: invoice == null
              ? TextInputAction.next
              : TextInputAction.done,
          onChanged: _onToChanged,
          onSubmitted: (_) =>
              invoice == null ? _amountFocus.requestFocus() : _review(),
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
        child: TextButton.icon(
          onPressed: _busy ? null : _paste,
          icon: const Icon(Icons.content_paste),
          label: Text(l.paste),
        ),
      ),
      const SizedBox(height: 12),
      if (invoice != null) _InvoiceAmount(invoice) else _amountField(l),
      const SizedBox(height: 20),
      WalletPicker(
        label: l.payFrom,
        hint: l.chooseWalletThatPays,
        showBalance: true,
        selected: wallet,
        wallets: wallets.wallets,
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
      LnurlRecipient() => null,
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
      _Details([
        (l.detailTo, _RecipientText(recipient)),
        if (note != null) (l.detailNote, Text(note)),
        (l.detailFrom, Text(wallet.name)),
        (l.detailNetwork, Text(l.kindLightning)),
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
      _Details([
        if (_sentAt case final at?) (l.detailDate, Text(_formatSentAt(at))),
        (l.detailFrom, Text(wallet.name)),
        if (_payment case final payment?)
          (
            l.detailFeePaid,
            Text(l.amountSats(formatSats(context, payment.feeSats))),
          ),
        if (_paid?.paymentHash case final hash?)
          (l.detailPaymentHash, _PaymentHash(hash)),
      ]),
      widget.frame.bottomGap,
      FilledButton(
        onPressed: widget.frame.onDone,
        style: quietButtonStyle(context),
        child: Text(l.done),
      ),
    ];
  }

  String _formatSentAt(DateTime at) {
    final locale = AppLocalizations.of(context).localeName;
    return DateFormat.yMMMd(locale).add_jm().format(at);
  }

  /// A plain text receipt, without the wallet name, which is private.
  String _receipt(Recipient recipient) {
    final l = AppLocalizations.of(context);
    final to = switch (recipient) {
      LnurlRecipient(:final label) => l.sentTo(label),
      InvoiceRecipient(:final invoice) => invoice.description,
    };
    return [
      l.paymentSent,
      l.amountSats(formatSats(context, _sats)),
      ?to,
      if (_sentAt case final at?)
        l.receiptLine(l.detailDate, _formatSentAt(at)),
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

String _label(Recipient recipient) => switch (recipient) {
  LnurlRecipient(:final label) => label,
  InvoiceRecipient() => '',
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

/// The fixed amount of a pasted invoice, in place of the amount field.
class _InvoiceAmount extends StatelessWidget {
  const _InvoiceAmount(this.invoice);

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final description = invoice.description;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.amountSetByInvoice,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          AmountText(invoice.sats, fontSize: 32),
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
    };
  }
}

/// The start and end of the hash, and a button that copies all of it.
class _PaymentHash extends StatelessWidget {
  const _PaymentHash(this.hash);

  final String hash;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final short = hash.length > 12
        ? '${hash.substring(0, 4)}...${hash.substring(hash.length - 4)}'
        : hash;
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          short,
          style: const TextStyle(fontFamily: monoFamily, fontSize: 13),
        ),
        CopyButton(
          text: hash,
          tooltip: l.copyPaymentHash,
          copied: l.paymentHashCopied,
        ),
      ],
    );
  }
}

/// Label and value rows, each read as one item. From 150% text, the label
/// goes above its value so neither is squeezed.
class _Details extends StatelessWidget {
  const _Details(this.rows);

  final List<(String, Widget)> rows;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    final stacked = MediaQuery.textScalerOf(context).scale(10) >= 15;
    final valueStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: c.text,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            for (final (i, (label, value)) in rows.indexed) ...[
              if (i > 0) Divider(height: 1, color: c.surface3),
              MergeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Flex(
                    direction: stacked ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(fontSize: 15, color: c.text2),
                      ),
                      SizedBox(width: 16, height: stacked ? 4 : 0),
                      if (stacked)
                        DefaultTextStyle.merge(style: valueStyle, child: value)
                      else
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.topEnd,
                            child: DefaultTextStyle.merge(
                              textAlign: TextAlign.end,
                              style: valueStyle,
                              child: value,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
