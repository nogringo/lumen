import 'package:ndk/ndk.dart';

import '../lightning/recipient.dart';

enum NwcConnectError { empty, notNwc, incomplete, duplicate }

class NwcConnectException implements Exception {
  const NwcConnectException(this.error);

  final NwcConnectError error;

  @override
  String toString() => 'NwcConnectException(${error.name})';
}

final _hex64 = RegExp(r'^[0-9a-f]{64}$');

/// Returns what is wrong with the format of [input], or null when it looks
/// like a usable connection string.
NwcConnectError? checkNwcUri(String input) {
  final value = input.trim();
  if (value.isEmpty) return NwcConnectError.empty;
  if (!value.toLowerCase().startsWith('nostr+walletconnect:')) {
    return NwcConnectError.notNwc;
  }

  final NostrWalletConnectUri uri;
  try {
    uri = NostrWalletConnectUri.parseConnectionUri(value);
  } catch (_) {
    return NwcConnectError.incomplete;
  }
  if (!_hex64.hasMatch(uri.walletPubkey) ||
      !_hex64.hasMatch(uri.secret.toLowerCase()) ||
      !uri.relays.every(_isRelayUrl)) {
    return NwcConnectError.incomplete;
  }
  return null;
}

bool _isRelayUrl(String relay) {
  final uri = Uri.tryParse(Uri.decodeFull(relay));
  return uri != null &&
      (uri.scheme == 'wss' || uri.scheme == 'ws') &&
      uri.host.isNotEmpty;
}

/// The Lightning address that some wallets add to the connection string as
/// `lud16`, or null when it has none or it is malformed.
String? nwcLightningAddress(String uri) {
  try {
    final lud16 = NostrWalletConnectUri.parseConnectionUri(uri.trim()).lud16;
    if (lud16 == null) return null;
    return switch (parseRecipient(lud16)) {
      LnurlRecipient(:final address?) => address,
      _ => null,
    };
  } catch (_) {
    return null;
  }
}

/// Whether [a] and [b] grant the same connection to the same wallet.
bool sameNwcConnection(String a, String b) {
  try {
    final first = NostrWalletConnectUri.parseConnectionUri(a.trim());
    final second = NostrWalletConnectUri.parseConnectionUri(b.trim());
    return first.walletPubkey == second.walletPubkey &&
        first.secret.toLowerCase() == second.secret.toLowerCase();
  } catch (_) {
    return false;
  }
}
