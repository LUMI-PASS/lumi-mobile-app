import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';
import 'package:lumi_pass/data/api_model/interest_topic/interest_topic.dart';

/// The words that answer one question — "what is your child into?", "what are
/// you looking for?" — as pills to pick any number of.
///
/// Only the pills: the question above them and the card around them belong to
/// the screen, which is what lets the child form, the parent's profile and the
/// sign-up sheet ask in their own layout and still offer the same control.
class TopicChips extends StatelessWidget {
  const TopicChips({
    super.key,
    required this.topics,
    required this.selected,
    required this.onToggle,
    this.fill,
    this.ink,
  });

  final List<InterestTopic> topics;

  /// Ids of the picked topics.
  final List<String> selected;
  final ValueChanged<String> onToggle;

  /// Colour of a pill that is not picked — one step off whatever it sits on.
  /// The theme's control colour unless the screen paints its own surface.
  final Color? fill;

  /// Label colour of a pill that is not picked.
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        for (final topic in topics)
          _TopicChip(
            label: topic.name,
            emoji: topic.emoji,
            fill: fill ?? colors.control,
            ink: ink ?? colors.textPrimary,
            selected: selected.contains(topic.id),
            onTap: () => onToggle(topic.id),
          ),
      ],
    );
  }
}

/// Pill toggle — the indigo of the plans screen when picked, [fill] when not.
class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.fill,
    required this.ink,
    this.emoji,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color fill;
  final Color ink;

  /// Shown in front of [label] when there is one.
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    return Bouncing(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? null : fill,
          gradient: selected ? AppGradients.indigo : null,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: AppText.regular14),
              6.kw,
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.medium14.copyWith(
                  color: selected ? AppColors.onBrand : ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
