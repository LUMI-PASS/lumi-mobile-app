import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/promo_pass_coverage.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';

/// The packet the signed-in user holds, or null. Read this rather than
/// `AppCubit` directly so every price site asks the question the same way.
///
/// `watch`, so a card rebuilds the instant the packet is bought, spent or
/// expires — that is what puts the prices back without a reload.
PromoPassCoverage? watchPromoPass(BuildContext context) {
  final app = context.watch<AppCubit>().state.buildable ?? const AppBuildable();
  return app.promoPass;
}

/// Non-listening variant for callers outside a build (checkout paths).
PromoPassCoverage? readPromoPass(BuildContext context) {
  final app = context.read<AppCubit>().state.buildable ?? const AppBuildable();
  return app.promoPass;
}

/// What replaces a price while a "Lumi Start" packet covers the activity.
///
/// A packet buyer has already paid; quoting them a figure they are not going to
/// be charged is the one thing this screen must not do. So the price is not
/// struck through or greyed — it is gone, and what stands in its place says why
/// and how many visits are left, because "free" with no reason reads as a bug.
///
/// [compact] is for list cards, where the row has one line to spare; the full
/// form adds the visit count and is for detail screens.
class PromoIncludedLabel extends StatelessWidget {
  const PromoIncludedLabel({
    super.key,
    required this.pass,
    this.compact = true,
  });

  final PromoPassCoverage pass;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: AppColors.green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.icons.sucess.svg(
                width: 12.w,
                height: 12.w,
                colorFilter:
                    const ColorFilter.mode(AppColors.green, BlendMode.srcIn),
              ),
              4.kw,
              Text(
                // Names the packet rather than saying "free": the buyer should
                // be able to tell WHY it costs nothing, and which of their
                // purchases is paying for it.
                'promo_included_in'.tr(namedArgs: {'packet': pass.title}),
                style: AppText.semibold12.copyWith(color: AppColors.green),
              ),
            ],
          ),
        ),
        if (!compact) ...[
          4.kh,
          Text(
            'promo_included_left'.tr(
              namedArgs: {'count': '${pass.activitiesLeft}'},
            ),
            style: AppText.regular12.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}
