import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/lumen_colors.dart';
import '../wallets/lumen_scope.dart';
import 'amount.dart';
import 'tappable.dart';
import 'wallet_kind_style.dart';

/// The wallet a payment goes into or out of, with a menu to pick another.
class WalletPicker extends StatefulWidget {
  const WalletPicker({
    super.key,
    required this.label,
    required this.hint,
    required this.selected,
    required this.wallets,
    required this.enabled,
    required this.onChanged,
    this.showBalance = false,
  });

  /// Above the wallet name, such as "Into".
  final String label;

  /// Read by screen readers, such as "Choose the wallet that receives".
  final String hint;
  final bool showBalance;
  final Wallet selected;
  final List<Wallet> wallets;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  State<WalletPicker> createState() => WalletPickerState();
}

class WalletPickerState extends State<WalletPicker> {
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
                    widget.label,
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
            if (widget.showBalance) ...[
              const SizedBox(width: 12),
              BalanceValue(LumenScope.walletsOf(context).balanceOf(selected)),
            ],
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
          hint: widget.hint,
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
