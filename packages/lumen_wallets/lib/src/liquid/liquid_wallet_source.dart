import 'dart:async';
import 'dart:convert';
import 'dart:math';

import '../random_id.dart';
import '../wallet.dart';
import 'liquid_engine.dart';

enum LiquidAddError {
  /// Not a valid recovery phrase of 12 or 24 words.
  invalidPhrase,

  /// The same phrase is already saved on this network.
  duplicate,

  /// The chain server did not answer while looking for the wallet's history.
  unreachable,
}

class LiquidAddException implements Exception {
  const LiquidAddException(this.error);

  final LiquidAddError error;

  @override
  String toString() => 'LiquidAddException(${error.name})';
}

/// Liquid wallets whose recovery phrase lives in Lumen.
final class LiquidWalletSource implements WalletSource {
  /// [secrets] holds the recovery phrases, so it must be encrypted at rest.
  /// [chainState] holds what each wallet knows of the chain, which grows by
  /// about 14 KB per transaction. Only [networks] can be added and loaded.
  LiquidWalletSource({
    required this._engine,
    required this._secrets,
    required this._chainState,
    this.networks = const {ChainNetwork.liquid},
    this._servers = defaultServers,
    this._retryDelays = const [Duration(seconds: 1), Duration(seconds: 3)],
    this._now = DateTime.now,
    this._watchInterval = const Duration(seconds: 10),
  });

  /// The Liquid Web Wallet's Waterfalls, then mempool.space's Esplora, whose
  /// hourly cap is not low enough for a full sync to hit it. Both answer
  /// browsers.
  static const defaultServers = {
    ChainNetwork.liquid: LiquidServers(
      waterfalls: 'https://waterfalls.liquidwebwallet.org/liquid/api',
      esplora: 'https://liquid.network/api',
    ),
    ChainNetwork.liquidTestnet: LiquidServers(
      waterfalls: 'https://waterfalls.liquidwebwallet.org/liquidtestnet/api',
      esplora: 'https://liquid.network/liquidtestnet/api',
    ),
  };

  final Set<ChainNetwork> networks;
  final LiquidEngine _engine;
  final KeyValueStore _secrets;
  final KeyValueStore _chainState;
  final Map<ChainNetwork, LiquidServers> _servers;
  final List<Duration> _retryDelays;
  final DateTime Function() _now;
  final Duration _watchInterval;

  Future<void> _writing = Future.value();

  static const _walletsKey = 'lumen.liquid.wallets';
  static String _phraseKey(String id) => 'lumen.liquid.$id.phrase';
  static String _stateKey(String id) => 'lumen.liquid.$id.state';

  /// A sync this recent is not repeated when the balance and the
  /// transactions are read one after the other.
  static const _fresh = Duration(seconds: 15);

  /// How long a wallet sends no sync after a server rate limited it.
  static const _rateLimitPause = Duration(minutes: 1);

  /// Throws a [LiquidChainException] when the engine cannot start, as on a
  /// web build without its wasm.
  Future<String> newPhrase() async {
    await _ready();
    return _engine.generatePhrase();
  }

  Future<PhraseProblem?> checkPhrase(String phrase) async {
    await _ready();
    return _engine.phraseProblem(_normalized(phrase));
  }

  Future<void> _ready() async {
    try {
      await _engine.ready();
    } catch (e) {
      throw LiquidChainException(LiquidChainError.other, '$e');
    }
  }

  /// Whether [phrase] is already saved on [network], so restoring it would
  /// only give the same wallet again.
  Future<bool> isSaved(
    String phrase, {
    ChainNetwork network = ChainNetwork.liquid,
  }) async => _isSaved(_normalized(phrase), network, await _records());

