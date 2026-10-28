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
  /// Neither 12 nor 24 words.
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

  /// The chain server kept asking to slow down, after LWK had already
  /// waited about a minute for it.
  rateLimited,

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

/// Where a Liquid wallet reads the chain and sends its transactions.
final class LiquidServers {
  const LiquidServers({this.waterfalls, required this.esplora});

  /// Tried first. It scans the whole wallet in one request instead of one
  /// per address, but learns the wallet's descriptor to do so.
  final String? waterfalls;

  /// Used when [waterfalls] is null or fails.
  final String esplora;

  @override
  bool operator ==(Object other) =>
      other is LiquidServers &&
      other.waterfalls == waterfalls &&
      other.esplora == esplora;

  @override
  int get hashCode => Object.hash(waterfalls, esplora);
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
    required LiquidServers servers,
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

  /// The page of [txid] on [explorer], a URL ending with `/`, with what it
  /// needs to unblind the wallet's own amounts in its fragment. Null when
  /// the wallet does not know the transaction.
  Future<String?> explorerUrl(String txid, String explorer);

  Future<LiquidDraft> prepareSend(String address, int sats);

  /// The whole L-BTC balance, the fee taken out of it.
  Future<LiquidDraft> prepareSendAll(String address);

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
  /// What the recipient gets, fee excluded.
  int get sats;
  int get fee;
}

abstract interface class LiquidSigned {
  String get txid;
}
