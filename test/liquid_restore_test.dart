import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/liquid_engine.dart';
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
  final fields = find.byType(TextField);

  /// Lets work started outside the test's fake clock, such as the stores
  /// opened by [pumpLumen], finish.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
    }
    await tester.pumpAndSettle();
  }

  Future<void> openRestore(
    WidgetTester tester, {
    Size size = phoneSize,
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    await pumpLumen(
      tester,
      sources,
      wallets: [],
      size: size,
      brightness: brightness,
      textScale: textScale,
    );
    for (final step in [
      find.text('Add a wallet'),
      find.textContaining('Fast, confidential transfers'),
      find.text('Restore a wallet'),
    ]) {
      await tester.ensureVisible(step);
      await tester.pumpAndSettle();
      await tester.tap(step);
      await tester.pumpAndSettle();
    }
  }

  String wordIn(WidgetTester tester, int index) =>
      tester.widget<TextField>(fields.at(index)).controller!.text;

  Future<void> tapRestore(WidgetTester tester) async {
    final button = find.text('Restore wallet');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await settle(tester);
  }

  testWidgets('a pasted phrase fills every field, then restores', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    engine.chain
      ..balanceSats = 25000
      ..txs = [
        ChainTx(
          txid: 'tx1',
          balance: 25000,
          fee: 30,
          height: 99,
          timestamp: DateTime.now(),
        ),
      ];
    await openRestore(tester);

    tester.takeAnnouncements();
    await tester.enterText(fields.first, '  ${liquidPhrase.toUpperCase()}\n');
    await tester.pump();

    expect([for (var i = 0; i < 12; i++) wordIn(tester, i)], words);
    expect([
      for (final a in tester.takeAnnouncements()) a.message,
    ], contains('12 words filled in'));

    await tapRestore(tester);

    final [wallet] = await tester.runAsync(sources.liquid.load) ?? [];
    expect(wallet.name, 'Liquid');
    expect(engine.chain.syncs, greaterThan(0));
    expect(find.text('Total balance'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('received 25,000 sats')), findsWidgets);
    handle.dispose();
  });

  testWidgets('the screen stays private while restoring', (tester) async {
    final calls = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('lumen/screen'),
      (call) async => calls.add(call.arguments),
    );
    await openRestore(tester);
    expect(calls, [true]);

    await tester.enterText(fields.first, liquidPhrase);
    await tester.pump();
    await tapRestore(tester);
    expect(calls, [true, false]);
  });

  testWidgets('a pasted 24-word phrase picks 24 words, then restores', (
    tester,
  ) async {
    final long = [...List.filled(23, 'abandon'), 'art'];
    await openRestore(tester);

    await tester.enterText(fields.at(3), long.join(' '));
    await tester.pump();

    expect(find.text('Word 24 of 24'), findsOneWidget);
    expect([for (var i = 0; i < 24; i++) wordIn(tester, i)], long);

    await tapRestore(tester);

    final [wallet] = await tester.runAsync(sources.liquid.load) ?? [];
    expect(wallet.name, 'Liquid');
  });

  testWidgets('the phrase length is one choice of two', (tester) async {
    final handle = tester.ensureSemantics();
    await openRestore(tester);
    expect(find.text('Word 1 of 12'), findsOneWidget);
    expect(find.text('Word 13 of 24'), findsNothing);

    await tester.tap(find.text('24 words'));
    await tester.pump();

    expect(find.text('Word 1 of 24'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('24 words')),
      matchesSemantics(
        label: '24 words',
        isChecked: true,
        hasCheckedState: true,
        isInMutuallyExclusiveGroup: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await tester.tap(find.text('12 words'));
    await tester.pump();
    expect(find.text('Word 1 of 12'), findsOneWidget);
    expect(find.text('Word 13 of 24'), findsNothing);
    handle.dispose();
  });

  testWidgets('a word and a space move on to the next field', (tester) async {
    await openRestore(tester);

    await tester.enterText(fields.first, 'abandon ');
    await tester.pump();

    expect(wordIn(tester, 0), 'abandon');
    expect(wordIn(tester, 1), isEmpty);
    final focused = FocusManager.instance.primaryFocus;
    expect(focused, tester.widget<TextField>(fields.at(1)).focusNode);
  });

  testWidgets('screen readers meet the fields in order', (tester) async {
    final handle = tester.ensureSemantics();
    await openRestore(tester);

    final read = [
      for (final node in tester.semantics.simulatedAccessibilityTraversal())
        if (RegExp(r'^Word \d+ of 12').hasMatch(node.label))
          node.label.split('\n').first,
    ];
    // Fields scrolled far out of view are left out of the traversal.
    expect(read.length, greaterThan(4));
    expect(read, [for (var i = 1; i <= read.length; i++) 'Word $i of 12']);
    handle.dispose();
  });

  testWidgets('an unknown word is flagged on its own field', (tester) async {
    await openRestore(tester);
    await tester.enterText(
      fields.first,
      [...words.take(4), 'abandonn', ...words.skip(5)].join(' '),
    );
    await tester.pump();

    await tapRestore(tester);

    expect(
      find.text(
        'This word is not in the recovery phrase list. Check its spelling.',
      ),
      findsOneWidget,
    );
    final focused = FocusManager.instance.primaryFocus;
    expect(focused, tester.widget<TextField>(fields.at(4)).focusNode);
    expect(await tester.runAsync(sources.liquid.load), isEmpty);
  });

  testWidgets('a missing word asks for it', (tester) async {
    await openRestore(tester);
    await tester.enterText(fields.first, words.take(11).join(' '));
    await tester.pump();

    await tapRestore(tester);

    expect(find.text('Type word 12 from your paper.'), findsOneWidget);
  });

  testWidgets('words that do not form a phrase say so', (tester) async {
    engine.problem = PhraseProblem.checksum;
    await openRestore(tester);
    await tester.enterText(fields.first, liquidPhrase);
    await tester.pump();

    await tapRestore(tester);

    expect(
      find.text(
        'These words do not form a recovery phrase. One of them may be '
        'wrong or out of place: check each one against your paper.',
      ),
      findsOneWidget,
    );
    expect(await tester.runAsync(sources.liquid.load), isEmpty);
  });

  testWidgets('a server that does not answer says so', (tester) async {
    engine.chain.syncError = const LiquidChainException(
      LiquidChainError.unreachable,
    );
    await openRestore(tester);
    await tester.enterText(fields.first, liquidPhrase);
    await tester.pump();

    final button = find.text('Restore wallet');
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();
    expect(
      find.text('Looking for this wallet\'s payments. This can take a minute.'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Lumen could not reach the Liquid server to look for this '
        'wallet\'s payments. Check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(await tester.runAsync(sources.liquid.load), isEmpty);
  });

  testWidgets('a phrase already in Lumen says so', (tester) async {
    await tester.runAsync(
      () => sources.liquid.add(phrase: liquidPhrase, name: 'Savings'),
    );
    await openRestore(tester);
    await tester.enterText(fields.first, liquidPhrase);
    await tester.pump();

    final handle = tester.ensureSemantics();
    tester.takeAnnouncements();
    await tapRestore(tester);

    expect(find.text('This wallet is already in Lumen.'), findsOneWidget);
    expect(engine.chain.syncs, 0);
    expect(
      [for (final a in tester.takeAnnouncements()) a.message],
      ['This wallet is already in Lumen.'],
    );
    expect(await tester.runAsync(sources.liquid.load), hasLength(1));
    handle.dispose();
  });

  for (final (name, size) in [('phone', phoneSize), ('desktop', desktopSize)]) {
    for (final brightness in Brightness.values) {
      testWidgets('restoring meets the guidelines, $name, ${brightness.name}', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await openRestore(tester, size: size, brightness: brightness);
        await expectGuidelines(tester);
        await tester.tap(find.text('24 words'));
        await tester.pump();
        await expectGuidelines(tester);

        await tester.enterText(fields.first, 'zzz');
        await tapRestore(tester);
        await tester.enterText(fields.at(1), 'ab');
        await tester.pump();
        await expectGuidelines(tester);
        handle.dispose();
      });
    }

    testWidgets('restoring lays out at 200% text, $name', (tester) async {
      await openRestore(tester, size: size, textScale: 2);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('24 words'));
      await tester.tap(find.text('24 words'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.enterText(fields.first, 'zzz');
      await tapRestore(tester);
      expect(tester.takeException(), isNull);
    });
  }
}
