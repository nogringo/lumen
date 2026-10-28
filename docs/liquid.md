# Liquid in Lumen

The plan for adding Liquid wallets to Lumen. Each step ends on a stable state that builds, passes its tests and can be committed on its own.

## Goal

A first Liquid release that lets someone:

- create a Liquid wallet from a new 12-word recovery phrase, or restore one from an existing phrase;
- see its L-BTC balance and transactions next to their other wallets, in the shared total and activity feed;
- receive to a Liquid address shown as a QR code;
- send to a Liquid address or a `liquidnetwork:` payment URI, with the fee shown before confirming;
- do all of this on the six platforms Lumen ships on, with the same accessibility bar as the rest of the app.

Out of scope for this release, listed in [Later](#later): Lightning payments from a Liquid wallet, assets other than L-BTC, watch-only wallets and hardware signers.

## What is already there

- `WalletKind.liquid` exists in [wallet.dart](../packages/lumen_wallets/lib/src/wallet.dart), with an icon, a color and a label in [wallet_kind_style.dart](../lib/widgets/wallet_kind_style.dart) and `kindLiquid` in every locale.
- The `Wallet` interface is shaped around Lightning: `createInvoice`, `watchPayment(Invoice)`, `payInvoice(Invoice)`, and a `Transaction` whose optional fields are Lightning ones.
- Wallets are saved through ndk's `WalletsRepo`, which only knows ndk's own wallet types. Liquid needs its own store.
- `Wallet.remove()` promises that "funds stay where they are". That holds for NWC. For a wallet whose only key lives in Lumen, removing it without a backup loses the funds.
- `spike_cdk_web/` already proved flutter_rust_bridge with a Rust wallet library on every platform, web included.

## Decisions to make first

### How to call LWK

[LWK](https://github.com/Blockstream/lwk) (Blockstream's Liquid Wallet Kit, in Rust) is the library to build on. There are two ways to reach it from Dart:

| | `lwk` on pub.dev | Our own Rust crate over flutter_rust_bridge |
|---|---|---|
| Maintained by | Bull Bitcoin ([lwk-dart](https://github.com/SatoshiPortal/lwk-dart)) | us |
| Platforms listed | Android, iOS, Linux, macOS | all six, if the spike confirms it |
| Web | not listed | LWK already builds for wasm (`lwk_wasm` runs in production web wallets) |
| Windows | not listed | to check in the spike |
| API surface | what the bindings expose | exactly what Lumen needs, nothing more |
| Cost | a dependency | a Rust toolchain in CI and releases, and the bridge to maintain |

Decided: our own crate. The spike (step 0) ran it on every platform the `lwk` package leaves out but web. The NIP-60 work will need a Rust bridge for CDK anyway, so one crate (say `packages/lumen_core`) can carry both libraries and the toolchain cost is paid once.

### Which chain backend

Decided: Waterfalls, with Esplora as the fallback. Electrum speaks raw TCP, which browsers cannot open, so the backend has to be HTTP. Waterfalls scans the whole wallet in one request, where Esplora needs one per address: an empty wallet syncs in about 0.25 s, against 6 to 8 s on Blockstream's Esplora, and a testnet wallet of 561 transactions syncs in 37 s, where liquid.network kept dropping the connection and then stopped answering for a while. In exchange, the Waterfalls server receives the wallet descriptor and can follow every past and future transaction. LWK encrypts the descriptor to the server's key, which keeps it out of URLs and logs on the way, but the server itself reads it.

Each sync and each broadcast goes to Waterfalls first, and to Esplora when Waterfalls fails. Sending a transaction to both is safe: a server that already has it counts as a success. A Waterfalls server that hangs instead of failing delays the fallback, since requests have no timeout and LWK retries a 429 or 503 for about a minute.

Default servers, on mainnet and testnet: `waterfalls.liquidwebwallet.org` (the Liquid Web Wallet's Waterfalls), then `liquid.network` (mempool.space's Esplora for Liquid). Both answer browsers (CORS). Blockstream's public Esplora caps unauthenticated use at 700 requests per hour per IP, and one sync costs 85 to 180 requests, so it cannot be the fallback without an API key.

### When to check the backup

Decided: before the wallet exists. A new wallet cannot receive until its owner has written down the 12 words and typed some of them back (step 4).

### Which descriptor

Decided: new wallets use LWK's single-signature default, `ct(slip77(...),elwpkh(...))` on `m/84'/1776'/0'`, with the SLIP-77 master blinding key. The Blockstream app and Aqua are built on GDK, which discovers both native (BIP84) and nested (BIP49) segwit accounts when restoring. So restoring looks for a history on BIP84, then on BIP49, and keeps the one that has it (`LiquidWalletSource.discover`). Only the first account of each is checked.

## Steps

### 0. Spike (done)

A throwaway project in `spike_lwk/` (git-ignored, like `spike_cdk_web/`): a Rust crate on `lwk_wollet` and `lwk_signer` 0.19.0, bridged with flutter_rust_bridge 2.13.0, and an integration test that creates a wallet, syncs on Liquid testnet, reads balance and history, saves and restores the wallet state, quotes a fee and sends a real transaction.

| Platform | Result |
|---|---|
| macOS | everything works |
| iOS simulator | everything works |
| Android emulator | everything works |
| Web, Chrome and Safari | everything works, single-threaded build, no COOP/COEP headers needed |
| Linux | the crate's tests pass in Docker, Flutter app not run |
| Windows | not tested, left to CI (step 9) |

What it taught us:

- **Sync speed.** LWK's Esplora client fetches address histories one by one. A small patch fetching them 4 at a time took a sync from 17 s to about 4 s on Blockstream and 1 to 2 s on liquid.network. 16 at a time gets rate limited. The patch is vendored in the spike; propose it upstream.
- **Network errors.** Both Safari and Linux hit a one-off connection failure with liquid.network, gone on the next try. Syncing and broadcasting need retries.
- **Wallet state.** LWK's state can be exported as encrypted strings and restored with no network, so Lumen keeps it in its own storage. It weighs about 14 KB per transaction (Liquid transactions carry large proofs), so it belongs in the history database or a file, not in secure storage.
- **Fees.** A simple send costs 26 to 33 sats.
- **Web size.** The wasm is 5.1 MB, 1.8 MB with brotli, before any size work.
- **Build fixes.** Pin `libc` to 0.2.189: 0.2.190 limits the `_dyld_*` functions to macOS, which breaks `backtrace` (pulled in by flutter_rust_bridge) on iOS. Link the `SystemConfiguration` framework on macOS and iOS (reqwest needs it). On wasm, use the nightly `llvm-ar`, as in `spike_cdk_web/tools/build_web.sh`.

### 1. Make the `Wallet` interface fit more than Lightning (done)

In `packages/lumen_wallets`, with NWC behaving exactly as before. The same changes will serve Bitcoin on-chain later.

- A receive request that is either a Lightning invoice or a chain address (sealed class), and `watchPayment` taking it.
- A send flow split in two: prepare (validate, quote the fee) then confirm. Liquid fees are known before sending; NWC can keep returning no quote.
- `Recipient` gains a Liquid case: an address, or a `liquidnetwork:` URI with optional amount and asset. Add errors for an address from the wrong network (testnet on mainnet) and for an asset other than L-BTC.
- `Transaction` gains a txid, a pending or confirmed state and its confirmation count. Lightning fields stay optional.
- What a wallet can do, so screens stop assuming Lightning: receive by invoice, receive by address, pay invoices, pay addresses.
- `remove()` documents that a self-custodial wallet's funds go with it unless the phrase is backed up.
- Update `test/fakes.dart` and every test that uses the old calls. Raise the history `_format` if saved records gain fields.

Done when: `flutter test` and `dart test` pass and the app works as today.

### 2. Liquid wallets in `lumen_wallets`, without UI (done)

- The Rust crate as a dependency of `lumen_wallets`, keeping the rule that the app never imports it directly. Start from the spike's crate, with its build fixes and the sync patch.
- Wallet state saved by Lumen after each sync (see step 0 for where), and retries around sync and broadcast.
- Recovery phrase: generate, validate (word list and checksum), and derive the descriptor.
- `LiquidWalletSource`: add from a phrase, load, rename, remove. Secrets go to `SealedStorage` under their own key, so App lock seals them with everything else.
- `LiquidWallet` implementing `Wallet`: sync, L-BTC balance, transactions mapped to `Transaction`, next unused address, prepare and confirm a send, broadcast.
- Network chosen per wallet (mainnet or testnet), with testnet only in debug builds.
- Tests: a known phrase gives known addresses (fixed vectors), transaction mapping, recipient parsing, and send errors, all against a fake backend so they run offline in CI.

Done when: the package tests pass and a scratch script can sync a testnet wallet and send from it.

How it came out:

- `packages/lumen_core` is a Flutter FFI plugin (Cargokit) holding the Rust crate in `rust/` and the generated bindings. Only `lumen_wallets` imports it, through `LwkEngine`. `LiquidWallet` talks to the `LiquidEngine` interface, which the tests fake.
- The app gives `LiquidWalletSource` two `KeyValueStore`s in step 3: one for the phrases and the wallet list (sealed secure storage), one for the chain state (the history database or a file). Testnet is enabled by passing it in `networks`.
- A sync less than 15 s old is not repeated, so a refresh that reads the balance and then the activity syncs once.
- Retries: sync and broadcast are tried 3 times on a dropped connection. A broadcast left without an answer is reported as unconfirmed, since it may have reached the server, and the next send syncs first so it cannot spend other coins and pay twice.
- Rate limits: LWK already retries each request on a 429, for about a minute. When the server still refuses, the scan is not started again, which would send every request once more, and the wallet sends no sync for a minute, the Receive watch included. A rate-limited broadcast counts as unconfirmed, since it may have gone through Waterfalls before Esplora refused it.
- Restoring: `discover` returns the derivation and the chain state it scanned, which `add` takes back, so nothing about a dropped restore stays in the source.
- iOS and macOS now build with CocoaPods, since Cargokit only ships a podspec. Flutter warns that plugins without Swift Package Manager support will become an error in a future version (see step 9).
- A pending transaction is dated from when Lumen first saw it, kept with the chain state.
- A payment to oneself shows as outgoing, 0 sats, with its fee. Worth a "to yourself" label in step 7.
- `tool/liquid_testnet.dart` syncs and sends on testnet (about 2 s for a full scan, 33 sats of fee).
- The crate's own tests (`cargo test`, including the known-phrase vectors) do not run in CI until step 9 installs Rust.
- "Send everything" (LWK's `drain_lbtc_wallet`) came with step 6.

### 3. Wire Liquid into the app (done)

- `WalletSources.liquid` next to `nwc`, and in `all`.
- `WalletsController` loads, refreshes and caches Liquid wallets like the others. Check that refresh timing suits chain sync, which is slower than an NWC call.
- History: Liquid transactions saved and listed like Lightning ones, with pending ones updated when they confirm.
- `WelcomeScreen._kinds` lists Liquid.

Done when: a wallet added by a test shows its balance and activity on Home, on its wallet screen and in Activity.

How it came out:

- `WalletSources.create` takes the Liquid stores and networks. The app passes `SealedStorage` for the phrases and `HistoryStore.chainState`, a store inside the encrypted history database, for the chain state. Testnet is enabled in debug builds only.
- `LwkEngine.open` loads the Rust library on first use, so the web app downloads the wasm only once a Liquid wallet opens. `generatePhrase` and `phraseProblem` are synchronous: step 4 must `await LwkEngine.init()` before calling them.
- Refresh timing suits chain sync as it is. Balance and activity share one sync. A background refresh waits 30 s, longer than the 15 s a sync stays fresh, so coming back to the app syncs. A pull to refresh within 15 s of the last sync reads the saved state. Walking older pages into the history reads local state, with no extra request.
- History: the newest page is saved again at each refresh, so a pending payment shows as confirmed once it is. The confirmation count saved with a payment then stops growing, so step 7 should read it live. A pending payment that never confirms (dropped from the mempool) stays in the history as pending.
- The launch cache keeps the txid and confirmations, so a pending payment is still pending at launch.
- The wallet menu hides "Copy connection string" for Liquid wallets.
- Still to adapt before anyone can add a Liquid wallet in the UI: Receive asks every wallet for an invoice, which Liquid wallets refuse (step 5); activity rows do not mark pending payments yet (step 5); the remove dialog says the funds stay where they are (step 8).
- `test/fakes.dart` has a `FakeLiquidEngine`, through `package:lumen_wallets/liquid_engine.dart`, and `memorySources` uses it.

### 4. Create and restore (done)

- Create: explain what the phrase is, show the 12 words, ask for a few of them back, then name the wallet. Nothing is saved before the check passes.
- Restore: 12 or 24 fields with BIP39 word suggestions, paste of a whole phrase, and a clear error on a wrong word or checksum. Restoring scans the chain before showing a balance.
- Accessibility: each word read with its number ("word 3 of 12, apple"), fields labeled the same way, focus order down the list, suggestions announced, nothing that relies on color or timing.
- Privacy: block screenshots and the app switcher preview while the phrase is on screen (`FLAG_SECURE` on Android, a cover view on iOS and macOS). Never copy the phrase to the clipboard.
- Every string in all locales.

Done when: widget and accessibility tests cover both flows, and a wallet created on one device restores on another.

Done in three commits: create, restore, then the screen privacy.

How create came out:

- "Add a wallet" opens a choice of wallet types, as in the mockups (frame 02): Lightning goes on to the NWC screen, Liquid to a screen that offers to create (and, next, to restore).
- The 12 words and the check are pushed outside the router (`pushStep`), so the phrase never reaches a URL, a route's `extra` or the browser history. They are still routes, so a screen reader lands on each new title.
- The words are shown down one column then the other, each column its own semantics node so screen readers read 1 to 12. At large text sizes they stack in one column.
- The check asks for 3 words picked at random, typed in the same field restore will use: BIP39 suggestions while it has focus (`phraseWordsStartingWith`, the English list in Dart), announced, reachable with Tab, and a keyboard that neither learns nor suggests words. The name comes prefilled with "Liquid". A Testnet switch shows in debug builds only.
- Going back to the explanation keeps the same phrase, since it may be written down already.
- `LiquidWalletSource.newPhrase` and `checkPhrase` are now asynchronous: they wait for `LiquidEngine.ready`, which loads LWK. When it cannot load, the screen says so instead of showing words.
- Not tried in the running app yet: the widget tests run on a fake engine.

How restore came out:

- The Liquid screen offers "Restore a wallet" next to "Create a new wallet". The restore screen has a choice of 12 or 24 words, the word fields, the name and, in debug builds, the Testnet switch.
- 24 words are accepted because the Blockstream app and the Jade also create 24-word phrases. The crate's `phrase_problem` takes 12 or 24 words and leaves the rest to BIP39, and a known 24-word phrase is checked against its master fingerprint in `cargo test`. New wallets keep 12 words.
- Words typed or pasted together are spread over the fields: a whole phrase from the first field, fewer words from the field they were typed in. Pasting 24 words picks 24 by itself. A word followed by a space moves on to the next field. Pasting several words is announced ("12 words filled in").
- Checks run in order, each written as a fix: an empty field or a word outside the BIP39 list is flagged under its own field, which takes focus; then the checksum, under the list.
- A phrase already saved on the same network is refused before any scan (`isSaved`, and `discover` checks it too), since the scan can take a minute. There is one wallet per phrase and network, whatever derivation it was found with.
- Restoring then runs `discover` (BIP84 then BIP49) before saving, with a message shown and announced while it scans. A server that does not answer (after the retries) gets its own message, and nothing is saved.

How the screen privacy came out:

- `PrivateScreen` wraps the words, the check and the restore screen, and talks to the native side over the `lumen/screen` channel. It counts the screens mounted, so going from the words to the check keeps the protection on.
- Android sets `FLAG_SECURE`: no screenshots or recordings, and a blank card in the app switcher.
- iOS covers the window when the app stops being active, so the app switcher snapshot is blank. iOS offers no way to block screenshots or recordings. Covering the screen while it is recorded or mirrored was left out, since it would also hide the words from someone mirroring to a larger screen to read them.
- macOS sets the window's `sharingType` to `.none`, which leaves it out of screen capture.
- Windows, Linux and web have nothing yet. Windows could use `SetWindowDisplayAffinity` in step 9.
- The phrase never reaches the clipboard: there is no copy button, and pasting into the restore fields only reads it.
- Not tried in the running app yet, like the rest of step 4.

### 5. Receive (done)

- A fresh address for each request, shown as text and QR. An optional amount turns it into a `liquidnetwork:` URI.
- Copy and share, as for invoices.
- Waiting for payment: sync often while the screen is open, report the payment as soon as it reaches the mempool, then show it as pending until it confirms.
- Accessibility: the address read in short groups, not as one long string.

Done when: receiving on testnet shows the payment without leaving the screen, and the receive tests cover the address case.

How receiving came out:

- A wallet that receives by address and not by invoice gets the address flow. The address shows as soon as the screen opens, with no amount, since an address takes any amount. The wallet picker stays enabled while the wallet syncs, and an address that arrives for a wallet no longer chosen is dropped.
- "Add amount" puts an optional amount in the QR code, and what is copied or shared becomes a `liquidnetwork:` URI (`liquidtestnet:` on testnet, `liquidRequest`) with the amount in L-BTC and the L-BTC `assetid`, which the Blockstream app requires next to an amount. The address stays the same, so the watch goes on while the amount is edited.
- The address is shown whole, in groups of four, and read aloud a group at a time ("Address lq1q, qvxk, ..."). Copy and share sit under it.
- `watchPayment` now emits the payment as a `Transaction`: once for NWC, built from the invoice; for Liquid, as soon as the first incoming payment to the address is in the mempool, then again when it confirms. The screen shows the amount that arrived, which may differ from the one asked.
- Once paid, the screen says "Waiting for confirmation, usually within 2 minutes", then "Confirmed", announced. The wallet is refreshed both times, so Home shows the payment right away.
- The widget tests use `FakeWallet.liquid`. The real wallet's futures start in `runAsync` during `pumpLumen`, so a real `LiquidWallet` would need the real event loop at each step. The package tests cover the real watch.
- Not tried in the running app on testnet yet.
- Activity rows, on Home and in Activity, show "Pending" with a clock under the amount of a payment still in the mempool, read after the amount ("received 21,000 sats, Pending").

### 6. Send (done)

- The send field recognizes Liquid addresses and URIs, typed, pasted or scanned.
- Amount, with a "send everything" option that leaves room for the fee.
- A review step with amount, fee and recipient before confirming.
- After sending: the txid and the pending state. Errors for not enough funds, wrong network, unsupported asset and a failed broadcast.

Done when: sending on testnet works end to end and the send tests cover each error.

Done in two commits: sending, then "send everything".

How sending came out:

- Wallets say which chain holds their funds (`Wallet.network`, null for Lightning), which step 7 can use for the explorer link. Send only offers wallets on the address's network, so a testnet address, read in debug builds, is paid from a testnet wallet. Without one, Send says the address is on testnet, as release builds do.
- Review now quotes the payment: `prepareSend` moved from the Send button to Review, for invoices and addresses alike, and Send sends that very quote. A Liquid quote shows its fee in a Fee row. A Lightning address still gets its invoice on sending, so no invoice is asked for a payment that is never confirmed.
- What cannot be paid stops before the review: not enough for the amount and its fee, or a server that does not answer. An asset other than L-BTC and an address from another network are caught when the To field is read.
- The review shows the whole address in groups of four, in columns, read aloud a group at a time, so it can be checked against the recipient's copy.
- Once sent: "Waiting for confirmation" with its usual delay, the fee paid, and the transaction ID, which can be copied and is in the shared receipt. The screen follows the transaction as Receive does, with a sync every 10 s (`Wallet.watchConfirmation`), then says "Confirmed", announced, and refreshes the wallet.
- Errors on a Liquid payment name the Liquid server or network, not the wallet: unreachable, refused, or sent without an answer. The last one offers no retry, as for Lightning.
- The To field's hint and errors name what the wallets can pay: Lightning, Liquid or both.
- Sending again after the network refused a payment sends the same reviewed transaction, which it will likely refuse again. Edit payment builds a new one.
- Tried in the running app on testnet.

How "send everything" came out:

- The crate drains with LWK (`drain_lbtc_wallet`, then `drain_lbtc_to`): every L-BTC coin goes in, and what the fee leaves goes to the address, with no change output. `LiquidDraft.sats` gives that amount, read from the wallet's net change. Other assets stay in the wallet.
- `Wallet.prepareSendAll`, behind the `payAll` capability, which only Liquid wallets have: NWC cannot know a Lightning fee before paying.
- The send form shows a "Send everything" switch under the amount when the paying wallet can drain and the address leaves the amount open. On, it hides the amount field and names the wallet that empties. The review shows the exact amount and fee.
- On testnet, draining four coins (104,974 sats) sent 104,934 sats for 40 of fee, and draining a wallet whose only coin was still in the mempool sent it all back for 20. `tool/liquid_testnet.dart --send-all <address>` does the same.
- Not tried in the running app yet.

### 7. Payment details (done)

- For Liquid: txid, confirmations, fee and date, plus a link to a block explorer that includes the unblinding data, since Liquid amounts are confidential.
- The shared receipt follows the same fields.

How it came out:

- `Wallet.chainDetails(txid)` reads one chain payment as the wallet knows it now: synced unless the last sync is less than 15 s old, and read from the saved state when the server does not answer. The payment screen shows the saved payment at once, then the live one, so the confirmation count is current. A payment saved as pending that turns out to be confirmed is announced.
- A chain payment shows "Waiting for confirmation" or "Confirmed" under its amount, and Confirmations, Fee paid and the transaction ID, which can be copied, in its details.
- "View on liquid.network" opens mempool.space's Liquid explorer in the browser. The link carries LWK's unblinding data (`unblinded_url`: the value, asset and both blinders of each of the wallet's inputs and outputs) in its fragment, which browsers never send to the server. mempool can then deduce one amount left blinded, such as what the recipient got. The link comes from the saved state, so it shows offline too. When the browser does not open, a note under the button says to copy the transaction ID instead.
- The receipt gains the network for every payment, and the confirmations and the transaction ID for chain ones. It leaves the link out: its fragment would show the amounts of the wallet's coins to whoever gets the receipt.
- `url_launcher`, already in the lock file through other packages, is now a direct dependency.
- `tool/liquid_testnet.dart` prints the explorer link of the newest transaction.
- The screen reads the payment once. It does not follow a pending one until it confirms, as Send and Receive do.
- Not tried in the running app yet. The link the testnet script prints, opened by hand, shows whether liquid.network unblinds the amounts.

### 8. Wallet settings

- Show the recovery phrase again, behind the App lock passphrase when one is set.
- Removing a Liquid wallet warns that the funds go with it unless the phrase is saved, and asks for confirmation.
- The Waterfalls and Esplora URLs, with a reset to the defaults. Leaving Waterfalls empty syncs through Esplora only.

### 9. Build, CI and release

- Install Rust and the needed targets in [ci.yml](../.github/workflows/ci.yml), [release.yml](../.github/workflows/release.yml) and the Pages workflow, with caching so builds stay fast. The Pages build needs nightly and the single-threaded wasm build.
- Build and run on Windows and Linux in CI, since the spike could not.
- Swift Package Manager: `lumen_core` only has a podspec, and Flutter warns that this will become an error. Check whether Cargokit or flutter_rust_bridge support SwiftPM by then, or write the `Package.swift` that runs the cargo build.
- Check the size added to the APK, the app bundles and the web build, and that the web build still deploys.
- Update the README feature list and screenshots, and `zapstore.yaml` if its description lists wallet kinds.

Done when: CI is green and a tagged release produces a working Android build with Liquid.

## Later

- **Lightning from Liquid.** Paying invoices and receiving over Lightning with Liquid funds needs a swap service. Boltz suspended its non-custodial swaps in August 2026, and Blockstream announced its own Blockstream Swaps, in beta. LWK has a `lwk_boltz` crate. Put swaps behind an interface and pick a provider once one is generally available.
- **Other Liquid assets**, such as USDt: show them, then send them.
- **Watch-only** wallets from a CT descriptor.
- **Hardware signers** such as the Jade.

## Open questions

- Can the wasm get smaller than 1.8 MB compressed, for example with `wasm-opt` or by loading it only once a Liquid wallet exists?
- Restoring checks BIP84 then BIP49 (see [Which descriptor](#which-descriptor)). Still to try by hand: a phrase from the Blockstream app and one from Aqua, restored in Lumen, show the same funds.
