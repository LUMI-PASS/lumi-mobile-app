import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_builder.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/cart_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/shop_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/shop_state.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_product_card.dart';

/// "Mahsulotlar" — the catalog, and the first tab of the shop.
///
/// Not a BasePage, deliberately: a BasePage creates its OWN copy of the cubit,
/// and the shop shell needs the same one to draw the balance in the app bar.
/// So the shell owns the provider and this is the BaseBuilder half of what a
/// BasePage would have given us. There is no listener to lose — this screen
/// never had one.
class ShopProductsView extends StatelessWidget {
  const ShopProductsView({super.key, this.onOpenCart});

  /// Switches the shell to the basket tab. The shell owns which tab is
  /// showing, so it passes this down rather than this screen guessing — the
  /// same arrangement the basket's "browse products" link uses.
  final VoidCallback? onOpenCart;

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
  Widget build(BuildContext context) {
    return BaseBuilder<ShopCubit, ShopBuildable, ShopListenable>(
      builder: _grid,
    );
  }

  Widget _grid(BuildContext context, ShopBuildable state) {
    final cubit = context.read<ShopCubit>();
    // Watched HERE and not inside the sliver's item builder. That builder runs
    // lazily during layout, and a watch from there subscribes this element
    // from the wrong phase — it happens to work today, but the dependency
    // belongs to the build that reads it. One snapshot, read by every card.
    final cart = context.watch<CartCubit>().state;

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
                          onTap: () async {
                            final toCart = await context.router.push(
                              ShopProductRoute(
                                productId: product.id,
                                preloaded: product,
                              ),
                            );
                            if (toCart == true) onOpenCart?.call();
                          },
                          inCart: cart.countOf(product.id),
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
