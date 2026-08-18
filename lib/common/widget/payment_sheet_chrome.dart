import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';

/// The chrome shared by every card-related bottom sheet — the checkout payment
/// chooser and the profile's card management alike.
///
/// These started out private to the checkout sheet. The profile needs the same
/// look for adding and confirming a card, and two copies of a payment sheet
/// would drift, so they live here instead.

/// The rounded sheet body: grab handle, keyboard-aware padding, scrolling
/// content that can't overflow the screen.
class PaymentSheetShell extends StatelessWidget {
  const PaymentSheetShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final media = MediaQuery.of(context);
    // Clear the home indicator from *inside* the sheet, and lift the whole
    // thing above the keyboard when a field is focused.
    final bottomInset = media.padding.bottom + media.viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(maxHeight: 0.9.sh),
      decoration: BoxDecoration(
        color: c.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 14.w,
        right: 14.w,
        top: 12.h,
        bottom: 12.h + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              // Figma `Pull`: rgba(170,178,188,0.35).
              color: const Color(0xFFAAB2BC).withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          // The content can outgrow the sheet on small screens, so the body
          // scrolls inside the shell instead of overflowing it.
          Flexible(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}

/// Inline error banner shown inside a sheet step when a gateway call fails.
class PaymentErrorNote extends StatelessWidget {
  const PaymentErrorNote({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 16.sp, color: AppColors.error),
          8.horizontalSpace,
          Expanded(
            child: Text(message,
                style: AppText.regular12.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// A pale input on the payment sheets (card number, expiry).
class PaymentField extends StatelessWidget {
  const PaymentField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.focusNode,
    this.autofocus = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;
  final FocusNode? focusNode;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: context.colors.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              cursorColor: AppColors.link,
              style:
                  AppText.medium16.copyWith(color: context.colors.textPrimary),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: AppText.medium16
                    .copyWith(color: context.colors.textSecondary),
              ),
            ),
          ),
          if (suffix != null) suffix!,
        ],
      ),
    );
  }
}

/// The paired "Cancel" / gradient-CTA footer shared by the payment sheets.
class PaymentSheetActions extends StatelessWidget {
  const PaymentSheetActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onCancel,
    this.busy = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onCancel;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onCancel,
            child: Container(
              height: 50.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.divider,
                borderRadius: BorderRadius.circular(44.r),
              ),
              child: Text(
                'cancel'.tr(),
                style: AppText.medium16
                    .copyWith(color: context.colors.textSecondary),
              ),
            ),
          ),
        ),
        8.horizontalSpace,
        Expanded(
          child: GradientButton(
            text: primaryLabel,
            loading: busy,
            onPressed: onPrimary,
          ),
        ),
      ],
    );
  }
}

/// The card schemes the gateway accepts, and how to recognise one.
enum CardBrand {
  uzcard('uzcard', 'UzCard'),
  humo('humo', 'Humo'),
  mastercard('mastercard', 'MasterCard'),
  unknown('unknown', 'Card');

  const CardBrand(this.key, this.label);

  /// Wire value.
  final String key;

  /// Display name shown next to the masked digits.
  final String label;

  static CardBrand fromKey(String? key) {
    final k = key?.trim().toLowerCase();
    for (final b in values) {
      if (b.key == k) return b;
    }
    return CardBrand.unknown;
  }

  /// Best-effort brand detection from the PAN's issuer prefix — the gateway
  /// doesn't tell us the brand, and the row has to show the right artwork.
  /// Works on a masked PAN too: the BIN is the part that stays visible.
  static CardBrand fromPan(String pan) {
    final d = pan.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length < 4) return CardBrand.unknown;
    final p4 = int.tryParse(d.substring(0, 4)) ?? 0;
    final p2 = int.tryParse(d.substring(0, 2)) ?? 0;
    if (p4 == 8600 || p4 == 5614) return CardBrand.uzcard;
    if (p4 == 9860) return CardBrand.humo;
    if (p2 >= 51 && p2 <= 55) return CardBrand.mastercard;
    if (p4 >= 2221 && p4 <= 2720) return CardBrand.mastercard;
    return CardBrand.unknown;
  }

  /// Brand artwork, or `null` for [unknown] — the row then falls back to a
  /// neutral card tile.
  AssetGenImage? get artwork => switch (this) {
        CardBrand.uzcard => Assets.images.pay.uzcard,
        CardBrand.humo => Assets.images.pay.humo,
        CardBrand.mastercard => Assets.images.pay.mastercard,
        CardBrand.unknown => null,
      };
}

/// The brand tile in a saved-card row. Falls back to a neutral card glyph when
/// the brand has no artwork ([CardBrand.unknown]).
///
/// The artwork is fitted, not cropped: the brand marks don't share an aspect
/// ratio (UzCard/Humo ship as card rectangles, MasterCard as a near-square
/// logo), so `cover` would slice the edges off the square ones.
class CardArtwork extends StatelessWidget {
  const CardArtwork({
    super.key,
    required this.brand,
    this.width = 44,
    this.height = 28,
  });

  final CardBrand brand;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final art = brand.artwork;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: SizedBox(
        width: width.w,
        height: height.h,
        child: art == null
            ? ColoredBox(
                color: context.colors.control,
                child: Icon(Icons.credit_card_rounded,
                    size: 16.sp, color: context.colors.textSecondary),
              )
            : art.image(fit: BoxFit.contain),
      ),
    );
  }
}
