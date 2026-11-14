import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/faq_accordion.dart';

@RoutePage()
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  static const List<(String, String)> _faqKeys = [
    ('faq_q1', 'faq_a1'),
    ('faq_q2', 'faq_a2'),
    ('faq_q3', 'faq_a3'),
    ('faq_q4', 'faq_a4'),
    ('faq_q5', 'faq_a5'),
    ('faq_q6', 'faq_a6'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: BaseAppBar(title: 'faqs_title'.tr()),
      body: const FaqList(items: _faqKeys),
    );
  }
}
