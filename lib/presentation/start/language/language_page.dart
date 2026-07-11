import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/common/widget/auth/auth_badges.dart';
import 'package:lumi_pass/common/widget/auth/auth_misc.dart';
import 'package:lumi_pass/common/widget/auth/auth_scaffold.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/auth/language_option_tile.dart';

class _Lang {
  const _Lang(this.code, this.label, this.locale, this.flag);
  final String code;
  final String label;
  final Locale locale;
  final AssetGenImage flag;
}

final _languages = [
  _Lang('en', 'English', const Locale('en', 'EN'), Assets.icons.auth.flagEn),
  _Lang('uz', "O'zbek tili", const Locale('uz', 'UZ'), Assets.icons.auth.flagUz),
  _Lang('ru', 'Русский', const Locale('ru', 'RU'), Assets.icons.auth.flagRu),
];

/// "Выберите язык" — full-screen language picker.
@RoutePage()
class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late String _selected = _resolveInitial();

  String _resolveInitial() {
    final code = context.locale.languageCode;
    return _languages.any((l) => l.code == code) ? code : 'uz';
  }

  void _select(_Lang lang) {
    if (_selected == lang.code) return;
    setState(() => _selected = lang.code);
    setCurrentLang(lang.code);
    context.setLocale(lang.locale);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AuthScaffold(
      child: Column(
        children: [
          SizedBox(height: 24.h),
          const LumiWordmark(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 32.h),
                  GradientIconBadge(asset: Assets.icons.auth.globe),
                  SizedBox(height: 16.h),
                  Text(
                    'select_language'.tr(),
                    textAlign: TextAlign.center,
                    style: AppText.heading20.copyWith(color: colors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'select_language_subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style:
                        AppText.regular14.copyWith(color: colors.textSecondary),
                  ),
                  SizedBox(height: 24.h),
                  for (final lang in _languages) ...[
                    LanguageOptionTile(
                      flagAsset: lang.flag,
                      label: lang.label,
                      selected: _selected == lang.code,
                      onTap: () => _select(lang),
                    ),
                    if (lang != _languages.last) SizedBox(height: 12.h),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: GradientButton(
              text: 'continue_button'.tr(),
              onPressed: () => context.router.replace(OnboardingRoute()),
            ),
          ),
        ],
      ),
    );
  }
}
