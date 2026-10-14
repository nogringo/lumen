import 'package:material_ui/material_ui.dart';
import 'package:qr/qr.dart';

/// Black on white in every theme, so any camera can read it.
class QrCodeView extends StatelessWidget {
  const QrCodeView({
    super.key,
    required this.data,
    required this.semanticLabel,
    this.size = 264,
  });

  final String data;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = QrImage(
      QrCode.fromData(data: data, errorCorrectLevel: QrErrorCorrectLevel.M),
    );
    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        width: size,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(painter: _QrPainter(image)),
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.image);

  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final count = image.moduleCount;
    final module = size.width / count;
    final path = Path();
    for (var y = 0; y < count; y++) {
      for (var x = 0; x < count; x++) {
        if (image.isDark(y, x)) {
          // Slightly larger squares avoid hairline gaps between modules.
          path.addRect(
            Rect.fromLTWH(x * module, y * module, module + 0.5, module + 0.5),
          );
        }
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.image != image;
}
