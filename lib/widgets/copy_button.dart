import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Copies [text], then shows a check for a moment and announces [copied].
class CopyButton extends StatefulWidget {
  const CopyButton({
    super.key,
    required this.text,
    required this.tooltip,
    required this.copied,
    this.style,
  });

  final String text;
  final String tooltip;
  final String copied;
  final ButtonStyle? style;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  var _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    final view = View.of(context);
    final direction = Directionality.of(context);
    await Clipboard.setData(ClipboardData(text: widget.text));
    SemanticsService.sendAnnouncement(view, widget.copied, direction);
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip,
      style: widget.style,
      icon: Icon(_copied ? Icons.check : Icons.content_copy_outlined),
      onPressed: _copy,
    );
  }
}
