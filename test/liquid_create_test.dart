import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

void main() {
  late FakeLiquidEngine engine;
  late WalletSources sources;

  setUp(() {
    engine = FakeLiquidEngine();
    sources = memorySources(liquidEngine: engine);
  });

  tearDown(() => sources.dispose());

  final words = liquidPhrase.split(' ');

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Future<void> openPhrase(
    WidgetTester tester, {
    Size size = phoneSize,
    Brightness brightness = Brightness.light,
  }) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [],
      size: size,
      brightness: brightness,
    );
    await tester.tap(find.text('Add a wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liquid'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create a new wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show the 12 words'));
    await settle(tester);
  }

  /// The word numbers the check asks for, from 1.
  List<int> asked(WidgetTester tester) => [
    for (final label
        in tester
            .widgetList<Text>(find.textContaining(RegExp(r'^Word \d+ of 12$')))
            .map((text) => text.data!))
      int.parse(RegExp(r'\d+').firstMatch(label)![0]!),
  ];

  Future<void> fillCheck(WidgetTester tester, {bool right = true}) async {
    final fields = find.byType(TextField);
    final numbers = asked(tester);
    for (var i = 0; i < numbers.length; i++) {
      await tester.enterText(
        fields.at(i),
        right ? words[numbers[i] - 1] : 'zoo',
      );
    }
    await tester.pump();
  }

  testWidgets('creating a wallet shows the phrase, checks it, then saves', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await openPhrase(tester);

    expect(find.text('Recovery phrase'), findsOneWidget);
    expect(find.bySemanticsLabel('Word 1 of 12, abandon'), findsOneWidget);
    expect(find.bySemanticsLabel('Word 12 of 12, about'), findsOneWidget);

    await tester.tap(find.text('I wrote them down'));
    await tester.pumpAndSettle();
    expect(find.text('Check your phrase'), findsOneWidget);
    expect(asked(tester), hasLength(3));

    await fillCheck(tester);
    await tester.tap(find.text('Create wallet'));
    await settle(tester);

    final [wallet] = await tester.runAsync(sources.liquid.load) ?? [];
    expect(wallet.name, 'Liquid');
    expect(find.text('Liquid'), findsWidgets);
    expect(find.text('Total balance'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the screen stays private from the words to the saved wallet', (
    tester,
  ) async {
    final calls = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('lumen/screen'),
      (call) async => calls.add(call.arguments),
    );
    await openPhrase(tester);
    expect(calls, [true]);

    await tester.tap(find.text('I wrote them down'));
    await tester.pumpAndSettle();
    expect(calls, [true]);

    await fillCheck(tester);
    await tester.tap(find.text('Create wallet'));
    await settle(tester);
    expect(calls, [true, false]);
  });

  testWidgets('a wrong word is shown inline and nothing is saved', (
    tester,
  ) async {
    await openPhrase(tester);
    await tester.tap(find.text('I wrote them down'));
    await tester.pumpAndSettle();
    final first = asked(tester).first;

    await fillCheck(tester, right: false);
    await tester.tap(find.text('Create wallet'));
    await settle(tester);

    expect(
      find.text('This is not word $first. Check your paper and type it again.'),
      findsOneWidget,
    );
    expect(await tester.runAsync(sources.liquid.load), isEmpty);
    final focused = FocusManager.instance.primaryFocus?.context;
    expect(focused?.findAncestorWidgetOfExactType<TextField>(), isNotNull);
  });

  testWidgets('screen readers read the words in order, one column first', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await openPhrase(tester);

    final read = [
      for (final node in tester.semantics.simulatedAccessibilityTraversal())
        if (node.label.startsWith('Word ')) node.label,
    ];
    expect(read, [
      for (var i = 0; i < 12; i++) 'Word ${i + 1} of 12, ${words[i]}',
    ]);
    handle.dispose();
  });

  testWidgets('typing a word offers the list words, announced', (tester) async {
    final handle = tester.ensureSemantics();
    await openPhrase(tester);
    await tester.tap(find.text('I wrote them down'));
    await tester.pumpAndSettle();

    tester.takeAnnouncements();
    await tester.tap(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'ab');
    await tester.pump();

    for (final word in ['abandon', 'ability', 'able', 'about']) {
      expect(find.widgetWithText(OutlinedButton, word), findsOneWidget);
    }
    expect([
      for (final a in tester.takeAnnouncements()) a.message,
    ], contains('4 suggestions'));

    await tester.tap(find.widgetWithText(OutlinedButton, 'about'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'about',
    );
    expect(find.byType(OutlinedButton), findsNothing);
    final focused = FocusManager.instance.primaryFocus?.context;
    expect(
      focused?.findAncestorWidgetOfExactType<TextField>()?.focusNode,
      isNot(tester.widget<TextField>(find.byType(TextField).first).focusNode),
    );
    handle.dispose();
  });

  testWidgets('a click on a suggestion fills the word on desktop', (
    tester,
  ) async {
    await openPhrase(tester, size: desktopSize);
    await tester.tap(find.text('I wrote them down'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'impo');
    await tester.pump();
    // A frame between press and release, as with a real click.
    final click = await tester.startGesture(
      tester.getCenter(find.widgetWithText(OutlinedButton, 'impose')),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    await click.up();
    await tester.pump();

    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      'impose',
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));

  testWidgets('a suggestion can be reached with the keyboard', (tester) async {
    await openPhrase(tester);
    await tester.tap(find.text('I wrote them down'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'zo');
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    final focused = FocusManager.instance.primaryFocus?.context;
    expect(focused?.findAncestorWidgetOfExactType<OutlinedButton>(), isNotNull);
    expect(find.widgetWithText(OutlinedButton, 'zone'), findsOneWidget);
  });

  testWidgets('back from the phrase returns to the explanation', (
    tester,
  ) async {
    await openPhrase(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('New Liquid wallet'), findsOneWidget);
    expect(find.text('Recovery phrase'), findsNothing);
  });

  testWidgets('an engine that cannot start says so', (tester) async {
    engine.unavailable = true;
    await openPhrase(tester);

    expect(
      find.text(
        'Lumen could not start Liquid on this device. Try again later.',
      ),
      findsOneWidget,
    );
    expect(find.text('Recovery phrase'), findsNothing);
  });

  for (final (name, size) in [('phone', phoneSize), ('desktop', desktopSize)]) {
    for (final brightness in Brightness.values) {
      testWidgets('creating a wallet meets the guidelines, $name, '
          '${brightness.name}', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpLumen(
          tester,
          sources,
          wallets: [],
          size: size,
          brightness: brightness,
        );
        await tester.tap(find.text('Add a wallet'));
        await tester.pumpAndSettle();
        await expectGuidelines(tester);
        await tester.tap(find.text('Liquid'));
        await tester.pumpAndSettle();
        await expectGuidelines(tester);
        await tester.tap(find.text('Create a new wallet'));
        await tester.pumpAndSettle();
        await expectGuidelines(tester);
        await tester.tap(find.text('Show the 12 words'));
        await settle(tester);
        await expectGuidelines(tester);
        await tester.tap(find.text('I wrote them down'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'ab');
        await tester.pump();
        await expectGuidelines(tester);
        handle.dispose();
      });
    }

    testWidgets('creating a wallet lays out at 200% text, $name', (
      tester,
    ) async {
      await pumpLumen(tester, sources, wallets: [], size: size, textScale: 2);
      for (final step in [
        find.text('Add a wallet'),
        find.textContaining('Fast, confidential transfers'),
        find.text('Create a new wallet'),
        find.text('Show the 12 words'),
        find.text('I wrote them down'),
      ]) {
        await tester.ensureVisible(step);
        await tester.pumpAndSettle();
        await tester.tap(step);
        await settle(tester);
        expect(tester.takeException(), isNull, reason: '$step');
      }
      expect(find.text('Check your phrase'), findsOneWidget);
    });
  }
}
