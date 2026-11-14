import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/faq_accordion.dart';

/// "How do coins work?" — opened from the link over Buy on the Lumi Coin
/// shelf. The profile FAQ's screen with the coin questions in it.
///
/// No numbers in the answers: the coin rate, the bonus and the pack sizes are
/// adminka settings and would go stale in a release. No cancellation question
/// either — the app does not tell buyers a coin booking cannot be cancelled.
class NewCoinsFaqPage extends StatelessWidget {
  const NewCoinsFaqPage({super.key});

  static const List<(String, String)> _faqKeys = [
    ('new_coins_faq_q1', 'new_coins_faq_a1'),
    ('new_coins_faq_q2', 'new_coins_faq_a2'),
    ('new_coins_faq_q3', 'new_coins_faq_a3'),
    ('new_coins_faq_q4', 'new_coins_faq_a4'),
    ('new_coins_faq_q5', 'new_coins_faq_a5'),
    ('new_coins_faq_q6', 'new_coins_faq_a6'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: BaseAppBar(title: 'new_coins_faq_title'.tr()),
      body: const FaqList(items: _faqKeys),
    );
  }
}
