# Lumen

Every way you hold bitcoin, in one place. Lumen connects Lightning wallets over Nostr Wallet Connect (NIP-47), shows their balances and activity together, and sends and receives Lightning payments with them, on Android, iOS, macOS, Windows, Linux and web.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/desktop-dark.png">
  <img src="docs/screenshots/desktop-light.png" alt="Lumen on desktop: a sidebar with two wallets, the total balance of 1,334,610 sats, Send and Receive buttons, and a table of recent activity across both wallets.">
</picture>

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/home-dark.png">
    <img src="docs/screenshots/home-light.png" width="260" alt="Home on a phone: the total balance, Send, Receive and Scan, the list of wallets and recent activity.">
  </picture>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/receive-dark.png">
    <img src="docs/screenshots/receive-light.png" width="260" alt="Receive: a QR code for a 21,000 sat invoice, with buttons to copy or share it, waiting for payment.">
  </picture>
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="docs/screenshots/payment-dark.png">
    <img src="docs/screenshots/payment-light.png" width="260" alt="A sent payment of 5,400 sats with its date, wallet, fee, payment hash, preimage and invoice.">
  </picture>
</p>

## Features

- **Every wallet at once.** Connect several NWC wallets and see one total balance and one activity feed. Before saving a connection, Lumen shows what it can and cannot do.
- **Send and receive.** Pay a Lightning invoice or address, create an invoice with a QR code, and get told the moment it is paid. On Android, scan QR codes with the camera.
- **Payment details.** Each payment keeps its date, fee, payment hash, preimage and invoice, and can be shared as a receipt.
- **History that stays.** Every transaction Lumen sees is saved on the device, encrypted with AES-256-GCM, so it remains readable offline.
- **App lock.** An optional passphrase, stretched with Argon2id, seals the wallets and the history. Cmd+L or Ctrl+L locks the app at once.

## Layout

This repository is a [pub workspace](https://dart.dev/tools/pub/workspaces):

- `lib/`: the Flutter app (screens, routing, theme, app lock, local history, translations).
- `packages/lumen_wallets/`: pure Dart wallet logic behind a `Wallet` interface. The app never imports `ndk` directly.
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

## Test

```sh
flutter test                                  # app, including accessibility guidelines
(cd packages/lumen_wallets && dart test)      # wallet logic
```

## Screenshots

The images above are rendered from demo data by a widget test, so they follow the UI as it changes:

```sh
flutter test tool/screenshots_test.dart       # writes docs/screenshots/
```
