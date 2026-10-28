import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:material_ui/material_ui.dart';

import 'fakes.dart';

void main() {
  late WalletSources sources;

  setUpAll(() => sources = memorySources());
  tearDownAll(() => sources.dispose());

  List<Transaction> payments(int count, {String name = 'Payment'}) => [
    for (var i = 0; i < count; i++)
      tx('$name$i', minutesAgo: i * 90, description: '$name $i'),
  ];

  Finder rows(String name) => find.textContaining(RegExp('^$name \\d+\$'));

  Future<void> openActivity(WidgetTester tester) async {
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  testWidgets('See all shows every saved payment, not only the latest', (
    tester,
  ) async {
    final wallet = FakeWallet('home', 'Home node')..transactions = payments(8);
    final controller = await pumpLumen(tester, sources, wallets: [wallet]);
    await tester.runAsync(() => controller.loadOlder(wallet));
    expect(rows('Payment'), findsNWidgets(5));

    await openActivity(tester);

    expect(find.text('Activity'), findsOneWidget);
    expect(rows('Payment'), findsNWidgets(8));
    expect(
      find.text('That is every payment Lumen has saved.', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('Show more adds older payments and says how many are shown', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final wallet = FakeWallet('home', 'Home node')..transactions = payments(60);
    final controller = await pumpLumen(tester, sources, wallets: [wallet]);
    await tester.runAsync(() => controller.loadOlder(wallet));
    await openActivity(tester);
    expect(rows('Payment'), findsNWidgets(50));

    tester.takeAnnouncements();
    await tester.scrollUntilVisible(find.text('Show more'), 500);
    await tester.tap(find.text('Show more'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(rows('Payment'), findsNWidgets(60));
    expect(find.text('Show more'), findsNothing);
    expect([
      for (final a in tester.takeAnnouncements()) a.message,
    ], contains('60 payments shown'));
    expect(FocusManager.instance.primaryFocus?.context?.widget, isA<Focus>());
    handle.dispose();
  });

  testWidgets('saved payments stay readable when the wallet is unreachable', (
    tester,
  ) async {
    final wallet = FakeWallet('home', 'Home node')..transactions = payments(12);
    final controller = await pumpLumen(tester, sources, wallets: [wallet]);
    await tester.runAsync(() => controller.loadOlder(wallet));

    wallet.activityError = ActivityError.unreachable;
    await tester.runAsync(() => controller.refresh(wallet));
    await tester.pumpAndSettle();
    await openActivity(tester);

    expect(rows('Payment'), findsNWidgets(12));
    expect(
      find.text('Activity from 1 wallet is not shown: it could not be loaded.'),
      findsOneWidget,
    );
  });

  testWidgets('See all on a wallet shows only that wallet', (tester) async {
    final home = FakeWallet('home', 'Home node')..transactions = payments(3);
    final phone = FakeWallet('phone', 'Phone')
      ..transactions = payments(4, name: 'Zap');
    final controller = await pumpLumen(tester, sources, wallets: [home, phone]);
    await tester.runAsync(
      () => Future.wait([
        controller.loadOlder(home),
        controller.loadOlder(phone),
      ]),
    );

    await tester.tap(find.text('Phone'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('See all'));
    await openActivity(tester);

    expect(find.text('Phone activity'), findsOneWidget);
    expect(rows('Zap'), findsNWidgets(4));
    expect(rows('Payment'), findsNothing);
  });

  testWidgets('a pending payment says so until it confirms', (tester) async {
    final handle = tester.ensureSemantics();
    final wallet = FakeWallet.liquid('savings', 'Savings')
      ..transactions = [
        tx('in', sats: 21000, incoming: true, confirmations: 0),
        tx('out', sats: 500, days: 1, confirmations: 3),
      ];
    final controller = await pumpLumen(tester, sources, wallets: [wallet]);

    expect(find.text('Pending'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'received 21,000 sats\nPending$')),
      findsOneWidget,
    );

    wallet.transactions = [
      tx('in', sats: 21000, incoming: true, confirmations: 1),
      ...wallet.transactions.skip(1),
    ];
    await tester.runAsync(() => controller.refresh(wallet));
    await tester.pumpAndSettle();
    expect(find.text('Pending'), findsNothing);
    handle.dispose();
  });

  for (final brightness in Brightness.values) {
    for (final (name, size) in [
      ('phone', phoneSize),
      ('desktop', desktopSize),
    ]) {
      testWidgets(
        'a pending payment meets the guidelines, $name, ${brightness.name}',
        (tester) async {
          final handle = tester.ensureSemantics();
          final wallet = FakeWallet.liquid('savings', 'Savings')
            ..transactions = [
              tx('in', sats: 21000, incoming: true, confirmations: 0),
              tx('out', sats: 500, confirmations: 0),
            ];
          await pumpLumen(
            tester,
            sources,
            wallets: [wallet],
            size: size,
            brightness: brightness,
          );

          expect(find.text('Pending'), findsNWidgets(2));
          await expectGuidelines(tester);
          handle.dispose();
        },
        variant: size == desktopSize
            ? TargetPlatformVariant.only(TargetPlatform.macOS)
            : const DefaultTestVariant(),
      );
    }
  }

  testWidgets('a pending payment lays out at 200% text', (tester) async {
    final wallet = FakeWallet.liquid('savings', 'Savings')
      ..transactions = [
        tx('in', sats: 2100000, incoming: true, confirmations: 0),
      ];
    await pumpLumen(tester, sources, wallets: [wallet], textScale: 2);

    expect(tester.takeException(), isNull);
    expect(find.text('Pending'), findsOneWidget);
  });
}