  /// Scans the chain for the history of a [phrase] to restore, and finds
  /// the derivation it was used with: nested segwit when only that one has
  /// a history, as some apps create, and native segwit otherwise.
  ///
  /// Throws a [LiquidAddException] when the phrase is invalid or already
  /// saved on [network], both found before any scan, or when the chain
  /// cannot be read.
  Future<LiquidDiscovery> discover(
    String phrase, {
    ChainNetwork network = ChainNetwork.liquid,
  }) async {
    final normalized = _checked(phrase);
    if (await isSaved(normalized, network: network)) {
      throw const LiquidAddException(LiquidAddError.duplicate);
    }
    Future<LiquidDiscovery?> scan(LiquidScript script) async {
      final chain = await _engine.open(
        phrase: normalized,
        network: network,
        script: script,
        servers: _servers[network]!,
        state: const [],
      );
      await _retrying(chain.sync);
      if ((await chain.transactions()).isEmpty) return null;
      return LiquidDiscovery._(network, script, await chain.state());
    }

    try {
      return await scan(LiquidScript.nativeSegwit) ??
          await scan(LiquidScript.nestedSegwit) ??
          LiquidDiscovery._(network, LiquidScript.nativeSegwit, const []);
    } on LiquidChainException {
      throw const LiquidAddException(LiquidAddError.unreachable);
    }
  }

  /// Saves the wallet [phrase] gives, with the derivation and chain state
  /// [discovery] found when it is restored. Throws a [LiquidAddException]
  /// when the phrase is invalid or already saved.
  Future<Wallet> add({
    required String phrase,
    required String name,
    ChainNetwork network = ChainNetwork.liquid,
    LiquidDiscovery? discovery,
  }) async {
    if (!networks.contains(network)) {
      throw ArgumentError.value(network, 'network', 'not enabled');
    }
    if (discovery != null && discovery.network != network) {
      throw ArgumentError.value(discovery, 'discovery', 'on another network');
    }
    final script = discovery?.script ?? LiquidScript.nativeSegwit;
    final normalized = _checked(phrase);
    return _write(() async {
      final records = await _records();
      if (await _isSaved(normalized, network, records)) {
        throw const LiquidAddException(LiquidAddError.duplicate);
      }
      final record = _Record(
        id: randomId(),
        name: name.trim(),
        network: network,
        script: script,
      );
      await _secrets.write(_phraseKey(record.id), normalized);
      if (discovery case LiquidDiscovery(:final _state)
          when _state.isNotEmpty) {
        await _writeState(record.id, _state, const {});
      }
      await _writeRecords([...records, record]);
      return LiquidWallet._(this, record);
    });
  }

  @override
  Future<List<Wallet>> load() async => [
    for (final record in await _records())
      if (networks.contains(record.network)) LiquidWallet._(this, record),
  ];

  /// One wallet per phrase and network, whatever derivation it was found
  /// with.
  Future<bool> _isSaved(
    String normalized,
    ChainNetwork network,
    List<_Record> records,
  ) async {
    for (final record in records) {
      if (record.network == network &&
          await _secrets.read(_phraseKey(record.id)) == normalized) {
        return true;
      }
    }
    return false;
  }

  String _checked(String phrase) {
    final normalized = _normalized(phrase);
    if (_engine.phraseProblem(normalized) != null) {
      throw const LiquidAddException(LiquidAddError.invalidPhrase);
    }
    return normalized;
  }

  static String _normalized(String phrase) =>
      phrase.trim().toLowerCase().split(RegExp(r'\s+')).join(' ');

  /// Runs [change] after the previous one, so two edits of the wallet list
  /// never overwrite each other.
  Future<T> _write<T>(Future<T> Function() change) {
    final result = _writing.then((_) => change());
    _writing = result.then((_) {}, onError: (Object _) {});
    return result;
  }

  Future<List<_Record>> _records() async {
    final saved = await _secrets.read(_walletsKey);
    if (saved == null) return [];
    return [
      for (final json in jsonDecode(saved) as List)
        _Record.fromJson(json as Map<String, Object?>),
    ];
  }

  Future<void> _writeRecords(List<_Record> records) => _secrets.write(
    _walletsKey,
    jsonEncode([for (final record in records) record.toJson()]),
  );

  Future<void> _rename(String id, String name) => _write(() async {
    await _writeRecords([
      for (final record in await _records())
        record.id == id ? record.renamed(name) : record,
    ]);
  });

  Future<void> _remove(String id) => _write(() async {
    await _writeRecords([
      for (final record in await _records())
        if (record.id != id) record,
    ]);
    await _secrets.delete(_phraseKey(id));
    await _chainState.delete(_stateKey(id));
  });

