// ignore_for_file: experimental_member_use

import 'dart:async';
import 'dart:convert';

import 'package:bech32/bech32.dart';
import 'package:clock/clock.dart';
import 'package:cryptography/cryptography.dart' show Sha256;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lumen/app.dart';
import 'package:lumen/lock/app_gate.dart';
import 'package:lumen/lock/app_lock.dart';
import 'package:lumen/lock/lock_store.dart';
import 'package:lumen/lock/sealed_storage.dart';
import 'package:lumen/settings/language.dart';
import 'package:lumen/wallets/history_store.dart';
import 'package:lumen/wallets/wallet_cache.dart';
import 'package:lumen/wallets/wallets_controller.dart';
import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:lumen_wallets/liquid_engine.dart';
import 'package:ndk/data_layer/repositories/wallets/mem_wallets_repo.dart';
import 'package:ndk/ndk.dart' show Bip340EventVerifier;

class FakeWallet implements Wallet {
  FakeWallet(
    this.id,
    this.name, {
    this.balance = 0,
    this.error,
    this.lightningAddress,
    this.capabilities = const {
      WalletCapability.receiveInvoice,
      WalletCapability.payInvoice,
    },
  }) : network = null;

  /// Receives on an address and pays addresses, as a Liquid wallet does.
  FakeWallet.liquid(
    this.id,
    this.name, {
    this.balance = 0,
    this.network = ChainNetwork.liquid,
  }) : lightningAddress = null,
       capabilities = const {
         WalletCapability.receiveAddress,
         WalletCapability.payAddress,
         WalletCapability.payAll,
       };

  @override
  final String id;

  @override
  String name;

  @override
  WalletKind get kind => capabilities.contains(WalletCapability.payAddress)
      ? WalletKind.liquid
      : WalletKind.lightning;

  @override
  final String? lightningAddress;

  @override
  final Set<WalletCapability> capabilities;

  @override
  final ChainNetwork? network;

  String? connection = 'nostr+walletconnect://wallet?secret=fake';

  @override
  Future<String?> connectionString() async => connection;

  int balance;
  BalanceError? error;
  int fetchCount = 0;
  bool removed = false;

  /// Newest first.
  List<Transaction> transactions = [];
  ActivityError? activityError;

  /// Lists every page from the newest, like a wallet that ignores offsets.
  bool ignoresOffset = false;
  final List<int> listedOffsets = [];

  ReceiveError? receiveError;
  Duration invoiceLifetime = const Duration(hours: 1);
  final List<int> invoiceAmounts = [];
  StreamController<Transaction>? _payment;
  PaymentRequest? _watched;

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

  int addressCount = 0;

  @override
  Future<ChainAddress> nextAddress() async {
    if (!capabilities.contains(WalletCapability.receiveAddress)) {
      throw UnsupportedError('No address');
    }
    await Future<void>.delayed(Duration.zero);
    if (receiveError case final error?) throw ReceiveException(error);
    addressCount++;
    return const ChainAddress(liquidAddress, network: ChainNetwork.liquid);
  }

  @override
  Stream<Transaction> watchPayment(PaymentRequest request) {
    _watched = request;
    _payment = StreamController<Transaction>();
    return _payment!.stream;
  }

  /// Pays the last request being watched, with [sats] when it sets no
  /// amount. A payment to an address stays pending until [confirm].
  void pay([int? sats]) {
    final request = _watched!;
    final onChain = request is ChainAddress;
    _payment!.add(
      _received(sats ?? request.sats!, confirmations: onChain ? 0 : null),
    );
    if (!onChain) _payment!.close();
  }

  void confirm() {
    final pending = _lastReceived!;
    _payment!
      ..add(_received(pending.sats, confirmations: 1))
      ..close();
  }

  Transaction? _lastReceived;

  Transaction _received(int sats, {int? confirmations}) =>
      _lastReceived = Transaction(
        id: 'paid',
        direction: TransactionDirection.incoming,
        sats: sats,
        at: DateTime.now(),
        txid: confirmations == null ? null : 'paid',
        confirmations: confirmations,
      );

