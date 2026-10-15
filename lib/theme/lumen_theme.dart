import 'package:material_ui/material_ui.dart';

import 'lumen_colors.dart';

const sansFamily = 'Geist';
const monoFamily = 'GeistMono';

ThemeData lumenTheme(Brightness brightness, {bool highContrast = false}) {
  final base = brightness == Brightness.dark
      ? LumenColors.dark
      : LumenColors.light;
  final c = highContrast ? base.highContrast() : base;

  WidgetStateProperty<BorderSide?> focusSide(Color color) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? BorderSide(color: color, width: 3)
            : null,
      );

  final text = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.w600,
      letterSpacing: -1.44,
      color: c.text,
    ),
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.48,
      color: c.text,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: c.text,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: c.text,
    ),
    bodyLarge: TextStyle(fontSize: 15, color: c.text),
    bodyMedium: TextStyle(fontSize: 15, color: c.text),
    bodySmall: TextStyle(fontSize: 13, color: c.text2),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: c.text,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: c.text2,
    ),
  );

  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: c.fieldBorder),
  );

  return ThemeData(
    brightness: brightness,
    // Desktop defaults to compact, which shrinks 48 dp targets to 40.
    visualDensity: VisualDensity.standard,
    fontFamily: sansFamily,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.accent,
      onSecondary: c.onAccent,
      error: c.danger,
      onError: c.surface,
      surface: c.surface,
      onSurface: c.text,
      onSurfaceVariant: c.text2,
      surfaceContainer: c.surface2,
      surfaceContainerHigh: c.surface2,
      surfaceContainerHighest: c.surface3,
      outline: c.fieldBorder,
      outlineVariant: c.line,
    ),
    scaffoldBackgroundColor: c.surface,
    focusColor: c.focus.withValues(alpha: 0.28),
    textTheme: text,
    extensions: [c],
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: c.text, size: 20),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.accentInk),
    textSelectionTheme: TextSelectionThemeData(cursorColor: c.accentInk),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(c.accent),
        foregroundColor: WidgetStatePropertyAll(c.onAccent),
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(56)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: sansFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        side: focusSide(c.text),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(c.accentInk),
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: sansFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconSize: const WidgetStatePropertyAll(16),
        side: focusSide(c.focus),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(c.text),
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        side: focusSide(c.focus),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: c.surface2,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: c.focus, width: 2),
      ),
      errorBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: c.danger),
      ),
      focusedErrorBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: c.danger, width: 2),
      ),
      helperStyle: TextStyle(fontSize: 13, height: 1.4, color: c.text2),
      helperMaxLines: 3,
      errorStyle: TextStyle(fontSize: 13, height: 1.4, color: c.danger),
      errorMaxLines: 4,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: c.line),
      ),
      titleTextStyle: text.titleMedium,
      contentTextStyle: TextStyle(fontSize: 15, height: 1.5, color: c.text2),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.surface3),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    ),
    menuButtonTheme: MenuButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(c.text),
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: sansFamily,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        side: focusSide(c.focus),
        // Focus shows as the ring alone, as in Tappable.
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return c.text.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered)) {
            return c.text.withValues(alpha: 0.06);
          }
          return Colors.transparent;
        }),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.surface2,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: TextStyle(fontFamily: sansFamily, fontSize: 15, color: c.text),
    ),
  );
}
