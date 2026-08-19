import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// Pill segmented switch on the design system — a `control`-toned track with a
/// brand-gradient thumb that slides to the selected segment.
///
/// Prefer this over the legacy `CustomSegmentedControl`, which hardcodes light
/// colours and sizes its thumb off `MediaQuery` width. The thumb here is a
/// fraction of the track, so it works at any width and in both themes.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<String> segments;
  final int selected;
  final ValueChanged<int> onChanged;

  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = segments.length;
    // A single segment has nowhere to slide; `Alignment.x` would divide by 0.
    final x = count < 2 ? 0.0 : -1 + 2 * selected / (count - 1);

    return Container(
      height: 48.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colors.control,
        borderRadius: BorderRadius.circular(44.r),
        border: Border.all(color: colors.controlBorder),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOutCubic,
            alignment: Alignment(x, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / count,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(40.r),
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(count, (i) {
              final isSelected = i == selected;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: _duration,
                      style: isSelected
                          ? AppText.semibold14
                              .copyWith(color: AppColors.onBrand)
                          : AppText.medium14
                              .copyWith(color: colors.textSecondary),
                      child: Text(
                        segments[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
