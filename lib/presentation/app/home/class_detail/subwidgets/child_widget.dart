import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/eligibility/eligibility_model.dart';

class ChildWidget extends StatelessWidget {
  const ChildWidget({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.canAfford = true,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final EligibleChild child;
  final bool canAfford;

  String _getIneligibilityText(String? reason) {
    switch (reason) {
      case 'child is young':
        return 'Too young';
      case 'child is old':
        return 'Too old';
      case 'child gender mismatch':
        return 'Gender mismatch';
      case 'child has no photo':
        return 'No photo';
      default:
        return reason ?? 'Not eligible';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = !child.isEligible;
    final primary = context.colors.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFFF3F4F6).withOpacity(0.9)
              : isSelected
                  ? primary
                  : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isDisabled
                ? primary.withOpacity(0.15)
                : isSelected
                    ? primary
                    : Colors.white.withOpacity(0.9),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: isSelected
                        ? primary.withOpacity(0.32)
                        : const Color(0xFF3C539A).withOpacity(0.1),
                    blurRadius: isSelected ? 22 : 18,
                    offset: Offset(0, isSelected ? 12 : 8),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
          child: InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: isDisabled ? null : onTap,
            child: Opacity(
              opacity: isDisabled ? 0.6 : 1.0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          color: isSelected
                              ? Colors.white
                              : primary,
                          size: 24.w,
                        ),
                      ),
                    ),
                    12.kw,

                    // Name + badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child:
                                    "${child.firstName ?? ''} ${child.lastName ?? ''}"
                                        .s(15)
                                        .w(700)
                                        .c(isSelected
                                            ? Colors.white
                                            : const Color(0xFF1E293B)),
                              ),
                              if (isSelected && !isDisabled)
                                Container(
                                  width: 24.w,
                                  height: 24.h,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.check_rounded,
                                      color: primary, size: 16.w),
                                ),
                            ],
                          ),
                          8.kh,
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 4.h,
                            children: [
                              // Age badge
                              _Badge(
                                text: "${child.age ?? '?'} years",
                                bgColor: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : const Color(0xFFFCE7F3),
                                textColor: isSelected
                                    ? Colors.white
                                    : const Color(0xFFDB2777),
                              ),
                              // Trial badge
                              if (child.isEligible &&
                                  (child.remainingTrials ?? 0) > 0)
                                _Badge(
                                  icon: Icons.star_rounded,
                                  text: "${child.remainingTrials} trials",
                                  bgColor: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : primary.withOpacity(0.08),
                                  textColor: isSelected
                                      ? Colors.white
                                      : primary,
                                ),
                              // Ineligibility badge
                              if (isDisabled)
                                _Badge(
                                  text: _getIneligibilityText(child.reason),
                                  bgColor:
                                      const Color(0xFFEF4444).withOpacity(0.08),
                                  textColor: const Color(0xFFEF4444),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Price
                    if (child.isEligible && child.effectiveClassPrice != null) ...[
                      8.kw,
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            "${child.effectiveClassPrice}"
                                .s(14)
                                .w(700)
                                .c(isSelected
                                    ? Colors.white
                                    : const Color(0xFFB45309)),
                            4.kw,
                            Assets.icons.coinLumi
                                .image(width: 16.w, height: 16.h),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.bgColor,
    required this.textColor,
    this.icon,
  });

  final String text;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 12.w),
            3.kw,
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
