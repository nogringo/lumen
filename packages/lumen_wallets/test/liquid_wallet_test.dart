import 'package:lumen_wallets/lumen_wallets.dart';
import 'package:lumen_wallets/src/liquid/liquid_engine.dart';
import 'package:test/test.dart';

const _phrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
const _address =
    'lq1qqvxk052kf3qtkxmrakx50a9gc3smqad2ync54hzntjt980kfej9kkfe0247rp5h4yzmdftsahhw64uy8pzfe7cpg4fgykm7cv';
const _elsewhere = ChainAddress(
  'lq1qqvp9g33gw9y05xava3dvcpq8pnkv82yj3tdnzp547eyp9yrztz2lkyxrhscd55ev4p7lj2n72jtkn5u4xnj4v577c42jhf3ww',
  network: ChainNetwork.liquid,
);

LiquidChainException _fails(LiquidChainError error) =>
    LiquidChainException(error);

final class _FakeChain implements LiquidChain {
  int balanceSats = 0;
  int tip = 100;
  List<ChainTx> txs = [];
  List<String> updates = [];
  int syncs = 0;
  bool changes = true;

  /// Thrown by the next calls, one each.
  final List<LiquidChainException> syncErrors = [];
  final List<LiquidChainException> broadcastErrors = [];
  LiquidChainException? prepareError;
  int broadcasts = 0;
  int fee = 30;

  @override
  Future<bool> sync() async {
    syncs++;
    if (syncErrors.isNotEmpty) throw syncErrors.removeAt(0);
    updates = [...updates, 'update$syncs'];
    return changes;
  }

  @override
  Future<List<String>> state() async => updates;

  @override
  Future<int> balance() async => balanceSats;

  @override
  Future<int> tipHeight() async => tip;

  @override
  Future<String> nextAddress() async => _address;

  @override
  Future<List<ChainTx>> transactions() async => txs;

  @override
  Future<String?> explorerUrl(String txid, String explorer) async =>
      txs.any((tx) => tx.txid == txid)
      ? '${explorer}tx/$txid#blinded=secrets'
      : null;

  @override
  Future<LiquidDraft> prepareSend(String address, int sats) async {
    if (prepareError case final error?) throw error;
    return _Draft(fee, address, sats);
  }

  @override
  Future<LiquidDraft> prepareSendAll(String address) async {
    if (balanceSats <= fee) {
      throw const LiquidChainException(LiquidChainError.insufficientFunds);
    }
    return _Draft(fee, address, balanceSats - fee);
  }

  @override
  Future<LiquidSigned> sign(LiquidDraft draft) async => const _Signed('tx9');

  @override
  Future<void> broadcast(LiquidSigned signed) async {
    broadcasts++;
    if (broadcastErrors.isNotEmpty) throw broadcastErrors.removeAt(0);
  }
}

final class _Draft implements LiquidDraft {
  const _Draft(this.fee, this.address, this.sats);

  @override
  final int fee;
  final String address;

  @override
  final int sats;
}

final class _Signed implements LiquidSigned {
  const _Signed(this.txid);

  @override
  final String txid;
}

final class _FakeEngine implements LiquidEngine {
  /// The chain each derivation of [_phrase] gives.
  final Map<LiquidScript, _FakeChain> chains = {
    for (final script in LiquidScript.values) script: _FakeChain(),
  };
  final List<List<String>> openedWith = [];

  var started = false;

  @override
  Future<void> ready() async => started = true;

  @override
  String generatePhrase() => _phrase;

  @override
  PhraseProblem? phraseProblem(String phrase) {
    if (![12, 24].contains(phrase.split(' ').length)) {
      return PhraseProblem.wordCount;
    }
    if (phrase.contains('zzz')) return PhraseProblem.unknownWord;
    return null;
  }

  @override
  Future<LiquidChain> open({
    required String phrase,
    required ChainNetwork network,
    required LiquidScript script,
    required LiquidServers servers,
    required List<String> state,
  }) async {
    openedWith.add(state);
    return chains[script]!..updates = state;
  }
}

