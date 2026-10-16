import 'package:http/http.dart' as http;
import 'package:ndk/domain_layer/repositories/wallets_repo.dart';
import 'package:ndk/ndk.dart';

import 'lightning/lnurl_pay.dart';
import 'liquid/liquid_engine.dart';
import 'liquid/liquid_wallet_source.dart';
import 'liquid/lwk_engine.dart';
import 'nwc/nwc_wallet_source.dart';
import 'wallet.dart';

/// Every wallet source Lumen supports, sharing one Nostr client.
final class WalletSources {
  WalletSources._(this._ndk, this.nwc, this.liquid, this._http)
    : lnurlPay = LnurlPay(_http);

  /// [repo] stores the wallets, connection secrets included, and
  /// [liquidSecrets] the recovery phrases, so both must be encrypted at
  /// rest. [liquidChainState] grows with each Liquid wallet's history.
  /// Testnet wallets need [ChainNetwork.liquidTestnet] in [liquidNetworks].
  factory WalletSources.create({
    required WalletsRepo repo,
    required EventVerifier eventVerifier,
    required KeyValueStore liquidSecrets,
    required KeyValueStore liquidChainState,
    Set<ChainNetwork> liquidNetworks = const {ChainNetwork.liquid},
    LiquidEngine liquidEngine = const LwkEngine(),
    http.Client? httpClient,
  }) {
    final ndk = Ndk(
      NdkConfig(
        eventVerifier: eventVerifier,
        cache: MemCacheManager(),
        walletsRepo: repo,
        bootstrapRelays: const [],
      ),
    );
    return WalletSources._(
      ndk,
      NwcWalletSource(ndk: ndk, repo: repo),
      LiquidWalletSource(
        engine: liquidEngine,
        secrets: liquidSecrets,
        chainState: liquidChainState,
        networks: liquidNetworks,
      ),
      httpClient ?? http.Client(),
    );
  }

  final Ndk _ndk;
  final NwcWalletSource nwc;
  final LiquidWalletSource liquid;
  final http.Client _http;

  /// Turns Lightning addresses and LNURLs into invoices.
  final LnurlPay lnurlPay;

  List<WalletSource> get all => [nwc, liquid];

  Future<void> dispose() {
    _http.close();
    return _ndk.destroy();
  }
}
