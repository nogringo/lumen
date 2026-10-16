import 'package:material_ui/material_ui.dart';

import '../theme/lumen_colors.dart';
import 'tappable.dart';

/// A row that is one switch, with a title and a hint.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String hint;
  final bool value;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return MergeSemantics(
      child: Tappable(
        onTap: onChanged,
        toggled: value,
        borderRadius: 20,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hint,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: c.text2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // The row is the control: the switch only shows its state.
                ExcludeFocus(
                  child: ExcludeSemantics(
                    child: IgnorePointer(
                      child: Switch(value: value, onChanged: (_) {}),
                    ),
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
