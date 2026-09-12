import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';

/// Soft mesh-gradient page wash: a near-white (near-black) base with four
/// purple-leaning glows bleeding in from the corners.
///
/// Four stacked radial gradients rather than one shader, so the blend stays
/// cheap enough to sit behind a scrolling page on every rebuild.
///
/// Used by the whole shop flow. Wrap it around a [Scaffold] whose
/// `backgroundColor` is transparent — the wash is the page background, so a
/// scaffold that paints its own would cover it.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Stack(
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: ColoredBox(
                color: c.auroraBase,
                child: Stack(
                  children: [
                    _Glow(c.auroraOrchid, const Alignment(-1, -0.85), 1.1),
                    _Glow(c.auroraBlush, const Alignment(1, -0.7), 0.95),
                    _Glow(c.auroraLilac, const Alignment(-0.9, 0.75), 0.9),
                    _Glow(c.auroraMauve, const Alignment(1, 0.95), 1.05),
                  ],
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow(this.color, this.center, this.radius);

  final Color color;
  final Alignment center;
  final double radius;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: center,
              radius: radius,
              colors: [color, color.withValues(alpha: 0)],
              stops: const [0, 1],
            ),
          ),
        ),
      );
}
