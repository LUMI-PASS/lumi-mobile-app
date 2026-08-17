import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/payment_sheet_chrome.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';

/// One saved card in the list: brand tile, label, masked digits, delete.
///
/// A compact row rather than a credit-card illustration — the user is managing
/// a list here, not admiring one card, and rows stay readable at four or five.
class CardRow extends StatelessWidget {
  const CardRow({
    super.key,
    required this.card,
    required this.onDelete,
    this.isRemoving = false,
  });

  final SavedCard card;
  final VoidCallback onDelete;
  final bool isRemoving;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // The gateway's vendor string is authoritative; the BIN of the masked PAN
    // is the fallback, since the first six digits survive masking.
    final byVendor = CardBrand.fromKey(card.vendor);
    final brand = byVendor == CardBrand.unknown
        ? CardBrand.fromPan(card.maskedNumber ?? '')
        : byVendor;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: isRemoving ? 0.4 : 1,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: c.scaffoldBg,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: c.divider),
              ),
              child: Center(child: CardArtwork(brand: brand, width: 32)),
            ),
            12.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  2.kh,
                  Text(
                    [
                      card.maskedNumber ?? '',
                      if (card.expiryDisplay.isNotEmpty) card.expiryDisplay,
                    ].where((s) => s.isNotEmpty).join('  ·  '),
                    style: AppText.regular12.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            8.kw,
            if (isRemoving)
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.error),
                ),
              )
            else
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDelete,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 22.sp, color: c.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
