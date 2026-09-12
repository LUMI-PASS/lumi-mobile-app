import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/cart_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/shop_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/shop_state.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_product_card.dart';

/// "Mahsulotlar" — the catalog, and the first tab of the shop.
///
/// The balance sits above the grid rather than waiting until checkout because
/// it is the reason to be on this screen at all: a grid of cups is a catalog,
/// but a grid of cups above "you have 84 000 coins" is an offer.
class ShopProductsView
    extends BasePage<ShopCubit, ShopBuildable, ShopListenable> {
  const ShopProductsView({super.key});

  @override
  void init(BuildContext context) {
    context.read<ShopCubit>().load();
    super.init(context);
  }

  /// How tall one product tile has to be.
  ///
  /// Measured rather than expressed as a `childAspectRatio`, because a ratio
  /// scales the WHOLE tile with its width: the block under the image is a
  /// fixed stack — a price, its struck-through original, two lines of name and
  /// the Add button — and a ratio makes it grow on a wide phone and clip on a
  /// narrow one. That is what overflowed when the Add button was added.
  ///
  /// It follows the OS text-size setting too, so turning up the font moves the
  /// tile down instead of clipping the button off the bottom of it.
  double _tileExtent(BuildContext context) {
    const nameLines = 2;
    const lineHeight = 1.4; // AppText's default, see AppText._s.

    final scaler = MediaQuery.textScalerOf(context);
    // The grid's own padding (16 each side) and the gap between the columns.
    final available = MediaQuery.sizeOf(context).width - 32.w - 12.w;
    final image = available / 2; // The card's image is square.

    // The old-price line is reserved on every card, discounted or not, so the
    // Add buttons line up across a row. See ShopPrice.reserveOldPriceLine.
    final price = scaler.scale(16) * lineHeight;
    final oldPrice = scaler.scale(13) * lineHeight;
    final name = scaler.scale(14) * lineHeight * nameLines;

    // image + gap + price + old price + gap + name + gap + Add button. The
    // extra pixel absorbs the rounding a fractional device pixel ratio
    // introduces — cheaper than a one-pixel overflow stripe.
    return image + 8.h + price + oldPrice + 4.h + name + 8.h + 36.h + 1;
  }

  @override
  Widget builder(BuildContext context, ShopBuildable state) {
    final cubit = context.read<ShopCubit>();

    return RefreshIndicator(
        color: AppColors.brandPurple,
        onRefresh: cubit.refresh,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Within one screen of the bottom, start the next page. The cubit
            // guards against the repeat firing a scroll produces per frame.
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 400) {
              cubit.loadMore();
            }
            return false;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (state.wallet != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                    child: _BalanceHeader(available: state.wallet!.available),
                  ),
                ),

              if (state.isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.hasError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Message(
                    title: 'shop_error_title'.tr(),
                    body: 'shop_error_body'.tr(),
                    onRetry: cubit.refresh,
                  ),
                )
              else if (state.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Message(
                    title: 'shop_empty_title'.tr(),
                    body: 'shop_empty_body'.tr(),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  sliver: SliverGrid(
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 16.h,
                      mainAxisExtent: _tileExtent(context),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) {
                        final product = state.products[index];
                        return ShopProductCard(
                          product: product,
                          onTap: () => context.router.push(
                            ShopProductRoute(
                              productId: product.id,
                              preloaded: product,
                            ),
                          ),
                          inCart: context
                              .watch<CartCubit>()
                              .state
                              .countOf(product.id),
                          onAdd: () =>
                              context.read<CartCubit>().add(product),
                          onSetCount: (next) => context
                              .read<CartCubit>()
                              .setCount(product, next),
                        );
                      },
                      childCount: state.products.length,
                    ),
                  ),
                ),

              if (state.isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
            ],
          ),
      ),
    );
  }
}

/// "You have N coins" — the reason the grid below is an offer, not a catalog.
class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({required this.available});

  final num available;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return FrostedCard(
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      // ONE coin mark, not two. A leading coin icon next to a CoinAmount —
      // which carries the mark itself — reads as decoration and makes the row
      // look like it is quoting two different things. The amount keeps the
      // mark, since that is the rule everywhere else in the app.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'shop_balance_label'.tr(),
            style: AppText.regular12.copyWith(color: c.textSecondary),
          ),
          2.kh,
          // One coin is one so'm — so this number is also exactly how much
          // merch it buys. No conversion is shown because there is none.
          CoinAmount(
            amount: available,
            style: AppText.semibold18,
            color: c.textPrimary,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title, required this.body, this.onRetry});

  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.semibold16.copyWith(color: c.textPrimary),
          ),
          8.kh,
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
          if (onRetry != null) ...[
            16.kh,
            TextButton(
              onPressed: onRetry,
              child: Text('retry'.tr()),
            ),
          ],
        ],
      ),
    );
  }
}