  /// Opens [record] from its saved state, or from scratch when the state no
  /// longer opens.
  Future<(LiquidChain, Map<String, int>)> _open(_Record record) async {
    final phrase = await _secrets.read(_phraseKey(record.id));
    if (phrase == null) throw StateError('No phrase for ${record.id}');
    var (updates, seen) = await _readState(record.id);
    Future<LiquidChain> open(List<String> state) => _engine.open(
      phrase: phrase,
      network: record.network,
      script: record.script,
      servers: _servers[record.network]!,
      state: state,
    );
    try {
      return (await open(updates), seen);
    } on LiquidChainException {
      if (updates.isEmpty) rethrow;
      return (await open(const []), <String, int>{});
    }
  }

  Future<(List<String>, Map<String, int>)> _readState(String id) async {
    try {
      final saved = await _chainState.read(_stateKey(id));
      if (saved == null) return (<String>[], <String, int>{});
      final json = jsonDecode(saved) as Map<String, Object?>;
      return (
        [for (final update in json['updates'] as List) update as String],
        {
          for (final MapEntry(:key, :value)
              in ((json['seen'] as Map?) ?? const {}).entries)
            key as String: value as int,
        },
      );
    } catch (_) {
      return (<String>[], <String, int>{});
    }
  }

  Future<void> _writeState(
    String id,
    List<String> updates,
    Map<String, int> seen,
  ) => _chainState.write(
    _stateKey(id),
    jsonEncode({'updates': updates, 'seen': seen}),
  );

  /// Calls [call] again after each of [_retryDelays] while the server does
  /// not answer, since public servers drop a connection now and then.
  Future<T> _retrying<T>(Future<T> Function() call) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await call();
      } on LiquidChainException catch (e) {
        if (e.error != LiquidChainError.unreachable ||
            attempt >= _retryDelays.length) {
          rethrow;
        }
        await Future<void>.delayed(_retryDelays[attempt]);
      }
    }
  }
}

/// What [LiquidWalletSource.discover] found for a phrase. It keeps the
/// chain state it scanned, not the phrase, so [LiquidWalletSource.add] need
/// not scan again.
final class LiquidDiscovery {
  const LiquidDiscovery._(this.network, this.script, this._state);

  final ChainNetwork network;
  final LiquidScript script;
  final List<String> _state;
}

final class _Record {
  const _Record({
    required this.id,
    required this.name,
    required this.network,
    required this.script,
  });

  factory _Record.fromJson(Map<String, Object?> json) => _Record(
    id: json['id'] as String,
    name: json['name'] as String,
    network: ChainNetwork.values.byName(json['network'] as String),
    script: LiquidScript.values.byName(json['script'] as String),
  );

  final String id;
  final String name;
  final ChainNetwork network;
  final LiquidScript script;

  _Record renamed(String name) =>
      _Record(id: id, name: name, network: network, script: script);

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'network': network.name,
    'script': script.name,
  };
}

final class _LiquidQuote extends SendQuote {
  const _LiquidQuote(
    this._wallet,
    this._draft, {
    required super.request,
    required super.sats,
    required super.feeSats,
  });

  final LiquidWallet _wallet;
  final LiquidDraft _draft;
}

/// A Liquid wallet whose recovery phrase lives in Lumen.
final class LiquidWallet implements Wallet {
  LiquidWallet._(this._source, this._record) : _name = _record.name;

  final LiquidWalletSource _source;
  final _Record _record;
  String _name;

  Future<LiquidChain>? _chain;

  /// When each pending transaction was first seen, since the chain only
  /// dates confirmed ones. In milliseconds.
  Map<String, int> _seen = {};
  Future<void>? _syncing;
  DateTime? _syncedAt;
  DateTime? _pausedUntil;

  @override
  String get id => _record.id;

  @override
  String get name => _name;

  @override
  ChainNetwork get network => _record.network;

  @override
  WalletKind get kind => WalletKind.liquid;

  @override
  String? get lightningAddress => null;

  @override
  Set<WalletCapability> get capabilities => const {
    WalletCapability.receiveAddress,
    WalletCapability.payAddress,
    WalletCapability.payAll,
  };

  @override
  Future<String?> connectionString() async => null;

  Future<LiquidChain> _opened() => _chain ??=
      () async {
        final (chain, seen) = await _source._open(_record);
        _seen = seen;
        return chain;
      }().catchError((Object e) {
        _chain = null;
        throw e;
      });

  /// The wallet, synced within [LiquidWalletSource._fresh] unless [force].
  Future<LiquidChain> _synced({bool force = false}) async {
    final chain = await _opened();
    final at = _syncedAt;
    final fresh =
        at != null && _source._now().difference(at) < LiquidWalletSource._fresh;
    if (force || !fresh) {
      await (_syncing ??= _syncOnce(chain).whenComplete(() => _syncing = null));
    }
    return chain;
  }

