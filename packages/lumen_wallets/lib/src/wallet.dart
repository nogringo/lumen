enum WalletKind { lightning, ecash, onchain, liquid }

abstract interface class Wallet {
  String get id;
  String get name;
  WalletKind get kind;

  /// Balance in sats.
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
