import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/control_chip.dart';

/// An FAQ screen's body: the mascot, then one accordion per question, only
/// one answer open at a time. Shared by the profile FAQ and the Lumi Coin
/// FAQ so the two screens are one design.
class FaqList extends StatefulWidget {
  const FaqList({super.key, required this.items});

  /// (question key, answer key) pairs, translated here.
  final List<(String, String)> items;

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  /// Only one answer is open at a time, as in the design. The first one
  /// starts open (index 0 is the mascot), so the screen opens on an answer
  /// rather than a wall of closed questions.
  int? _expandedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      // +1 for the mascot header, which scrolls with the list so a long
      // expanded answer still gets the full screen height.
      itemCount: widget.items.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Center(
            child: Assets.images.mascot.mascotFaq.image(
              width: 160.w,
              height: 160.w,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
          );
        }
        final (question, answer) = widget.items[index - 1];
        return FaqAccordion(
          question: question.tr(),
          answer: answer.tr(),
          isExpanded: _expandedIndex == index,
          onTap: () => setState(
            () => _expandedIndex = _expandedIndex == index ? null : index,
          ),
        );
      },
    );
  }
}

/// One question of an FAQ: the question with a chevron chip, and the answer
/// under it while open. The caller owns which one is open — the FAQ screens
/// keep one answer open at a time.
class FaqAccordion extends StatelessWidget {
  const FaqAccordion({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: AppText.semibold16
                          .copyWith(color: context.colors.textPrimary),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ControlChip(
                    padding: EdgeInsets.all(8.w),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Assets.icons.arrowDown.svg(
                        width: 20.w,
                        height: 20.w,
                        colorFilter: ColorFilter.mode(
                          context.colors.textPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (isExpanded) ...[
                SizedBox(height: 6.h),
                Text(
                  answer,
                  style: AppText.regular14
                      .copyWith(color: context.colors.textPrimary),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
