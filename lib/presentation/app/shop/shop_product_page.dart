import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/multi_lang.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
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
                        style: TextButton.styleFrom(
                          foregroundColor: context.colors.primary,
                        ),
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
                if (product.inStock && product.available <= 3) ...[
                  10.kh,
                  Text(
                    'shop_only_n_left'.tr(args: ['${product.available}']),
                    style: AppText.medium13.copyWith(color: AppColors.warning),
                  ),
                ],
                if (product.tags.isNotEmpty) ...[
                  12.kh,
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      for (final tag in product.tags) _Tag(label: tag),
                    ],
                  ),
                ],
                if (description.isNotEmpty) ...[
                  24.kh,
                  Text(
                    'shop_about_title'.tr(),
                    style: AppText.semibold16.copyWith(color: c.textPrimary),
                  ),
                  8.kh,
                  Text(
                    description,
                    style: AppText.regular14.copyWith(
                      color: c.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
                24.kh,
                Text(
                  'shop_details_title'.tr(),
                  style: AppText.semibold16.copyWith(color: c.textPrimary),
                ),
                10.kh,
                _DetailsCard(product: product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// The buy bar reads the BASKET, not a counter of its own.
  ///
  /// It used to keep a private `_count` that always started at 1. Open a
  /// product already sitting in the basket twice over and this screen said
  /// "1", while the button underneath it — which adds to what is already
  /// there — would have made it three. The label and the effect disagreed,
  /// and the basket was right both times. So there is no second number here
  /// any more: what this screen shows is what the basket holds.
  Widget _buyBar(BuildContext context, ShopProduct product) {
    final c = context.colors;

    if (!product.inStock) {
      return _bar(
        child: SizedBox(
          height: 52.h,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: c.disabled,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              'shop_sold_out'.tr(),
              style: AppText.semibold16.copyWith(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final count = context.watch<CartCubit>().state.countOf(product.id);

    if (count == 0) {
      return _bar(
        child: SizedBox(
          height: 52.h,
          child: ElevatedButton(
            onPressed: () => context.read<CartCubit>().add(product),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              'shop_add_for'.tr(args: [product.price.toRawUzsPrice()]),
              style: AppText.semibold16.copyWith(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final cart = context.read<CartCubit>();

    return _bar(
      child: Row(
        children: [
          ShopQuantityStepper(
            count: count,
            // Down from one takes it out of the basket, exactly as it does on
            // the card and in the basket itself. The bar then flips back to
            // offering to add it.
            onDecrease: () => cart.setCount(product, count - 1),
            onIncrease:
                count < _maxCount ? () => cart.setCount(product, count + 1) : null,
          ),
          12.kw,
          Expanded(
            child: SizedBox(
              height: 52.h,
              child: ElevatedButton(
                // Popping with `true` is how the shell learns to switch to the
                // basket tab — this screen is pushed over it and does not own
                // which tab is showing.
                onPressed: () => context.router.maybePop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'shop_go_to_cart'
                      .tr(args: [(product.price * count).toRawUzsPrice()]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.semibold16.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar({required Widget child}) => SafeArea(
        minimum: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: child,
      );
}

/// Everything the shop actually knows about a product, said plainly.
///
/// Only real fields — availability, how many have gone, the per-order
/// ceiling, and the delivery promise the backend makes when it stamps
/// `promised_by` on the order. Nothing is invented to fill the card out: a
/// row with no answer is simply not drawn.
class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.product});

  final ShopProduct product;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final rows = <({String label, String value, Color? tint})>[
      (
        label: 'shop_availability'.tr(),
        value: product.inStock
            ? 'shop_n_items'.tr(args: ['${product.available}'])
            : 'shop_sold_out'.tr(),
        tint: product.inStock ? null : AppColors.error,
      ),
      if (product.soldCount > 0)
        (
          label: 'shop_sold_label'.tr(),
          value: 'shop_n_items'.tr(args: ['${product.soldCount}']),
          tint: null,
        ),
      (
        label: 'shop_max_per_order'.tr(),
        value: 'shop_n_items'.tr(args: ['${product.maxPerOrder}']),
        tint: null,
      ),
      (
        label: 'shop_delivery_title'.tr(),
        value: 'shop_delivery_days'.tr(),
        tint: null,
      ),
    ];

    return FrostedCard(
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: c.divider),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].label,
                      style:
                          AppText.regular14.copyWith(color: c.textSecondary),
                    ),
                  ),
                  8.kw,
                  Text(
                    rows[i].value,
                    style: AppText.medium14
                        .copyWith(color: rows[i].tint ?? c.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A product tag, as the adminka typed it. Not translated — these are free
/// text on the product, not a closed vocabulary the app could map.
class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: AppText.medium12.copyWith(color: c.textSecondary),
      ),
    );
  }
}
