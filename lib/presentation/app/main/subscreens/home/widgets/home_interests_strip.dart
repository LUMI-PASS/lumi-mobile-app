import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// "Pick your interests" — a slim, loud promo strip for an account from
/// before the question was asked at sign-up.
///
/// Shaped like a marketplace offer bar rather than one of the feed's ticket
/// banners: short and wide, a bold heading with one phrase on a highlight
/// block, the artwork spilling off the right edge. It has to read as
/// something to DO, not one more card to scroll past.
///
/// What says it can be tapped is a shine that sweeps across the bar every few
/// seconds — movement in a still feed draws the eye — and the strip sinking a
/// little while pressed.
///
/// Not dismissable on purpose. Home cannot be personal without the answer,
/// so the strip stays until there is one — answering is the way to clear it.
///
/// Fixed brand inks rather than theme roles: like the packet slide in the
/// carousel, it is the same saturated block in both themes.
class HomeInterestsStrip extends StatefulWidget {
  const HomeInterestsStrip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<HomeInterestsStrip> createState() => _HomeInterestsStripState();
}

class _HomeInterestsStripState extends State<HomeInterestsStrip>
    with SingleTickerProviderStateMixin {
  /// One sweep, then a rest: the shine crosses in the first [_sweep] of each
  /// cycle and the bar sits still for the remainder. A shine that never
  /// stopped would stop being noticed.
  static const _cycle = Duration(milliseconds: 3200);
  static const _sweep = 0.35;

  late final _shine = AnimationController(vsync: this, duration: _cycle);
  bool _pressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Someone who has asked the system for less motion gets a still bar.
    if (MediaQuery.disableAnimationsOf(context)) {
      _shine.stop();
    } else if (!_shine.isAnimating) {
      _shine.repeat();
    }
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  void _press(bool down) {
    if (_pressed != down) setState(() => _pressed = down);
  }

  @override
  Widget build(BuildContext context) {
    final height = 104.h;
    final radius = BorderRadius.circular(20.r);
    final heading = AppText.bold18.copyWith(
      color: Colors.white,
      height: 1.15,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _press(true),
        onTapUp: (_) => _press(false),
        onTapCancel: () => _press(false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: SizedBox(
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.promoStrip,
                      borderRadius: radius,
                    ),
                  ),
                ),
                // Over the fill and under the art and the copy, so it reads
                // as light on the bar's surface rather than a wipe over the
                // words.
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: radius,
                    child: AnimatedBuilder(
                      animation: _shine,
                      builder: (_, __) {
                        final t = (_shine.value / _sweep).clamp(0.0, 1.0);
                        // -1 is wholly off the left edge, 1 off the right.
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              // Steep in alignment units because the bar is
                              // over three times wider than tall: this is
                              // what tilts the band to a "/" on screen
                              // rather than leaving it upright.
                              begin: const Alignment(-1, -1.9),
                              end: const Alignment(1, 1.9),
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.35),
                                Colors.white.withValues(alpha: 0),
                              ],
                              stops: const [0.4, 0.5, 0.6],
                              transform: _SlideGradient(-1 + 2 * t),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Larger than the strip and pushed up past its top edge, so
                // the artwork stands out of the bar instead of sitting inside
                // it.
                Positioned(
                  right: -4.w,
                  bottom: -2.h,
                  width: height * 1.25,
                  height: height * 1.25,
                  child: Assets.images.banner.bannerInterests.image(
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
                Positioned.fill(
                  right: height * 1.15,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 0, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'home_interests_strip_lead'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: heading,
                        ),
                        4.verticalSpace,
                        // The phrase that says what is on offer, on a block of
                        // its own colour — the loudest thing on the strip.
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.coinGold,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'home_interests_strip_highlight'.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            // White cannot be read on gold.
                            style: heading.copyWith(color: AppColors.ink),
                          ),
                        ),
                        6.verticalSpace,
                        Text(
                          'home_interests_strip_tail'.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.semibold12.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Moves a gradient sideways by [fraction] of the painted width, so one
/// band of light can be slid across a box without recomputing its stops.
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.fraction);

  final double fraction;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * fraction, 0, 0);
}
