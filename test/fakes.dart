// ignore_for_file: experimental_member_use

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
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

  ReceiveError? receiveError;
  Duration invoiceLifetime = const Duration(hours: 1);
  final List<int> invoiceAmounts = [];
  StreamController<void>? _payment;

  @override
  Future<int> fetchBalance() async {
    fetchCount++;
    await Future<void>.delayed(Duration.zero);
    if (error case final error?) throw BalanceException(error);
    return balance;
  }

  @override
  Future<Invoice> createInvoice(int sats) async {
    await Future<void>.delayed(Duration.zero);
    if (receiveError case final error?) throw ReceiveException(error);
    invoiceAmounts.add(sats);
    return Invoice(
      request: 'lnbc${sats}n1p${'q' * 200}x0',
      sats: sats,
      paymentHash: 'hash$sats',
      expiresAt: DateTime.now().add(invoiceLifetime),
    );
  }

  @override
  Stream<void> watchPayment(Invoice invoice) {
    _payment = StreamController<void>();
    return _payment!.stream;
  }

  /// Pays the last invoice being watched.
  void pay() => _payment
    ?..add(null)
    ..close();

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

const phoneSize = Size(390, 844);
const desktopSize = Size(1440, 900);

Future<WalletsController> pumpLumen(
  WidgetTester tester,
  WalletSources sources, {
  required List<FakeWallet> wallets,
  Size size = phoneSize,
  Brightness brightness = Brightness.light,
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearAllTestValues);

  final controller = await tester.runAsync(() => loadedController(wallets));
  await tester.pumpWidget(testApp(sources, controller!));
  await tester.runAsync(controller.refreshAll);
  await tester.pumpAndSettle();
  return controller;
}
