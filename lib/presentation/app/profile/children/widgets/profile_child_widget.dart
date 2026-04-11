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
    final age = childModel.age ?? getAge(childModel.dob);
    final remainingTrials = childModel.remainingTrials;
    final unlockThreshold = childModel.unlockThresholdCoin;
    final coinsIntoCycle = childModel.coinsIntoUnlockCycle;

    final hasProgress = unlockThreshold != null &&
        unlockThreshold > 0 &&
        coinsIntoCycle != null;
    final progressPercent = hasProgress
        ? ((coinsIntoCycle! / unlockThreshold!) * 100).clamp(0.0, 100.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo / Avatar
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: context.colors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: childModel.hasPhoto == true
                  ? Image.network(
                      _childPhotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar(context),
                    )
                  : _defaultAvatar(context),
            ),
            12.kw,
            // Name + badges
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "${childModel.firstName ?? ''} ${childModel.lastName ?? ''}"
                      .s(15)
                      .w(600),
                  6.kh,
                  Row(
                    children: [
                      // Age badge with icon
                      if (age != null)
                        _IconBadge(
                          icon: Icons.cake_outlined,
                          text: "$age",
                          color: const Color(0xFFFF94C7),
                        ),
                      if (age != null) 6.kw,
                      // Gender icon
                      if (childModel.gender != null)
                        Icon(
                          childModel.gender?.toUpperCase() == 'MALE'
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          size: 18.w,
                          color: childModel.gender?.toUpperCase() == 'MALE'
                              ? Colors.blue.shade300
                              : Colors.pink.shade300,
                        ),
                      if (remainingTrials != null) ...[
                        6.kw,
                        _IconBadge(
                          icon: Icons.card_giftcard_rounded,
                          text: "$remainingTrials",
                          color: context.colors.primary,
                        ),
                      ],
                    ],
                  ),
                  // Compact progress bar
                  if (hasProgress) ...[
                    8.kh,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3.r),
                      child: LinearProgressIndicator(
                        value: progressPercent / 100,
                        backgroundColor:
                            context.colors.primary.withOpacity(0.08),
                        valueColor:
                            AlwaysStoppedAnimation(context.colors.primary),
                        minHeight: 4.h,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            8.kw,
            // Edit icon
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 18.w,
                color: Colors.grey.shade500,
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

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: color),
          3.kw,
          text.s(10).w(700).c(color),
        ],
      ),
    );
  }
}
