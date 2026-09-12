import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/multi_lang.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/shop/shop_cart.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/cart_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_price.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_quantity_stepper.dart';

/// "Savatcha" — the basket, and the shop's second tab.
///
/// The counts here are the ones the checkout will send, but the PRICES are
/// only a preview: the server re-prices the basket when the order is created
/// and its answer is what the buyer pays. That is why nothing on this screen
/// is stored and sent as an amount — only product ids and counts travel.
class ShopCartView extends StatelessWidget {
  const ShopCartView({super.key, this.onBrowse});

  /// Sends an empty basket back to the catalog tab. The shell owns which tab
  /// is showing, so it passes this down rather than this screen guessing.
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cart = context.watch<CartCubit>().state;

    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.mascot.mascotCategories.image(
                width: 140.w,
                height: 140.w,
                fit: BoxFit.contain,
              ),
              12.kh,
              Text(
                'shop_cart_empty_title'.tr(),
                textAlign: TextAlign.center,
                style: AppText.semibold16.copyWith(color: c.textPrimary),
              ),
              8.kh,
              Text(
                'shop_cart_empty_body'.tr(),
                textAlign: TextAlign.center,
                style: AppText.regular13.copyWith(color: c.textSecondary),
              ),
              if (onBrowse != null) ...[
                16.kh,
                TextButton(
                  onPressed: onBrowse,
                  style: TextButton.styleFrom(foregroundColor: c.primary),
                  child: Text('shop_cart_browse'.tr()),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
            children: [
              for (final line in cart.lines) ...[
                _CartLineTile(line: line),
                12.kh,
              ],
              8.kh,
              _OrderSummary(cart: cart),
            ],
          ),
        ),
        _CheckoutBar(cart: cart),
      ],
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({required this.line});

  final ShopCartLine line;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<CartCubit>();
    final product = line.product;
    final image = sanitizeImageUrl(product.image);

    // Stock is the only ceiling; per-order limits are gone.
    final ceiling = product.available;

    return FrostedCard(
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.router.push(
                  ShopProductRoute(productId: product.id, preloaded: product),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 72.w,
                    height: 72.w,
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
              ),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The line total, not the unit price: this is what this
                    // row contributes to the bill, and the per-unit figure is
                    // spelled out underneath for anyone doing the arithmetic.
                    ShopPrice(
                      price: line.lineTotal,
                      oldPrice: line.lineSubtotal,
                      coinPrice: line.lineCoinTotal,
                      // Full "110 000 so'm" struck through on the line below,
                      // so the row states two prices rather than a price and
                      // a loose number.
                      oldPriceWithUnit: true,
                    ),
                    4.kh,
                    Text(
                      multiLang(product.name),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.regular14.copyWith(color: c.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.kh,
          Row(
            children: [
              Expanded(
                child: Text(
                  'shop_price_each'.tr(args: [product.price.toRawUzsPrice()]),
                  style: AppText.regular13.copyWith(color: c.textSecondary),
                ),
              ),
              ShopQuantityStepper(
                count: line.count,
                // Down from one empties the line. It is the only way out of
                // the basket now that the ✕ is gone, and it is the one every
                // shop in the region uses.
                onDecrease: () => cubit.setCount(product, line.count - 1),
                onIncrease: line.count < ceiling
                    ? () => cubit.setCount(product, line.count + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Buyurtmangiz" — the bill, itemised.
///
/// Worth its own card because the number in the bottom bar is the only one a
/// buyer is asked to accept, and a total that appears without its parts is a
/// total nobody checks.
class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.cart});

  final ShopCart cart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return FrostedCard(
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'shop_cart_summary'.tr(),
            style: AppText.bold18.copyWith(color: c.textPrimary),
          ),
          16.kh,
          _SummaryRow(
            label: 'shop_n_items'.tr(args: ['${cart.count}']),
            value: cart.subtotal.toRawUzsPrice(),
          ),
          if (cart.hasDiscount) ...[
            12.kh,
            _SummaryRow(
              label: 'shop_cart_discounts'.tr(),
              value: '- ${cart.discount.toRawUzsPrice()}',
              valueColor: AppColors.brandPink,
            ),
          ],
          16.kh,
          Divider(height: 1, color: c.divider),
          16.kh,
          Row(
            children: [
              Expanded(
                child: Text(
                  'shop_total'.tr(),
                  style:
                      AppText.semibold16.copyWith(color: AppColors.brandPurple),
                ),
              ),
              Text(
                cart.total.toRawUzsPrice(),
                style: AppText.bold16.copyWith(color: AppColors.brandPurple),
              ),
            ],
          ),
          // Both bills, because the buyer has not chosen yet and the two are
          // alternatives rather than parts of one sum. The word for it is
          // "or", which is why this row is labelled and not just appended.
          if (cart.coinTotal > 0) ...[
            10.kh,
            Row(
              children: [
                Expanded(
                  child: Text(
                    'shop_or_with_coins'.tr(),
                    style: AppText.regular14.copyWith(color: c.textSecondary),
                  ),
                ),
                CoinAmount(
                  amount: cart.coinTotal,
                  style: AppText.semibold16,
                  color: c.textPrimary,
                  iconSize: 18,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppText.regular14.copyWith(color: c.textPrimary),
          ),
        ),
        Text(
          value,
          style: AppText.medium14.copyWith(color: valueColor ?? c.textPrimary),
        ),
      ],
    );
  }
}

/// The total and the way out of the basket.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart});

  final ShopCart cart;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // Only the hairline, no fill: the page background runs under the bar, and
    // an opaque tray here would cut the page in half right above the nav.
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: Row(
          children: [
            // The total repeated beside the button, not only in the summary
            // above it: at the moment of committing, the amount should be
            // under the thumb that is committing to it.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  cart.total.toRawUzsPrice(),
                  style: AppText.bold18.copyWith(color: AppColors.brandPurple),
                ),
                if (cart.coinTotal > 0)
                  CoinAmount(
                    amount: cart.coinTotal,
                    style: AppText.regular12,
                    color: c.textSecondary,
                    iconSize: 12,
                  )
                else
                  Text(
                    'shop_n_items'.tr(args: ['${cart.count}']),
                    style: AppText.regular12.copyWith(color: c.textSecondary),
                  ),
              ],
            ),
            16.kw,
            Expanded(
              child: SizedBox(
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () =>
                      context.router.push(const ShopCheckoutRoute()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'shop_checkout_cta'.tr(),
                    style: AppText.semibold16.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
