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
    this.focusNode,
  });

  final VoidCallback onTap;
  final Widget child;
  final double borderRadius;
  final bool selected;
  final FocusNode? focusNode;

  @override
  State<Tappable> createState() => _TappableState();
}

class _TappableState extends State<Tappable> {
  var _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    final radius = BorderRadius.circular(widget.borderRadius);
    return Semantics(
      button: true,
      selected: widget.selected,
      child: Material(
        color: widget.selected ? c.surface2 : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          onFocusChange: (focused) => setState(() => _focused = focused),
          borderRadius: radius,
          focusColor: Colors.transparent,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: _focused ? Border.all(color: c.focus, width: 3) : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
