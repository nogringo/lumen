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

class ActivityException implements Exception {
  const ActivityException(this.error);

  final ActivityError error;

  @override
  String toString() => 'ActivityException(${error.name})';
}

enum TransactionDirection { incoming, outgoing }

/// A settled payment into or out of one wallet.
final class Transaction {
  const Transaction({
    required this.id,
    required this.direction,
    required this.sats,
    required this.at,
    this.description,
  });

  /// Unique within its wallet, such as the payment hash.
  final String id;
  final TransactionDirection direction;
  final int sats;

  /// When the payment settled.
  final DateTime at;
  final String? description;

  bool get isIncoming => direction == TransactionDirection.incoming;
}

/// A Lightning invoice that pays into one wallet.
final class Invoice {
  const Invoice({
    required this.request,
    required this.sats,
    this.paymentHash,
    this.expiresAt,
  });

  /// The BOLT11 payment request.
  final String request;
  final int sats;
  final String? paymentHash;
  final DateTime? expiresAt;

  bool isExpiredAt(DateTime now) =>
      expiresAt != null && !now.isBefore(expiresAt!);
}

abstract interface class Wallet {
  String get id;
  String get name;
  WalletKind get kind;

  /// Balance in sats. Throws a [BalanceException] when it cannot be read.
  Future<int> fetchBalance();

  /// Throws a [ReceiveException] when the wallet cannot create it.
  Future<Invoice> createInvoice(int sats);

  /// Emits once when [invoice] is paid, then closes. Cancelling the
  /// subscription stops watching.
  Stream<void> watchPayment(Invoice invoice);

  /// The latest settled transactions, newest first. Throws an
  /// [ActivityException] when they cannot be read.
  Future<List<Transaction>> fetchTransactions({int limit = 10});

  Future<void> rename(String name);

  /// Forgets the wallet in Lumen. Funds stay where they are.
  Future<void> remove();
}

/// Loads the saved wallets of one kind. Adding a wallet is specific to each
/// source, since every kind needs different input.
abstract interface class WalletSource {
  Future<List<Wallet>> load();
}
