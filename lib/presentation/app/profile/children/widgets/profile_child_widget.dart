import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
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
    final colors = context.colors;
    final age = childModel.age ?? getAge(childModel.dob);
    final unlockThreshold = childModel.unlockThresholdCoin;
    final coinsIntoCycle = childModel.coinsIntoUnlockCycle;

    final hasProgress =
        unlockThreshold != null && unlockThreshold > 0 && coinsIntoCycle != null;
    final progress =
        hasProgress ? (coinsIntoCycle / unlockThreshold).clamp(0.0, 1.0) : 0.0;

    final fullName =
        '${childModel.firstName ?? ''} ${childModel.lastName ?? ''}'.trim();

    return Container3d(
      onTap: onTap,
      isLight: true,
      backgroundColor: colors.surface,
      borderColor: colors.controlBorder,
      padding: EdgeInsets.all(14.w),
      borderRadius: BorderRadius.circular(20.r),
      child: Row(
        children: [
          _Avatar(
            photoUrl: childModel.hasPhoto == true ? _childPhotoUrl : null,
          ),
          14.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.semibold16.copyWith(color: colors.textPrimary),
                ),
                6.kh,
                if (age != null)
                  _AgeChip(label: '$age ${'age_years_suffix'.tr()}'),
                if (hasProgress) ...[
                  10.kh,
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: colors.control,
                            valueColor: AlwaysStoppedAnimation(colors.primary),
                            minHeight: 5.h,
                          ),
                        ),
                      ),
                      8.kw,
                      Text(
                        '$coinsIntoCycle/$unlockThreshold',
                        style: AppText.medium10.copyWith(
                          color: colors.textSecondary,
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
              color: colors.control,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: colors.controlBorder),
            ),
            child: Icon(
              CupertinoIcons.pencil,
              size: 16.w,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Container(
      width: 54.w,
      height: 54.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withOpacity(0.15), primary.withOpacity(0.06)],
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

class _AgeChip extends StatelessWidget {
  const _AgeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.brandPink.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.gift_fill, size: 11.w, color: AppColors.brandPink),
          4.kw,
          Text(
            label,
            style: AppText.semibold12.copyWith(color: AppColors.brandPink),
          ),
        ],
      ),
    );
  }
}
