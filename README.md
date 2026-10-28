# Lumen

Every way you hold bitcoin, in one place. Lumen connects Lightning wallets over Nostr Wallet Connect (NIP-47), holds Liquid wallets of its own, shows their balances and activity together, and sends and receives with them, on Android, iOS, macOS, Windows, Linux and web.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/desktop-dark.png">
  <img src="docs/screenshots/desktop-light.png" alt="Lumen on desktop: a sidebar with two Lightning wallets and a Liquid one, the total balance of 1,584,610 sats, Send and Receive buttons, and a table of recent activity across the three wallets, where a Liquid payment is still pending.">
</picture>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/home-dark.png">
    <img src="docs/screenshots/home-light.png" width="260" alt="Home on a phone: the total balance, Send, Receive and Scan, the list of wallets, Lightning and Liquid, and recent activity.">
  </picture>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/receive-dark.png">
    <img src="docs/screenshots/receive-light.png" width="260" alt="Receive: a QR code for a 21,000 sat invoice, with buttons to copy or share it, waiting for payment.">
  </picture>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/payment-dark.png">
    <img src="docs/screenshots/payment-light.png" width="260" alt="A sent payment of 5,400 sats with its date, wallet, network, fee, payment hash, preimage and invoice.">
  </picture>
</p>

## Features

- **Every wallet at once.** Connect several NWC wallets, add Liquid wallets, and see one total balance and one activity feed. Before saving a connection, Lumen shows what it can and cannot do.
- **Liquid wallets.** Create one from a new 12-word recovery phrase, which Lumen asks you to type back before the wallet exists, or restore one from 12 or 24 words. The phrase never reaches the clipboard, Android and macOS keep it out of screenshots, and it can be shown again later. Lumen syncs through Waterfalls, falls back to Esplora, and lets you pick other servers in Settings.
- **Send and receive.** Pay a Lightning invoice or address, or a Liquid address with its fee shown before you confirm, and send everything a Liquid wallet holds. Create an invoice or show a Liquid address with a QR code, and get told the moment it is paid. On Android, scan QR codes with the camera.
- **Payment details.** Lightning payments keep their date, fee, payment hash, preimage and invoice. Liquid payments keep their confirmations, fee and transaction ID, with a liquid.network link that carries what the explorer needs to unblind the amounts. Each can be shared as a receipt.
- **History that stays.** Every transaction Lumen sees is saved on the device, encrypted with AES-256-GCM, so it remains readable offline.
- **App lock.** An optional passphrase, stretched with Argon2id, seals the wallets, recovery phrases included, and the history. Cmd+L or Ctrl+L locks the app at once.

## Layout

This repository is a [pub workspace](https://dart.dev/tools/pub/workspaces):

- `lib/`: the Flutter app (screens, routing, theme, app lock, local history, translations).
- `packages/lumen_wallets/`: pure Dart wallet logic behind a `Wallet` interface. The app never imports `ndk` directly.
- `packages/lumen_core/`: the Rust crate behind Liquid wallets (LWK), bridged to Dart with flutter_rust_bridge. Only `lumen_wallets` imports it.
- `test/`: widget and accessibility tests, with fake wallets in `test/fakes.dart`.
- `mockups/`: the HTML design mockups and the accessibility requirements.
- `tool/`: scripts for the app icons and the screenshots above.

## Run

```sh
flutter pub get
flutter run
```

- macOS and iOS store wallets in the Keychain, so pick your development team in Xcode (Runner target, Signing & Capabilities) before the first run.
- Linux needs `libsecret-1-dev` to build.
- Building needs Rust through [rustup](https://rustup.rs): the build compiles `lumen_core` on the stable toolchain and adds the targets it needs.
- On the web, run `tool/build_wasm.sh` first, or Liquid wallets cannot open. It needs [wasm-pack](https://github.com/wasm-bindgen/wasm-pack) and installs the nightly toolchain it builds with.

## Test

```sh
flutter test                                  # app, including accessibility guidelines
(cd packages/lumen_wallets && dart test)      # wallet logic
(cd packages/lumen_core/rust && cargo test)   # Rust core, offline
flutter test integration_test -d macos        # the Rust core as the app bundles it
```

## Screenshots

The images above are rendered from demo data by a widget test, so they follow the UI as it changes:

```sh
flutter test tool/screenshots_test.dart       # writes docs/screenshots/
```
