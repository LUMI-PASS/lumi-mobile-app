import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps a widget so it can be shaken to flag it as the thing the user still
/// has to fill in — used instead of printing a validation message somewhere
/// else on the screen, far from the control that caused it.
///
/// Drive it through a [GlobalKey]:
///
/// ```dart
/// final _key = GlobalKey<ShakerState>();
/// Shaker(key: _key, child: MyRow());
/// _key.currentState?.shake();
/// ```
class Shaker extends StatefulWidget {
  const Shaker({super.key, required this.child});

  final Widget child;

  @override
  State<Shaker> createState() => ShakerState();
}

class ShakerState extends State<Shaker>
    with SingleTickerProviderStateMixin {
  /// Peak horizontal travel, in logical pixels. Deliberately small: this is a
  /// nudge, not a wobble.
  static const double _amplitude = 8;

  /// Full left-right swings within one shake.
  static const double _cycles = 3;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Shakes the child once, with a light haptic tap. Restarts if already
  /// running, so repeated taps on a blocked CTA keep flagging the control.
  void shake() {
    HapticFeedback.mediumImpact();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      // The child is built once and reused across every frame of the shake.
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        // A damped sine: full swing at the start, settling back to rest.
        final dx = math.sin(t * math.pi * 2 * _cycles) * _amplitude * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}
