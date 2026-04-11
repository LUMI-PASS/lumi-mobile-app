import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/presentation/app/profile/children/widgets/profile_child_widget.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class ChildrenPage
    extends BasePage<ChildrenCubit, ChildrenBuildable, ChildrenListenable> {
  const ChildrenPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<ChildrenCubit>().getChildren();
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    context.read<ChildrenCubit>().getChildren();
    super.onFocusGained(context);
  }

  @override
  Widget builder(context, state) {
    final children = state.childrenList ?? [];
    final trialSummary = state.trialSummary;

    return RefreshIndicator(
      onRefresh: () => context.read<ChildrenCubit>().getChildren(),
      child: Scaffold(
        appBar: BaseAppBar(
          title: 'my_children'.tr(),
        ),
        body: state.isLoading
            ? const _ChildrenShimmer()
            : Column(
                children: [
                  Expanded(
                    child: children.isEmpty
                        ? ListView(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            children: [
                              SizedBox(height: 80.h),
                              Icon(
                                Icons.child_care_rounded,
                                size: 80.w,
                                color: Colors.grey.shade300,
                              ),
                              16.kh,
                              Center(
                                child: 'no_children_yet'.tr()
                                    .s(16)
                                    .w(600)
                                    .c(Colors.grey.shade400),
                              ),
                              8.kh,
                              Center(
                                child: 'add_first_child'.tr()
                                    .s(13)
                                    .c(Colors.grey.shade400),
                              ),
                            ],
                          )
                        : ListView(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            children: [
                              // Trial wallet - compact icon-based card
                              if (trialSummary != null)
                                _TrialWalletCard(trialSummary: trialSummary),
                              if (trialSummary != null) 12.kh,

                              // Children list
                              ...children.map((child) => Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: ProfileChildWidget(
                                      childModel: child,
                                      onTap: () => context.router.push(
                                        AddChildRoute(
                                            childModel: child,
                                            parentId: null),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: CommonButton.outlined(
                          onPressed: () => context.router.push(
                            AddChildRoute(childModel: null, parentId: null),
                          ),
                          text: 'add_child'.tr(),
                          textColor: context.colors.primary,
                          borderColor: context.colors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Compact icon-based trial wallet card
class _TrialWalletCard extends StatelessWidget {
  const _TrialWalletCard({required this.trialSummary});

  final ParentTrialSummary trialSummary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withOpacity(0.08),
            context.colors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          // Trial icon
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              color: context.colors.primary,
              size: 22.w,
            ),
          ),
          12.kw,
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    "${trialSummary.totalRemainingTrials}"
                        .s(18)
                        .w(800)
                        .c(context.colors.primary),
                    4.kw,
                    'free_trials'.tr().s(13).w(500).c(Colors.grey.shade600),
                  ],
                ),
                2.kh,
                Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        size: 14.w, color: Colors.amber.shade600),
                    4.kw,
                    Expanded(
                      child:
                          'spend_coins_unlock'.tr(args: ['${trialSummary.unlockThresholdCoin}', '${trialSummary.unlockBatchTrials}'])
                              .s(11)
                              .w(500)
                              .c(Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer loading for children list
class _ChildrenShimmer extends StatelessWidget {
  const _ChildrenShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Column(
          children: [
            // Trial card skeleton
            Container(
              height: 68.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            12.verticalSpace,
            // Child card skeletons
            ...List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int? getAge(String? dob) {
  if (dob == null) return null;
  try {
    final birthDate = DateTime.parse(dob);
    final now = DateTime.now();

    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  } catch (_) {
    return null;
  }
}
