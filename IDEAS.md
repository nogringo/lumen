# Lumen ideas

## Supported funding sources

In implementation order:

1. **NWC** (Nostr Wallet Connect, NIP-47): connect a remote Lightning wallet.
2. **NIP-60**: Cashu wallet stored on Nostr relays.
3. **Bitcoin on-chain**: support regular on-chain Bitcoin transactions.
4. **Liquid**: support the Liquid network.

## Offline transaction history

Every transaction Lumen has seen stays readable offline. Internet is only needed to fetch what is new. Build it together with the "See all" activity screen, not by growing the launch cache (`WalletCache`, the last 10 per wallet), which stays for Home.

- **Lumen keeps its own copy.** The source of truth depends on the wallet: the NWC service, NIP-60 history events on relays, or the blockchain through an indexer for on-chain and Liquid. Some NWC services keep a short history, so Lumen's copy can end up more complete than theirs.
- **An encrypted local database.** Payment history is as private as the balance. Secure storage is meant for small secrets and is limited on web, and ndk_flutter's `FlutterSecureStorageWalletsRepo` rewrites every wallet and transaction under one key on each save, so neither scales to thousands of entries. Candidates: SQLite with SQLCipher through drift, or encrypted sembast (ndk already ships a `SembastWalletsRepo`). It must work on web too.
- **Incremental sync.** NWC `list_transactions` takes `from`, `until`, `limit` and `offset`: ask only for what is newer than the last known transaction, dedupe by payment hash, and page through older history in the background after a wallet is added.
- **What still needs a connection.** Payments made while the device was offline, or before the wallet was added to Lumen, need one sync to show up.
