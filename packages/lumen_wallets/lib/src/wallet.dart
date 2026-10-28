enum WalletKind { lightning, ecash, onchain, liquid }

enum BalanceError {
  /// The wallet or its relays did not answer.
  unreachable,

  /// The wallet answered, but this connection may not read the balance.
  noPermission,
}

class BalanceException implements Exception {
  const BalanceException(this.error);

  final BalanceError error;

  @override
  String toString() => 'BalanceException(${error.name})';
}

enum ReceiveError {
  /// The wallet or its relays did not answer, or refused the request.
  unreachable,

  /// The wallet answered, but this connection may not create invoices.
  noPermission,
}

class ReceiveException implements Exception {
  const ReceiveException(this.error);

  final ReceiveError error;

  @override
  String toString() => 'ReceiveException(${error.name})';
}

enum ActivityError {
  /// The wallet or its relays did not answer.
  unreachable,

  /// The wallet answered, but this connection may not list transactions.
  noPermission,
}

enum SendError {
  /// The wallet or its relays did not answer, so nothing was sent.
  unreachable,

  /// The wallet answered, but this connection may not pay invoices.
  noPermission,

  /// The wallet holds less than the amount and its fee reserve.
  insufficientBalance,

  /// The connection's spending budget is used up.
  budgetExceeded,

  /// The wallet tried and the payment failed, for example with no route.
  failed,

  /// The wallet got the request but did not say how it ended in time. The
  /// payment may still go through.
  unconfirmed,

  /// An address on another network than the wallet's, such as testnet.
  wrongNetwork,
}

class SendException implements Exception {
  const SendException(this.error);

  final SendError error;

  @override
  String toString() => 'SendException(${error.name})';
}

class ActivityException implements Exception {
  const ActivityException(this.error);

  final ActivityError error;

  @override
  String toString() => 'ActivityException(${error.name})';
}

enum TransactionDirection { incoming, outgoing }

/// A payment into or out of one wallet. Lightning payments are listed once
/// settled, chain payments as soon as they are seen.
final class Transaction {
  const Transaction({
    required this.id,
    required this.direction,
    required this.sats,
    required this.at,
    this.description,
    this.paymentHash,
    this.feeSats,
    this.preimage,
    this.invoice,
    this.txid,
    this.confirmations,
  });

  /// Unique within its wallet, such as the payment hash or the txid.
  final String id;
  final TransactionDirection direction;
  final int sats;

  /// When the payment settled, or was first seen while pending.
  final DateTime at;
  final String? description;

  /// Lightning only, like [preimage] and [invoice].
  final String? paymentHash;

  /// The fee the wallet paid, when it says.
  final int? feeSats;

  /// Proof that a Lightning payment was made.
  final String? preimage;

  /// The BOLT11 request that was paid.
  final String? invoice;

  /// The chain transaction. Chain payments only, like [confirmations].
  final String? txid;

  /// How many blocks confirm the payment, zero while it waits in the mempool.
  final int? confirmations;

  bool get isIncoming => direction == TransactionDirection.incoming;

  bool get isPending => confirmations == 0;
}

/// One page of a wallet's transaction list, newest first.
final class TransactionPage {
  const TransactionPage(this.transactions, {required this.listed});

  /// The settled payments on this page.
  final List<Transaction> transactions;

  /// How many entries the wallet listed, pending and failed ones included.
  /// The next page starts this many entries further. Zero means the list
  /// ended.
  final int listed;
}

/// What a wallet is asked to pay, or gives to be paid.
sealed class PaymentRequest {
  const PaymentRequest();

  /// The amount asked, when the request sets one.
  int? get sats;
}

/// A BOLT11 Lightning invoice.
final class Invoice extends PaymentRequest {
  const Invoice({
    required this.request,
    required this.sats,
    this.paymentHash,
    this.expiresAt,
    this.description,
  });

  /// The BOLT11 payment request.
  final String request;

  @override
  final int sats;
  final String? paymentHash;
  final DateTime? expiresAt;
  final String? description;

  bool isExpiredAt(DateTime now) =>
      expiresAt != null && !now.isBefore(expiresAt!);
}

enum ChainNetwork { liquid, liquidTestnet }

/// An address on a chain, such as a Liquid address.
final class ChainAddress extends PaymentRequest {
  const ChainAddress(this.address, {required this.network, this.sats});

  final String address;
  final ChainNetwork network;

  @override
  final int? sats;
}

/// A payment checked and ready to send, from [Wallet.prepareSend]. Wallets
/// extend it to keep what they need to send it.
base class SendQuote {
  const SendQuote({required this.request, required this.sats, this.feeSats});

  final PaymentRequest request;
  final int sats;

  /// The fee, when the wallet knows it before sending.
  final int? feeSats;
}

/// A payment the wallet sent.
final class Payment {
  const Payment({required this.feeSats, this.preimage, this.txid});

  final int feeSats;

  /// Lightning only.
  final String? preimage;

  /// Chain only.
  final String? txid;
}

/// What a wallet can do, whatever its connection allows.
enum WalletCapability {
  /// [Wallet.createInvoice].
  receiveInvoice,

  /// [Wallet.nextAddress].
  receiveAddress,

  /// Sending to an [Invoice].
  payInvoice,

  /// Sending to a [ChainAddress].
  payAddress,
}

abstract interface class Wallet {
  String get id;
  String get name;
  WalletKind get kind;

  /// The `name@domain` address that pays into this wallet, when known.
  String? get lightningAddress;

  /// The string that connects another app to this wallet, such as a NIP-47
  /// connection URI, or null when it has none. It grants what this connection
  /// grants, so it is a secret.
  Future<String?> connectionString();

  /// Methods outside these throw an [UnsupportedError].
  Set<WalletCapability> get capabilities;

  /// Balance in sats. Throws a [BalanceException] when it cannot be read.
  Future<int> fetchBalance();

  /// Throws a [ReceiveException] when the wallet cannot create it.
  Future<Invoice> createInvoice(int sats);

  /// An address that has not received yet. Throws a [ReceiveException] when
  /// the wallet cannot give one.
  Future<ChainAddress> nextAddress();

  /// Emits the payment of [request] as soon as the wallet sees it, again
  /// once a pending one confirms, then closes. Cancelling the subscription
  /// stops watching.
  Stream<Transaction> watchPayment(PaymentRequest request);

  /// Checks that [request] can be paid and quotes the fee, without sending
  /// anything. [sats] is the amount for a request that sets none. Throws a
  /// [SendException] when it cannot be paid.
  Future<SendQuote> prepareSend(PaymentRequest request, {int? sats});

  /// Sends the payment [quote] describes. Throws a [SendException] when it
  /// did not go through, or may not have.
  Future<Payment> confirmSend(SendQuote quote);

  /// Up to [limit] transactions, starting [offset] entries from the newest.
  /// Throws an [ActivityException] when they cannot be read.
  Future<TransactionPage> fetchTransactions({int limit = 10, int offset = 0});

  Future<void> rename(String name);

  /// Forgets the wallet in Lumen. Funds held elsewhere, as behind an NWC
  /// connection, stay there. A wallet whose keys live in Lumen takes its
  /// funds with it, unless its recovery phrase is backed up.
  Future<void> remove();
}

/// Strings saved by key, such as the platform's secure storage.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// A [KeyValueStore] that lasts as long as the object, for tests and scripts.
final class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

/// Loads the saved wallets of one kind. Adding a wallet is specific to each
/// source, since every kind needs different input.
abstract interface class WalletSource {
  Future<List<Wallet>> load();
}
