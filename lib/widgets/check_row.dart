import 'package:material_ui/material_ui.dart';

import '../theme/lumen_colors.dart';
import 'tappable.dart';

/// A row that is one checkbox, with its label.
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.error = false,
    this.focusNode,
  });

  final String label;
  final bool value;
  final VoidCallback onChanged;

  /// Draws the box in the error color, next to a message that says why.
  final bool error;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return MergeSemantics(
      child: Tappable(
        onTap: onChanged,
        ticked: value,
        focusNode: focusNode,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                // The row is the control: the box only shows its state.
                ExcludeFocus(
                  child: ExcludeSemantics(
                    child: IgnorePointer(
                      child: Checkbox(
                        value: value,
                        isError: error,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 15, height: 1.4, color: c.text),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