  Future<void> _syncOnce(LiquidChain chain) async {
    if (_pausedUntil case final until? when _source._now().isBefore(until)) {
      throw const LiquidChainException(LiquidChainError.rateLimited);
    }
    final bool changed;
    try {
      changed = await _source._retrying(chain.sync);
    } on LiquidChainException catch (e) {
      if (e.error == LiquidChainError.rateLimited) {
        _pausedUntil = _source._now().add(LiquidWalletSource._rateLimitPause);
      }
      rethrow;
    }
    _syncedAt = _source._now();
    if (changed) await _save(chain);
  }

  Future<void> _save(LiquidChain chain) async {
    final now = _source._now().millisecondsSinceEpoch;
    final pending = {
      for (final tx in await chain.transactions())
        if (tx.height == null) tx.txid,
    };
    _seen = {for (final txid in pending) txid: _seen[txid] ?? now};
    await _source._writeState(id, await chain.state(), _seen);
  }

  @override
  Future<int> fetchBalance() async {
    try {
      return await (await _synced()).balance();
    } on LiquidChainException {
      throw const BalanceException(BalanceError.unreachable);
    }
  }

  @override
  Future<Invoice> createInvoice(int sats) =>
      throw UnsupportedError('Liquid wallets have no invoices yet');

  /// Synced first when the server answers, so an address paid since the
  /// last sync is not given again. Without an answer, the saved state gives
  /// one, which may have been paid already.
  @override
  Future<ChainAddress> nextAddress() async {
    final LiquidChain chain;
    try {
      chain = await _opened();
    } on LiquidChainException {
      throw const ReceiveException(ReceiveError.unreachable);
    }
    try {
      await _synced();
    } on LiquidChainException {
      // Given from the saved state.
    }
    try {
      return ChainAddress(await chain.nextAddress(), network: network);
    } on LiquidChainException {
      throw const ReceiveException(ReceiveError.unreachable);
    }
  }

  /// Syncs every few seconds. Emits the first incoming transaction paying
  /// [request] while still in the mempool, then again when it confirms.
  @override
  Stream<Transaction> watchPayment(PaymentRequest request) {
    final address = switch (request) {
      ChainAddress(:final address) => address,
      Invoice() => throw UnsupportedError('Liquid wallets have no invoices'),
    };
    return _follow(
      (tx, payment) => tx.received.contains(address) && payment.isIncoming,
    );
  }

  /// Syncs every few seconds, as [watchPayment] does.
  @override
  Stream<Transaction> watchConfirmation(String txid) =>
      _follow((tx, _) => false, txid: txid);

