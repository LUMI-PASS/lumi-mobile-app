import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';

@RoutePage()
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const List<_FaqItemKeys> _faqKeys = [
    _FaqItemKeys(questionKey: 'faq_q1', answerKey: 'faq_a1'),
    _FaqItemKeys(questionKey: 'faq_q2', answerKey: 'faq_a2'),
    _FaqItemKeys(questionKey: 'faq_q3', answerKey: 'faq_a3'),
    _FaqItemKeys(questionKey: 'faq_q4', answerKey: 'faq_a4'),
    _FaqItemKeys(questionKey: 'faq_q5', answerKey: 'faq_a5'),
    _FaqItemKeys(questionKey: 'faq_q6', answerKey: 'faq_a6'),
    _FaqItemKeys(questionKey: 'faq_q7', answerKey: 'faq_a7'),
  ];

  @override
  Widget build(BuildContext context) {
    final faqItems = _faqKeys
        .map((k) => _FaqItem(
              question: k.questionKey.tr(),
              answer: k.answerKey.tr(),
            ))
        .toList();

    return Scaffold(
      appBar: BaseAppBar(title: 'faqs_title'.tr()),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: faqItems.length,
        separatorBuilder: (_, __) => 10.kh,
        itemBuilder: (context, index) {
          return _FaqAccordion(item: faqItems[index], index: index);
        },
      ),
    );
  }
}

class _FaqItemKeys {
  final String questionKey;
  final String answerKey;

  const _FaqItemKeys({required this.questionKey, required this.answerKey});
}

class _FaqItem {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});
}

class _FaqAccordion extends StatefulWidget {
  const _FaqAccordion({required this.item, required this.index});

  final _FaqItem item;
  final int index;

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: _isExpanded
            ? context.colors.primary.withOpacity(0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _isExpanded
              ? context.colors.primary.withOpacity(0.2)
              : Colors.grey.shade200,
        ),
        boxShadow: [
          if (!_isExpanded)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        children: [
          // Question header
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: _isExpanded
                          ? context.colors.primary
                          : context.colors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: "${widget.index + 1}".s(12).w(700).c(
                            _isExpanded
                                ? Colors.white
                                : context.colors.primary,
                          ),
                    ),
                  ),
                  12.kw,
                  Expanded(
                    child: widget.item.question.s(14).w(600).c(
                          _isExpanded
                              ? context.colors.primary
                              : (context.colors.black ?? Colors.black),
                        ),
                  ),
                  8.kw,
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22.w,
                      color: _isExpanded
                          ? context.colors.primary
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Answer body
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.only(
                  left: 56.w, right: 16.w, bottom: 16.h),
              child: Text(
                  widget.item.answer,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}
