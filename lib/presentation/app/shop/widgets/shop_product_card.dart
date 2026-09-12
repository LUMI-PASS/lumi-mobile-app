import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/multi_lang.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_price.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_quantity_stepper.dart';

/// One product in the shop grid.
///
/// Price first, then the name: a shopper scanning a grid is comparing prices,
/// and the name is what they read once one of them has stopped them.
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
    this.onSetCount,
    this.inCart = 0,
  });

  final ShopProduct product;
  final VoidCallback onTap;

  /// Puts the first one in the basket. Omit it and the card is just a link —
  /// which is what the "you might also like" strips want.
  final VoidCallback? onAdd;

  /// Changes the count once it is in the basket. Zero removes the line, which
  /// is what the minus does when it is showing 1.
  final ValueChanged<int>? onSetCount;

  /// How many of this product the basket already holds. Above zero the button
  /// becomes the counter, so the card never asks "add?" about something that
  /// is already in there.
  final int inCart;

  /// Never offer more than the shop can deliver: the lower of the per-order
  /// limit and what is left on the shelf.
  int get _ceiling => product.maxPerOrder < product.available
      ? product.maxPerOrder
      : product.available;

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
                        style:
                            AppText.semibold12.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          8.kh,
          // The discount lives on the price now, not as a corner badge on the
          // photo: "−67%" over an image says a number is important without
          // saying which number, and the buyer has to look twice to pair them.
          ShopPrice(
            price: product.price,
            oldPrice: product.oldPrice,
            reserveOldPriceLine: true,
          ),
          4.kh,
          Text(
            multiLang(product.name),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.regular14.copyWith(color: c.textPrimary),
          ),
          if (onAdd != null) ...[
            8.kh,
            if (soldOut)
              _AddButton(enabled: false, onTap: () {})
            else if (inCart > 0 && onSetCount != null)
              ShopQuantityStepper(
                count: inCart,
                expanded: true,
                // At one, down is removal — the basket line goes away rather
                // than sitting there at zero.
                onDecrease: () => onSetCount!(inCart - 1),
                onIncrease:
                    inCart < _ceiling ? () => onSetCount!(inCart + 1) : null,
              )
            else
              _AddButton(enabled: true, onTap: onAdd!),
          ],
        ],
      ),
    );
  }
}

/// "Qo'shish" — the first tap only. Every tap after it is on the stepper that
/// has taken this button's place, which is why there is no count in here.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 36.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.brandPurple
              : c.control,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.icons.shop.cart.svg(
              width: 15.w,
              height: 15.w,
              colorFilter: ColorFilter.mode(
                enabled ? Colors.white : c.textMuted,
                BlendMode.srcIn,
              ),
            ),
            6.kw,
            Text(
              'shop_add_to_cart'.tr(),
              style: AppText.semibold12.copyWith(
                color: enabled ? Colors.white : c.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
