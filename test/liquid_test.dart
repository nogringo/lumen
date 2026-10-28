import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/wallets/history_store.dart';
import 'package:lumen/wallets/wallet_cache.dart';
import 'package:lumen/wallets/wallets_controller.dart';
import 'package:lumen_wallets/liquid_engine.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

import 'fakes.dart';

void main() {
  late FakeLiquidEngine engine;
  late WalletSources sources;

  setUp(() {
    engine = FakeLiquidEngine();
    sources = memorySources(liquidEngine: engine);
  });

  tearDown(() => sources.dispose());

  ChainTx received(String txid, int sats, {int? height}) => ChainTx(
    txid: txid,
    balance: sats,
    fee: 30,
    height: height,
    timestamp: height == null ? null : DateTime.now(),
  );

  Future<WalletsController> loadAll() async {
    final controller = WalletsController(
      sources.all,
      cache: MemoryWalletCache(),
      history: await HistoryStore.memory(),
    );
    addTearDown(controller.close);
    await controller.load();
    await controller.refreshAll();
    return controller;
  }

  test('saved Liquid wallets load with the others', () async {
    await sources.liquid.add(phrase: liquidPhrase, name: 'Savings');
    engine.chain
      ..balanceSats = 25000
      ..txs = [received('tx1', 25000, height: 99)];

    final controller = await loadAll();

    final wallet = controller.wallets.single;
    expect((wallet.name, wallet.kind), ('Savings', WalletKind.liquid));
    expect(controller.balanceOf(wallet).sats, 25000);
    final [payment] = controller.activityOf(wallet).transactions!;
    expect((payment.txid, payment.confirmations), ('tx1', 2));
  });

  test('a pending payment in the history confirms', () async {
    await sources.liquid.add(phrase: liquidPhrase, name: 'Savings');
    engine.chain.txs = [received('tx1', 5000)];
    final controller = await loadAll();
    final wallet = controller.wallets.single;
    await controller.loadOlder(wallet);
    expect(
      (await controller.history(limit: 10)).single.transaction.isPending,
      isTrue,
    );

    engine.chain.txs = [received('tx1', 5000, height: 100)];
    await controller.refresh(wallet);

    final [saved] = await controller.history(limit: 10);
    expect(saved.transaction.confirmations, 1);
  });

  testWidgets('a Liquid wallet shows on Home, its screen and in Activity', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    engine.chain
      ..balanceSats = 25000
      ..txs = [received('tx1', 25000, height: 99)];
    final wallet = await tester.runAsync(
      () => sources.liquid.add(phrase: liquidPhrase, name: 'Savings'),
    );
    await pumpLumen(tester, sources, wallets: [wallet!]);

    expect(find.text('Savings'), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp('received 25,000 sats')),
      findsOneWidget,
    );

    await tester.tap(find.text('Savings').first);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('^Liquid')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('25,000')), findsWidgets);
    expect(
      find.bySemanticsLabel(RegExp('received 25,000 sats')),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('See all'));
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(find.text('Savings activity'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('received 25,000 sats')),
      findsOneWidget,
    );
    handle.dispose();
  });

  Future<void> openMenu(WidgetTester tester, String name) async {
    await tester.tap(find.text(name).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('$name options'));
    await tester.pumpAndSettle();
  }

  testWidgets('a Liquid wallet offers its phrase, not a connection string', (
    tester,
  ) async {
    final wallet = await tester.runAsync(
      () => sources.liquid.add(phrase: liquidPhrase, name: 'Savings'),
    );
    await pumpLumen(tester, sources, wallets: [wallet!]);
    await openMenu(tester, 'Savings');

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Show recovery phrase'), findsOneWidget);
    expect(find.text('Copy connection string'), findsNothing);
  });

  testWidgets('a Lightning wallet has no phrase to show', (tester) async {
    await pumpLumen(tester, sources, wallets: [FakeWallet('home', 'Home')]);
    await openMenu(tester, 'Home');

    expect(find.text('Copy connection string'), findsOneWidget);
    expect(find.text('Show recovery phrase'), findsNothing);
  });

  testWidgets('the recovery phrase shows after a warning, kept private', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final calls = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('lumen/screen'),
      (call) async => calls.add(call.arguments),
    );
    final wallet = await tester.runAsync(
      () => sources.liquid.add(phrase: liquidPhrase, name: 'Savings'),
    );
    await pumpLumen(tester, sources, wallets: [wallet!]);
    await openMenu(tester, 'Savings');
    await tester.tap(find.text('Show recovery phrase'));
    await tester.pumpAndSettle();

    expect(find.text('Show the recovery phrase?'), findsOneWidget);
    expect(find.bySemanticsLabel('Passphrase'), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Recovery phrase'), findsNothing);
    expect(calls, isEmpty);

    await tester.tap(find.byTooltip('Savings options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show recovery phrase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.text('Recovery phrase'), findsOneWidget);
    expect(
      find.text(
        'These words restore Savings in Lumen or another Liquid app. '
        'Keep them on paper, in this order.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Word 1 of 12, abandon'), findsOneWidget);
    expect(find.bySemanticsLabel('Word 12 of 12, about'), findsOneWidget);
    expect(calls, [true]);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Recovery phrase'), findsNothing);
    expect(find.byTooltip('Savings options'), findsOneWidget);
    expect(calls, [true, false]);
    handle.dispose();
  });

  testWidgets('a restored 24-word phrase shows every word', (tester) async {
    final handle = tester.ensureSemantics();
    final words = [...List.filled(23, 'abandon'), 'art'];
    final wallet = await tester.runAsync(
      () => sources.liquid.add(phrase: words.join(' '), name: 'Jade'),
    );
    await pumpLumen(tester, sources, wallets: [wallet!]);
    await openMenu(tester, 'Jade');
    await tester.tap(find.text('Show recovery phrase'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Word 1 of 24, abandon'), findsOneWidget);
    expect(find.bySemanticsLabel('Word 24 of 24, art'), findsOneWidget);
    handle.dispose();
  });

  const savedCheck = 'I have my own copy of the recovery phrase';
  const notSaved =
      'Check this box once you have your own copy of the recovery phrase.';

  Future<void> openRemove(WidgetTester tester, String name) async {
    await openMenu(tester, name);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Remove $name?'), findsOneWidget);
  }

  testWidgets('removing a Liquid wallet needs its phrase said to be saved', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final wallet = await tester.runAsync(
      () => sources.liquid.add(phrase: liquidPhrase, name: 'Savings'),
    );
    await pumpLumen(tester, sources, wallets: [wallet!]);
    await openRemove(tester, 'Savings');
    expect(
      find.text(
        "Lumen deletes this wallet's recovery phrase from this device. "
        'Without your own copy of the words, its funds are lost for good.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text(notSaved), findsOneWidget);
    expect(
      tester.getSemantics(find.text(savedCheck)),
      matchesSemantics(
        label: savedCheck,
        hasCheckedState: true,
        isChecked: false,
        isFocusable: true,
        isFocused: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(await tester.runAsync(sources.liquid.load), hasLength(1));

    await tester.tap(find.text(savedCheck));
    await tester.pumpAndSettle();
    expect(find.text(notSaved), findsNothing);
    expect(
      tester.getSemantics(find.text(savedCheck)),
      matchesSemantics(
        label: savedCheck,
        hasCheckedState: true,
        isChecked: true,
        isFocusable: true,
        isFocused: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(await tester.runAsync(sources.liquid.load), isEmpty);
    expect(find.text('Remove Savings?'), findsNothing);
    handle.dispose();
  });

  testWidgets('the remove dialog shows the phrase, then comes back', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final wallet = await tester.runAsync(
      () => sources.liquid.add(phrase: liquidPhrase, name: 'Savings'),
    );
    await pumpLumen(tester, sources, wallets: [wallet!]);
    await openRemove(tester, 'Savings');

    await tester.tap(find.text('Show recovery phrase'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Savings?'), findsNothing);
    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Word 1 of 12, abandon'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Recovery phrase'), findsNothing);
    expect(find.text('Remove Savings?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Remove Savings?'), findsNothing);
    expect(await tester.runAsync(sources.liquid.load), hasLength(1));
    handle.dispose();
  });

  testWidgets('removing a Lightning wallet asks for no phrase', (tester) async {
    final wallet = FakeWallet('home', 'Home');
    await pumpLumen(tester, sources, wallets: [wallet]);
    await openRemove(tester, 'Home');
    expect(
      find.text(
        'Lumen forgets this connection. The wallet and its funds are not '
        'affected, and you can connect it again later.',
      ),
      findsOneWidget,
    );
    expect(find.text(savedCheck), findsNothing);
    expect(find.text('Show recovery phrase'), findsNothing);

    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(wallet.removed, isTrue);
  });
}
