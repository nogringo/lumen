import 'dart:async';

import 'package:clock/clock.dart';
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
  WalletsController(
    this._sources, {
    required this._cache,
    this.staleAfter = const Duration(seconds: 30),
  });

  /// How long [refreshStale] leaves a wallet alone after an attempt.
  final Duration staleAfter;

  final List<WalletSource> _sources;
  final WalletCache _cache;
  final List<Wallet> _wallets = [];
  final Map<String, BalanceState> _balances = {};
  final Map<String, ActivityState> _activity = {};
  final Map<String, Future<void>> _refreshing = {};
  final Map<String, DateTime> _attemptedAt = {};
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

  /// Background refresh, for when the app comes back to the foreground. It
  /// skips wallets tried within [staleAfter] and shows no loading state, so a
  /// wallet that stays unreachable does not flicker.
  Future<void> refreshStale() => Future.wait([
    for (final w in _wallets)
      if (_isStale(w)) refresh(w, quiet: true),
  ]);

  bool _isStale(Wallet wallet) {
    final at = _attemptedAt[wallet.id];
    return at == null || clock.now().difference(at) >= staleAfter;
  }

  /// A [quiet] refresh keeps the current state on screen until it settles.
  Future<void> refresh(Wallet wallet, {bool quiet = false}) {
    if (!quiet) _showLoading(wallet);
    return _refreshing[wallet.id] ??= _refresh(wallet);
  }

  void _showLoading(Wallet wallet) {
    _balances[wallet.id] = BalanceState(
      sats: _balances[wallet.id]?.sats,
      loading: true,
    );
    _activity[wallet.id] = ActivityState(
      transactions: _activity[wallet.id]?.transactions,
      loading: true,
    );
    notifyListeners();
  }

  Future<void> _refresh(Wallet wallet) async {
    _attemptedAt[wallet.id] = clock.now();
    try {
      await Future.wait([_refreshBalance(wallet), _refreshActivity(wallet)]);
    } finally {
      _refreshing.remove(wallet.id);
    }
  }

  Future<void> _refreshBalance(Wallet wallet) async {
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
    _attemptedAt.remove(wallet.id);
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
