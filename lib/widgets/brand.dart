import 'package:material_ui/material_ui.dart';

import '../theme/lumen_colors.dart';
import 'screen_parts.dart';

class LogoMark extends StatelessWidget {
  const LogoMark({super.key}) : _small = false;
  const LogoMark.small({super.key}) : _small = true;

  final bool _small;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return ExcludeSemantics(
      child: Container(
        width: _small ? 36 : 88,
        height: _small ? 36 : 88,
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(_small ? 12 : 28),
        ),
        child: Icon(
          Icons.wb_sunny_outlined,
          size: _small ? 22 : 48,
          color: c.onAccent,
        ),
      ),
    );
  }
}

class Brand extends StatelessWidget {
  /// The home screen title on phone and tablet.
  const Brand.title({super.key}) : _isTitle = true;

  /// The logo at the top of the desktop sidebar.
  const Brand.logo({super.key}) : _isTitle = false;

  final bool _isTitle;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        const LogoMark.small(),
        const SizedBox(width: 10),
        Text('Lumen', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
    return _isTitle ? ScreenTitle(child: row) : row;
  }
}
