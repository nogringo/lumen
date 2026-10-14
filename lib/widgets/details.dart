import 'package:material_ui/material_ui.dart';

import '../theme/lumen_colors.dart';
import '../theme/lumen_theme.dart';
import 'copy_button.dart';

/// The start and end of a long value, and a button that copies all of it.
class CopyableValue extends StatelessWidget {
  const CopyableValue(
    this.value, {
    super.key,
    required this.tooltip,
    required this.copied,
  });

  final String value;
  final String tooltip;
  final String copied;

  @override
  Widget build(BuildContext context) {
    final short = value.length > 12
        ? '${value.substring(0, 4)}...${value.substring(value.length - 4)}'
        : value;
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          short,
          style: const TextStyle(fontFamily: monoFamily, fontSize: 13),
        ),
        CopyButton(text: value, tooltip: tooltip, copied: copied),
      ],
    );
  }
}

/// Label and value rows, each read as one item. From 150% text, the label
/// goes above its value so neither is squeezed.
class DetailsCard extends StatelessWidget {
  const DetailsCard(this.rows, {super.key});

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
