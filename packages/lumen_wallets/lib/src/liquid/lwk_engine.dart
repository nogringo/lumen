import 'package:lumen_core/lumen_core.dart' as core;

import '../wallet.dart';
import 'liquid_engine.dart';

/// [LiquidEngine] over LWK, through lumen_core.
final class LwkEngine implements LiquidEngine {
  const LwkEngine();

  static Future<void>? _loading;

  /// Loads the Rust library, once. In the app it is bundled; elsewhere, as
  /// in a script, pass the path of the one `cargo build` made.
  ///
  /// [ready] and [open] call it, so the web app downloads the wasm only when
  /// a Liquid wallet is opened or created.
  static Future<void> init({String? libraryPath}) => _loading ??=
      core.RustLib.init(
        externalLibrary: libraryPath == null
            ? null
            : core.ExternalLibrary.open(libraryPath),
      ).catchError((Object e) {
        _loading = null;
        throw e;
      });

  @override
  Future<void> ready() => init();

  @override
  String generatePhrase() => _guard(core.generatePhrase);

  @override
  PhraseProblem? phraseProblem(String phrase) =>
      switch (core.phraseProblem(phrase: phrase)) {
        null => null,
        core.PhraseProblem.wordCount => PhraseProblem.wordCount,
        core.PhraseProblem.unknownWord => PhraseProblem.unknownWord,
        core.PhraseProblem.checksum => PhraseProblem.checksum,
      };

  @override
  Future<LiquidChain> open({
    required String phrase,
    required ChainNetwork network,
    required LiquidScript script,
    required LiquidServers servers,
    required List<String> state,
  }) async {
    try {
      await init();
    } catch (e) {
      throw LiquidChainException(LiquidChainError.other, '$e');
    }
    return _LwkChain(
      await _guardAsync(
        () => core.LiquidWallet.open(
          phrase: phrase,
          network: switch (network) {
            ChainNetwork.liquid => core.LiquidNetwork.mainnet,
            ChainNetwork.liquidTestnet => core.LiquidNetwork.testnet,
          },
          script: switch (script) {
            LiquidScript.nativeSegwit => core.ScriptKind.nativeSegwit,
            LiquidScript.nestedSegwit => core.ScriptKind.nestedSegwit,
          },
          waterfallsUrl: servers.waterfalls,
          esploraUrl: servers.esplora,
          state: state,
        ),
      ),
    );
  }
}

final class _LwkChain implements LiquidChain {
  _LwkChain(this._wallet);

  final core.LiquidWallet _wallet;

  @override
  Future<bool> sync() => _guardAsync(_wallet.sync_);

  @override
  Future<List<String>> state() => _guardAsync(_wallet.state);

  @override
  Future<int> balance() async => (await _guardAsync(_wallet.balance)).toInt();

  @override
  Future<int> tipHeight() => _wallet.tipHeight();

  @override
  Future<String> nextAddress() async =>
      (await _guardAsync(_wallet.address)).address;

  @override
  Future<List<ChainTx>> transactions() async => [
    for (final tx in await _guardAsync(_wallet.transactions))
      ChainTx(
        txid: tx.txid,
        balance: tx.balance.toInt(),
        fee: tx.fee.toInt(),
        height: tx.height,
        timestamp: switch (tx.timestamp) {
          final seconds? => DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
          null => null,
        },
        received: tx.received,
      ),
  ];

  @override
  Future<LiquidDraft> prepareSend(String address, int sats) async => _LwkDraft(
    await _guardAsync(
      () => _wallet.prepareSend(address: address, sats: BigInt.from(sats)),
    ),
  );

  @override
  Future<LiquidSigned> sign(LiquidDraft draft) async => _LwkSigned(
    await _guardAsync(() => _wallet.sign(draft: (draft as _LwkDraft)._draft)),
  );

  @override
  Future<void> broadcast(LiquidSigned signed) =>
      _guardAsync(() => _wallet.broadcast(signed: (signed as _LwkSigned)._tx));
}

final class _LwkDraft implements LiquidDraft {
  _LwkDraft(this._draft);

  final core.LiquidDraft _draft;

  @override
  int get fee => _draft.fee.toInt();
}

final class _LwkSigned implements LiquidSigned {
  _LwkSigned(this._tx);

  final core.LiquidSigned _tx;

  @override
  String get txid => _tx.txid;
}

T _guard<T>(T Function() call) {
  try {
    return call();
  } on core.LiquidError catch (e) {
    throw _exception(e);
  }
}

Future<T> _guardAsync<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on core.LiquidError catch (e) {
    throw _exception(e);
  }
}

LiquidChainException _exception(core.LiquidError error) =>
    LiquidChainException(switch (error.kind) {
      core.LiquidErrorKind.unreachable => LiquidChainError.unreachable,
      core.LiquidErrorKind.rejected => LiquidChainError.rejected,
      core.LiquidErrorKind.insufficientFunds =>
        LiquidChainError.insufficientFunds,
      core.LiquidErrorKind.invalidAddress => LiquidChainError.invalidAddress,
      core.LiquidErrorKind.wrongNetwork => LiquidChainError.wrongNetwork,
      core.LiquidErrorKind.other => LiquidChainError.other,
    }, error.message);
