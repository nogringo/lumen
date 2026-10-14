import 'package:flutter/widgets.dart';

import '../wallets/lumen_scope.dart';

/// The window width decides, not the device: a tablet in landscape is desktop.
enum LayoutSize {
  phone,
  tablet,
  desktop;

  static LayoutSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 840) return desktop;
    if (width >= 600) return tablet;
    return phone;
  }

  EdgeInsets get screenPadding => switch (this) {
    phone => const EdgeInsets.fromLTRB(20, 16, 20, 32),
    tablet => const EdgeInsets.fromLTRB(40, 32, 40, 40),
    desktop => const EdgeInsets.fromLTRB(56, 40, 56, 40),
  };
}

/// On desktop the sidebar lists every wallet and replaces the back button.
bool hasSidebar(BuildContext context) =>
    LayoutSize.of(context) == LayoutSize.desktop &&
    LumenScope.walletsOf(context).wallets.isNotEmpty;
