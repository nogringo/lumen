// ignore_for_file: experimental_member_use

import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:lumen_wallets/src/nwc/nwc_wallet_source.dart' show nwcSendError;
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
    expect(wallets.single.lightningAddress, isNull);
  });

  test('a connection string keeps its Lightning address', () async {
    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret&lud16=phone%40example.com';
    final added = await sources.nwc.add(uri: uri, name: 'Phone');
    expect(added.lightningAddress, 'phone@example.com');

    final savedRepo = MemWalletsRepo();
    await savedRepo.storeWallet(
      ndk.NwcWallet(
        id: 'w2',
        name: 'Phone',
        supportedUnits: const {'sat'},
        nwcUrl: uri,
      ),
    );
    final saved = WalletSources.create(
      repo: savedRepo,
      eventVerifier: Bip340EventVerifier(),
    );
    addTearDown(saved.dispose);
    final loaded = (await saved.nwc.load()).single;
    expect(loaded.lightningAddress, 'phone@example.com');
  });

  test('rename is saved', () async {
    final wallet = (await sources.nwc.load()).single;

    await wallet.rename('  Savings node ');

    expect(wallet.name, 'Savings node');
    expect((await repo.getWallet('w1')).name, 'Savings node');
  });

  test('gives back the saved connection string', () async {
    final saved = (await sources.nwc.load()).single;
    expect(await saved.connectionString(), _uri);

    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret';
    final added = await sources.nwc.add(uri: ' $uri\n', name: 'Phone');
    expect(await added.connectionString(), uri);
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

  test('knows a saved connection, whatever its relays', () async {
    final sameConnection =
        'nostr+walletconnect://$_pubkey?relays=wss://other.example&secret=$_secret';
    final other =
        'nostr+walletconnect://${'a' * 64}?relay=wss://relay.example.com&secret=$_secret';

    expect(await sources.nwc.isSaved(sameConnection), isTrue);
    expect(await sources.nwc.isSaved(other), isFalse);
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

  test('an unreachable wallet cannot create an invoice', () async {
    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret';
    final wallet = await sources.nwc.add(uri: uri, name: 'Phone');

    await expectLater(
      wallet.createInvoice(21),
      throwsA(
        isA<ReceiveException>().having(
          (e) => e.error,
          'error',
          ReceiveError.unreachable,
        ),
      ),
    );
  });

  test('an unreachable wallet cannot list its transactions', () async {
    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret';
    final wallet = await sources.nwc.add(uri: uri, name: 'Phone');

    await expectLater(
      wallet.fetchTransactions(),
      throwsA(
        isA<ActivityException>().having(
          (e) => e.error,
          'error',
          ActivityError.unreachable,
        ),
      ),
    );
  });

  test('an unreachable wallet sends nothing', () async {
    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret';
    final wallet = await sources.nwc.add(uri: uri, name: 'Phone');

    final quote = await wallet.prepareSend(
      const Invoice(request: 'lnbc1', sats: 1),
    );
    expect(quote.sats, 1);
    expect(quote.feeSats, isNull);

    await expectLater(
      wallet.confirmSend(quote),
      throwsA(
        isA<SendException>().having(
          (e) => e.error,
          'error',
          SendError.unreachable,
        ),
      ),
    );
  });

  test('NIP-47 payment errors keep their meaning', () {
    SendError of(String code) =>
        nwcSendError(Exception('error pay_invoice code: $code Some message'));

    expect(of('INSUFFICIENT_BALANCE'), SendError.insufficientBalance);
    expect(of('QUOTA_EXCEEDED'), SendError.budgetExceeded);
    expect(of('RESTRICTED'), SendError.noPermission);
    expect(of('PAYMENT_FAILED'), SendError.failed);
    expect(of('INTERNAL'), SendError.failed);
  });

  test('a payment without an answer may still go through', () {
    expect(
      nwcSendError('Timed out while executing NWC request pay_invoice'),
      SendError.unconfirmed,
    );
    expect(
      nwcSendError(StateError('NWC connection is closed')),
      SendError.unconfirmed,
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

  test('an unreachable wallet has nothing to show before saving', () async {
    final uri =
        'nostr+walletconnect://${'a' * 64}?relay=ws://127.0.0.1:9&secret=$_secret';

    expect(await sources.nwc.inspect(uri), isNull);
    expect(await sources.nwc.load(), hasLength(1));
  });
}
