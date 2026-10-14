import 'package:material_ui/material_ui.dart';

/// Color tokens from mockups/styles.css. Every text pair meets 4.5:1 and every
/// icon, border and focus pair meets 3:1, in both themes.
@immutable
class LumenColors extends ThemeExtension<LumenColors> {
  const LumenColors({
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.line,
    required this.fieldBorder,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentInk,
    required this.onAccent,
    required this.focus,
    required this.positive,
    required this.danger,
    required this.nwc,
    required this.cashu,
    required this.chain,
    required this.liquid,
  });

  static const dark = LumenColors(
    surface: Color(0xFF111317),
    surface2: Color(0xFF191C22),
    surface3: Color(0xFF252A33),
    line: Color(0xFF2A2F38),
    fieldBorder: Color(0xFF747B88),
    text: Color(0xFFF3F1EB),
    text2: Color(0xFFA6ABB5),
    text3: Color(0xFF868C98),
    accent: Color(0xFFFFB547),
    accentInk: Color(0xFFFFC56E),
    onAccent: Color(0xFF1B1203),
    focus: Color(0xFFFFC56E),
    positive: Color(0xFF5BD68A),
    danger: Color(0xFFFF8F80),
    nwc: Color(0xFFFACC15),
    cashu: Color(0xFFB49CFB),
    chain: Color(0xFFFB923C),
    liquid: Color(0xFF2DD4BF),
  );

  static const light = LumenColors(
    surface: Color(0xFFFBFAF7),
    surface2: Color(0xFFF0EEE9),
    surface3: Color(0xFFE2DFD7),
    line: Color(0xFFDEDAD1),
    fieldBorder: Color(0xFF7D828B),
    text: Color(0xFF16181C),
    text2: Color(0xFF50565F),
    text3: Color(0xFF5F656E),
    accent: Color(0xFFFFB547),
    accentInk: Color(0xFF8F5400),
    onAccent: Color(0xFF1B1203),
    focus: Color(0xFF8F5400),
    positive: Color(0xFF157A3C),
    danger: Color(0xFFB42318),
    nwc: Color(0xFFA16207),
    cashu: Color(0xFF6D3FD9),
    chain: Color(0xFFC2410C),
    liquid: Color(0xFF0F766E),
  );

  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color line;
  final Color fieldBorder;
  final Color text;
  final Color text2;
  final Color text3;
  final Color accent;
  final Color accentInk;
  final Color onAccent;
  final Color focus;
  final Color positive;
  final Color danger;
  final Color nwc;
  final Color cashu;
  final Color chain;
  final Color liquid;

  /// For the system's increased contrast setting: secondary text, borders and
  /// dividers take the strongest color available.
  LumenColors highContrast() => LumenColors(
    surface: surface,
    surface2: surface2,
    surface3: surface3,
    line: fieldBorder,
    fieldBorder: text,
    text: text,
    text2: text,
    text3: text,
    accent: accent,
    accentInk: accentInk,
    onAccent: onAccent,
    focus: focus,
    positive: positive,
    danger: danger,
    nwc: nwc,
    cashu: cashu,
    chain: chain,
    liquid: liquid,
  );

  static LumenColors of(BuildContext context) =>
      Theme.of(context).extension<LumenColors>()!;

  @override
  LumenColors copyWith() => this;

  @override
  LumenColors lerp(LumenColors? other, double t) =>
      other == null || t < 0.5 ? this : other;
}
