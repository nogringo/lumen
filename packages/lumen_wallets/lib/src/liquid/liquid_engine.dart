import '../wallet.dart';

/// How addresses derive from a recovery phrase. Lumen creates native segwit
/// wallets. Other apps may have used nested segwit with the same phrase.
enum LiquidScript {
  /// BIP84.
  nativeSegwit,

  /// BIP49.
  nestedSegwit,
}

enum PhraseProblem {
  /// Not 12 words.
  wordCount,

  /// A word outside the BIP39 English list.
  unknownWord,

  /// Every word is valid but they do not form a phrase, as after a typo that
  /// lands on another word.
  checksum,
}

enum LiquidChainError {
  /// The chain server did not answer, or not usefully. Nothing was sent.
  unreachable,

  /// The chain server refused the transaction.
  rejected,
  insufficientFunds,
  invalidAddress,
  wrongNetwork,
  other,
}

class LiquidChainException implements Exception {
  const LiquidChainException(this.error, [this.message = '']);

  final LiquidChainError error;
  final String message;

  @override
  String toString() => 'LiquidChainException(${error.name}: $message)';
}

/// Creates and opens Liquid wallets: LWK in Lumen, a fake in tests.
abstract interface class LiquidEngine {
  /// Completes once the engine can be used, which may mean loading a library.
  Future<void> ready();

  /// A new 12-word recovery phrase.
  String generatePhrase();

  /// What is wrong with [phrase], or null when it is valid.
  PhraseProblem? phraseProblem(String phrase);

  /// [state] is what [LiquidChain.state] returned last time.
  Future<LiquidChain> open({
    required String phrase,
    required ChainNetwork network,
    required LiquidScript script,
    required String esploraUrl,
    required List<String> state,
  });
}

/// One Liquid wallet as LWK sees it. Every method throws a
/// [LiquidChainException] when it fails.
abstract interface class LiquidChain {
  /// Fetches what changed on chain. Returns whether anything did.
  Future<bool> sync();

  /// What to pass to [LiquidEngine.open] next time.
  Future<List<String>> state();

  /// L-BTC, in sats.
  Future<int> balance();

  Future<int> tipHeight();

  /// The first receiving address not paid yet.
  Future<String> nextAddress();

  /// Newest first.
  Future<List<ChainTx>> transactions();

  Future<LiquidDraft> prepareSend(String address, int sats);

  Future<LiquidSigned> sign(LiquidDraft draft);

  /// Safe to call again for the same [signed] transaction.
  Future<void> broadcast(LiquidSigned signed);
}

final class ChainTx {
  const ChainTx({
    required this.txid,
    required this.balance,
    required this.fee,
    this.height,
    this.timestamp,
    this.received = const [],
  });

  final String txid;

  /// The wallet's net L-BTC change, fee included.
  final int balance;
  final int fee;

  /// Null while in the mempool.
  final int? height;

  /// The block time.
  final DateTime? timestamp;

  /// The wallet's receiving addresses it pays.
  final List<String> received;
}

abstract interface class LiquidDraft {
  int get fee;
}

abstract interface class LiquidSigned {
  String get txid;
}