  SendError? sendError;

  /// Thrown while preparing, before anything is sent.
  SendError? prepareError;
  int feeSats = 0;

  /// The fee quoted before sending, as a Liquid wallet does.
  int? quotedFeeSats;
  final List<SendQuote> paid = [];

  /// When set, payments wait for it to complete.
  Completer<void>? paymentGate;

  @override
  Future<SendQuote> prepareSend(PaymentRequest request, {int? sats}) async {
    await Future<void>.delayed(Duration.zero);
    if (prepareError case final error?) throw SendException(error);
    return SendQuote(
      request: request,
      sats: request.sats ?? sats!,
      feeSats: quotedFeeSats,
    );
  }

  /// Sends [balance], less [quotedFeeSats].
  @override
  Future<SendQuote> prepareSendAll(ChainAddress address) async {
    await Future<void>.delayed(Duration.zero);
    if (prepareError case final error?) throw SendException(error);
    return SendQuote(
      request: address,
      sats: balance - (quotedFeeSats ?? 0),
      feeSats: quotedFeeSats,
    );
  }

  @override
  Future<Payment> confirmSend(SendQuote quote) async {
    await Future<void>.delayed(Duration.zero);
    await paymentGate?.future;
    if (sendError case final error?) throw SendException(error);
    paid.add(quote);
    final fee = quote.feeSats ?? feeSats;
    balance -= quote.sats + fee;
    return quote.request is ChainAddress
        ? Payment(feeSats: fee, txid: sentTxid)
        : Payment(feeSats: fee, preimage: 'preimage');
  }

  StreamController<Transaction>? _sent;

  @override
  Stream<Transaction> watchConfirmation(String txid) {
    _sent = StreamController<Transaction>();
    return _sent!.stream;
  }

  /// Confirms the chain payment sent last, being watched.
  void confirmSent() {
    final quote = paid.last;
    _sent!
      ..add(
        Transaction(
          id: sentTxid,
          direction: TransactionDirection.outgoing,
          sats: quote.sats,
          at: DateTime.now(),
          feeSats: quote.feeSats,
          txid: sentTxid,
          confirmations: 1,
        ),
      )
      ..close();
  }

  static const sentTxid =
      'c3a1f00dfeedbeefc3a1f00dfeedbeefc3a1f00dfeedbeefc3a1f00dfeed5e7d';

  @override
  Future<TransactionPage> fetchTransactions({
    int limit = 10,
    int offset = 0,
  }) async {
    await Future<void>.delayed(Duration.zero);
    if (activityError case final error?) throw ActivityException(error);
    listedOffsets.add(offset);
    final page = transactions
        .skip(ignoresOffset ? 0 : offset)
        .take(limit)
        .toList();
    return TransactionPage(page, listed: page.length);
  }

