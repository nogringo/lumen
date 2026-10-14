import 'package:flutter_test/flutter_test.dart';
import 'package:lumen/wallets/wallet_cache.dart';
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
    final cache = MemoryWalletCache();
    final first = FakeWallet('a', 'Home node', balance: 2100);
    await (await loadedController([first], cache: cache)).refreshAll();

    final wallet = FakeWallet('a', 'Home node', balance: 2500);
    final controller = await loadedController([wallet], cache: cache);

    expect(controller.balanceOf(wallet).sats, 2100);
    expect(controller.balanceOf(wallet).loading, isTrue);
    expect(controller.hasKnownBalance, isTrue);
    await controller.refreshAll();
    expect(controller.balanceOf(wallet).sats, 2500);
    expect(await cache.readBalance('a'), 2500);
  });

  test('shows the last known activity at launch while it refreshes', () async {
    final cache = MemoryWalletCache();
    final first = FakeWallet('a', 'Home node')..transactions = [tx('old')];
    await (await loadedController([first], cache: cache)).refreshAll();

    final wallet = FakeWallet('a', 'Home node')
      ..transactions = [tx('new'), tx('old', minutesAgo: 1)];
    final controller = await loadedController([wallet], cache: cache);

    final state = controller.activityOf(wallet);
    expect([for (final t in state.transactions!) t.id], ['old']);
    expect(state.loading, isTrue);
    await controller.refreshAll();
    expect(
      [for (final t in (await cache.readActivity('a'))!) t.id],
      ['new', 'old'],
    );
  });

  test('a failed refresh keeps the saved activity', () async {
    final cache = MemoryWalletCache();
    final wallet = FakeWallet('a', 'Home node')..transactions = [tx('kept')];
    final controller = await loadedController([wallet], cache: cache);
    await controller.refreshAll();

    wallet.activityError = ActivityError.unreachable;
    await controller.refresh(wallet);

    expect(await cache.readActivity('a'), hasLength(1));
  });

  test('remove forgets the saved balance and activity', () async {
    final cache = MemoryWalletCache();
    final wallet = FakeWallet('a', 'Home node', balance: 10)
      ..transactions = [tx('gone')];
    final controller = await loadedController([wallet], cache: cache);
    await controller.refreshAll();

    await controller.remove(wallet);
    await Future<void>.delayed(Duration.zero);

    expect(await cache.readBalance('a'), isNull);
    expect(await cache.readActivity('a'), isNull);
  });

  test('merges the activity of every wallet, newest first', () async {
    final home = FakeWallet('a', 'Home node')
      ..transactions = [tx('coffee', minutesAgo: 60), tx('rent', days: 3)];
    final phone = FakeWallet('b', 'Phone')
      ..transactions = [tx('zap', minutesAgo: 2, incoming: true)];
    final controller = await loadedController([home, phone]);
    await controller.refreshAll();

    expect(
      [for (final item in controller.recentActivity) item.transaction.id],
      ['zap', 'coffee', 'rent'],
    );
    expect(controller.recentActivity.first.wallet, phone);
    expect(controller.isLoadingActivity, isFalse);
  });

  test('keeps the known activity when a refresh fails', () async {
    final wallet = FakeWallet('a', 'Home node')..transactions = [tx('coffee')];
    final controller = await loadedController([wallet]);
    await controller.refreshAll();

    wallet.activityError = ActivityError.unreachable;
    await controller.refresh(wallet);

    final state = controller.activityOf(wallet);
    expect(state.error, ActivityError.unreachable);
    expect(state.transactions, hasLength(1));
    expect(controller.activityUnavailableCount, 1);
  });

  test('remove drops the wallet activity', () async {
    final kept = FakeWallet('a', 'Home node')..transactions = [tx('kept')];
    final removed = FakeWallet('b', 'Old')..transactions = [tx('gone')];
    final controller = await loadedController([kept, removed]);
    await controller.refreshAll();

    await controller.remove(removed);

    expect(
      [for (final item in controller.recentActivity) item.transaction.id],
      ['kept'],
    );
  });
}
