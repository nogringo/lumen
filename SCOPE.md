# Lumen v1 scope

Lumen v1 reads the balance and recent activity of one or more Lightning wallets connected over NWC (NIP-47), and sends and receives Lightning payments with them, on every platform. Anything in the mockups that is not listed here is out of v1.

## Platforms

Android, iOS, macOS, Windows, Linux and web.

## Languages

English, French, German, Spanish, Finnish, Italian, Japanese, Portuguese (Portugal and Brazil), Russian and Simplified Chinese. Lumen follows the system language and falls back to English.

## Features

### NWC wallets

- Add a wallet by pasting a `nostr+walletconnect://` connection string and giving it a name.
- Before saving, check that the connection string is valid. Otherwise show an inline error that says how to fix it.
- Hold several NWC wallets at once.
- Rename a wallet.
- Remove a wallet.

### Balances

- Home shows the total balance in sats and one row per wallet with its own balance.

### Activity

- Home shows the latest settled payments of every wallet, newest first, with the wallet each went through. A wallet screen shows its own.
- Each payment shows its description (or Received / Sent), when it settled, and its amount with a sign and words, never color alone.
- On desktop, activity is a table with column headers.
- Activity loads with the balances, with `list_transactions`. At launch, the last activity read shows until it refreshes. A wallet whose activity cannot be read says why: unreachable, or a connection without that permission.

### Send

- Send from Home or from a wallet screen, which preselects that wallet.
- Pay a BOLT11 invoice, a Lightning address or an LNURL, typed or pasted (also as a `lightning:` or `bitcoin:` link with an invoice). An invoice sets the amount, an address or LNURL takes the amount typed in sats.
- An invoice without amount, an expired invoice, an amount outside what the address accepts, or a known balance below the amount is caught before the payment, with an inline error that says how to fix it.
- Lumen picks the first wallet whose balance covers the amount. The user can switch before reviewing.
- Review the amount, recipient, note, wallet and network, then send with `pay_invoice`. An address is only asked for its invoice at that point, and an invoice for another amount is refused.
- Confirm the payment on screen with the fee paid, and refresh the wallet. A failure says why. When the wallet does not answer in time, Lumen says the payment may still go through and offers no retry.

### Receive

- Receive from Home or from a wallet screen, which preselects that wallet.
- Pick the wallet that receives and the amount in sats, then show the Lightning invoice as a QR code and as text, with Copy and Share.
- Show the time left on the invoice. Once it expires, replace it in one tap.
- Detect the payment (NWC notifications, with `lookup_invoice` as a fallback), confirm it on screen and refresh the wallet balance.

### App lock

- Turn App lock on in Settings with a passphrase of at least 12 characters, typed twice. It works the same on every platform.
- While App lock is on, the wallets, the cached balances and the activity are encrypted at rest. The passphrase goes through Argon2id and opens a random data key, and the data is sealed with AES-256-GCM under that key.
- Lumen opens on the lock screen, and Lock now locks it at any time. Locking closes the wallet connections and forgets the key. Lumen does not lock by itself when it goes to the background.
- After 5 wrong passphrases in a row, each new try waits: 30 seconds, then twice as long each time, up to about an hour. The wait survives a restart.
- Change the passphrase with the current one. Turning App lock off asks for the passphrase and decrypts the data.
- A forgotten passphrase can only be answered by resetting Lumen, which removes every wallet and App lock from the device.
- Biometrics will come later, as a shortcut that unlocks the data key from the platform keystore.

## Screens

Based on the mockups, trimmed to the features above:

| Screen | Mockup frames | Changes for v1 |
|---|---|---|
| Welcome | 01, 19 | Lists Lightning only. "Add a wallet" opens the NWC screen directly. |
| Connect with NWC | 03 | No Scan button, no permissions card. |
| Home / Overview | 04, 08, 17, 20 | Send and Receive are the actions, no Scan. Recent activity has no See all, and its rows do not open a detail. The Settings button opens Settings. On desktop the sidebar ends with Settings, then Lock now while App lock is on. |
| Wallet | 09, 21 (layout only) | Name, balance, Send, Receive and the wallet's recent activity. The options menu holds Rename and Remove. |
| Send | 10, 11, 12, 22 | Lightning only. The amount is typed in a field, not on a keypad. A Paste button replaces Scan. No fiat value, no fee estimate before sending (NWC has none), no receipt sharing or payment hash. |
| Receive | 13, 23 | Lightning only, so no network switch. The amount is typed first, then the invoice is created. |
| Settings | 14, 24 | Only the Security group: the App lock switch, then Change passphrase and Lock now while it is on. Turning App lock on opens a passphrase screen, turning it off asks for the passphrase in a dialog. |
| Locked | 15, 25 | A passphrase field instead of the system prompt, with Unlock and Forgot your passphrase. |

The three layouts (phone, tablet, desktop), both themes and the accessibility requirements from the mockups apply to every screen.

## Dependencies

- `ndk` and `ndk_flutter`
- `flutter_secure_storage`
- `flutter_localizations` and `intl`
- `go_router`
- `qr` (draws invoice QR codes)
- `bech32` (decodes invoices and LNURLs)
- `http` (LNURL-pay, for Lightning addresses)
- `share_plus`
- `serverpod_argon2` (Argon2id for the App lock passphrase)
- `cryptography` (AES-256-GCM for the data sealed by App lock)
