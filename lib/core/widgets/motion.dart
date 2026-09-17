import 'package:flutter/material.dart';

/// Short, finite motion. Financial values are never interpolated or counted up.
abstract final class CherryMotion {
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context);
  static Duration duration(BuildContext context) =>
      reduced(context) ? Duration.zero : const Duration(milliseconds: 240);
}

/// Reveals a page once, without replaying when its data changes.
class PageEntrance extends StatefulWidget {
  final Widget child;
  const PageEntrance({super.key, required this.child});
  @override
  State<PageEntrance> createState() => _PageEntranceState();
}

class _PageEntranceState extends State<PageEntrance>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final curve = CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
  );
  bool started = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (CherryMotion.reduced(context)) {
      controller.value = 1;
      started = true;
    } else if (!started) {
      started = true;
      controller.forward();
    }
  }

  @override
  void dispose() {
    curve.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: curve,
    alwaysIncludeSemantics: true,
    child: AnimatedBuilder(
      animation: curve,
      child: widget.child,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, 8 * (1 - curve.value)),
        child: child,
      ),
    ),
  );
}

class CherryPageTransitions extends PageTransitionsBuilder {
  const CherryPageTransitions();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (CherryMotion.reduced(context)) {
      return child;
    }
    // Preserve interactive swipe-back on Apple platforms.
    if (Theme.of(context).platform == TargetPlatform.iOS ||
        Theme.of(context).platform == TargetPlatform.macOS) {
      return const CupertinoPageTransitionsBuilder().buildTransitions(
        route,
        context,
        animation,
        secondaryAnimation,
        child,
      );
    }
    return FadeTransition(opacity: animation, child: child);
  }
}

/// A change animates only its incoming state, so stale statuses are not announced.
class StateReveal extends StatelessWidget {
  final Widget child;
  const StateReveal({super.key, required this.child});
  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: CherryMotion.duration(context),
    switchInCurve: Curves.easeOutCubic,
    layoutBuilder: (current, previous) => current ?? const SizedBox.shrink(),
    transitionBuilder: (child, animation) =>
        FadeTransition(opacity: animation, child: child),
    child: child,
  );
}

class ActionLabel extends StatelessWidget {
  final bool busy;
  final String label;
  final String busyLabel;
  const ActionLabel({
    super.key,
    required this.busy,
    required this.label,
    required this.busyLabel,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: busy,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (busy) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CherryMotion.reduced(context)
                ? const Icon(Icons.hourglass_top_rounded, size: 16)
                : const CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
        ],
        Flexible(child: Text(busy ? busyLabel : label)),
      ],
    ),
  );
}
