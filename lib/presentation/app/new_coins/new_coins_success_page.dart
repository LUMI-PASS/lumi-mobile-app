import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/presentation/app/new_coins/widgets/new_coins_widgets.dart';

/// "The coins are yours."
///
/// Says what was just bought, and gets out of the
/// way: one button, back to wherever the buyer came from — the shelf, or the
/// booking that was a top-up short of being paid.
///
/// It is the last page of the coin screens and looks like them: the light
/// stage in both themes, the pack's colour washing off the top edge, the
/// pack's own coin, and the button in the pack's tone. It used to be the
/// app-wide brand gradient with a green tick — a different product's "done"
/// at the end of a purchase made entirely in the pack's colour.
class NewCoinsSuccessPage extends StatelessWidget {
  NewCoinsSuccessPage({
    super.key,
    required this.coins,
    NewCoinTone? tone,
  }) : tone = tone ?? NewCoinTone.extra;

  /// How many coins the purchase was for.
  final int coins;

  /// The colour of what was bought — the pack's own. Left out, it is the
  /// top-up tone loose coins are sold in.
  final NewCoinTone tone;

  @override
  Widget build(BuildContext context) {
    const c = AppColorScheme.light;

    return Theme(
      data: Theme.of(context).copyWith(
        brightness: Brightness.light,
        extensions: const [AppColorScheme.light],
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: AppColors.coinStage,
          body: Stack(
            children: [
              Positioned.fill(child: NewCoinsBackdrop(tone: tone)),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 16.h),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      NewCoinArt(tone: tone),
                      20.kh,
                      Text(
                        'new_coins_success_title'.tr(),
                        textAlign: TextAlign.center,
                        style:
                            AppText.semibold24.copyWith(color: AppColors.ink),
                      ),
                      10.kh,
                      Text(
                        'new_coins_success_body'.tr(args: [coins.toGrouped()]),
                        textAlign: TextAlign.center,
                        style: AppText.regular14.copyWith(
                          color: c.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(flex: 3),
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          height: 58.h,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: tone.button,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: tone.accent.withValues(alpha: 0.5),
                                blurRadius: 24.r,
                                offset: Offset(0, 8.h),
                              ),
                            ],
                          ),
                          child: Text(
                            'new_coins_success_cta'.tr(),
                            style: AppText.semibold16
                                .copyWith(color: tone.onAccent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
