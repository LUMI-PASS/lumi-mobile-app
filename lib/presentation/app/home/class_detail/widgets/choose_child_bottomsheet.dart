import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/loading_view.dart';
import 'package:lumi_pass/data/api_model/eligibility/eligibility_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/child_widget.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/not_enough_coin_content.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/get_ticket_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';

import 'about_pocket_bottomsheet.dart';

class ChooseChildBottomsheet
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  ChooseChildBottomsheet({super.key, required this.classId});

  final String? classId;
  int selectedTariffIndex = -1;
  Tariff? selectedTariff;

  void _onTariffSelected(Tariff tariff, int index) {
    setState(() {
      selectedTariff = tariff;
      selectedTariffIndex = index;
    });
  }

  @override
  void init(BuildContext context) {
    if (classId != null) {
      context.read<ChildrenCubit>().checkClassEligibility(classId!);
    }
    super.init(context);
  }

  num _resolveEffectivePrice(
      EligibleChild child, ClassEligibilityData eligData) {
    if (child.effectiveClassPrice != null) {
      return child.effectiveClassPrice!;
    }
    if (child.willUseTrial == true && eligData.classTrialPrice != null) {
      return eligData.classTrialPrice!;
    }
    return eligData.classPrice ?? 0;
  }

  @override
  Widget builder(context, state) {
    final eligData = state.eligibilityData;
    final isLoading = state.eligibilityLoading;
    final hasEligData = eligData != null;
    final primary = context.colors.primary;

    final hasEnoughCoins = eligData?.isBalanceEnough == true;
    final selectedChildId = state.selectedChildId;

    final selectedChild = hasEligData
        ? eligData.children
            .where((c) => c.id == selectedChildId)
            .firstOrNull
        : null;

    final selectedChildPrice = selectedChild != null
        ? _resolveEffectivePrice(selectedChild, eligData!)
        : null;
    final canAffordSelected = selectedChildPrice != null
        ? (eligData!.walletBalance >= selectedChildPrice)
        : false;
    final canProceed = selectedChild != null &&
        selectedChild.isEligible &&
        canAffordSelected;

    final totalTrials = hasEligData
        ? eligData.children.fold<int>(
            0, (sum, c) => sum + (c.remainingTrials ?? 0))
        : 0;
    final unlockThreshold = eligData?.trialUnlockThresholdCoin ?? 700;
    final unlockBatch = eligData?.trialUnlockBatchLessonsPerUnlock ?? 3;

    final progressCoins = selectedChild?.coinsIntoUnlockCycle ??
        ((selectedChild?.paidCoinAccumulator ?? 0) %
            (unlockThreshold > 0 ? unlockThreshold : 700));
    final safeThreshold = unlockThreshold > 0 ? unlockThreshold : 700;
    final progressPercent =
        (progressCoins / safeThreshold * 100).clamp(0, 100).round();

    final eligibleChildren = hasEligData
        ? eligData.children.where((c) => c.isEligible).toList()
        : [];
    final minEffectivePrice = eligibleChildren.isNotEmpty
        ? eligibleChildren.fold<num>(
            double.infinity,
            (min, c) =>
                _resolveEffectivePrice(c, eligData!) < min
                    ? _resolveEffectivePrice(c, eligData)
                    : min)
        : 0;
    final showLowBalance = hasEligData &&
        ((minEffectivePrice > 0 &&
                eligData.walletBalance < minEffectivePrice) ||
            eligData.walletBalance == 0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: context.colors.scaffoldBg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 48.w,
              height: 5.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Title
          Center(
            child: 'select_child'.tr()
                .s(22)
                .w(700)
                .c(const Color(0xFF1E293B)),
          ),
          20.kh,

          if (isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 48.h),
              child: const Center(child: LoadingView()),
            )
          else if (!hasEligData)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 48.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 48.w, color: const Color(0xFF94A3B8)),
                    12.kh,
                    'could_not_check_eligibility'.tr()
                        .s(16)
                        .w(500)
                        .c(const Color(0xFF64748B)),
                  ],
                ),
              ),
            )
          else ...[
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance Card
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF5F3FF),
                            Color(0xFFFDF2F8),
                            Color(0xFFFFF1F2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  'your_balance'.tr()
                                      .s(11)
                                      .w(600)
                                      .c(const Color(0xFF64748B)),
                                  6.kh,
                                  Row(
                                    children: [
                                      "${eligData.walletBalance.toInt()}"
                                          .s(28)
                                          .w(700)
                                          .c(primary),
                                      8.kw,
                                      Assets.icons.coinLumi
                                          .image(width: 28.w, height: 28.h),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (showLowBalance) ...[
                            12.kh,
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: eligData.walletBalance == 0
                                    ? const Color(0xFFFEF2F2)
                                    : const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 16.w,
                                    color: eligData.walletBalance == 0
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFFF59E0B),
                                  ),
                                  8.kw,
                                  Expanded(
                                    child: (eligData.walletBalance == 0
                                            ? 'no_coins_warning'.tr()
                                            : 'low_balance_warning'.tr())
                                        .s(12)
                                        .w(500)
                                        .c(eligData.walletBalance == 0
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFFB45309)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    16.kh,

                    // Trial Info
                    if (totalTrials > 0 || unlockThreshold > 0)
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C539A).withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            'trial_lessons'.tr()
                                .s(14)
                                .w(600)
                                .c(const Color(0xFF1E293B)),
                            4.kh,
                            'earn_trials'.tr()
                                .s(12)
                                .w(400)
                                .c(const Color(0xFF64748B)),
                            10.kh,
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  'total_remaining_trials'.tr()
                                      .s(12)
                                      .w(600)
                                      .c(const Color(0xFF047857)),
                                  "$totalTrials"
                                      .s(18)
                                      .w(700)
                                      .c(const Color(0xFF047857)),
                                ],
                              ),
                            ),
                            8.kh,
                            'spend_coins_unlock'.tr(args: ['$unlockThreshold', '$unlockBatch'])
                                .s(11)
                                .w(400)
                                .c(const Color(0xFF94A3B8)),
                          ],
                        ),
                      ),

                    16.kh,

                    // Children list or tariffs
                    if (hasEnoughCoins || eligData.children.isNotEmpty) ...[
                      'choose_your_child'.tr()
                          .s(16)
                          .w(700)
                          .c(const Color(0xFF1E293B)),
                      12.kh,
                      if (eligData.children.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.child_care_rounded,
                                    size: 48.w,
                                    color: const Color(0xFF94A3B8)),
                                12.kh,
                                'no_children_add_first'.tr()
                                    .s(14)
                                    .w(500)
                                    .c(const Color(0xFF64748B)),
                              ],
                            ),
                          ),
                        )
                      else
                        ...eligData.children.map((child) => ChildWidget(
                              child: child,
                              isSelected: selectedChildId == child.id,
                              canAfford: child.isEligible &&
                                  eligData.walletBalance >=
                                      _resolveEffectivePrice(child, eligData),
                              onTap: () {
                                context.read<ChildrenCubit>().selectChild(
                                    selectedChildId == child.id
                                        ? null
                                        : child.id);
                              },
                            )),
                    ] else ...[
                      'not_enough_coins'.tr()
                          .s(15)
                          .w(700)
                          .c(const Color(0xFF1E293B)),
                      12.kh,
                      NotEnoughCoinContent(
                        onTariffSelected: _onTariffSelected,
                        selectedIndex: selectedTariffIndex,
                      ),
                    ],

                    // Expected Charge & Progress
                    if (selectedChild != null &&
                        selectedChild.isEligible) ...[
                      12.kh,
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C539A).withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                'expected_charge'.tr()
                                    .s(14)
                                    .w(600)
                                    .c(const Color(0xFF1E293B)),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10.w, vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    children: [
                                      "$selectedChildPrice"
                                          .s(14)
                                          .w(700)
                                          .c(const Color(0xFFB45309)),
                                      4.kw,
                                      Assets.icons.coinLumi
                                          .image(width: 16.w, height: 16.h),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            8.kh,
                            (selectedChild.willUseTrial == true
                                    ? 'uses_trial_price'.tr()
                                    : 'uses_full_price'.tr())
                                .s(12)
                                .w(500)
                                .c(selectedChild.willUseTrial == true
                                    ? const Color(0xFF047857)
                                    : const Color(0xFFF97316)),

                            // Progress bar
                            16.kh,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                'unlock_progress'.tr()
                                    .s(11)
                                    .w(600)
                                    .c(const Color(0xFF94A3B8)),
                                "$progressPercent%"
                                    .s(11)
                                    .w(600)
                                    .c(const Color(0xFF94A3B8)),
                              ],
                            ),
                            8.kh,
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: progressPercent / 100,
                                minHeight: 6.h,
                                backgroundColor: primary.withOpacity(0.08),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(primary),
                              ),
                            ),
                            8.kh,
                            'coins_to_next_unlock'.tr(args: ['${selectedChild.coinsToNextUnlock ?? 0}'])
                                .s(11)
                                .w(400)
                                .c(const Color(0xFF94A3B8)),

                            // Insufficient balance warning
                            if (!canAffordSelected) ...[
                              12.kh,
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: 'insufficient_balance'.tr()
                                    .s(12)
                                    .w(600)
                                    .c(const Color(0xFFEF4444))
                                    .a(TextAlign.center),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    16.kh,
                  ],
                ),
              ),
            ),

            // Next Button - pinned at bottom
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: SafeArea(
                top: false,
                child: Material(
                  color:
                      (hasEnoughCoins ? canProceed : selectedTariff != null)
                          ? primary
                          : primary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(18.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),
                    onTap: (hasEnoughCoins
                            ? canProceed
                            : selectedTariff != null)
                        ? () {
                            Navigator.pop(context);
                            showModalBottomSheet(
                              context: context,
                              builder: (ctx) {
                                return hasEnoughCoins
                                    ? GetTicketBottomsheet(
                                        childId: selectedChildId,
                                        classId: classId,
                                        eligibilityData: eligData,
                                      )
                                    : AboutPocketBottomsheet(
                                        tariff: selectedTariff ?? Tariff(),
                                      );
                              },
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                            );
                          }
                        : null,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.32),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: 'next'.tr()
                            .s(16)
                            .w(700)
                            .c(Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
