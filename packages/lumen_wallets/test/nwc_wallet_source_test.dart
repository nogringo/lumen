// ignore_for_file: experimental_member_use

import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:ndk/data_layer/repositories/wallets/mem_wallets_repo.dart';
import 'package:ndk/entities.dart' as ndk show NwcWallet;
import 'package:ndk/ndk.dart' show Bip340EventVerifier;
import 'package:test/test.dart';

const _pubkey =
    'b889ff5b1513b641e2a139f661a661364979c5beee91842f8f0ef42ab558e9d4';
const _secret =
    '71a8c14c1407c113601079c4302dab36460f0ccd0ad506f1f2dc73b5100e4f3c';
const _uri =
    'nostr+walletconnect://$_pubkey?relay=wss://relay.example.com&secret=$_secret';

void main() {
  late MemWalletsRepo repo;
  late WalletSources sources;

  setUp(() async {
    repo = MemWalletsRepo();
    await repo.storeWallet(
      ndk.NwcWallet(
        id: 'w1',
        name: 'Home node',
        supportedUnits: const {'sat'},
        nwcUrl: _uri,
      ),
    );
    sources = WalletSources.create(
      repo: repo,
      eventVerifier: Bip340EventVerifier(),
    );
  });

  tearDown(() => sources.dispose());

  test('loads saved NWC wallets as Lightning wallets', () async {
    final wallets = await sources.nwc.load();

    expect(wallets, hasLength(1));
    expect(wallets.single.id, 'w1');
    expect(wallets.single.name, 'Home node');
    expect(wallets.single.kind, WalletKind.lightning);
  });

  test('rename is saved', () async {
    final wallet = (await sources.nwc.load()).single;

    await wallet.rename('  Savings node ');

    expect(wallet.name, 'Savings node');
    expect((await repo.getWallet('w1')).name, 'Savings node');
  });

  test('remove forgets the wallet', () async {
    final wallet = (await sources.nwc.load()).single;

    await wallet.remove();

    expect(await sources.nwc.load(), isEmpty);
    expect(await repo.getWallets(), isEmpty);
  });

  test('add saves the wallet at once, before any network answer', () async {
    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret';

    final wallet = await sources.nwc.add(uri: uri, name: ' Phone ');

    expect(wallet.name, 'Phone');
    expect(wallet.kind, WalletKind.lightning);
    final stored = await repo.getWallet(wallet.id) as ndk.NwcWallet;
    expect(stored.nwcUrl, uri);
    expect(stored.name, 'Phone');
  });

  test('a connection being added counts as a duplicate', () async {
    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret';
    await sources.nwc.add(uri: uri, name: 'Phone');

    await expectLater(
      sources.nwc.add(uri: uri, name: 'Again'),
      throwsA(
        isA<NwcConnectException>().having(
          (e) => e.error,
          'error',
          NwcConnectError.duplicate,
        ),
      ),
    );
  });

  test('removing a wallet that is still being added keeps it removed', () async {
    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret';
    final wallet = await sources.nwc.add(uri: uri, name: 'Phone');

    await wallet.remove();

    expect(await repo.getWallets(ids: [wallet.id]), isEmpty);
    expect(
      (await sources.nwc.load()).map((w) => w.id),
      isNot(contains(wallet.id)),
    );
  });

  test('adding a connection that is already saved fails', () async {
    final sameConnection =
        'nostr+walletconnect://$_pubkey?relays=wss://other.example&secret=$_secret';

    await expectLater(
      sources.nwc.add(uri: sameConnection, name: 'Again'),
      throwsA(
        isA<NwcConnectException>().having(
          (e) => e.error,
          'error',
          NwcConnectError.duplicate,
        ),
      ),
    );
  });

  test('adding a malformed string fails with its format error', () async {
    await expectLater(
      sources.nwc.add(uri: 'lnbc1...', name: 'Nope'),
      throwsA(
        isA<NwcConnectException>().having(
          (e) => e.error,
          'error',
          NwcConnectError.notNwc,
        ),
      ),
    );
  });
}
