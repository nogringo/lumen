import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/lumen_colors.dart';

class LumenBackButton extends StatelessWidget {
  const LumenBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context).back,
      style: IconButton.styleFrom(
        backgroundColor: LumenColors.of(context).surface2,
      ),
      icon: const Icon(LucideIcons.chevronLeft),
      onPressed: () => context.canPop() ? context.pop() : context.go('/'),
    );
  }
}

/// Phone and tablet header: back button, centered title, optional action.
class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const LumenBackButton(),
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
        SizedBox(width: 48, child: trailing),
      ],
    );
  }
}

/// Desktop header next to the sidebar: left-aligned title, optional action.
class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
