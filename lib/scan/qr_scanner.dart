import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';

const _channel = MethodChannel('lumen/scanner');

/// Only the Android app has a camera screen so far.
bool get canScanQrCodes =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Opens the camera until it reads a QR code. Null when the user closes it.
Future<String?> scanQrCode(BuildContext context) async {
  final l = AppLocalizations.of(context);
  try {
    final text = await _channel.invokeMethod<String>('scan', {
      'title': l.scanQrCode,
      'hint': l.scanHint,
      'close': l.close,
      'lightOn': l.turnOnLight,
      'lightOff': l.turnOffLight,
      'cameraNeeded': l.cameraNeeded,
      'allowCamera': l.allowCamera,
      'openSettings': l.openSettings,
      'noCamera': l.noCamera,
    });
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  } on PlatformException {
    return null;
  }
}
