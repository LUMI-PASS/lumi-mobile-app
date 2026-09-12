import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/multi_lang.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';

/// One product in the shop grid.
///
/// A sold-out product is shown, dimmed, rather than hidden: "we have this and
/// it's gone" is information a buyer wants, and hiding it makes a restock look
/// like a brand new product.
class ShopProductCard extends StatelessWidget {
  const ShopProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAdd,
    this.inCart = 0,
  });

  final ShopProduct product;
  final VoidCallback onTap;

  /// Adds one to the basket. Omit it and the card is just a link — which is
  /// what the "you might also like" strips want.
  final VoidCallback? onAdd;

  /// How many of this product the basket already holds, so the button can say
  /// so instead of pretending each tap is the first.
  final int inCart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final soldOut = !product.inStock;
    final image = sanitizeImageUrl(product.image);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Opacity(
                    opacity: soldOut ? 0.45 : 1,
                    child: image == null
                        ? Container(color: c.surface)
                        : CachedNetworkImage(
                            imageUrl: image,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Container(color: c.surface),
                          ),
                  ),
                ),
                if (soldOut)
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'shop_sold_out'.tr(),
                        style: AppText.semibold12
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  )
                else if (product.hasDiscount)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '-${(100 - (product.price / product.oldPrice!) * 100).round()}%',
                        style: AppText.semibold12
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          8.kh,
          Text(
            multiLang(product.name),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.semibold14.copyWith(color: c.textPrimary),
          ),
          4.kh,
          // Prices are in so'm, never coin-marked — the coin mark belongs to
          // wallet-side numbers only, and a price tag carrying it would read as
          // a second currency. The checkout screen is where coins come in.
          Row(
            children: [
              Text(
                product.price.toRawUzsPrice(),
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
              if (product.hasDiscount) ...[
                6.kw,
                Text(
                  product.oldPrice!.toGrouped(),
                  style: AppText.regular12.copyWith(
                    color: c.textSecondary,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          if (onAdd != null) ...[
            8.kh,
            _AddButton(
              enabled: !soldOut,
              inCart: inCart,
              onTap: onAdd!,
            ),
          ],
        ],
      ),
    );
  }
}

/// "Qo'shish" — the add-to-basket button under a card.
///
/// Once the product is in the basket it shows the count rather than staying a
/// generic Add, so a second tap is an obvious increment rather than a question
/// about whether the first one worked.
class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.enabled,
    required this.inCart,
    required this.onTap,
  });

  final bool enabled;
  final int inCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final added = inCart > 0;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: !enabled
              ? c.disabled
              : added
                  ? AppColors.brandPurple
                  : AppColors.brandPurple.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10.r),
        ),
        // Once it is in the basket the button becomes the count on a filled
        // pill. No tick and no second cart glyph: a purple pill reading "2" is
        // already unambiguous, and it keeps the card free of a Material icon
        // that would sit oddly beside the Iconsax-weight set everywhere else.
        child: added
            ? Text(
                '$inCart',
                style: AppText.semibold12.copyWith(color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icons.shop.cart.svg(
                    width: 15.w,
                    height: 15.w,
                    colorFilter: ColorFilter.mode(
                      enabled ? AppColors.brandPurple : c.textMuted,
                      BlendMode.srcIn,
                    ),
                  ),
                  6.kw,
                  Text(
                    'shop_add_to_cart'.tr(),
                    style: AppText.semibold12.copyWith(
                      color: enabled ? AppColors.brandPurple : c.textMuted,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
