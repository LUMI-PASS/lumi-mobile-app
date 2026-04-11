import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';

class LanguageOption {
  final String code;
  final String label;
  final Locale locale;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.label,
    required this.locale,
    required this.flag,
  });
}

const _languages = [
  LanguageOption(
    code: 'uz',
    label: "O'zbekcha",
    locale: Locale('uz', 'UZ'),
    flag: '🇺🇿',
  ),
  LanguageOption(
    code: 'ru',
    label: 'Русский',
    locale: Locale('ru', 'RU'),
    flag: '🇷🇺',
  ),
  LanguageOption(
    code: 'en',
    label: 'English',
    locale: Locale('en', 'EN'),
    flag: '🇬🇧',
  ),
];

/// Shows the language selection bottom sheet.
/// [onChanged] is called when the user picks a different language.
Future<void> showLanguageBottomSheet(
  BuildContext context, {
  VoidCallback? onChanged,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _LanguageSheet(
      parentContext: context,
      onChanged: onChanged,
    ),
  );
}

class _LanguageSheet extends StatelessWidget {
  const _LanguageSheet({required this.parentContext, this.onChanged});

  final BuildContext parentContext;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final currentLocale = parentContext.locale;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          16.verticalSpace,
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Strings.selectLanguage,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E3D5D),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close_rounded,
                  size: 24.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          20.verticalSpace,
          // Language list
          ..._languages.map((lang) {
            final isSelected = currentLocale == lang.locale;
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: GestureDetector(
                onTap: () {
                  if (!isSelected) {
                    // Save to storage for API calls
                    setCurrentLang(lang.code);
                    // Set easy_localization locale for UI
                    parentContext.setLocale(lang.locale);
                    // Close sheet first, then refresh data
                    Navigator.pop(context);
                    onChanged?.call();
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFA652C7)
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3C539A).withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang.flag,
                        style: TextStyle(fontSize: 22.sp),
                      ),
                      12.horizontalSpace,
                      Text(
                        lang.label,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E3D5D),
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          size: 22.sp,
                          color: const Color(0xFFA652C7),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          8.verticalSpace,
        ],
      ),
    );
  }
}
