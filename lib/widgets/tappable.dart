import 'package:material_ui/material_ui.dart';

import '../theme/lumen_colors.dart';

/// An ink-well row with the visible focus ring the mockups require.
class Tappable extends StatefulWidget {
  const Tappable({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius = 12,
    this.selected = false,
    this.toggled,
    this.checked,
    this.ticked,
    this.focusNode,
    this.decorated = true,
    this.onFocusChange,
  });

  final VoidCallback onTap;
  final Widget child;
  final double borderRadius;
  final bool selected;

  /// Makes the row a switch for screen readers, on or off.
  final bool? toggled;

  /// Makes the row one choice of several for screen readers, picked or not.
  final bool? checked;

  /// Makes the row a checkbox for screen readers, ticked or not.
  final bool? ticked;
  final FocusNode? focusNode;

  /// False leaves the fill and focus ring to a parent that draws them over a
  /// larger area, such as a table row.
  final bool decorated;
  final ValueChanged<bool>? onFocusChange;

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    final radius = BorderRadius.circular(widget.borderRadius);
    final plain =
        widget.toggled == null &&
        widget.checked == null &&
        widget.ticked == null;
    return Semantics(
      button: plain,
      toggled: widget.toggled,
      checked: widget.checked ?? widget.ticked,
      inMutuallyExclusiveGroup: widget.checked == null ? null : true,
      selected: plain ? widget.selected : null,
      child: Material(
        color: widget.selected ? c.surface2 : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          onFocusChange: (focused) {
            setState(() => _focused = focused);
            widget.onFocusChange?.call(focused);
          },
          borderRadius: radius,
          focusColor: Colors.transparent,
          hoverColor: widget.decorated ? null : Colors.transparent,
          highlightColor: widget.decorated ? null : Colors.transparent,
          splashFactory: widget.decorated ? null : NoSplash.splashFactory,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: _focused && widget.decorated
                  ? Border.all(color: c.focus, width: 3)
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
