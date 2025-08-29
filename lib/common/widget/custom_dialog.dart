import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommonDialogView extends StatelessWidget {
  final String title;
  final String description;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final VoidCallback? onSecondaryButtonPressed;
  final Widget? customContent;
  final bool barrierDismissible;
  final Color? primaryButtonColor;
  final Color? secondaryButtonColor;
  final Color? titleColor;
  final Color? descriptionColor;
  final bool? loading;
  final bool? hasCloseButton;
  final VoidCallback? onClosePressed;

  const CommonDialogView(
      {Key? key,
      required this.title,
      required this.description,
      this.primaryButtonText,
      this.secondaryButtonText,
      this.onPrimaryButtonPressed,
      this.onSecondaryButtonPressed,
      this.customContent,
      this.barrierDismissible = true,
      this.primaryButtonColor = const Color(0xFFFF3B30),
      this.secondaryButtonColor,
      this.titleColor = Colors.white,
      this.descriptionColor = const Color(0xFFBBBBBB),
      this.loading,
      this.hasCloseButton,
      this.onClosePressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 14.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hasCloseButton ?? false)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () {
                        onClosePressed?.call();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close)),
                ],
              ),
            if (customContent != null) ...[
              16.kh,
              customContent!,
            ],
            title.s(18).w(600).a(TextAlign.center),
            12.kh,
            description.s(400).s(14).a(TextAlign.center),
            if (secondaryButtonText != null || primaryButtonText != null) 24.kh,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (secondaryButtonText != null) ...[
                  Flexible(
                    child: CommonButton.elevated(
                      loading: loading ?? false,
                      onPressed: () {
                        onSecondaryButtonPressed?.call();
                        Navigator.pop(context);
                      },
                      text: secondaryButtonText!,
                      backgroundColor:
                          secondaryButtonColor ?? context.colors.primary2,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                16.kw,
                if (primaryButtonText != null)
                  Flexible(
                    child: CommonButton.elevated(
                      onPressed:(){
                        Navigator.of(context).pop();
                        onPrimaryButtonPressed?.call();
                      },
                      text: primaryButtonText!,
                      backgroundColor:
                          primaryButtonColor ?? context.colors.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    String? primaryButtonText,
    String? secondaryButtonText,
    VoidCallback? onPrimaryButtonPressed,
    VoidCallback? onSecondaryButtonPressed,
    Widget? customContent,
    bool barrierDismissible = true,
    Color? primaryButtonColor,
    Color? secondaryButtonColor,
    Color? titleColor,
    Color? descriptionColor,
    bool? loading,
    bool? hasCloseButton,
    VoidCallback? onClosePressed,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return CommonDialogView(
          title: title,
          description: description,
          primaryButtonText: primaryButtonText,
          secondaryButtonText: secondaryButtonText,
          onPrimaryButtonPressed: onPrimaryButtonPressed,
          onSecondaryButtonPressed: onSecondaryButtonPressed,
          customContent: customContent,
          primaryButtonColor: primaryButtonColor,
          secondaryButtonColor: secondaryButtonColor,
          titleColor: titleColor,
          descriptionColor: descriptionColor,
          loading: loading,
          hasCloseButton: hasCloseButton,
          onClosePressed: onClosePressed,
        );
      },
    );
  }
}
