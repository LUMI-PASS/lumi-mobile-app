import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/shop_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/shop_state.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_product_card.dart';

/// Lumi Shop — merch, bought with coins or money or a mix of the two.
///
/// The balance sits at the top rather than at checkout because it is the
/// reason to be on this screen at all: a grid of cups is a catalog, but a grid
/// of cups above "you have 84 000 coins" is an offer.
@RoutePage()
class ShopPage extends BasePage<ShopCubit, ShopBuildable, ShopListenable> {
  const ShopPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<ShopCubit>().load();
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, ShopBuildable state) {
    final c = context.colors;
    final cubit = context.read<ShopCubit>();

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'shop_title'.tr()),
      body: RefreshIndicator(
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
                    child: _BalanceHeader(
                      available: state.wallet!.available,
                      activeOrders: state.activeOrderCount,
                      onOrders: () =>
                          context.router.push(ShopOrdersRoute()),
                    ),
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
                      // Square image plus two lines of text underneath.
                      childAspectRatio: 0.68,
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
      ),
    );
  }
}

/// "You have N coins" plus a way into the buyer's own orders.
class _BalanceHeader extends StatelessWidget {
  const _BalanceHeader({
    required this.available,
    required this.activeOrders,
    required this.onOrders,
  });

  final num available;
  final int activeOrders;
  final VoidCallback onOrders;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      children: [
        FrostedCard(
          borderRadius: BorderRadius.circular(16.r),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Assets.icons.coinLumi.image(width: 28.w, height: 28.w),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'shop_balance_label'.tr(),
                      style: AppText.regular12
                          .copyWith(color: c.textSecondary),
                    ),
                    2.kh,
                    // One coin is one so'm — so this number is also exactly
                    // how much merch it buys. No conversion is shown because
                    // there is none.
                    CoinAmount(
                      amount: available,
                      style: AppText.semibold18,
                      color: c.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        12.kh,
        GestureDetector(
          onTap: onOrders,
          child: FrostedCard(
            borderRadius: BorderRadius.circular(16.r),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'shop_my_orders'.tr(),
                    style:
                        AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                ),
                if (activeOrders > 0) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandPurple,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '$activeOrders',
                      style: AppText.semibold12
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  8.kw,
                ],
                Icon(Icons.chevron_right, color: c.textSecondary, size: 20.w),
              ],
            ),
          ),
        ),
      ],
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
