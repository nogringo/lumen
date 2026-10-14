// ignore_for_file: experimental_member_use

import 'package:flutter/widgets.dart';
import 'package:lumen/app.dart';
import 'package:lumen/wallets/balance_store.dart';
import 'package:lumen/wallets/wallets_controller.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:ndk/data_layer/repositories/wallets/mem_wallets_repo.dart';
import 'package:ndk/ndk.dart' show Bip340EventVerifier;

class FakeWallet implements Wallet {
  FakeWallet(this.id, this.name, {this.balance = 0, this.error});

  @override
  final String id;

  @override
  String name;

  @override
  WalletKind get kind => WalletKind.lightning;

  int balance;
  BalanceError? error;
  int fetchCount = 0;
  bool removed = false;

  @override
  Future<int> fetchBalance() async {
    fetchCount++;
    await Future<void>.delayed(Duration.zero);
    if (error case final error?) throw BalanceException(error);
    return balance;
  }

  @override
  Future<void> rename(String name) async => this.name = name;

  @override
  Future<void> remove() async => removed = true;
}

class FakeSource implements WalletSource {
  FakeSource(this.wallets);

  final List<Wallet> wallets;

  @override
  Future<List<Wallet>> load() async => wallets;
}

/// Real sources over an in-memory store, for screens that need them.
WalletSources memorySources() => WalletSources.create(
  repo: MemWalletsRepo(),
  eventVerifier: Bip340EventVerifier(),
);

Future<WalletsController> loadedController(
  List<Wallet> wallets, {
  BalanceStore? store,
}) async {
  final controller = WalletsController([
    FakeSource(wallets),
  ], store: store ?? MemoryBalanceStore());
  await controller.load();
  return controller;
}

Widget testApp(WalletSources sources, WalletsController wallets) =>
    LumenApp(sources: sources, wallets: wallets);
