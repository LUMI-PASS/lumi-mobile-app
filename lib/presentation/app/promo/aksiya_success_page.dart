import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';

/// "You bought it — now here is the clock."
///
/// A success screen for a bundle with a deadline has one job beyond saying well
/// done: making sure the buyer leaves it knowing they have to book. That is why
/// the days are the largest thing on the page after the tick, and why the
/// primary action goes to the catalogue rather than back to where they came
/// from — the sale is only half the promise.
class AksiyaSuccessPage extends StatefulWidget {
  const AksiyaSuccessPage({super.key, required this.campaign});

  final PromoCampaign campaign;

  @override
  State<AksiyaSuccessPage> createState() => _AksiyaSuccessPageState();
}

class _AksiyaSuccessPageState extends State<AksiyaSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Straight to the catalogue. The buyer has five days and nothing booked, so
  /// the screen that helps is the one with activities on it.
  void _bookNow() {
    final router = context.router;
    router.popUntil((route) => route.settings.name == MainRoute.name);
    router.push(SearchDiscoveryRoute());
  }

  void _later() {
    context.router.popUntil((route) => route.settings.name == MainRoute.name);
  }

  @override
  Widget build(BuildContext context) {
    final campaign = widget.campaign;
    final fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.brandPurple, Color(0xFFFF7093)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -80,
              child: Opacity(
                opacity: 0.15,
                child: Assets.icons.background.congratsMisc.svg(
                  width: 300.w,
                  height: 300.w,
                  colorFilter:
                      const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 24.h),
                child: Column(
                  children: [
                    const Spacer(),
                    ScaleTransition(
                      scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _ctrl,
                          curve: const Interval(
                            0,
                            0.7,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      ),
                      child: Assets.images.paymentSuccess.image(width: 180.w),
                    ),
                    24.kh,
                    FadeTransition(
                      opacity: fade,
                      child: Column(
                        children: [
                          Text(
                            'aksiya_success_title'.tr(),
                            textAlign: TextAlign.center,
                            style: AppText.heading20.copyWith(
                              color: AppColors.onBrand,
                            ),
                          ),
                          12.kh,
                          Text(
                            'aksiya_success_body'.tr(namedArgs: {
                              'count': '${campaign.activitiesCount}',
                              'days': '${campaign.validDays}',
                            }),
                            textAlign: TextAlign.center,
                            style: AppText.regular14.copyWith(
                              color: AppColors.onBrand.withValues(alpha: 0.92),
                              height: 1.5,
                            ),
                          ),
                          24.kh,
                          _DeadlineBanner(days: campaign.validDays),
                        ],
                      ),
                    ),
                    const Spacer(),
                    FadeTransition(
                      opacity: fade,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _bookNow,
                            child: Container(
                              height: 52.h,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.onBrand,
                                borderRadius: BorderRadius.circular(44.r),
                              ),
                              child: Text(
                                'aksiya_success_book_cta'.tr(),
                                style: AppText.semibold16.copyWith(
                                  color: AppColors.brandPurple,
                                ),
                              ),
                            ),
                          ),
                          8.kh,
                          TextButton(
                            onPressed: _later,
                            child: Text(
                              'aksiya_success_later'.tr(),
                              style: AppText.medium14.copyWith(
                                color: AppColors.onBrand.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The clock, stated plainly. Not a footnote — it is the condition the buyer
/// just accepted, and the one thing they will regret not having read.
class _DeadlineBanner extends StatelessWidget {
  const _DeadlineBanner({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.onBrand.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.onBrand.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.time.svg(
            width: 18.w,
            height: 18.w,
            colorFilter:
                const ColorFilter.mode(AppColors.onBrand, BlendMode.srcIn),
          ),
          10.kw,
          Flexible(
            child: Text(
              'aksiya_success_deadline'.tr(namedArgs: {'days': '$days'}),
              style: AppText.semibold14.copyWith(color: AppColors.onBrand),
            ),
          ),
        ],
      ),
    );
  }
}
