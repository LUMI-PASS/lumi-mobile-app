import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/promo/promo_eligibility.dart';

/// "Pay with my аксия" — the promo-pass switch in a booking summary.
///
/// Renders nothing when there is no pass and nothing to explain, so every
/// caller can drop it into a column unconditionally. Deliberately the same
/// shape as [UseBalanceRow]: both are payment methods the buyer already owns,
/// and they read as a pair.
///
/// It stays on screen for a refusal the buyer can FIX here — a date past the
/// deadline, or a place the pass has already been used at — because those are
/// the two cases where hiding the row would look like the pass had vanished.
/// The switch is dead in that state and the reason is printed under it.
class UsePromoPassRow extends StatelessWidget {
  const UsePromoPassRow({
    super.key,
    required this.eligibility,
    required this.enabled,
    required this.applied,
    required this.onChanged,
  });

  final PromoEligibility eligibility;

  /// Whether the switch can be touched. False while a checkout is in flight —
  /// the visit is already committed at that point.
  final bool enabled;

  /// Whether the buyer has asked to spend a visit on this booking.
  final bool applied;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!eligibility.shouldShowRow) return const SizedBox.shrink();

    final c = context.colors;
    final pass = eligibility.pass;
    final canUse = eligibility.eligible;
    final on = canUse && applied;
    final reason = eligibility.reason;

    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Assets.icons.coupon.svg(
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  canUse ? AppColors.brandPurple : c.disabled,
                  BlendMode.srcIn,
                ),
              ),
              10.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'aksiya_use_pass'.tr(),
                      style: AppText.semibold14.copyWith(
                        color: canUse ? c.textPrimary : c.textSecondary,
                      ),
                    ),
                    2.kh,
                    // What is on offer when off, what is being taken when on —
                    // the buyer should never have to toggle it to find out.
                    Text(
                      on
                          ? 'aksiya_use_pass_covers'.tr(namedArgs: {
                              'amount': eligibility.covered.toRawUzsPrice(),
                            })
                          : 'aksiya_use_pass_left'.tr(namedArgs: {
                              'count': '${pass?.activitiesLeft ?? 0}',
                            }),
                      style: AppText.regular12.copyWith(
                        color: on ? AppColors.green : c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: on,
                onChanged: (enabled && canUse) ? onChanged : null,
                activeColor: AppColors.brandPurple,
              ),
            ],
          ),
          // Only ever shown for a refusal the buyer can act on — the row is
          // hidden entirely for the rest, so this never prints "you have no
          // pass" beside a switch.
          if (!canUse && reason != null) ...[
            8.kh,
            Text(
              reason.messageKey.tr(),
              style: AppText.regular12.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}
