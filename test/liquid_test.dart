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

  testWidgets('a Liquid wallet has no connection string to copy', (
    tester,
  ) async {
    final wallet = await tester.runAsync(
      () => sources.liquid.add(phrase: liquidPhrase, name: 'Savings'),
    );
    await pumpLumen(tester, sources, wallets: [wallet!]);
    await tester.tap(find.text('Savings').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Savings options'));
    await tester.pumpAndSettle();

    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Copy connection string'), findsNothing);
  });
}