void main() {
  late _FakeEngine engine;
  late MemoryKeyValueStore secrets;
  late MemoryKeyValueStore chainState;
  late DateTime now;

  LiquidWalletSource source({Set<ChainNetwork>? networks}) =>
      LiquidWalletSource(
        engine: engine,
        secrets: secrets,
        chainState: chainState,
        networks: networks ?? const {ChainNetwork.liquid},
        retryDelays: const [Duration.zero, Duration.zero],
        now: () => now,
        watchInterval: const Duration(milliseconds: 10),
      );

  late _FakeChain chain;

  setUp(() {
    engine = _FakeEngine();
    chain = engine.chains[LiquidScript.nativeSegwit]!;
    secrets = MemoryKeyValueStore();
    chainState = MemoryKeyValueStore();
    now = DateTime(2026, 10, 16, 12);
  });

  test('a new phrase waits for the engine to start', () async {
    expect(await source().newPhrase(), _phrase);
    expect(engine.started, isTrue);
    expect(await source().checkPhrase('abandon zzz'), PhraseProblem.wordCount);
  });

  group('saving', () {
    test('a wallet keeps its phrase under its own key', () async {
      final wallet = await source().add(
        phrase: '  Abandon ${_phrase.substring(8).replaceAll(' ', '  ')} ',
        name: ' Savings ',
      );

      expect(secrets.values['lumen.liquid.${wallet.id}.phrase'], _phrase);
      expect(secrets.values['lumen.liquid.wallets'], isNot(contains('about')));

      final loaded = (await source().load()).single;
      expect(loaded.id, wallet.id);
      expect(loaded.name, 'Savings');
      expect(loaded.kind, WalletKind.liquid);
      expect(loaded.capabilities, {
        WalletCapability.receiveAddress,
        WalletCapability.payAddress,
        WalletCapability.payAll,
      });
      expect(await loaded.connectionString(), isNull);
      expect(await loaded.recoveryPhrase(), _phrase);
    });

    test('rename is saved, remove forgets the phrase and state', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      await wallet.fetchBalance();
      expect(chainState.values, isNotEmpty);

      await wallet.rename('Cold');
      expect((await source().load()).single.name, 'Cold');

      await wallet.remove();
      expect(await source().load(), isEmpty);
      expect(secrets.values.keys, ['lumen.liquid.wallets']);
      expect(chainState.values, isEmpty);
    });

    test('a phrase that is invalid or saved already is refused', () async {
      final wallets = source();
      await wallets.add(phrase: _phrase, name: 'Savings');

      for (final (phrase, error) in [
        ('abandon about', LiquidAddError.invalidPhrase),
        (_phrase.replaceFirst('abandon', 'zzz'), LiquidAddError.invalidPhrase),
        (_phrase.toUpperCase(), LiquidAddError.duplicate),
      ]) {
        await expectLater(
          wallets.add(phrase: phrase, name: 'Again'),
          throwsA(
            isA<LiquidAddException>().having((e) => e.error, 'error', error),
          ),
          reason: phrase,
        );
      }
    });

    test('testnet is only added and loaded where enabled', () async {
      await expectLater(
        source().add(
          phrase: _phrase,
          name: 'Test',
          network: ChainNetwork.liquidTestnet,
        ),
        throwsArgumentError,
      );

      final both = {ChainNetwork.liquid, ChainNetwork.liquidTestnet};
      await source(
        networks: both,
      ).add(phrase: _phrase, name: 'Test', network: ChainNetwork.liquidTestnet);
      expect(await source(networks: both).load(), hasLength(1));
      expect(await source().load(), isEmpty);
    });
  });

  group('syncing', () {
    test('the chain state is saved and opened again', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.balanceSats = 25000;
      expect(await wallet.fetchBalance(), 25000);

      final reloaded = (await source().load()).single;
      await reloaded.fetchBalance();
      expect(engine.openedWith.last, ['update1']);
    });

    test('balance and activity read together sync once', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');

      await wallet.fetchBalance();
      await wallet.fetchTransactions();
      expect(chain.syncs, 1);

      now = now.add(const Duration(minutes: 1));
      await wallet.fetchBalance();
      expect(chain.syncs, 2);
    });

    test('a dropped connection is retried', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.syncErrors.addAll([
        _fails(LiquidChainError.unreachable),
        _fails(LiquidChainError.unreachable),
      ]);
      chain.balanceSats = 700;

      expect(await wallet.fetchBalance(), 700);
      expect(chain.syncs, 3);
    });

    test('a server that stays silent leaves the balance unread', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.syncErrors.addAll(
        List.filled(3, _fails(LiquidChainError.unreachable)),
      );

      await expectLater(
        wallet.fetchBalance(),
        throwsA(
          isA<BalanceException>().having(
            (e) => e.error,
            'error',
            BalanceError.unreachable,
          ),
        ),
      );
    });

    test('a rate limit is not retried, and pauses syncing', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.syncErrors.add(_fails(LiquidChainError.rateLimited));

      await expectLater(
        wallet.fetchBalance(),
        throwsA(isA<BalanceException>()),
      );
      expect(chain.syncs, 1);

      now = now.add(const Duration(seconds: 30));
      await expectLater(
        wallet.prepareSend(_elsewhere, sats: 100),
        throwsA(
          isA<SendException>().having(
            (e) => e.error,
            'error',
            SendError.unreachable,
          ),
        ),
      );
      expect(chain.syncs, 1);

      now = now.add(const Duration(minutes: 1));
      await wallet.fetchBalance();
      expect(chain.syncs, 2);
    });

    test('a saved state that no longer opens is dropped', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chainState.values['lumen.liquid.${wallet.id}.state'] = 'not json';

      await (await source().load()).single.fetchBalance();
      expect(engine.openedWith.last, isEmpty);
    });
  });

  group('activity', () {
    test('chain transactions read like payments', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain
        ..tip = 120
        ..txs = [
          ChainTx(
            txid: 'in',
            balance: 25000,
            fee: 40,
            height: 101,
            timestamp: DateTime(2026, 10, 1),
          ),
          ChainTx(
            txid: 'out',
            balance: -5030,
            fee: 30,
            height: 120,
            timestamp: DateTime(2026, 10, 2),
          ),
          const ChainTx(txid: 'asset', balance: 0, fee: 26, height: 110),
          const ChainTx(txid: 'pending', balance: 1000, fee: 26),
        ];

      final page = await wallet.fetchTransactions(limit: 10);
      final [pending, out, incoming] = page.transactions;

      expect(
        (pending.id, pending.isPending, pending.at),
        ('pending', true, now),
      );
      expect((pending.confirmations, pending.txid), (0, 'pending'));

      expect(
        (out.direction, out.sats, out.feeSats),
        (TransactionDirection.outgoing, 5000, 30),
      );
      expect(out.confirmations, 1);

      expect(
        (incoming.direction, incoming.sats, incoming.feeSats),
        (TransactionDirection.incoming, 25000, null),
      );
      expect(incoming.confirmations, 20);
      expect(incoming.at, DateTime(2026, 10, 1));
    });

    test('a pending payment keeps the time it was first seen', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.txs = [const ChainTx(txid: 'pending', balance: 1000, fee: 26)];
      final seenAt = now;
      await wallet.fetchBalance();

      now = now.add(const Duration(hours: 1));
      final reloaded = (await source().load()).single;
      final page = await reloaded.fetchTransactions();
      expect(page.transactions.single.at, seenAt);
    });

    test('pages are cut from the newest', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.txs = [
        for (var i = 0; i < 5; i++)
          ChainTx(
            txid: 'tx$i',
            balance: 100,
            fee: 26,
            height: 10 + i,
            timestamp: DateTime(2026, 10, 1 + i),
          ),
      ];

      final second = await wallet.fetchTransactions(limit: 2, offset: 2);
      expect([for (final t in second.transactions) t.id], ['tx2', 'tx1']);
      expect(second.listed, 2);
      expect((await wallet.fetchTransactions(offset: 5)).listed, 0);
    });

    test('one payment is read live, with its explorer link', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain
        ..tip = 101
        ..txs = [const ChainTx(txid: 'out', balance: -5030, fee: 30)];
      expect((await wallet.chainDetails('out'))!.transaction.isPending, isTrue);

      chain.txs = [
        const ChainTx(txid: 'out', balance: -5030, fee: 30, height: 100),
      ];
      now = now.add(const Duration(minutes: 1));
      final details = (await wallet.chainDetails('out'))!;
      expect(
        (details.transaction.sats, details.transaction.confirmations),
        (5000, 2),
      );
      expect(
        '${details.explorer}',
        'https://liquid.network/tx/out#blinded=secrets',
      );
      expect(await wallet.chainDetails('unknown'), isNull);
    });

    test('a payment is read from the saved state while offline', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.txs = [
        const ChainTx(txid: 'in', balance: 2000, fee: 26, height: 100),
      ];
      await wallet.fetchBalance();
      now = now.add(const Duration(minutes: 1));
      chain.syncErrors.addAll([
        for (var i = 0; i < 3; i++) _fails(LiquidChainError.unreachable),
      ]);

      final details = await wallet.chainDetails('in');
      expect(details!.transaction.confirmations, 1);
    });

    test('a testnet payment links to the testnet explorer', () async {
      final wallet = await source(
        networks: const {ChainNetwork.liquidTestnet},
      ).add(phrase: _phrase, name: 'Test', network: ChainNetwork.liquidTestnet);
      chain.txs = [const ChainTx(txid: 'in', balance: 2000, fee: 26)];

      final details = await wallet.chainDetails('in');
      expect(
        '${details!.explorer}',
        startsWith('https://liquid.network/testnet/tx/in#'),
      );
    });
  });

  group('sending', () {
    test('quotes the fee, then sends and returns the txid', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');

      final quote = await wallet.prepareSend(_elsewhere, sats: 5000);
      expect((quote.sats, quote.feeSats), (5000, 30));
      expect(chain.broadcasts, 0);

      final payment = await wallet.confirmSend(quote);
      expect((payment.txid, payment.feeSats), ('tx9', 30));
      expect(chain.broadcasts, 1);
    });

    test('sends everything, the fee taken out of it', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      await expectLater(
        wallet.prepareSendAll(_elsewhere),
        throwsA(
          isA<SendException>().having(
            (e) => e.error,
            'error',
            SendError.insufficientBalance,
          ),
        ),
      );

      chain.balanceSats = 12000;
      final quote = await wallet.prepareSendAll(_elsewhere);
      expect((quote.sats, quote.feeSats), (11970, 30));
      expect((await wallet.confirmSend(quote)).txid, 'tx9');
    });

    test('a sent transaction is followed until it confirms', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      final payment = await wallet.confirmSend(
        await wallet.prepareSend(_elsewhere, sats: 5000),
      );
      chain.txs = [ChainTx(txid: payment.txid!, balance: -5030, fee: 30)];

      final confirmed = wallet.watchConfirmation(payment.txid!).toList();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      chain.txs = [
        ChainTx(txid: payment.txid!, balance: -5030, fee: 30, height: 100),
      ];

      final [sent] = await confirmed.timeout(const Duration(seconds: 5));
      expect(
        (sent.txid, sent.sats, sent.isIncoming, sent.confirmations),
        ('tx9', 5000, false, 1),
      );
    });

    test('a link amount wins over the typed one', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      final quote = await wallet.prepareSend(
        ChainAddress(
          _elsewhere.address,
          network: ChainNetwork.liquid,
          sats: 21,
        ),
        sats: 5000,
      );
      expect(quote.sats, 21);
    });

    test('what cannot be paid fails before anything is sent', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      Matcher fails(SendError error) =>
          throwsA(isA<SendException>().having((e) => e.error, 'error', error));

      await expectLater(
        wallet.prepareSend(
          ChainAddress(_address, network: ChainNetwork.liquidTestnet),
          sats: 1,
        ),
        fails(SendError.wrongNetwork),
      );

      chain.prepareError = _fails(LiquidChainError.insufficientFunds);
      await expectLater(
        wallet.prepareSend(_elsewhere, sats: 1),
        fails(SendError.insufficientBalance),
      );
      expect(
        () => wallet.prepareSend(
          const Invoice(request: 'lnbc1', sats: 1),
          sats: 1,
        ),
        throwsUnsupportedError,
      );
      expect(chain.broadcasts, 0);
    });

    test('a broadcast is retried, then reported as unconfirmed', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.broadcastErrors.add(_fails(LiquidChainError.unreachable));
      final payment = await wallet.confirmSend(
        await wallet.prepareSend(_elsewhere, sats: 100),
      );
      expect(payment.txid, 'tx9');
      expect(chain.broadcasts, 2);

      chain.broadcastErrors.addAll(
        List.filled(3, _fails(LiquidChainError.unreachable)),
      );
      await expectLater(
        wallet.confirmSend(await wallet.prepareSend(_elsewhere, sats: 100)),
        throwsA(
          isA<SendException>().having(
            (e) => e.error,
            'error',
            SendError.unconfirmed,
          ),
        ),
      );
    });

    test('the send after an unconfirmed one syncs first', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      final quote = await wallet.prepareSend(_elsewhere, sats: 100);
      expect(chain.syncs, 1);
      chain.broadcastErrors.addAll(
        List.filled(3, _fails(LiquidChainError.unreachable)),
      );
      await expectLater(
        wallet.confirmSend(quote),
        throwsA(isA<SendException>()),
      );

      await wallet.prepareSend(_elsewhere, sats: 100);
      expect(chain.syncs, 2);
    });

    test('a rate-limited broadcast is not retried', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.broadcastErrors.add(_fails(LiquidChainError.rateLimited));

      await expectLater(
        wallet.confirmSend(await wallet.prepareSend(_elsewhere, sats: 100)),
        throwsA(
          isA<SendException>().having(
            (e) => e.error,
            'error',
            SendError.unconfirmed,
          ),
        ),
      );
      expect(chain.broadcasts, 1);
    });

    test('a refused transaction failed', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.broadcastErrors.add(_fails(LiquidChainError.rejected));

      await expectLater(
        wallet.confirmSend(await wallet.prepareSend(_elsewhere, sats: 100)),
        throwsA(
          isA<SendException>().having(
            (e) => e.error,
            'error',
            SendError.failed,
          ),
        ),
      );
      expect(chain.broadcasts, 1);
    });
  });

  group('receiving', () {
    test('gives the next address and sees it paid', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      final address = await wallet.nextAddress();
      expect(
        (address.address, address.network),
        (_address, ChainNetwork.liquid),
      );

      final paid = wallet.watchPayment(address).toList();
      await Future<void>.delayed(Duration.zero);
      chain.txs = [
        const ChainTx(txid: 'in', balance: 1000, fee: 26, received: [_address]),
      ];
      await Future<void>.delayed(const Duration(milliseconds: 50));
      chain.txs = [
        const ChainTx(
          txid: 'in',
          balance: 1000,
          fee: 26,
          height: 100,
          received: [_address],
        ),
      ];

      final [pending, confirmed] = await paid.timeout(
        const Duration(seconds: 5),
      );
      expect(
        (pending.txid, pending.sats, pending.isPending),
        ('in', 1000, true),
      );
      expect((confirmed.txid, confirmed.confirmations), ('in', 1));
    });

    test('a payment already confirmed is reported once', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      final address = await wallet.nextAddress();
      chain.txs = [
        const ChainTx(
          txid: 'in',
          balance: 1000,
          fee: 26,
          height: 99,
          received: [_address],
        ),
      ];

      final [payment] = await wallet
          .watchPayment(address)
          .toList()
          .timeout(const Duration(seconds: 5));
      expect(payment.confirmations, 2);
    });

    test('the watch follows the first payment, not the next ones', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      final address = await wallet.nextAddress();
      final paid = wallet.watchPayment(address).toList();
      chain.txs = [
        const ChainTx(txid: 'a', balance: 700, fee: 26, received: [_address]),
      ];
      await Future<void>.delayed(const Duration(milliseconds: 50));
      chain.txs = [
        const ChainTx(txid: 'b', balance: 500, fee: 26, received: [_address]),
        const ChainTx(
          txid: 'a',
          balance: 700,
          fee: 26,
          height: 100,
          received: [_address],
        ),
      ];

      final payments = await paid.timeout(const Duration(seconds: 5));
      expect(
        [for (final p in payments) (p.txid, p.sats)],
        [('a', 700), ('a', 700)],
      );
    });

    test('a transaction spending from the address is not a payment', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      final address = await wallet.nextAddress();
      final paid = wallet.watchPayment(address).first;
      chain.txs = [
        const ChainTx(
          txid: 'self',
          balance: -26,
          fee: 26,
          received: [_address],
        ),
      ];
      await Future<void>.delayed(const Duration(milliseconds: 50));
      chain.txs = [
        const ChainTx(txid: 'in', balance: 900, fee: 26, received: [_address]),
        ...chain.txs,
      ];

      expect((await paid.timeout(const Duration(seconds: 5))).txid, 'in');
    });

    test('the watch waits out a rate limit', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      final address = await wallet.nextAddress();
      chain.syncErrors.add(_fails(LiquidChainError.rateLimited));

      final paid = wallet.watchPayment(address).toList();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(chain.syncs, 2);

      now = now.add(const Duration(minutes: 1));
      chain.txs = [
        const ChainTx(
          txid: 'in',
          balance: 1000,
          fee: 26,
          height: 100,
          received: [_address],
        ),
      ];
      expect(await paid.timeout(const Duration(seconds: 5)), hasLength(1));
      expect(chain.syncs, 3);
    });

    test('an address is still given while the server is silent', () async {
      final wallet = await source().add(phrase: _phrase, name: 'Savings');
      chain.syncErrors.addAll(
        List.filled(3, _fails(LiquidChainError.unreachable)),
      );

      expect((await wallet.nextAddress()).address, _address);
    });
  });

  group('restoring', () {
    test('a phrase used with nested segwit only is restored as such', () async {
      final wallets = source();
      final nested = engine.chains[LiquidScript.nestedSegwit]!
        ..txs = [const ChainTx(txid: 'old', balance: 1000, fee: 26, height: 5)];

      final discovery = await wallets.discover(_phrase);
      expect(discovery.script, LiquidScript.nestedSegwit);

      final wallet = await wallets.add(
        phrase: _phrase,
        name: 'Restored',
        discovery: discovery,
      );
      await wallet.fetchBalance();
      expect(engine.openedWith.last, ['update1']);
      expect(nested.syncs, 2);
    });

    test('a fresh phrase or a native one stays native', () async {
      expect(
        (await source().discover(_phrase)).script,
        LiquidScript.nativeSegwit,
      );

      chain.txs = [const ChainTx(txid: 'a', balance: 1, fee: 26, height: 5)];
      engine.chains[LiquidScript.nestedSegwit]!.txs = chain.txs;
      expect(
        (await source().discover(_phrase)).script,
        LiquidScript.nativeSegwit,
      );
    });

    test('a phrase already saved is refused before any scan', () async {
      final both = {ChainNetwork.liquid, ChainNetwork.liquidTestnet};
      await source(networks: both).add(phrase: _phrase, name: 'Saved');
      final scans = chain.syncs;

      await expectLater(
        source(networks: both).discover(_phrase.toUpperCase()),
        throwsA(
          isA<LiquidAddException>().having(
            (e) => e.error,
            'error',
            LiquidAddError.duplicate,
          ),
        ),
      );
      expect(chain.syncs, scans);
      expect(await source().isSaved(' ${_phrase.toUpperCase()} '), isTrue);
      expect(
        await source().isSaved(_phrase, network: ChainNetwork.liquidTestnet),
        isFalse,
      );

      await source(networks: both)
          .discover(_phrase, network: ChainNetwork.liquidTestnet);
      expect(chain.syncs, greaterThan(scans));
    });

    test(
      'a phrase saved with one derivation is not added with another',
      () async {
        final wallets = source();
        await wallets.add(phrase: _phrase, name: 'Native');
        engine.chains[LiquidScript.nestedSegwit]!.txs = [
          const ChainTx(txid: 'old', balance: 1000, fee: 26, height: 5),
        ];
        final elsewhere = LiquidWalletSource(
          engine: engine,
          secrets: MemoryKeyValueStore(),
          chainState: MemoryKeyValueStore(),
        );
        final nested = await elsewhere.discover(_phrase);
        expect(nested.script, LiquidScript.nestedSegwit);

        await expectLater(
          wallets.add(phrase: _phrase, name: 'Nested', discovery: nested),
          throwsA(
            isA<LiquidAddException>().having(
              (e) => e.error,
              'error',
              LiquidAddError.duplicate,
            ),
          ),
        );
      },
    );

    test('a discovery on another network is refused', () async {
      final both = {ChainNetwork.liquid, ChainNetwork.liquidTestnet};
      final discovery = await source(networks: both).discover(_phrase);

      await expectLater(
        source(networks: both).add(
          phrase: _phrase,
          name: 'Test',
          network: ChainNetwork.liquidTestnet,
          discovery: discovery,
        ),
        throwsArgumentError,
      );
    });
  });
}
