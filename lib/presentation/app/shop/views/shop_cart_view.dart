import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/multi_lang.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/shop/shop_cart.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/cart_cubit.dart';

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
              Icon(
                Icons.shopping_cart_outlined,
                size: 48.w,
                color: c.textPlaceholder,
              ),
              16.kh,
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
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            itemCount: cart.lines.length,
            separatorBuilder: (_, __) => 12.kh,
            itemBuilder: (_, index) => _CartLineTile(line: cart.lines[index]),
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

    // Never offer more than the shop can actually deliver: the lower of the
    // per-order limit and what is left on the shelf.
    final ceiling = product.maxPerOrder < product.available
        ? product.maxPerOrder
        : product.available;

    return FrostedCard(
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.all(12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.router.push(
              ShopProductRoute(productId: product.id, preloaded: product),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 64.w,
                height: 64.w,
                child: image == null
                    ? Container(color: c.surface)
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: c.surface),
                      ),
              ),
            ),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        multiLang(product.name),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppText.semibold14.copyWith(color: c.textPrimary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => cubit.remove(product.id),
                      child: Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Icon(
                          Icons.close,
                          size: 18.w,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                4.kh,
                Text(
                  line.lineTotal.toRawUzsPrice(),
                  style: AppText.semibold14.copyWith(color: c.textPrimary),
                ),
                8.kh,
                Row(
                  children: [
                    _StepButton(
                      icon: Icons.remove,
                      // At one, the next step down is removal — and that is
                      // what the ✕ is for, so this simply stops.
                      enabled: line.count > 1,
                      onTap: () =>
                          cubit.setCount(product, line.count - 1),
                    ),
                    SizedBox(
                      width: 40.w,
                      child: Text(
                        '${line.count}',
                        textAlign: TextAlign.center,
                        style: AppText.semibold14
                            .copyWith(color: c.textPrimary),
                      ),
                    ),
                    _StepButton(
                      icon: Icons.add,
                      enabled: line.count < ceiling,
                      onTap: () =>
                          cubit.setCount(product, line.count + 1),
                    ),
                    const Spacer(),
                    if (line.count >= ceiling)
                      Text(
                        'shop_cart_max'.tr(args: ['$ceiling']),
                        style: AppText.regular12
                            .copyWith(color: AppColors.warning),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: c.border),
        ),
        child: Icon(
          icon,
          size: 16.w,
          color: enabled ? c.textPrimary : c.disabled,
        ),
      ),
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

    return Container(
      decoration: BoxDecoration(
        color: c.bottomBar,
        border: Border(top: BorderSide(color: c.divider)),
      ),
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'shop_cart_items'.tr(args: ['${cart.count}']),
                    style: AppText.regular13.copyWith(color: c.textSecondary),
                  ),
                ),
                Text(
                  cart.total.toRawUzsPrice(),
                  style: AppText.semibold18.copyWith(color: c.textPrimary),
                ),
              ],
            ),
            12.kh,
            SizedBox(
              width: double.infinity,
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
          ],
        ),
      ),
    );
  }
}
