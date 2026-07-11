import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Telegram-style circular-reveal theme transition (ported from wisdom_mobile).
///
/// Wraps the app content — see `MaterialApp.router`'s `builder` in `main.dart`.
/// The dark-mode toggle calls
/// `ThemeTransitionOverlay.of(context).toggleTheme(...)` instead of flipping
/// [themeModeNotifier] directly, and the theme change happens *inside*
/// [toggleTheme] via `onToggle`.
///
/// How it works: snapshot the current screen into a `ui.Image`, switch the
/// theme underneath it, then animate a circular clip on the stale snapshot so
/// the newly-themed tree bleeds through from the toggle outwards.
class ThemeTransitionOverlay extends StatefulWidget {
  final Widget child;

  const ThemeTransitionOverlay({super.key, required this.child});

  static ThemeTransitionOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeTransitionOverlayState>()!;
  }

  /// Null when no overlay is above [context] — lets a toggle degrade to an
  /// unanimated switch instead of throwing.
  static ThemeTransitionOverlayState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<ThemeTransitionOverlayState>();
  }

  @override
  State<ThemeTransitionOverlay> createState() => ThemeTransitionOverlayState();
}

class ThemeTransitionOverlayState extends State<ThemeTransitionOverlay>
    with SingleTickerProviderStateMixin {
  final _repaintKey = GlobalKey();
  late final AnimationController _controller;
  late final CurvedAnimation _curved;
  ui.Image? _snapshot;
  Offset? _origin;
  bool _isDarkening = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _snapshot?.dispose();
            _snapshot = null;
            _origin = null;
          });
          _controller.reset();
        }
      });
    _curved = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _curved.dispose();
    _snapshot?.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Captures the current screen, calls [onToggle] (which should change the
  /// theme), then plays a circular reveal from [position].
  /// [isDarkening] controls the animation direction:
  /// - `true`  → circle expands OUT from the toggle, punching a growing hole
  ///   in the stale snapshot
  /// - `false` → the stale snapshot collapses IN to the toggle, the new theme
  ///   arriving from the edges
  Future<void> toggleTheme({
    required Offset position,
    required bool isDarkening,
    required VoidCallback onToggle,
  }) async {
    if (_controller.isAnimating) return;

    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) {
      onToggle();
      return;
    }

    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    if (!mounted) {
      image.dispose();
      return;
    }

    setState(() {
      _snapshot = image;
      _origin = position;
      _isDarkening = isDarkening;
    });

    // Toggle the theme so the tree underneath repaints with the new colors.
    onToggle();

    // Let one frame pass so the new theme is painted, then reveal it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          key: _repaintKey,
          child: widget.child,
        ),
        if (_snapshot != null && _origin != null)
          Positioned.fill(
            child: _RevealAnimation(
              animation: _curved,
              snapshot: _snapshot!,
              origin: _origin!,
              isDarkening: _isDarkening,
              pixelRatio: MediaQuery.of(context).devicePixelRatio,
            ),
          ),
      ],
    );
  }
}

class _RevealAnimation extends AnimatedWidget {
  final ui.Image snapshot;
  final Offset origin;
  final bool isDarkening;
  final double pixelRatio;

  const _RevealAnimation({
    required Animation<double> animation,
    required this.snapshot,
    required this.origin,
    required this.isDarkening,
    required this.pixelRatio,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final progress = (listenable as Animation<double>).value;

    return IgnorePointer(
      child: ClipPath(
        clipper: isDarkening
            ? _ExpandingHoleClipper(fraction: progress, center: origin)
            : _ShrinkingCircleClipper(fraction: progress, center: origin),
        child: CustomPaint(
          painter: _SnapshotPainter(snapshot, pixelRatio),
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// The stale snapshot keeps a growing circular hole; the new theme underneath
/// is revealed through it.
class _ExpandingHoleClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;

  _ExpandingHoleClipper({required this.fraction, required this.center});

  @override
  Path getClip(Size size) {
    final currentRadius = _maxDistance(size, center) * fraction;

    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: currentRadius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_ExpandingHoleClipper old) =>
      old.fraction != fraction || old.center != center;
}

/// The stale snapshot is clipped to a circle shrinking from full-screen down to
/// the toggle; the new theme arrives from the edges.
class _ShrinkingCircleClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;

  _ShrinkingCircleClipper({required this.fraction, required this.center});

  @override
  Path getClip(Size size) {
    final currentRadius = _maxDistance(size, center) * (1.0 - fraction);

    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: currentRadius));
  }

  @override
  bool shouldReclip(_ShrinkingCircleClipper old) =>
      old.fraction != fraction || old.center != center;
}

/// Radius that still covers the furthest corner from [center].
double _maxDistance(Size size, Offset center) {
  return [
    Offset.zero,
    Offset(size.width, 0),
    Offset(0, size.height),
    Offset(size.width, size.height),
  ].map((c) => (c - center).distance).reduce(max);
}

class _SnapshotPainter extends CustomPainter {
  final ui.Image image;
  final double pixelRatio;

  _SnapshotPainter(this.image, this.pixelRatio);

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(_SnapshotPainter old) => old.image != image;
}
