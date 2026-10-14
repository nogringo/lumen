import 'package:http/http.dart' as http;
import 'package:ndk/domain_layer/repositories/wallets_repo.dart';
import 'package:ndk/ndk.dart';

import 'lightning/lnurl_pay.dart';
import 'nwc/nwc_wallet_source.dart';
import 'wallet.dart';

/// Every wallet source Lumen supports, sharing one Nostr client.
final class WalletSources {
  WalletSources._(this._ndk, this.nwc, this._http) : lnurlPay = LnurlPay(_http);

  /// [repo] stores the wallets, connection secrets included, so it must be
  /// encrypted at rest.
  factory WalletSources.create({
    required WalletsRepo repo,
    required EventVerifier eventVerifier,
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
      httpClient ?? http.Client(),
    );
  }

  final Ndk _ndk;
  final NwcWalletSource nwc;
  final http.Client _http;

  /// Turns Lightning addresses and LNURLs into invoices.
  final LnurlPay lnurlPay;

  List<WalletSource> get all => [nwc];

  Future<void> dispose() {
    _http.close();
    return _ndk.destroy();
  }
}
