# Lumen

Every way you hold bitcoin, in one place. Lumen v1 reads the balance and recent activity of Lightning wallets connected over Nostr Wallet Connect (NIP-47) and receives Lightning payments into them, on Android, iOS, macOS, Windows, Linux and web. See [SCOPE.md](SCOPE.md) for what v1 covers and [mockups/](mockups/index.html) for the design and accessibility requirements.

## Layout

This repository is a [pub workspace](https://dart.dev/tools/pub/workspaces):

- `lib/`: the Flutter app (screens, routing, theme, translations).
- `packages/lumen_wallets/`: pure Dart wallet logic behind a `Wallet` interface. The app never imports `ndk` directly.

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

## Accessibility

Accessibility is a core goal, not a polish item. The app follows the requirements at the end of the mockups (WCAG 2.2 AA, VoiceOver, TalkBack, Switch Access, hardware keyboard), and `test/accessibility_test.dart` checks tap targets, labels, text contrast and layout at 200% text size on phone and desktop, in both themes.

- On web, the accessibility tree is on from startup.
- Balances and activity refresh when the app comes back to the foreground, by pulling down, with Cmd+R, Ctrl+R or F5, or with the "Refresh balances" screen reader action on the total.
