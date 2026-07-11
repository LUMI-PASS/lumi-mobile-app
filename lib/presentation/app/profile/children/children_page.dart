import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_state.dart';
import 'package:lumi_pass/presentation/app/profile/children/widgets/child_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/profile/children/widgets/profile_child_widget.dart';
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

    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: BaseAppBar(title: 'my_children'.tr()),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const _ChildrenShimmer()
                : RefreshIndicator(
                    onRefresh: () => context.read<ChildrenCubit>().getChildren(),
                    child: children.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                            itemCount: children.length,
                            separatorBuilder: (_, __) => 12.kh,
                            itemBuilder: (_, index) {
                              final child = children[index];
                              return ProfileChildWidget(
                                childModel: child,
                                onTap: () => ChildBottomsheet.show(
                                  context,
                                  childModel: child,
                                ),
                              );
                            },
                          ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: _AddChildButton(
                onTap: () => ChildBottomsheet.show(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width "card button" — the same 3D press affordance as the child cards.
class _AddChildButton extends StatelessWidget {
  const _AddChildButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container3d(
      onTap: onTap,
      width: double.infinity,
      backgroundColor: colors.primary,
      borderColor: colors.primary,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      borderRadius: BorderRadius.circular(16.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.person_badge_plus_fill,
            color: colors.onPrimary,
            size: 20.w,
          ),
          10.kw,
          Text(
            'add_child'.tr(),
            style: AppText.semibold16.copyWith(color: colors.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 80.h),
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withOpacity(0.14),
                      colors.primary.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.person_2_fill,
                  size: 40.w,
                  color: colors.primary.withOpacity(0.45),
                ),
              ),
              20.kh,
              Text(
                'no_children_yet'.tr(),
                style: AppText.semibold16.copyWith(color: colors.textPrimary),
              ),
              8.kh,
              Text(
                'add_first_child'.tr(),
                textAlign: TextAlign.center,
                style: AppText.regular13.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChildrenShimmer extends StatelessWidget {
  const _ChildrenShimmer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.control,
      highlightColor: colors.surface,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        itemCount: 3,
        separatorBuilder: (_, __) => 12.kh,
        itemBuilder: (_, __) => Container(
          height: 86.h,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20.r),
          ),
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
