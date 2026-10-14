import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

import 'wallet_cache.dart';

@immutable
class BalanceState {
  const BalanceState({this.sats, this.loading = false, this.error});

  final int? sats;
  final bool loading;
  final BalanceError? error;

  bool get failed => error != null;
}

@immutable
class ActivityState {
  const ActivityState({this.transactions, this.loading = false, this.error});

  /// Newest first. Kept while a refresh loads or after it fails.
  final List<Transaction>? transactions;
  final bool loading;
  final ActivityError? error;
}

typedef WalletTransaction = ({Wallet wallet, Transaction transaction});

class WalletsController extends ChangeNotifier {
  WalletsController(this._sources, {required this._cache});

  final List<WalletSource> _sources;
  final WalletCache _cache;
  final List<Wallet> _wallets = [];
  final Map<String, BalanceState> _balances = {};
  final Map<String, ActivityState> _activity = {};
  final Map<String, Future<void>> _refreshing = {};
  final _listRevision = ValueNotifier(0);

  List<Wallet> get wallets => List.unmodifiable(_wallets);

  /// Notifies only when wallets are added or removed, not on balance updates.
  Listenable get listChanges => _listRevision;

  Wallet? walletById(String id) {
    for (final wallet in _wallets) {
      if (wallet.id == id) return wallet;
    }
    return null;
  }

  BalanceState balanceOf(Wallet wallet) =>
      _balances[wallet.id] ?? const BalanceState(loading: true);

  int get totalSats =>
      _wallets.fold(0, (sum, w) => sum + (balanceOf(w).sats ?? 0));

  bool get hasKnownBalance => _wallets.any((w) => balanceOf(w).sats != null);

  bool get isRefreshing => _wallets.any((w) => balanceOf(w).loading);

  ActivityState activityOf(Wallet wallet) =>
      _activity[wallet.id] ?? const ActivityState(loading: true);

  /// Every wallet's known transactions, newest first.
  List<WalletTransaction> get recentActivity => [
    for (final wallet in _wallets)
      for (final transaction in activityOf(wallet).transactions ?? const [])
        (wallet: wallet, transaction: transaction),
  ]..sort((a, b) => b.transaction.at.compareTo(a.transaction.at));

  bool get isLoadingActivity => _wallets.any((w) => activityOf(w).loading);

  int get activityUnavailableCount =>
      _wallets.where((w) => activityOf(w).error != null).length;

  int get unavailableCount => _wallets.where((w) => balanceOf(w).failed).length;

  Future<void> load() async {
    for (final source in _sources) {
      _wallets.addAll(await source.load());
    }
    await Future.wait([for (final w in _wallets) _restore(w)]);
    _listChanged();
    refreshAll();
  }

  Future<void> _restore(Wallet wallet) async {
    final (sats, transactions) = await (
      _cache.readBalance(wallet.id),
      _cache.readActivity(wallet.id),
    ).wait;
    if (sats != null) _balances[wallet.id] = BalanceState(sats: sats);
    if (transactions != null) {
      _activity[wallet.id] = ActivityState(transactions: transactions);
    }
  }

  Future<void> refreshAll() =>
      Future.wait([for (final w in _wallets) refresh(w)]);

  Future<void> refresh(Wallet wallet) =>
      _refreshing[wallet.id] ??= _refresh(wallet);

  Future<void> _refresh(Wallet wallet) async {
    try {
      await Future.wait([_refreshBalance(wallet), _refreshActivity(wallet)]);
    } finally {
      _refreshing.remove(wallet.id);
    }
  }

  Future<void> _refreshBalance(Wallet wallet) async {
    _balances[wallet.id] = BalanceState(
      sats: _balances[wallet.id]?.sats,
      loading: true,
    );
    notifyListeners();
    BalanceState result;
    try {
      result = BalanceState(sats: await wallet.fetchBalance());
    } on BalanceException catch (e) {
      result = BalanceState(error: e.error);
    } catch (_) {
      result = const BalanceState(error: BalanceError.unreachable);
    }
    if (!_wallets.contains(wallet)) return;
    _balances[wallet.id] = result;
    notifyListeners();
    if (result.sats case final sats?) {
      unawaited(_cache.writeBalance(wallet.id, sats).catchError((Object _) {}));
    }
  }

  Future<void> _refreshActivity(Wallet wallet) async {
    final known = _activity[wallet.id]?.transactions;
    _activity[wallet.id] = ActivityState(transactions: known, loading: true);
    notifyListeners();
    ActivityState result;
    try {
      result = ActivityState(transactions: await wallet.fetchTransactions());
    } on ActivityException catch (e) {
      result = ActivityState(transactions: known, error: e.error);
    } catch (_) {
      result = ActivityState(
        transactions: known,
        error: ActivityError.unreachable,
      );
    }
    if (!_wallets.contains(wallet)) return;
    _activity[wallet.id] = result;
    notifyListeners();
    if (result.error == null) {
      unawaited(
        _cache
            .writeActivity(wallet.id, result.transactions!)
            .catchError((Object _) {}),
      );
    }
  }

  void added(Wallet wallet) {
    _wallets.add(wallet);
    _listChanged();
    refresh(wallet);
  }

  Future<void> rename(Wallet wallet, String name) async {
    await wallet.rename(name);
    notifyListeners();
  }

  Future<void> remove(Wallet wallet) async {
    await wallet.remove();
    _wallets.remove(wallet);
    _balances.remove(wallet.id);
    _activity.remove(wallet.id);
    _listChanged();
    unawaited(_cache.delete(wallet.id).catchError((Object _) {}));
  }

  void _listChanged() {
    _listRevision.value++;
    notifyListeners();
  }

  @override
  void dispose() {
    _listRevision.dispose();
    super.dispose();
  }
}
