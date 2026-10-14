import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import '../wallets/lumen_scope.dart';
import '../wallets/wallets_controller.dart';
import '../widgets/amount.dart';
import '../widgets/qr_code_view.dart';
import '../widgets/screen_parts.dart';
import '../widgets/tappable.dart';
import '../widgets/wallet_kind_style.dart';

/// Full screen on phones, a dialog over the current page on larger screens.
Future<void> openReceive(BuildContext context, {Wallet? wallet}) async {
  if (LayoutSize.of(context) == LayoutSize.phone) {
    await context.push(
      wallet == null ? '/receive' : '/receive?wallet=${wallet.id}',
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (_) => _ReceiveDialog(walletId: wallet?.id),
  );
}

class ReceiveScreen extends StatelessWidget {
  const ReceiveScreen({super.key, this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: FillScroll(
          padding: LayoutSize.of(context).screenPadding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: _ReceiveFlow(
                walletId: walletId,
                expand: true,
                header: hasSidebar(context)
                    ? PageTitle(l.receive)
                    : TopBar(title: l.receive),
                onDone: () =>
                    context.canPop() ? context.pop() : context.go('/'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiveDialog extends StatelessWidget {
  const _ReceiveDialog({this.walletId});

  final String? walletId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: _ReceiveFlow(
            walletId: walletId,
            header: Row(
              children: [
                const SizedBox(width: 48),
                const SizedBox(width: 8),
                Expanded(
                  child: ScreenTitle(
                    child: Text(
                      l.receive,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: l.close,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            onDone: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}

class _ReceiveFlow extends StatefulWidget {
  const _ReceiveFlow({
    required this.header,
    required this.onDone,
    this.walletId,
    this.expand = false,
  });

  final Widget header;
  final VoidCallback onDone;
  final String? walletId;

  /// Fills the screen height to keep the main button at the bottom.
  final bool expand;

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
        _WalletPicker(
          selected: wallet,
          wallets: wallets.wallets,
          enabled: !_creating,
          onChanged: _chooseWallet,
        ),
        const SizedBox(height: 20),
        ...switch (invoice) {
          null => _amountForm(),
          _ when _expired => _expiredView(),
          _ => _invoiceView(invoice),
        },
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [widget.header, const SizedBox(height: 20), ...body],
    );
  }

  Widget get _bottomGap =>
      widget.expand ? const Spacer() : const SizedBox(height: 28);

  List<Widget> _amountForm() {
    final l = AppLocalizations.of(context);
    return [
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
        _ErrorNote(error.message(l)),
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
      Focus(focusNode: _resultFocus, child: _ErrorNote(l.invoiceExpired)),
      _bottomGap,
      FilledButton(
        onPressed: _creating ? null : _create,
        child: Text(l.newInvoice),
      ),
    ];
  }

  List<Widget> _paidView(Invoice invoice, Wallet wallet) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    return [
      const SizedBox(height: 16),
      Center(
        child: ExcludeSemantics(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.positive.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, size: 36, color: c.positive),
          ),
        ),
      ),
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
        style: TextStyle(fontSize: 15, color: c.text2),
      ),
      _bottomGap,
      FilledButton(
        onPressed: widget.onDone,
        style: FilledButton.styleFrom(
          backgroundColor: c.surface2,
          foregroundColor: c.text,
        ),
        child: Text(l.done),
      ),
    ];
  }
}

class _WalletPicker extends StatefulWidget {
  const _WalletPicker({
    required this.selected,
    required this.wallets,
    required this.enabled,
    required this.onChanged,
  });

  final Wallet selected;
  final List<Wallet> wallets;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<_WalletPicker> createState() => _WalletPickerState();
}

class _WalletPickerState extends State<_WalletPicker> {
  /// The menu matches the picker's width, measured when it opens.
  var _width = 0.0;
  final _selectedItem = FocusNode();
  final _picker = FocusNode();

  @override
  void dispose() {
    _selectedItem.dispose();
    _picker.dispose();
    super.dispose();
  }

  void _toggle(MenuController controller) {
    if (!widget.enabled) return;
    if (controller.isOpen) return controller.close();
    setState(() => _width = context.size?.width ?? 0);
    controller.open();
    // Inside the menu, Escape closes only the menu, not the dialog under it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _selectedItem.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final selected = widget.selected;
    final wallets = widget.wallets;
    final canChoose = wallets.length > 1;
    final radius = BorderRadius.circular(18);
    final content = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            SourceBadge(selected.kind),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.receiveInto,
                    style: TextStyle(fontSize: 13, color: c.text2),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selected.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (canChoose) ...[
              const SizedBox(width: 8),
              Icon(Icons.unfold_more, color: c.text3),
            ],
          ],
        ),
      ),
    );

    if (!canChoose) {
      return MergeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(color: c.surface2, borderRadius: radius),
          child: content,
        ),
      );
    }
    final balances = LumenScope.walletsOf(context);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      onClose: _picker.requestFocus,
      style: MenuStyle(
        minimumSize: WidgetStatePropertyAll(Size(_width, 0)),
        maximumSize: WidgetStatePropertyAll(Size(_width, double.infinity)),
      ),
      menuChildren: [
        for (final wallet in wallets)
          MenuItemButton(
            focusNode: wallet.id == selected.id ? _selectedItem : null,
            onPressed: () => widget.onChanged(wallet.id),
            child: Semantics(
              selected: wallet.id == selected.id,
              child: SizedBox(
                // Minus the menu's padding and the item's.
                width: _width - 32,
                child: Row(
                  children: [
                    SourceBadge(wallet.kind, size: BadgeSize.small),
                    const SizedBox(width: 12),
                    Expanded(child: Text(wallet.name)),
                    const SizedBox(width: 12),
                    BalanceValue(balances.balanceOf(wallet)),
                    const SizedBox(width: 12),
                    SizedBox.square(
                      dimension: 18,
                      child: wallet.id == selected.id
                          ? Icon(Icons.check, size: 18, color: c.text)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
      builder: (context, controller, _) => MergeSemantics(
        child: Semantics(
          hint: l.chooseWallet,
          child: Material(
            color: c.surface2,
            borderRadius: radius,
            child: Tappable(
              borderRadius: 18,
              focusNode: _picker,
              onTap: () => _toggle(controller),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _CopyLine extends StatefulWidget {
  const _CopyLine(this.request);

  final String request;

  @override
  State<_CopyLine> createState() => _CopyLineState();
}

class _CopyLineState extends State<_CopyLine> {
  var _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  String get _short {
    final request = widget.request;
    if (request.length <= 32) return request;
    return '${request.substring(0, 24)}...${request.substring(request.length - 4)}';
  }

  Future<void> _copy() async {
    final l = AppLocalizations.of(context);
    final view = View.of(context);
    final direction = Directionality.of(context);
    await Clipboard.setData(ClipboardData(text: widget.request));
    SemanticsService.sendAnnouncement(view, l.invoiceCopied, direction);
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _share(BuildContext buttonContext) {
    final box = buttonContext.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: widget.request,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

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
          IconButton(
            tooltip: l.copyInvoice,
            style: raised,
            icon: Icon(_copied ? Icons.check : Icons.content_copy_outlined),
            onPressed: _copy,
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: l.shareInvoice,
              style: raised,
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _share(buttonContext),
            ),
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

class _ErrorNote extends StatelessWidget {
  const _ErrorNote(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.error_outline, size: 18, color: c.danger),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(fontSize: 15, height: 1.4, color: c.danger),
          ),
        ),
      ],
    );
  }
}

extension on ReceiveError {
  String message(AppLocalizations l) => switch (this) {
    ReceiveError.unreachable => l.receiveUnreachable,
    ReceiveError.noPermission => l.receiveNoPermission,
  };
}
