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
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/multi_lang.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/shop/shop_repository.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/cart_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_price.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_quantity_stepper.dart';

/// One product, and the decision to buy it.
///
/// Not a BasePage: there is one read and one local counter here, and a cubit
/// for that would be more plumbing than screen. The product usually arrives
/// [preloaded] from the grid, so the fetch is a refresh of the stock figure
/// rather than a load — what was on the card a minute ago may already be gone.
@RoutePage()
class ShopProductPage extends StatefulWidget {
  const ShopProductPage({
    super.key,
    required this.productId,
    this.preloaded,
  });

  final String productId;

  /// What the grid already knew. Renders immediately so tapping a card does
  /// not open a spinner over information the app is already holding.
  final ShopProduct? preloaded;

  @override
  State<ShopProductPage> createState() => _ShopProductPageState();
}

class _ShopProductPageState extends State<ShopProductPage> {
  late ShopProduct? _product = widget.preloaded;
  bool _loading = false;
  bool _failed = false;
  int _count = 1;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _product == null;
      _failed = false;
    });
    try {
      final fresh = await getIt<ShopRepository>().getProduct(widget.productId);
      if (!mounted) return;
      setState(() {
        _product = fresh;
        _loading = false;
        // The buyer may have been sitting on this screen while stock moved.
        // Clamp rather than letting checkout refuse an impossible quantity.
        _count = _count.clamp(1, fresh.available > 0 ? fresh.available : 1);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        // A failed refresh with something already on screen is not an error
        // state — the buyer keeps what the grid gave them.
        _failed = _product == null;
      });
    }
  }

  /// The ceiling on the stepper: never more than is left, never more than the
  /// per-order limit.
  int get _maxCount {
    final product = _product;
    if (product == null) return 1;
    final limit = product.maxPerOrder < product.available
        ? product.maxPerOrder
        : product.available;
    return limit < 1 ? 1 : limit;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final product = _product;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'shop_title'.tr()),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _failed || product == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'shop_error_title'.tr(),
                        style: AppText.semibold16
                            .copyWith(color: c.textPrimary),
                      ),
                      12.kh,
                      TextButton(
                        onPressed: _load,
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                )
              : _content(context, product),
      bottomNavigationBar:
          product == null ? null : _buyBar(context, product),
    );
  }

  Widget _content(BuildContext context, ShopProduct product) {
    final c = context.colors;
    final images = product.images.isEmpty ? [''] : product.images;
    final description = multiLang(product.description);

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 320.h,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _imageIndex = i),
              itemBuilder: (_, index) {
                final url = sanitizeImageUrl(images[index]);
                if (url == null) return Container(color: c.surface);
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(color: c.surface),
                );
              },
            ),
          ),
          if (images.length > 1) ...[
            8.kh,
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  images.length,
                  (i) => Container(
                    width: 6.w,
                    height: 6.w,
                    margin: EdgeInsets.symmetric(horizontal: 3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _imageIndex
                          ? AppColors.brandPurple
                          : c.divider,
                    ),
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  multiLang(product.name),
                  style: AppText.semibold18.copyWith(color: c.textPrimary),
                ),
                8.kh,
                ShopPrice(
                  price: product.price,
                  oldPrice: product.oldPrice,
                  large: true,
                ),
                8.kh,
                // The one place the coin mark belongs on a price: it is not a
                // second price, it is the same number said again — which is
                // exactly the point being made.
                Row(
                  children: [
                    Assets.icons.coinLumi.image(width: 16.w, height: 16.w),
                    6.kw,
                    Expanded(
                      child: Text(
                        'shop_pay_with_coins_hint'.tr(),
                        style: AppText.regular12
                            .copyWith(color: c.textSecondary),
                      ),
                    ),
                  ],
                ),
                if (product.inStock && product.available <= 3) ...[
                  12.kh,
                  Text(
                    'shop_only_n_left'
                        .tr(args: ['${product.available}']),
                    style: AppText.medium13
                        .copyWith(color: AppColors.warning),
                  ),
                ],
                if (description.isNotEmpty) ...[
                  20.kh,
                  Text(
                    description,
                    style:
                        AppText.regular14.copyWith(color: c.textSecondary),
                  ),
                ],
                20.kh,
                if (product.inStock)
                  Row(
                    children: [
                      Text(
                        'shop_quantity'.tr(),
                        style: AppText.semibold14
                            .copyWith(color: c.textPrimary),
                      ),
                      const Spacer(),
                      ShopQuantityStepper(
                        count: _count,
                        // One is the floor here, unlike in the basket: this
                        // screen has nothing to remove, it is deciding how
                        // many to add.
                        onDecrease: _count > 1
                            ? () => setState(() => _count -= 1)
                            : null,
                        onIncrease: _count < _maxCount
                            ? () => setState(() => _count += 1)
                            : null,
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

  Widget _buyBar(BuildContext context, ShopProduct product) {
    final c = context.colors;
    final soldOut = !product.inStock;

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
      child: SizedBox(
        height: 52.h,
        child: ElevatedButton(
          onPressed: soldOut
              ? null
              : () {
                  context.read<CartCubit>().add(product, count: _count);
                  // Straight back to where they were browsing. Jumping them to
                  // the basket would interrupt a shopping trip that is very
                  // often not over — the badge already says it worked.
                  context.router.maybePop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor:
                soldOut ? c.disabled : AppColors.brandPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: Text(
            soldOut
                ? 'shop_sold_out'.tr()
                : 'shop_add_for'
                    .tr(args: [(product.price * _count).toRawUzsPrice()]),
            style: AppText.semibold16.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
