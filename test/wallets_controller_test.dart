import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/wallets/balance_store.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

import 'fakes.dart';

void main() {
  test('sums the balances it could read and counts the others', () async {
    final controller = await loadedController([
      FakeWallet('a', 'Home node', balance: 152300),
      FakeWallet('b', 'Phone', balance: 1000),
      FakeWallet('c', 'Offline', error: BalanceError.unreachable),
    ]);
    await controller.refreshAll();

    expect(controller.totalSats, 153300);
    expect(controller.unavailableCount, 1);
    expect(controller.hasKnownBalance, isTrue);
    expect(controller.isRefreshing, isFalse);
  });

  test('keeps why a balance could not be read', () async {
    final wallet = FakeWallet(
      'a',
      'Read only',
      error: BalanceError.noPermission,
    );
    final controller = await loadedController([wallet]);
    await controller.refreshAll();

    expect(controller.balanceOf(wallet).error, BalanceError.noPermission);
    expect(controller.unavailableCount, 1);
  });

  test('a new wallet starts loading its balance', () async {
    final controller = await loadedController([]);
    final wallet = FakeWallet('a', 'New', balance: 7);

    controller.added(wallet);
    expect(controller.balanceOf(wallet).loading, isTrue);
    await controller.refresh(wallet);

    expect(controller.balanceOf(wallet).sats, 7);
  });

  test('a refresh in flight is reused', () async {
    final wallet = FakeWallet('a', 'Home node', balance: 5);
    final controller = await loadedController([wallet]);
    await controller.refreshAll();
    final before = wallet.fetchCount;

    await Future.wait([controller.refresh(wallet), controller.refresh(wallet)]);

    expect(wallet.fetchCount, before + 1);
  });

  test('a failed wallet recovers on the next refresh', () async {
    final wallet = FakeWallet(
      'a',
      'Home node',
      balance: 42,
      error: BalanceError.unreachable,
    );
    final controller = await loadedController([wallet]);
    await controller.refreshAll();
    expect(controller.balanceOf(wallet).failed, isTrue);

    wallet.error = null;
    await controller.refresh(wallet);

    expect(controller.balanceOf(wallet).sats, 42);
    expect(controller.unavailableCount, 0);
  });

  test('remove drops the wallet and its balance from the total', () async {
    final kept = FakeWallet('a', 'Home node', balance: 10);
    final removed = FakeWallet('b', 'Old', balance: 90);
    final controller = await loadedController([kept, removed]);
    await controller.refreshAll();
    var listChanges = 0;
    controller.listChanges.addListener(() => listChanges++);

    await controller.remove(removed);

    expect(removed.removed, isTrue);
    expect(controller.wallets, [kept]);
    expect(controller.totalSats, 10);
    expect(listChanges, 1);
  });

  test('balance updates do not count as list changes', () async {
    final wallet = FakeWallet('a', 'Home node', balance: 1);
    final controller = await loadedController([wallet]);
    await controller.refreshAll();
    var listChanges = 0;
    controller.listChanges.addListener(() => listChanges++);

    await controller.refresh(wallet);
    await controller.rename(wallet, 'Renamed');

    expect(listChanges, 0);
  });

  test('shows the last known balance at launch while it refreshes', () async {
    final store = MemoryBalanceStore();
    final first = FakeWallet('a', 'Home node', balance: 2100);
    await (await loadedController([first], store: store)).refreshAll();

    final wallet = FakeWallet('a', 'Home node', balance: 2500);
    final controller = await loadedController([wallet], store: store);

    expect(controller.balanceOf(wallet).sats, 2100);
    expect(controller.balanceOf(wallet).loading, isTrue);
    expect(controller.hasKnownBalance, isTrue);
    await controller.refreshAll();
    expect(controller.balanceOf(wallet).sats, 2500);
    expect(await store.read('a'), 2500);
  });

  test('remove forgets the saved balance', () async {
    final store = MemoryBalanceStore();
    final wallet = FakeWallet('a', 'Home node', balance: 10);
    final controller = await loadedController([wallet], store: store);
    await controller.refreshAll();

    await controller.remove(wallet);
    await Future<void>.delayed(Duration.zero);

    expect(await store.read('a'), isNull);
  });
}
