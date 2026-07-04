import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/presentation/app/profile/children/children_page.dart';

class ProfileChildWidget extends StatelessWidget {
  const ProfileChildWidget({
    super.key,
    required this.onTap,
    required this.childModel,
  });

  final VoidCallback onTap;
  final ChildModel childModel;

  String get _childPhotoUrl =>
      '${Constants.baseUrl}assets/files/child-photo/${childModel.id}';

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final age = childModel.age ?? getAge(childModel.dob);
    final unlockThreshold = childModel.unlockThresholdCoin;
    final coinsIntoCycle = childModel.coinsIntoUnlockCycle;

    final hasProgress = unlockThreshold != null &&
        unlockThreshold > 0 &&
        coinsIntoCycle != null;
    final progressPercent = hasProgress
        ? ((coinsIntoCycle / unlockThreshold) * 100).clamp(0.0, 100.0)
        : 0.0;

    final fullName =
        '${childModel.firstName ?? ''} ${childModel.lastName ?? ''}'.trim();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C4EF2).withOpacity(0.07),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _Avatar(
              photoUrl: childModel.hasPhoto == true ? _childPhotoUrl : null,
              primary: primary,
            ),
            14.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  fullName.s(16).w(700).c(const Color(0xFF1E293B)),
                  6.kh,
                  if (age != null)
                    _Chip(
                      icon: CupertinoIcons.gift_fill,
                      label: '$age yrs',
                      color: const Color(0xFFEC4899),
                    ),
                  if (hasProgress) ...[
                    10.kh,
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: progressPercent / 100,
                              backgroundColor: primary.withOpacity(0.10),
                              valueColor: AlwaysStoppedAnimation(primary),
                              minHeight: 5.h,
                            ),
                          ),
                        ),
                        8.kw,
                        Text(
                          '$coinsIntoCycle/$unlockThreshold',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: primary.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            8.kw,
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                CupertinoIcons.pencil,
                size: 16.w,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.primary});

  final String? photoUrl;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54.w,
      height: 54.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.15),
            primary.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoUrl != null
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(primary),
            )
          : _placeholder(primary),
    );
  }

  Widget _placeholder(Color color) => Center(
        child: Icon(
          CupertinoIcons.person_fill,
          size: 26.w,
          color: color.withOpacity(0.45),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.w, color: color),
          4.kw,
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
