import 'dart:math';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../layout/layout.dart';
import '../theme/lumen_colors.dart';

class LumenBackButton extends StatelessWidget {
  const LumenBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final back = AppLocalizations.of(context).back;
    return IconButton(
      tooltip: isDesktopPlatform(context)
          ? '$back (${backKeys(context)})'
          : back,
      style: IconButton.styleFrom(
        backgroundColor: LumenColors.of(context).surface2,
      ),
      icon: const Icon(Icons.chevron_left),
      onPressed: () => context.canPop() ? context.pop() : context.go('/'),
    );
  }
}

/// Phone and tablet header: back button, centered title, optional actions.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.actions = const []});

  final String title;

  /// Icon buttons, 48 wide each.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    // As wide on both sides, so the title stays centered.
    final side = 48.0 * max(1, actions.length);
    return Row(
      children: [
        SizedBox(
          width: side,
          child: const Align(
            alignment: AlignmentDirectional.centerStart,
            child: LumenBackButton(),
          ),
        ),
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
        SizedBox(
          width: side,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          ),
        ),
      ],
    );
  }
}

/// Desktop header next to the sidebar: left-aligned title, optional action.
class PageTitle extends StatelessWidget {
  const PageTitle(
    this.title, {
    super.key,
    this.trailing,
    this.backButton = false,
  });

  final String title;
  final Widget? trailing;

  /// For a page the sidebar does not list, which it cannot lead back from.
  final bool backButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (backButton) ...[const LumenBackButton(), const SizedBox(width: 12)],
        Expanded(
          child: ScreenTitle(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// A shortcut on [key] as the platform writes it, like ⌘R or Ctrl+R.
String shortcutKeys(BuildContext context, String key) =>
    switch (Theme.of(context).platform) {
      TargetPlatform.macOS || TargetPlatform.iOS => '⌘$key',
      _ => 'Ctrl+$key',
    };

/// The keys that go back, as the app binds them. ⌘← rather than ⌘[, which
/// layouts such as AZERTY only type with ⌥⇧.
String backKeys(BuildContext context) => switch (Theme.of(context).platform) {
  TargetPlatform.macOS || TargetPlatform.iOS => '⌘←',
  _ => 'Alt+←',
};

/// Whether the platform is driven by a mouse, which cannot pull to refresh.
bool isDesktopPlatform(BuildContext context) =>
    switch (Theme.of(context).platform) {
      TargetPlatform.macOS ||
      TargetPlatform.windows ||
      TargetPlatform.linux => true,
      _ => false,
    };

/// Desktop stand-in for pull to refresh, which a mouse cannot do. Its icon
/// spins while [loading], unless animations are turned off.
class RefreshButton extends StatefulWidget {
  const RefreshButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  @override
  State<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends State<RefreshButton>
    with SingleTickerProviderStateMixin {
  late final _turns = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );
  var _spinning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _spin();
  }

  @override
  void didUpdateWidget(RefreshButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _spin();
  }

  void _spin() {
    final still = MediaQuery.disableAnimationsOf(context);
    final spinning = widget.loading && !still;
    if (spinning == _spinning) return;
    _spinning = spinning;
    if (spinning) {
      _turns.repeat();
    } else if (still) {
      _turns.reset();
    } else {
      // Ends the turn rather than stopping askew.
      _turns.forward();
    }
  }

  @override
  void dispose() {
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Stays enabled while loading, so it keeps keyboard focus.
    return IconButton(
      tooltip: '${widget.label} (${shortcutKeys(context, 'R')})',
      onPressed: widget.onPressed,
      icon: RotationTransition(turns: _turns, child: const Icon(Icons.refresh)),
    );
  }
}

class SectionHead extends StatelessWidget {
  const SectionHead({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: Theme.of(context).textTheme.titleSmall),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Scrolls when the content is taller than the screen, otherwise fills it so
/// a [Spacer] can push a button to the bottom.
class FillScroll extends StatelessWidget {
  const FillScroll({super.key, required this.padding, required this.child});

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Padding inside the sliver: a SliverPadding around it would add the
        // bottom padding to the filled height and always scroll.
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(padding: padding, child: child),
        ),
      ],
    );
  }
}

/// The screen's heading. It names the route for screen readers and takes
/// keyboard focus when the screen opens.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Semantics(header: true, namesRoute: true, child: child),
    );
  }
}

/// A label above the field, read together with it by screen readers.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// A form-like page: a header, then [content] in one column no wider than
/// a phone, with [bottom] pushed to the bottom on phones.
class NarrowPage extends StatelessWidget {
  const NarrowPage({
    super.key,
    required this.title,
    required this.content,
    this.bottom = const [],
    this.backButton = false,
  });

  final String title;
  final List<Widget> content;
  final List<Widget> bottom;

  /// Shows a back button on desktop too, for a page the sidebar does not
  /// list.
  final bool backButton;

  static const _maxWidth = 560.0;

  @override
  Widget build(BuildContext context) {
    final sidebar = hasSidebar(context);
    final padding = LayoutSize.of(context).screenPadding;
    return Scaffold(
      body: SafeArea(
        // Spare width goes into the padding rather than a max width, which
        // FillScroll would not see when it measures the content's height.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final spare = max(
              0.0,
              constraints.maxWidth - padding.horizontal - _maxWidth,
            );
            final inset = sidebar
                ? EdgeInsetsDirectional.only(end: spare)
                : EdgeInsetsDirectional.symmetric(horizontal: spare / 2);
            return FillScroll(
              padding: padding + inset.resolve(Directionality.of(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sidebar)
                    PageTitle(title, backButton: backButton)
                  else
                    TopBar(title: title),
                  const SizedBox(height: 20),
                  ...content,
                  if (bottom.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    if (LayoutSize.of(context) == LayoutSize.phone)
                      const Spacer(),
                    ...bottom,
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One point of a short list, after a check mark.
class CheckLine extends StatelessWidget {
  const CheckLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = LumenColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: ExcludeSemantics(
              child: Icon(Icons.check, size: 18, color: c.positive),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, height: 1.4, color: c.text),
            ),
          ),
        ],
      ),
    );
  }
}
