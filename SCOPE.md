# Lumen v1 scope

Lumen v1 reads the balance of one or more Lightning wallets connected over NWC (NIP-47) and receives Lightning payments into them, on every platform. Sending comes in the next version. Anything in the mockups that is not listed here is out of v1.

## Platforms

Android, iOS, macOS, Windows, Linux and web.

## Languages

English and French. Lumen follows the system language and falls back to English.

## Features

### NWC wallets

- Add a wallet by pasting a `nostr+walletconnect://` connection string and giving it a name.
- Before saving, check that the connection string is valid. Otherwise show an inline error that says how to fix it.
- Hold several NWC wallets at once.
- Rename a wallet.
- Remove a wallet.

### Balances

- Home shows the total balance in sats and one row per wallet with its own balance.

### Receive

- Receive from Home or from a wallet screen, which preselects that wallet.
- Pick the wallet that receives and the amount in sats, then show the Lightning invoice as a QR code and as text, with Copy and Share.
- Show the time left on the invoice. Once it expires, replace it in one tap.
- Detect the payment (NWC notifications, with `lookup_invoice` as a fallback), confirm it on screen and refresh the wallet balance.

## Screens

Based on the mockups, trimmed to the features above:

| Screen | Mockup frames | Changes for v1 |
|---|---|---|
| Welcome | 01, 19 | Lists Lightning only. "Add a wallet" opens the NWC screen directly. |
| Connect with NWC | 03 | No Scan button, no permissions card. |
| Home / Overview | 04, 08, 17, 20 | Receive is the only action. No activity, no Settings button, no Lock now. |
| Wallet | 09, 21 (layout only) | Name, balance and Receive. The options menu holds Rename and Remove. |
| Receive | 13, 23 | Lightning only, so no network switch. The amount is typed first, then the invoice is created. |

The three layouts (phone, tablet, desktop), both themes and the accessibility requirements from the mockups apply to every screen.

## Dependencies

- `ndk` and `ndk_flutter`
- `flutter_secure_storage`
- `flutter_localizations` and `intl`
- `go_router`
- `qr` (draws invoice QR codes)
- `share_plus`
