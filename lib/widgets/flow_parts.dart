import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';
import 'screen_parts.dart';

/// What a transaction flow needs from the screen or dialog that holds it.
class FlowFrame {
  const FlowFrame({
    required this.headerWith,
    required this.onDone,
    required this.expand,
  });

  /// The flow's header, with [action] as its icon button when given.
  final Widget Function({Widget? action}) headerWith;
  Widget get header => headerWith();
  final VoidCallback onDone;

  /// Fills the screen height to keep the main button at the bottom.
  final bool expand;

  Widget get bottomGap => expand ? const Spacer() : const SizedBox(height: 28);
}

typedef FlowBuilder = Widget Function(FlowFrame frame);

/// Full screen on phones at [location], a dialog over the current page on
/// larger screens.
Future<void> openFlow(
  BuildContext context, {
  required String location,
  required String title,
  required FlowBuilder builder,
  Object? extra,
}) async {
  if (LayoutSize.of(context) == LayoutSize.phone) {
    await context.push(location, extra: extra);
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (_) => FlowDialog(title: title, builder: builder),
  );
}

/// Pushes one step of a multi-step flow outside the router, so what it
/// shows, such as a recovery phrase, never reaches the URL or the browser
/// history.
Future<T?> pushStep<T>(BuildContext context, WidgetBuilder builder) {
  final instant =
      MediaQuery.disableAnimationsOf(context) ||
      LayoutSize.of(context) == LayoutSize.desktop;
  return Navigator.of(context).push(
    instant
        ? PageRouteBuilder<T>(
            pageBuilder: (context, _, _) => builder(context),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          )
        : MaterialPageRoute<T>(builder: builder),
  );
}

class FlowScreen extends StatelessWidget {
  const FlowScreen({super.key, required this.title, required this.builder});

  final String title;
  final FlowBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FillScroll(
          padding: LayoutSize.of(context).screenPadding,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: builder(
                FlowFrame(
                  expand: true,
                  headerWith: ({action}) => hasSidebar(context)
                      ? PageTitle(title, trailing: action)
                      : TopBar(title: title, trailing: action),
                  onDone: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlowDialog extends StatelessWidget {
  const FlowDialog({super.key, required this.title, required this.builder});

  final String title;
  final FlowBuilder builder;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: builder(
            FlowFrame(
              expand: false,
              headerWith: ({action}) => Row(
                children: [
                  SizedBox(width: 48, child: action),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ScreenTitle(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: l.close,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ],
              ),
              onDone: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorNote extends StatelessWidget {
  const ErrorNote(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.error_outline, size: 18, color: c.danger),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(fontSize: 15, height: 1.4, color: c.danger),
          ),
        ),
      ],
    );
  }
}

/// The check mark above a payment result.
class SuccessMark extends StatelessWidget {
  const SuccessMark({super.key});

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return Center(
      child: ExcludeSemantics(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: c.positive.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: 36, color: c.positive),
        ),
      ),
    );
  }
}

/// The start and end of a long invoice, enough to compare it by eye.
String shortInvoice(String request) {
  if (request.length <= 32) return request;
  return '${request.substring(0, 24)}...${request.substring(request.length - 4)}';
}

/// A secondary full-width button, such as Done after a payment.
ButtonStyle quietButtonStyle(BuildContext context) {
  final c = LumenColors.of(context);
  return FilledButton.styleFrom(
    backgroundColor: c.surface2,
    foregroundColor: c.text,
  );
}
