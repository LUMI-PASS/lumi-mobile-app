import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// A full-width switch of equal halves with a brand pill that slides under
/// the picked one. Driven by a continuous [position] rather than an index, so
/// paired with a [PageView] the pill follows the swipe as it happens: feed it
/// `PageController.page` and animate the controller from [onSelect].
///
/// First used for Bookings' Active / Past.
class SegmentedTabSwitch extends StatelessWidget {
  const SegmentedTabSwitch({
    super.key,
    required this.labels,
    required this.position,
    required this.onSelect,
  });

  final List<String> labels;

  /// The page offset, 0…labels.length-1, fractional mid-swipe.
  final double position;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inset = 4.w;
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: colors.segmentTrack,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth / labels.length;
          return Stack(
            children: [
              Positioned(
                left: width * position.clamp(0, labels.length - 1),
                top: 0,
                bottom: 0,
                width: width,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.indigo,
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelect(i),
                        child: Center(
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.semibold14.copyWith(
                              // Cross-fades with the pill as it passes.
                              color: Color.lerp(
                                AppColors.onBrand,
                                colors.textSecondary,
                                (position - i).abs().clamp(0, 1).toDouble(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
