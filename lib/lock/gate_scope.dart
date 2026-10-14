import 'package:flutter/widgets.dart';

import 'app_gate.dart';

/// Gives the lock screen, Settings and Lock now access to the [AppGate].
class GateScope extends InheritedWidget {
  const GateScope({super.key, required this.gate, required super.child});

  final AppGate gate;

  static AppGate of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<GateScope>()!.gate;

  @override
  bool updateShouldNotify(GateScope oldWidget) => gate != oldWidget.gate;
}
