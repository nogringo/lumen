import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

/// Opens the system share sheet for [text], anchored on iPad and macOS to the
/// widget of [anchor].
void shareText(BuildContext anchor, String text) {
  final box = anchor.findRenderObject() as RenderBox?;
  SharePlus.instance.share(
    ShareParams(
      text: text,
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}
