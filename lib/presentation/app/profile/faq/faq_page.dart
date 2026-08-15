import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/widget/control_chip.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';

@RoutePage()
class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  static const List<_FaqItemKeys> _faqKeys = [
    _FaqItemKeys(questionKey: 'faq_q1', answerKey: 'faq_a1'),
    _FaqItemKeys(questionKey: 'faq_q2', answerKey: 'faq_a2'),
    _FaqItemKeys(questionKey: 'faq_q3', answerKey: 'faq_a3'),
    _FaqItemKeys(questionKey: 'faq_q4', answerKey: 'faq_a4'),
    _FaqItemKeys(questionKey: 'faq_q5', answerKey: 'faq_a5'),
    _FaqItemKeys(questionKey: 'faq_q6', answerKey: 'faq_a6'),
    _FaqItemKeys(questionKey: 'faq_q7', answerKey: 'faq_a7'),
  ];

  /// Only one answer is open at a time, as in the design.
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: BaseAppBar(title: 'faqs_title'.tr()),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
        // +1 for the mascot header, which scrolls with the list so a long
        // expanded answer still gets the full screen height.
        itemCount: _faqKeys.length + 1,
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
          final keys = _faqKeys[index - 1];
          return _FaqAccordion(
            question: keys.questionKey.tr(),
            answer: keys.answerKey.tr(),
            isExpanded: _expandedIndex == index,
            onTap: () => setState(
              () => _expandedIndex = _expandedIndex == index ? null : index,
            ),
          );
        },
      ),
    );
  }
}

class _FaqItemKeys {
  const _FaqItemKeys({required this.questionKey, required this.answerKey});

  final String questionKey;
  final String answerKey;
}

class _FaqAccordion extends StatelessWidget {
  const _FaqAccordion({
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
