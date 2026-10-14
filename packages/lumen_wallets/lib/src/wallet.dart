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

abstract interface class Wallet {
  String get id;
  String get name;
  WalletKind get kind;

  /// Balance in sats. Throws a [BalanceException] when it cannot be read.
  Future<int> fetchBalance();

  Future<void> rename(String name);

  /// Forgets the wallet in Lumen. Funds stay where they are.
  Future<void> remove();
}

/// Loads the saved wallets of one kind. Adding a wallet is specific to each
/// source, since every kind needs different input.
abstract interface class WalletSource {
  Future<List<Wallet>> load();
}
