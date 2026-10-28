import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/theme/lumen_theme.dart';
import 'package:lumen/widgets/screen_parts.dart';
import 'package:material_ui/material_ui.dart';

// One instance, so pumping again does not animate a theme change.
final _theme = lumenTheme(Brightness.light);

Future<void> _pumpButton(
  WidgetTester tester, {
  required bool loading,
  bool still = false,
}) => tester.pumpWidget(
  MaterialApp(
    theme: _theme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: still),
      child: child!,
    ),
    home: Scaffold(
      body: RefreshButton(
        label: 'Refresh balance',
        loading: loading,
        onPressed: () {},
      ),
    ),
  ),
);

double _turns(WidgetTester tester) => tester
    .widget<RotationTransition>(
      find.descendant(
        of: find.byType(RefreshButton),
        matching: find.byType(RotationTransition),
      ),
    )
    .turns
    .value;

Future<void> _wait(WidgetTester tester, int milliseconds) async {
  await tester.pump();
  await tester.pump(Duration(milliseconds: milliseconds));
}

void main() {
  testWidgets('the icon spins while loading, then ends its turn', (
    tester,
  ) async {
    await _pumpButton(tester, loading: true);
    await _wait(tester, 250);
    expect(_turns(tester), closeTo(0.25, 0.01));

    await _pumpButton(tester, loading: false);
    await _wait(tester, 250);
    expect(_turns(tester), closeTo(0.5, 0.01));
    await tester.pumpAndSettle();
    expect(_turns(tester), 1);
  });

  testWidgets('the icon stays still with animations turned off', (
    tester,
  ) async {
    await _pumpButton(tester, loading: true, still: true);
    await _wait(tester, 250);
    expect(_turns(tester), 0);
    expect(tester.hasRunningAnimations, isFalse);

    await _pumpButton(tester, loading: true);
    await _wait(tester, 250);
    expect(_turns(tester), closeTo(0.25, 0.01));

    await _pumpButton(tester, loading: true, still: true);
    await tester.pump();
    expect(_turns(tester), 0);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
