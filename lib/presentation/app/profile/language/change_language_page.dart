import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/auth/language_option_tile.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/data/service/push_notification_service.dart';
import 'package:lumi_pass/di/injection.dart';

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

/// "Выберите язык" — the language picker reached from Profile → Settings.
/// The pick is only committed when the user taps "Сохранить".
@RoutePage()
class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  late String _selected = _resolveInitial();

  String _resolveInitial() {
    final code = context.locale.languageCode;
    return _languages.any((l) => l.code == code) ? code : 'uz';
  }

  void _save() {
    final lang = _languages.firstWhere((l) => l.code == _selected);
    if (lang.locale != context.locale) {
      setCurrentLang(lang.code);
      context.setLocale(lang.locale);
      // Re-register the device so the backend learns the NEW language. Without
      // this the token keeps whatever language was current when it was first
      // registered, and a language-targeted push would reach this device in the
      // language the user just switched away from. Fire-and-forget: a failed
      // re-register must not hold up the screen closing.
      unawaited(getIt<PushNotificationService>().registerCurrentDevice(
        locale: lang.code,
      ));
    }
    context.router.maybePop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      appBar: BaseAppBar(title: 'select_language'.tr()),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              itemCount: _languages.length,
              separatorBuilder: (_, __) => 12.kh,
              itemBuilder: (_, index) {
                final lang = _languages[index];
                return LanguageOptionTile(
                  flagAsset: lang.flag,
                  label: lang.label,
                  selected: _selected == lang.code,
                  onTap: () => setState(() => _selected = lang.code),
                );
              },
            ),
          ),
          Container(
            color: colors.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: GradientButton(
                  text: 'save_button'.tr(),
                  onPressed: _save,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
