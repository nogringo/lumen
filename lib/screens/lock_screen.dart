import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../lock/gate_scope.dart';
import '../theme/lumen_colors.dart';
import '../widgets/brand.dart';
import '../widgets/passphrase_field.dart';
import '../widgets/screen_parts.dart';

/// Shows nothing of the wallets: they are not even loaded until the
/// passphrase opens them.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passphrase = TextEditingController();
  final _focus = FocusNode();
  String? _error;
  var _checking = false;

  @override
  void dispose() {
    _passphrase.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final l = AppLocalizations.of(context);
    if (_passphrase.text.isEmpty) {
      setState(() => _error = l.errorPassphraseEmpty);
      reportFieldError(context, l.errorPassphraseEmpty, _focus);
      return;
    }
    if (_checking) return;
    setState(() => _checking = true);
    final gate = GateScope.of(context);
    final check = await gate.unlock(_passphrase.text);
    if (!mounted) return;
    final message = refusalMessage(l, check, gate.lock.retryAt);
    setState(() {
      _checking = false;
      _error = message;
    });
    if (message == null) return;
    _passphrase.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _passphrase.text.length,
    );
    reportFieldError(context, message, _focus);
  }

  Future<void> _forgot() async {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.resetTitle),
        content: Text(l.resetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: c.danger),
            child: Text(l.reset),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await GateScope.of(context).reset();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = LumenColors.of(context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: FillScroll(
          padding: LayoutSize.of(context).screenPadding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const Center(child: LogoMark()),
                  const SizedBox(height: 24),
                  ScreenTitle(
                    child: Text(
                      l.lockedTitle,
                      textAlign: TextAlign.center,
                      style: text.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.lockedLead,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: c.text2,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PassphraseField(
                    label: l.passphraseLabel,
                    controller: _passphrase,
                    focusNode: _focus,
                    errorText: _error,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _unlock(),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _unlock,
                    icon: _checking
                        ? SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: c.onAccent,
                            ),
                          )
                        : const Icon(Icons.lock_outline),
                    label: Text(l.unlock),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: _forgot,
                      child: Text(l.forgotPassphrase),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
