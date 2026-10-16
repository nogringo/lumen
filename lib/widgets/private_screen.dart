import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const _channel = MethodChannel('lumen/screen');

/// How many [PrivateScreen]s are mounted, as a phrase screen stays under the
/// one pushed on top of it.
var _mounted = 0;

/// Keeps the screen out of sight while [child] is shown: out of screenshots,
/// recordings and the app switcher on Android, out of the app switcher on
/// iOS, out of screen capture on macOS. Other platforms have no such switch.
class PrivateScreen extends StatefulWidget {
  const PrivateScreen({super.key, required this.child});

  final Widget child;

  @override
  State<PrivateScreen> createState() => _PrivateScreenState();
}

class _PrivateScreenState extends State<PrivateScreen> {
  @override
  void initState() {
    super.initState();
    if (_mounted++ == 0) _setPrivate(true);
  }

  @override
  void dispose() {
    if (--_mounted == 0) _setPrivate(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<void> _setPrivate(bool private) async {
  if (kIsWeb) return;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android || TargetPlatform.iOS || TargetPlatform.macOS:
      try {
        await _channel.invokeMethod<void>('setPrivate', private);
      } on PlatformException {
        // The phrase still shows, just without the protection.
      } on MissingPluginException {
        // Same.
      }
    default:
  }
}
