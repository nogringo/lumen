import 'package:flutter/widgets.dart';
import 'package:lumen_wallets/lumen_wallets.dart';

import 'wallets_controller.dart';

class LumenScope extends InheritedNotifier<WalletsController> {
  const LumenScope({
    super.key,
    required this.sources,
    required WalletsController wallets,
    required super.child,
  }) : super(notifier: wallets);

  final WalletSources sources;

  /// Rebuilds [context] when wallets or balances change.
  static WalletsController walletsOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LumenScope>()!.notifier!;

  static WalletsController readWallets(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LumenScope>()!.notifier!;

  static WalletSources sourcesOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LumenScope>()!.sources;
}