  /// Syncs every few seconds. Emits the oldest transaction that [matches]
  /// accepts, then follows it: emitted again once it confirms, then closed.
  /// A [txid] already known is followed from the start and only emitted
  /// once confirmed.
  Stream<Transaction> _follow(
    bool Function(ChainTx tx, Transaction payment) matches, {
    String? txid,
  }) {
    late final StreamController<Transaction> controller;
    Timer? timer;
    var checking = false;
    var seen = txid;

    Future<void> check() async {
      if (checking || controller.isClosed) return;
      checking = true;
      try {
        final chain = await _synced(force: true);
        final tip = await chain.tipHeight();
        final payment = [
          for (final tx in await chain.transactions())
            if (_transaction(tx, tip) case final t?
                when seen == null ? matches(tx, t) : tx.txid == seen)
              t,
        ].lastOrNull;
        if (payment == null || controller.isClosed) return;
        if (seen == null || !payment.isPending) {
          seen = payment.id;
          controller.add(payment);
        }
        if (!payment.isPending) {
          timer?.cancel();
          await controller.close();
        }
      } catch (_) {
        // Tried again on the next tick.
      } finally {
        checking = false;
      }
    }

    controller = StreamController<Transaction>(
      onListen: () {
        check();
        timer = Timer.periodic(_source._watchInterval, (_) {
          check();
        });
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<SendQuote> prepareSend(PaymentRequest request, {int? sats}) {
    final address = switch (request) {
      ChainAddress() => request,
      Invoice() => throw UnsupportedError('Liquid wallets pay addresses only'),
    };
    final amount = address.sats ?? sats;
    if (amount == null || amount <= 0) {
      throw ArgumentError.value(sats, 'sats', 'must be positive');
    }
    return _prepare(
      address,
      (chain) => chain.prepareSend(address.address, amount),
    );
  }

  /// Ignores an amount [address] asks for.
  @override
  Future<SendQuote> prepareSendAll(ChainAddress address) =>
      _prepare(address, (chain) => chain.prepareSendAll(address.address));

  Future<SendQuote> _prepare(
    ChainAddress address,
    Future<LiquidDraft> Function(LiquidChain chain) build,
  ) async {
    if (address.network != network) {
      throw const SendException(SendError.wrongNetwork);
    }
    try {
      final draft = await build(await _synced());
      return _LiquidQuote(
        this,
        draft,
        request: address,
        sats: draft.sats,
        feeSats: draft.fee,
      );
    } on LiquidChainException catch (e) {
      throw SendException(switch (e.error) {
        LiquidChainError.unreachable ||
        LiquidChainError.rateLimited => SendError.unreachable,
        LiquidChainError.insufficientFunds => SendError.insufficientBalance,
        LiquidChainError.wrongNetwork => SendError.wrongNetwork,
        _ => SendError.failed,
      });
    }
  }

  /// A broadcast left without an answer may have reached the server, so it
  /// is reported as [SendError.unconfirmed], and the next send syncs first:
  /// without the sent transaction in the wallet, it could spend other coins
  /// and pay twice. A rate limit counts as no answer, since the fallback
  /// server may be the one that refused, after the first one went silent.
  @override
  Future<Payment> confirmSend(SendQuote quote) async {
    if (quote is! _LiquidQuote || !identical(quote._wallet, this)) {
      throw ArgumentError.value(quote, 'quote', 'not prepared by this wallet');
    }
    final chain = await _opened();
    final LiquidSigned signed;
    try {
      signed = await chain.sign(quote._draft);
    } on LiquidChainException {
      throw const SendException(SendError.failed);
    }
    try {
      await _source._retrying(() => chain.broadcast(signed));
    } on LiquidChainException catch (e) {
      if (e.error != LiquidChainError.unreachable &&
          e.error != LiquidChainError.rateLimited) {
        throw const SendException(SendError.failed);
      }
      _syncedAt = null;
      throw const SendException(SendError.unconfirmed);
    }
    _seen[signed.txid] = _source._now().millisecondsSinceEpoch;
    try {
      await _save(chain);
    } catch (_) {
      // The next sync saves it.
    }
    return Payment(feeSats: quote.feeSats!, txid: signed.txid);
  }

  @override
  Future<TransactionPage> fetchTransactions({
    int limit = 10,
    int offset = 0,
  }) async {
    final List<ChainTx> listed;
    final int tip;
    try {
      final chain = await _synced();
      listed = await chain.transactions();
      tip = await chain.tipHeight();
    } on LiquidChainException {
      throw const ActivityException(ActivityError.unreachable);
    }
    final all = [for (final tx in listed) ?_transaction(tx, tip)]
      ..sort((a, b) => b.at.compareTo(a.at));
    final page = all.skip(offset).take(limit).toList();
    return TransactionPage(page, listed: page.length);
  }

  /// Null for a transaction that moves no L-BTC of this wallet, such as one
  /// receiving another asset.
  Transaction? _transaction(ChainTx tx, int tip) {
    if (tx.balance == 0) return null;
    final incoming = tx.balance > 0;
    final height = tx.height;
    return Transaction(
      id: tx.txid,
      direction: incoming
          ? TransactionDirection.incoming
          : TransactionDirection.outgoing,
      sats: incoming ? tx.balance : -tx.balance - tx.fee,
      at:
          tx.timestamp ??
          DateTime.fromMillisecondsSinceEpoch(
            _seen[tx.txid] ?? _source._now().millisecondsSinceEpoch,
          ),
      feeSats: incoming ? null : tx.fee,
      txid: tx.txid,
      confirmations: height == null ? 0 : max(1, tip - height + 1),
    );
  }

  @override
  Future<void> rename(String name) async {
    await _source._rename(id, name.trim());
    _name = name.trim();
  }

  /// Takes the funds with it unless the recovery phrase is backed up.
  @override
  Future<void> remove() => _source._remove(id);
}
