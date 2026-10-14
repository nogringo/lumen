import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:test/test.dart';

const _pubkey =
    'b889ff5b1513b641e2a139f661a661364979c5beee91842f8f0ef42ab558e9d4';
const _secret =
    '71a8c14c1407c113601079c4302dab36460f0ccd0ad506f1f2dc73b5100e4f3c';
const _valid =
    'nostr+walletconnect://$_pubkey?relay=wss://relay.example.com&secret=$_secret';

void main() {
  group('checkNwcUri', () {
    test('accepts a complete connection string', () {
      expect(checkNwcUri(_valid), isNull);
      expect(checkNwcUri('  $_valid\n'), isNull);
    });

    test('accepts several relays', () {
      expect(
        checkNwcUri(
          'nostr+walletconnect://$_pubkey?relays=wss://a.example,wss://b.example&secret=$_secret',
        ),
        isNull,
      );
    });

    test('rejects an empty value', () {
      expect(checkNwcUri('   '), NwcConnectError.empty);
    });

    test('rejects other schemes', () {
      expect(checkNwcUri('lnbc1pjx7v3u...'), NwcConnectError.notNwc);
      expect(checkNwcUri('https://example.com'), NwcConnectError.notNwc);
    });

    test('rejects a string missing its secret, relay or pubkey', () {
      expect(
        checkNwcUri(
          'nostr+walletconnect://$_pubkey?relay=wss://relay.example.com',
        ),
        NwcConnectError.incomplete,
      );
      expect(
        checkNwcUri('nostr+walletconnect://$_pubkey?secret=$_secret'),
        NwcConnectError.incomplete,
      );
      expect(
        checkNwcUri(
          'nostr+walletconnect://abc?relay=wss://relay.example.com&secret=$_secret',
        ),
        NwcConnectError.incomplete,
      );
    });

    test('rejects a truncated secret', () {
      expect(
        checkNwcUri(
          'nostr+walletconnect://$_pubkey?relay=wss://relay.example.com&secret=71a8c14c...',
        ),
        NwcConnectError.incomplete,
      );
    });

    test('rejects a relay that is not a websocket', () {
      expect(
        checkNwcUri(
          'nostr+walletconnect://$_pubkey?relay=https://relay.example.com&secret=$_secret',
        ),
        NwcConnectError.incomplete,
      );
    });
  });

  group('sameNwcConnection', () {
    test('ignores relay order and encoding', () {
      expect(
        sameNwcConnection(
          _valid,
          'nostr+walletconnect://$_pubkey?relays=wss%3A%2F%2Fother.example&secret=$_secret',
        ),
        isTrue,
      );
    });

    test('tells apart two connections to the same wallet', () {
      final other = _valid.replaceFirst(_secret, 'f' * 64);
      expect(sameNwcConnection(_valid, other), isFalse);
    });
  });
}
