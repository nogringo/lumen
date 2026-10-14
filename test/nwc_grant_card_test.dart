import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/l10n/generated/app_localizations.dart';
import 'package:lumen/theme/lumen_theme.dart';
import 'package:lumen/widgets/nwc_grant_card.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

const _partial = NwcGrant(
  abilities: {NwcAbility.readBalance, NwcAbility.pay},
  budget: NwcBudget(sats: 50000, period: BudgetPeriod.month),
);

Future<void> _pumpCard(
  WidgetTester tester, {
  NwcGrant? grant,
  bool checking = false,
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) async {
  tester.view.physicalSize = phoneSize;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  await tester.pumpWidget(
    MaterialApp(
      theme: lumenTheme(brightness),
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: NwcGrantCard(checking: checking, grant: grant),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('lists what the connection can and cannot do', (tester) async {
    final handle = tester.ensureSemantics();
    await _pumpCard(tester, grant: _partial);

    expect(find.text('This connection can'), findsOneWidget);
    expect(find.text('This connection cannot'), findsOneWidget);
    expect(find.text('Up to 50,000 sats a month'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Allowed\s+Pay invoices$')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Not allowed\s+Create invoices$')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('a connection that allows everything has no cannot list', (
    tester,
  ) async {
    await _pumpCard(
      tester,
      grant: NwcGrant(abilities: NwcAbility.values.toSet()),
    );

    expect(find.text('This connection cannot'), findsNothing);
    expect(find.textContaining('Up to'), findsNothing);
  });

  testWidgets('a connection that allows nothing Lumen uses says so', (
    tester,
  ) async {
    await _pumpCard(tester, grant: const NwcGrant(abilities: {}));

    expect(find.text('This connection can'), findsNothing);
    expect(find.text('This connection cannot'), findsOneWidget);
    expect(find.byIcon(Icons.block), findsNWidgets(4));
  });

  testWidgets('says when the wallet could not be reached', (tester) async {
    await _pumpCard(tester);

    expect(find.textContaining('You can still connect it'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('meets the guidelines, ${brightness.name}', (tester) async {
      final handle = tester.ensureSemantics();
      for (final (grant, checking) in [
        (_partial, false),
        (null, false),
        (null, true),
      ]) {
        await _pumpCard(
          tester,
          grant: grant,
          checking: checking,
          brightness: brightness,
        );
        await expectLater(tester, meetsGuideline(textContrastGuideline));
      }
      handle.dispose();
    });
  }

  testWidgets('lays out at 200% text', (tester) async {
    for (final (grant, checking) in [
      (_partial, false),
      (null, false),
      (null, true),
    ]) {
      await _pumpCard(tester, grant: grant, checking: checking, textScale: 2);
      expect(tester.takeException(), isNull);
    }
  });
}
