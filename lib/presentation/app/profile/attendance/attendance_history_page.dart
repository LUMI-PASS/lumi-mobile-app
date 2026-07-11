import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/presentation/app/profile/attendance/cubit/attendance_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/attendance/cubit/attendance_state.dart';
import 'package:lumi_pass/presentation/app/profile/children/children_page.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class AttendanceHistoryPage extends BasePage<AttendanceCubit,
    AttendanceBuildable, AttendanceListenable> {
  const AttendanceHistoryPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<AttendanceCubit>().getChildren();
    super.init(context);
  }

  @override
  Widget builder(context, state) {
    final children = state.children ?? [];

    return Scaffold(
      appBar: const BaseAppBar(title: 'Attendance History'),
      body: state.isLoading
          ? _buildShimmer()
          : children.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  itemCount: children.length,
                  separatorBuilder: (_, __) => 12.kh,
                  itemBuilder: (context, index) {
                    return _ChildSelectionCard(
                      child: children[index],
                      onTap: () {
                        context.router.push(
                          AttendanceDetailRoute(
                            childModel: children[index],
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.child_care_rounded,
                size: 40.w,
                color: context.colors.primary.withOpacity(0.4),
              ),
            ),
            20.kh,
            "No children found"
                .s(16)
                .w(600)
                .c(context.colors.textPrimary),
            8.kh,
            "Please add a child first to view attendance history"
                .s(14)
                .w(400)
                .c(Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: List.generate(
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
        ),
      ),
    );
  }
}

class _ChildSelectionCard extends StatelessWidget {
  const _ChildSelectionCard({
    required this.child,
    required this.onTap,
  });

  final ChildModel child;
  final VoidCallback onTap;

  String get _childPhotoUrl =>
      '${Constants.baseUrl}assets/files/child-photo/${child.id}';

  @override
  Widget build(BuildContext context) {
    final age = child.age ?? getAge(child.dob);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: child.hasPhoto == true
                  ? Image.network(
                      _childPhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar(context),
                    )
                  : _defaultAvatar(context),
            ),
            14.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "${child.firstName ?? ''} ${child.lastName ?? ''}"
                      .s(15)
                      .w(600)
                      .c(context.colors.textPrimary),
                  4.kh,
                  if (age != null)
                    Row(
                      children: [
                        Icon(Icons.cake_outlined,
                            size: 14.w, color: Colors.grey.shade500),
                        4.kw,
                        "$age years old"
                            .s(13)
                            .w(400)
                            .c(Colors.grey.shade500),
                      ],
                    ),
                ],
              ),
            ),
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 14.w,
                color: context.colors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar(BuildContext context) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        size: 26.w,
        color: context.colors.primary.withOpacity(0.4),
      ),
    );
  }
}
