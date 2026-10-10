import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';

/// The "save" heart, with the pop it makes when it changes.
///
/// It animates on [saved] CHANGING, not on a tap, so it needs no controller
/// from its owner and cannot fall out of step with the store: whatever flips
/// the value — the tap here, a save made on another screen, the store putting
/// the heart back after a refused request — is what plays the animation.
///
/// Saving is the event worth celebrating: the heart swells past its size and
/// settles, with a light tap in the hand. Un-saving only dips, quietly, so
/// undoing a mis-tap does not get the same fanfare as the tap it undoes.
class SaveHeartIcon extends StatefulWidget {
  const SaveHeartIcon({
    super.key,
    required this.saved,
    required this.offColor,
    this.size = 16,
  });

  final bool saved;

  /// The tint while not saved. Saved is always [AppColors.error].
  final Color offColor;

  final double size;

  @override
  State<SaveHeartIcon> createState() => _SaveHeartIconState();
}

class _SaveHeartIconState extends State<SaveHeartIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  /// Overshoot, a small undershoot, rest — the bounce of something landing.
  static final Animatable<double> _pop = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 1.45)
          .chain(CurveTween(curve: Curves.easeOutCubic)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 1.45, end: 0.9)
          .chain(CurveTween(curve: Curves.easeInOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.9, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
  ]);

  /// A single shallow dip and back.
  static final Animatable<double> _dip = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: 0.8)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween(begin: 0.8, end: 1.0)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 55,
    ),
  ]);

  @override
  void didUpdateWidget(SaveHeartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.saved == widget.saved) return;
    if (widget.saved) HapticFeedback.lightImpact();
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: (widget.saved ? _pop : _dip).animate(_controller),
      child: TweenAnimationBuilder<Color?>(
        // The tint crosses over with the pop instead of snapping under it.
        tween: ColorTween(
          end: widget.saved ? AppColors.error : widget.offColor,
        ),
        duration: const Duration(milliseconds: 180),
        builder: (_, color, __) => HomeIcon(
          Assets.icons.home.heart,
          size: widget.size,
          color: color,
        ),
      ),
    );
  }
}
