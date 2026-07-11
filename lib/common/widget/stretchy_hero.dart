import 'package:flutter/widgets.dart';

/// A hero box that grows *upwards* while the scroll view is overscrolled at the
/// top, so pulling the page down stretches the image instead of dragging it off
/// the screen and exposing the scaffold behind it.
///
/// Put it where the hero's [SizedBox] would go, inside a scroll view driven by
/// [controller]:
///
/// ```dart
/// SliverToBoxAdapter(
///   child: StretchyHero(
///     controller: _scrollController,
///     height: 300.h,
///     child: Stack(fit: StackFit.expand, children: [...]),
///   ),
/// )
/// ```
///
/// The child is laid out taller than the slot and bottom-aligned, so the extra
/// height spills into the overscroll gap. Nothing between here and the viewport
/// clips, and the gap is inside the viewport's bounds, so the overflow paints.
class StretchyHero extends StatelessWidget {
  const StretchyHero({
    super.key,
    required this.controller,
    required this.height,
    required this.child,
  });

  final ScrollController controller;

  /// Resting height — what the hero occupies when not overscrolled.
  final double height;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: AnimatedBuilder(
        animation: controller,
        // Built once; only the overflow box's constraints change per frame.
        child: child,
        builder: (context, child) {
          // `offset` throws before the controller is attached (first frame).
          final offset =
              controller.hasClients ? controller.position.pixels : 0.0;
          final stretched = height + (offset < 0 ? -offset : 0.0);
          return OverflowBox(
            alignment: Alignment.bottomCenter,
            minHeight: stretched,
            maxHeight: stretched,
            child: child,
          );
        },
      ),
    );
  }
}
