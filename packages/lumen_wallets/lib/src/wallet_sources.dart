import 'package:ndk/domain_layer/repositories/wallets_repo.dart';
import 'package:ndk/ndk.dart';

import 'nwc/nwc_wallet_source.dart';
import 'wallet.dart';

/// Every wallet source Lumen supports, sharing one Nostr client.
final class WalletSources {
  WalletSources._(this._ndk, this.nwc);

  /// [repo] stores the wallets, connection secrets included, so it must be
  /// encrypted at rest.
  factory WalletSources.create({
    required WalletsRepo repo,
    required EventVerifier eventVerifier,
  }) {
    final ndk = Ndk(
      NdkConfig(
        eventVerifier: eventVerifier,
        cache: MemCacheManager(),
        walletsRepo: repo,
        bootstrapRelays: const [],
      ),
    );
    return WalletSources._(ndk, NwcWalletSource(ndk: ndk, repo: repo));
  }

  final Ndk _ndk;
  final NwcWalletSource nwc;

  List<WalletSource> get all => [nwc];

  Future<void> dispose() => _ndk.destroy();
}
