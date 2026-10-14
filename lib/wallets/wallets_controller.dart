import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

import 'history_store.dart';
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
    required this._history,
    this.staleAfter = const Duration(seconds: 30),
  });

  /// How long [refreshStale] leaves a wallet alone after an attempt.
  final Duration staleAfter;

  final List<WalletSource> _sources;
  final WalletCache _cache;
  final HistoryStore _history;
  final List<Wallet> _wallets = [];
  final Map<String, BalanceState> _balances = {};
  final Map<String, ActivityState> _activity = {};
  final Map<String, Future<void>> _refreshing = {};
  final Map<String, DateTime> _attemptedAt = {};
  final Map<String, Future<void>> _loadingOlder = {};
  final _listRevision = ValueNotifier(0);
  final _historyRevision = ValueNotifier(0);
  var _closed = false;

  /// Transactions kept for Home and the launch cache, per wallet.
  static const _recentCount = 10;
  static const _pageSize = 25;

  /// Bounds one walk through a wallet's list, in case it ignores the offset.
  static const _maxPages = 200;

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

  /// Notifies when transactions are saved to the history.
  Listenable get historyChanges => _historyRevision;

  /// Whether older transactions of [wallet], or of any wallet, are loading.
  bool isLoadingOlder([Wallet? wallet]) => wallet == null
      ? _loadingOlder.isNotEmpty
      : _loadingOlder.containsKey(wallet.id);

  /// The saved transactions of [wallet], or of every wallet, newest first.
  /// They stay readable offline.
  Future<List<WalletTransaction>> history({
    Wallet? wallet,
    required int limit,
  }) async {
    final byId = {
      for (final w in wallet == null ? _wallets : [wallet]) w.id: w,
    };
    final saved = await _history.read(byId.keys.toSet(), limit: limit);
    return [
      for (final (:walletId, :transaction) in saved)
        if (byId[walletId] case final wallet?)
          (wallet: wallet, transaction: transaction),
    ];
  }

  /// Transaction [id] of [wallet], from the history or else from the latest
  /// activity.
  Future<Transaction?> transaction(Wallet wallet, String id) async {
    final saved = await _history
        .find(wallet.id, id)
        .catchError((Object _) => null);
    if (saved != null) return saved;
    for (final t in activityOf(wallet).transactions ?? const <Transaction>[]) {
      if (t.id == id) return t;
    }
    return null;
  }

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
    TransactionPage? page;
    ActivityState result;
    try {
      page = await wallet.fetchTransactions(limit: _pageSize);
      result = ActivityState(
        transactions: page.transactions.take(_recentCount).toList(),
      );
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
    if (page != null) await _saveNewest(wallet, page);
  }

  /// Saves [first], then the pages after it until one holds a transaction
  /// already saved, so payments made while Lumen was away fill in. A wallet
  /// seen for the first time walks its older transactions in the background
  /// instead.
  Future<void> _saveNewest(Wallet wallet, TransactionPage first) async {
    final HistorySync sync;
    try {
      sync = await _history.readSync(wallet.id);
      if (!sync.started) {
        await _history.save(wallet.id, first.transactions);
        await _history.writeSync(wallet.id, HistorySync(offset: first.listed));
      } else {
        var page = first;
        var offset = 0;
        for (var i = 0; i < _maxPages && !_closed; i++) {
          final added = await _history.save(wallet.id, page.transactions);
          if (page.listed == 0 || added < page.transactions.length) break;
          offset += page.listed;
          page = await wallet.fetchTransactions(
            limit: _pageSize,
            offset: offset,
          );
        }
      }
    } catch (_) {
      // Picked up again at the next refresh.
      return;
    }
    _historyChanged();
    if (!sync.complete) unawaited(loadOlder(wallet));
  }

  /// Walks [wallet]'s older transactions into the history, from where the
  /// last walk stopped. A walk cut short goes on at the next refresh.
  Future<void> loadOlder(Wallet wallet) {
    if (_loadingOlder[wallet.id] case final running?) return running;
    final walk = _loadOlder(wallet).whenComplete(() {
      _loadingOlder.remove(wallet.id);
      if (!_closed) notifyListeners();
    });
    _loadingOlder[wallet.id] = walk;
    notifyListeners();
    return walk;
  }

  Future<void> _loadOlder(Wallet wallet) async {
    bool gone() => _closed || !_wallets.contains(wallet);
    try {
      var sync = await _history.readSync(wallet.id);
      List<String>? previous;
      for (var i = 0; i < _maxPages && !sync.complete && !gone(); i++) {
        final page = await wallet.fetchTransactions(
          limit: _pageSize,
          offset: sync.offset,
        );
        if (gone()) return;
        final ids = [for (final t in page.transactions) t.id];
        // A wallet that ignores the offset lists the same page again.
        final repeated = ids.isNotEmpty && listEquals(ids, previous);
        previous = ids;
        await _history.save(wallet.id, page.transactions);
        sync = HistorySync(
          offset: sync.offset + page.listed,
          complete: page.listed == 0 || repeated,
        );
        await _history.writeSync(wallet.id, sync);
        _historyChanged();
      }
    } catch (_) {
      // Picked up again at the next refresh.
    }
  }

  void _historyChanged() {
    if (!_closed) _historyRevision.value++;
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
    // After any save still in flight for it.
    final saving = [?_refreshing[wallet.id], ?_loadingOlder[wallet.id]];
    unawaited(
      Future.wait(saving)
          .then((_) => _history.delete(wallet.id))
          .catchError((Object _) {}),
    );
    _historyChanged();
  }

  void _listChanged() {
    _listRevision.value++;
    notifyListeners();
  }

  /// Stops syncing and closes the history, when Lumen locks.
  Future<void> close() async {
    dispose();
    await _history.close();
  }

  @override
  void dispose() {
    _closed = true;
    _listRevision.dispose();
    _historyRevision.dispose();
    super.dispose();
  }
}
