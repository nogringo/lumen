import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

import 'balance_store.dart';

@immutable
class BalanceState {
  const BalanceState({this.sats, this.loading = false, this.error});

  final int? sats;
  final bool loading;
  final BalanceError? error;

  bool get failed => error != null;
}

class WalletsController extends ChangeNotifier {
  WalletsController(this._sources, {required this._store});

  final List<WalletSource> _sources;
  final BalanceStore _store;
  final List<Wallet> _wallets = [];
  final Map<String, BalanceState> _balances = {};
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

  bool get isRefreshing => _refreshing.isNotEmpty;

  int get unavailableCount => _wallets.where((w) => balanceOf(w).failed).length;

  Future<void> load() async {
    for (final source in _sources) {
      _wallets.addAll(await source.load());
    }
    final saved = await Future.wait([
      for (final w in _wallets) _store.read(w.id),
    ]);
    for (final (i, sats) in saved.indexed) {
      if (sats != null) _balances[_wallets[i].id] = BalanceState(sats: sats);
    }
    _listChanged();
    refreshAll();
  }

  Future<void> refreshAll() =>
      Future.wait([for (final w in _wallets) refresh(w)]);

  Future<void> refresh(Wallet wallet) =>
      _refreshing[wallet.id] ??= _refresh(wallet);

  Future<void> _refresh(Wallet wallet) async {
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
    } finally {
      _refreshing.remove(wallet.id);
    }
    if (!_wallets.contains(wallet)) return;
    _balances[wallet.id] = result;
    notifyListeners();
    if (result.sats case final sats?) {
      unawaited(_store.write(wallet.id, sats).catchError((Object _) {}));
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
    _listChanged();
    unawaited(_store.delete(wallet.id).catchError((Object _) {}));
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