  /// Read from [transactions], as the chain has them now.
  @override
  Future<ChainDetails?> chainDetails(String txid) async {
    if (network == null) throw UnsupportedError('No chain');
    await Future<void>.delayed(Duration.zero);
    for (final t in transactions) {
      if (t.txid == txid) {
        return ChainDetails(
          t,
          explorer: Uri.parse('https://liquid.network/tx/$txid#blinded=1,2'),
        );
      }
    }
    return null;
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
  int? feeSats,
  String? preimage,
  String? invoice,

  /// Makes it a chain payment, pending at zero.
  int? confirmations,
}) => Transaction(
  id: id,
  direction: incoming
      ? TransactionDirection.incoming
      : TransactionDirection.outgoing,
  sats: sats,
  at: clock.now().subtract(Duration(days: days, minutes: minutesAgo)),
  description: description,
  paymentHash: confirmations == null ? id : null,
  feeSats: feeSats,
  preimage: preimage,
  invoice: invoice,
  txid: confirmations == null ? null : id,
  confirmations: confirmations,
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

/// One Liquid chain for every wallet, read from memory.
final class FakeLiquidChain implements LiquidChain {
  int balanceSats = 0;
  int tip = 100;

  /// Newest first.
  List<ChainTx> txs = [];
  int syncs = 0;

  /// Thrown by every sync while set.
  LiquidChainException? syncError;

  /// Thrown when asked for an address while set.
  LiquidChainException? addressError;

  @override
  Future<bool> sync() async {
    syncs++;
    if (syncError case final error?) throw error;
    return true;
  }

  @override
  Future<List<String>> state() async => ['sync $syncs'];

  @override
  Future<int> balance() async => balanceSats;

  @override
  Future<int> tipHeight() async => tip;

  @override
  Future<String> nextAddress() async {
    if (addressError case final error?) throw error;
    return liquidAddress;
  }

  @override
  Future<List<ChainTx>> transactions() async => txs;

  @override
  Future<String?> explorerUrl(String txid, String explorer) async =>
      txs.any((tx) => tx.txid == txid) ? '${explorer}tx/$txid' : null;

  @override
  Future<LiquidDraft> prepareSend(String address, int sats) =>
      throw UnimplementedError();

  @override
  Future<LiquidDraft> prepareSendAll(String address) =>
      throw UnimplementedError();

  @override
  Future<LiquidSigned> sign(LiquidDraft draft) => throw UnimplementedError();

  @override
  Future<void> broadcast(LiquidSigned signed) => throw UnimplementedError();
}

final class FakeLiquidEngine implements LiquidEngine {
  final chain = FakeLiquidChain();

  /// Set to make the engine fail to start.
  bool unavailable = false;

  @override
  Future<void> ready() async {
    if (unavailable) throw StateError('No engine');
  }

  @override
  String generatePhrase() => liquidPhrase;

  /// What [phraseProblem] says of any 12 words.
  PhraseProblem? problem;

  @override
  PhraseProblem? phraseProblem(String phrase) =>
      [12, 24].contains(phrase.split(' ').length)
      ? problem
      : PhraseProblem.wordCount;

  @override
  Future<LiquidChain> open({
    required String phrase,
    required ChainNetwork network,
    required LiquidScript script,
    required LiquidServers servers,
    required List<String> state,
  }) async => chain;
}

const liquidPhrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

/// The first address of [liquidPhrase].
const liquidAddress =
    'lq1qqvxk052kf3qtkxmrakx50a9gc3smqad2ync54hzntjt980kfej9kkfe0247rp5h4yzmdftsahhw64uy8pzfe7cpg4fgykm7cv';

/// Real sources over in-memory stores, for screens that need them.
WalletSources memorySources({
  http.Client? httpClient,
  MemWalletsRepo? repo,
  LiquidEngine? liquidEngine,
  Set<ChainNetwork> liquidNetworks = const {ChainNetwork.liquid},
}) => WalletSources.create(
  repo: repo ?? MemWalletsRepo(),
  eventVerifier: Bip340EventVerifier(),
  liquidSecrets: MemoryKeyValueStore(),
  liquidChainState: MemoryKeyValueStore(),
  liquidNetworks: liquidNetworks,
  liquidEngine: liquidEngine ?? FakeLiquidEngine(),
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
  HistoryStore? history,
  Duration staleAfter = const Duration(seconds: 30),
}) async {
  final controller = WalletsController(
    [FakeSource(wallets)],
    cache: cache ?? MemoryWalletCache(),
    history: history ?? await HistoryStore.memory(),
    staleAfter: staleAfter,
  );
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
  required List<Wallet> wallets,
  Size size = phoneSize,
  Brightness brightness = Brightness.light,
  double textScale = 1,
  LanguageSetting? language,
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
  await tester.pumpWidget(
    LumenApp(
      gate: gate,
      language: language ?? LanguageSetting(MemoryLanguageStore()),
    ),
  );
  await tester.runAsync(() async {
    await controller.refreshAll();
    await Future.wait([
      for (final w in controller.wallets) controller.loadOlder(w),
    ]);
  });
  await tester.pumpAndSettle();
  return controller;
}

/// The haptic feedback types played so far, such as
/// `HapticFeedbackType.successNotification`.
List<String> watchHaptics(WidgetTester tester) {
  final played = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        played.add(call.arguments as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return played;
}

Future<void> expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}
