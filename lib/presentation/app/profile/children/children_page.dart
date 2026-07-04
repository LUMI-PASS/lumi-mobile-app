import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/presentation/app/profile/children/widgets/child_bottomsheet.dart';
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
                        ? _EmptyState()
                        : ListView(
                            padding: EdgeInsets.fromLTRB(
                                16.w, 12.h, 16.w, 24.h),
                            children: [
                              ...children.map((child) => Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: ProfileChildWidget(
                                      childModel: child,
                                      onTap: () => ChildBottomsheet.show(
                                        context,
                                        childModel: child,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                      child: GestureDetector(
                        onTap: () => ChildBottomsheet.show(context),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: context.colors.primary,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.primary.withOpacity(0.30),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.person_badge_plus_fill,
                                  color: Colors.white, size: 20.w),
                              10.kw,
                              'add_child'.tr().s(15).w(700).c(Colors.white),
                            ],
                          ),
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

/// Shimmer loading for children list
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withOpacity(0.14),
                    primary.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.person_2_fill,
                size: 40.w,
                color: primary.withOpacity(0.45),
              ),
            ),
            20.kh,
            'no_children_yet'
                .tr()
                .s(17)
                .w(700)
                .c(const Color(0xFF1E293B)),
            8.kh,
            Text(
              'add_first_child'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChildrenShimmer extends StatelessWidget {
  const _ChildrenShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        child: Column(
          children: [
            ...List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  height: 86.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
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
