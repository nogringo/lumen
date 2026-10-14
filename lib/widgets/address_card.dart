import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';
import 'copy_button.dart';
import 'flow_parts.dart';
import 'qr_code_view.dart';
import 'share_text.dart';

/// The wallet's Lightning address, which receives any amount without an
/// invoice.
class AddressCard extends StatelessWidget {
  const AddressCard(this.address, {super.key});

  final String address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final raised = IconButton.styleFrom(backgroundColor: c.surface3);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 6, 10),
      decoration: BoxDecoration(
        color: c.surface2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.lightningAddress,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address,
                    style: TextStyle(fontSize: 15, height: 1.3, color: c.text),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l.showAddressQr,
            style: raised,
            icon: const Icon(Icons.qr_code_2),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => FlowDialog(
                title: l.lightningAddress,
                builder: (frame) => _AddressQr(frame: frame, address: address),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CopyButton(
            text: address,
            tooltip: l.copyAddress,
            copied: l.addressCopied,
            style: raised,
          ),
        ],
      ),
    );
  }
}

class _AddressQr extends StatelessWidget {
  const _AddressQr({required this.frame, required this.address});

  final FlowFrame frame;
  final String address;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        frame.header,
        const SizedBox(height: 20),
        Center(
          child: QrCodeView(
            data: 'lightning:$address',
            semanticLabel: l.addressQrLabel(address),
          ),
        ),
        const SizedBox(height: 16),
        ExcludeSemantics(
          child: Text(
            address,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: LumenColors.of(context).text,
            ),
          ),
        ),
        frame.bottomGap,
        Builder(
          builder: (buttonContext) => FilledButton.icon(
            onPressed: () => shareText(buttonContext, address),
            style: quietButtonStyle(context),
            icon: const Icon(Icons.share_outlined),
            label: Text(l.shareAddress),
          ),
        ),
      ],
    );
  }
}
