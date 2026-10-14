// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:convert';

import 'package:bech32/bech32.dart';
import 'package:clock/clock.dart';
import 'package:cryptography/cryptography.dart' show Sha256;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lumen/app.dart';
import 'package:lumen/lock/app_gate.dart';
import 'package:lumen/lock/app_lock.dart';
import 'package:lumen/lock/lock_store.dart';
import 'package:lumen/lock/sealed_storage.dart';
import 'package:lumen/wallets/wallet_cache.dart';
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

  List<Transaction> transactions = [];
  ActivityError? activityError;

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

  SendError? sendError;
  int feeSats = 0;
  final List<Invoice> paid = [];

  /// When set, payments wait for it to complete.
  Completer<void>? paymentGate;

  @override
  Future<Payment> payInvoice(Invoice invoice) async {
    await Future<void>.delayed(Duration.zero);
    await paymentGate?.future;
    if (sendError case final error?) throw SendException(error);
    paid.add(invoice);
    balance -= invoice.sats + feeSats;
    return Payment(feeSats: feeSats, preimage: 'preimage');
  }

  @override
  Future<List<Transaction>> fetchTransactions({int limit = 10}) async {
    await Future<void>.delayed(Duration.zero);
    if (activityError case final error?) throw ActivityException(error);
    return transactions.take(limit).toList();
  }

  @override
  Future<void> rename(String name) async => this.name = name;

  @override
  Future<void> remove() async => removed = true;
}

Transaction tx(
  String id, {
  int sats = 1000,
  bool incoming = false,
  int minutesAgo = 0,
  int days = 0,
  String? description,
}) => Transaction(
  id: id,
  direction: incoming
      ? TransactionDirection.incoming
      : TransactionDirection.outgoing,
  sats: sats,
  at: clock.now().subtract(Duration(days: days, minutes: minutesAgo)),
  description: description,
);

/// Keeps tests fast: Argon2 has its own test.
class FastKdf implements PassphraseKdf {
  const FastKdf();

  @override
  Future<List<int>> derive(
    String passphrase,
    List<int> salt,
    KdfCost cost,
  ) async => (await Sha256().hash([...utf8.encode(passphrase), ...salt])).bytes;
}

class FakeSource implements WalletSource {
  FakeSource(this.wallets);

  final List<Wallet> wallets;

  @override
  Future<List<Wallet>> load() async => wallets;
}

/// Real sources over an in-memory store, for screens that need them.
WalletSources memorySources({http.Client? httpClient}) => WalletSources.create(
  repo: MemWalletsRepo(),
  eventVerifier: Bip340EventVerifier(),
  httpClient: httpClient,
);

/// A BOLT11 invoice that decodes like a real one, with a blank signature.
/// Without [sats], it leaves the amount to the payer.
String fakeBolt11(
  int? sats, {
  String? description,
  DateTime? createdAt,
  Duration expiry = const Duration(hours: 1),
}) {
  List<int> number(int value, [int length = 1]) {
    final words = <int>[];
    for (; value > 0 || words.length < length; value ~/= 32) {
      words.insert(0, value % 32);
    }
    return words;
  }

  List<int> words(List<int> bytes) {
    final out = <int>[];
    var buffer = 0;
    var bits = 0;
    for (final byte in bytes) {
      buffer = (buffer << 8 | byte) & 0xfff;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        out.add(buffer >> bits & 31);
      }
    }
    if (bits > 0) out.add(buffer << (5 - bits) & 31);
    return out;
  }

  List<int> tag(int type, List<int> data) => [
    type,
    ...number(data.length, 2),
    ...data,
  ];

  final created = (createdAt ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
  final data = [
    ...number(created, 7),
    ...tag(1, words([for (var i = 0; i < 32; i++) ((sats ?? 0) + i) % 256])),
    if (description != null) ...tag(13, words(utf8.encode(description))),
    ...tag(6, number(expiry.inSeconds)),
    ...List.filled(104, 0),
  ];
  final hrp = sats == null ? 'lnbc' : 'lnbc${sats * 10}n';
  return const Bech32Codec().encode(Bech32(hrp, data), 4000);
}

Future<WalletsController> loadedController(
  List<Wallet> wallets, {
  WalletCache? cache,
}) async {
  final controller = WalletsController([
    FakeSource(wallets),
  ], cache: cache ?? MemoryWalletCache());
  await controller.load();
  return controller;
}

/// A gate whose sessions all use [sources] and [wallets].
AppGate testGate(
  WalletSources sources,
  WalletsController wallets, {
  LockStore? lockStore,
}) => AppGate(
  lock: AppLock(lockStore ?? MemoryLockStore(), kdf: const FastKdf()),
  storage: SealedStorage(),
  openSession: () async => LumenSession(sources, wallets),
);

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
  final gate = testGate(sources, controller!);
  await tester.runAsync(gate.start);
  await tester.pumpWidget(LumenApp(gate: gate));
  await tester.runAsync(controller.refreshAll);
  await tester.pumpAndSettle();
  return controller;
}
