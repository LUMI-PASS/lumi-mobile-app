import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/promo/promo_repository.dart';
import 'package:lumi_pass/presentation/app/promo/widgets/aksiya_widgets.dart';

/// One bought "аксия" pass: what is left on it, when it runs out, and where the
/// spent visits went.
///
/// The deadline is the whole point of this screen. A bundle with visits left and
/// two days to use them is the case the product exists to serve, so the
/// countdown is stated in days AND as a date — "3 days" tells you to hurry, the
/// date tells you whether Saturday still counts.
class AksiyaPassPage extends StatefulWidget {
  const AksiyaPassPage({super.key, required this.passId});

  final String passId;

  @override
  State<AksiyaPassPage> createState() => _AksiyaPassPageState();
}

class _AksiyaPassPageState extends State<AksiyaPassPage> {
  final PromoRepository _repo = getIt<PromoRepository>();

  PromoPass? _pass;
  bool _isLoading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _failed = false;
    });
    try {
      final pass = await _repo.getPass(widget.passId);
      if (!mounted) return;
      setState(() => _pass = pass);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pass = _pass;

    return Scaffold(
      backgroundColor: c.pageBg,
      appBar: BaseAppBar(title: 'aksiya_pass_title'.tr()),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            )
          : pass == null || _failed
              ? Center(
                  child: Text(
                    'aksiya_pass_load_failed'.tr(),
                    style: AppText.regular14.copyWith(color: c.textSecondary),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.brandPurple,
                  onRefresh: _load,
                  child: _content(pass),
                ),
      bottomNavigationBar: pass == null || !pass.isUsable
          ? null
          : AksiyaBottomBar(
              label: 'aksiya_spend_cta'.tr(),
              onTap: () => context.router.push(SearchDiscoveryRoute()),
            ),
    );
  }

  Widget _content(PromoPass pass) {
    final c = context.colors;
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      children: [
        AksiyaPassCard.fromPass(pass),
        12.kh,
        _CodeRow(code: pass.code),
        // The rule that makes the bundle what it is, restated where the buyer is
        // choosing where to spend the rest of it — this is the screen on which
        // "but I already went there" gets answered.
        if (pass.distinctActivities && pass.activitiesLeft > 0) ...[
          12.kh,
          _RuleNote(
            text: 'aksiya_rule_distinct'.tr(
              namedArgs: {'count': '${pass.activitiesTotal}'},
            ),
          ),
        ],
        if (pass.redemptions.isNotEmpty) ...[
          20.kh,
          Text(
            'aksiya_pass_used_section'.tr(),
            style: AppText.semibold18.copyWith(color: c.textSection),
          ),
          12.kh,
          for (final r in pass.redemptions) AksiyaRedemptionRow(redemption: r),
        ],
        if (pass.activitiesLeft > 0) ...[
          8.kh,
          Text(
            'aksiya_pass_remaining_hint'.tr(
              namedArgs: {'count': '${pass.activitiesLeft}'},
            ),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
        ] else ...[
          8.kh,
          Text(
            'aksiya_pass_all_used'.tr(),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// The pass code. Shown because support asks for it, and because a code the
/// buyer can read out is what makes a door dispute resolvable.
class _CodeRow extends StatelessWidget {
  const _CodeRow({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Text(
            'aksiya_pass_code_label'.tr(),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
          const Spacer(),
          Text(
            code,
            style: AppText.semibold14.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _RuleNote extends StatelessWidget {
  const _RuleNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: AppText.regular13.copyWith(color: c.textSecondary),
      ),
    );
  }
}
