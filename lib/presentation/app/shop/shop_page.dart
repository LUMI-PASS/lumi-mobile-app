import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/aurora_background.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/cart_cubit.dart';
import 'package:lumi_pass/common/base/base_builder.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/shop_cubit.dart';
import 'package:lumi_pass/presentation/app/shop/cubit/shop_state.dart';
import 'package:lumi_pass/presentation/app/shop/views/shop_cart_view.dart';
import 'package:lumi_pass/presentation/app/shop/views/shop_orders_view.dart';
import 'package:lumi_pass/presentation/app/shop/views/shop_products_view.dart';

/// Lumi Shop — merch, bought with coins or money or a mix of the two.
///
/// Three tabs, which is the shape every store in the region uses and therefore
/// the one that needs no explaining: the catalog, the basket, and the buyer's
/// own orders.
///
/// An [IndexedStack] rather than swapping the body: the catalog holds a
/// scroll position and a loaded page of products, and rebuilding it every time
/// somebody checks their basket would throw both away.
///
/// The basket cubit is provided HERE, from the singleton, so the badge on the
/// tab, the buttons in the grid and the checkout all read one basket. A
/// per-screen copy would leave the badge permanently at zero.
@RoutePage()
class ShopPage extends StatefulWidget {
  const ShopPage({super.key, this.initialTab = 0, this.justPaid = false});

  /// 0 catalog · 1 basket · 2 orders. Deep links and the post-payment redirect
  /// both land on a specific tab.
  final int initialTab;

  /// Arrived straight from paying — the orders tab explains what happens next.
  final bool justPaid;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  late int _tab = widget.initialTab.clamp(0, 2);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CartCubit>.value(value: getIt<CartCubit>()),
        // Owned by the shell, not by the catalog tab, because the app bar
        // draws the balance from it and the app bar sits above the tab. Loaded
        // here for the same reason — the balance has to arrive whichever tab
        // the shop opened on.
        BlocProvider<ShopCubit>(create: (_) => getIt<ShopCubit>()..load()),
      ],
      child: Builder(
        builder: (context) {
          final cartCount = context.watch<CartCubit>().state.count;

          return AuroraBackground(
            child: Scaffold(
              // The aurora behind it is the page background.
              backgroundColor: Colors.transparent,
              appBar: BaseAppBar(
                title: _titleFor(_tab, cartCount),
                // Back only on the catalog. The basket and the orders list are
                // tabs of this same screen, not pushes onto it — a back arrow
                // there would offer to leave the shop, which is not what the
                // arrow above a basket reads as.
                leading: _tab == 0 ? null : const SizedBox.shrink(),
                // Only over the catalog: the balance answers "what can I
                // afford?", which is a question the basket and the orders list
                // have already stopped asking.
                actions: _tab == 0 ? const [_CoinBalanceChip()] : null,
              ),
              body: IndexedStack(
                index: _tab,
                children: [
                  ShopProductsView(onOpenCart: () => setState(() => _tab = 1)),
                  ShopCartView(onBrowse: () => setState(() => _tab = 0)),
                  ShopOrdersView(justPaid: widget.justPaid),
                ],
              ),
              bottomNavigationBar: _ShopNavBar(
                index: _tab,
                cartCount: cartCount,
                onChanged: (next) => setState(() => _tab = next),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The basket's title counts what is in it — "3 ta tovar savatda" — because
  /// a screen that already shows the things does not need to be labelled
  /// "Cart", and the count is the one fact worth putting in a header.
  String _titleFor(int tab, int cartCount) => switch (tab) {
        1 when cartCount > 0 =>
          'shop_cart_title_n'.tr(args: ['$cartCount']),
        1 => 'shop_tab_cart'.tr(),
        2 => 'shop_my_orders'.tr(),
        _ => 'shop_title'.tr(),
      };
}

class _ShopNavBar extends StatelessWidget {
  const _ShopNavBar({
    required this.index,
    required this.cartCount,
    required this.onChanged,
  });

  final int index;
  final int cartCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    // No fill and no top hairline: the aurora wash runs straight through the
    // nav, so the bar reads as part of the page rather than a tray glued to
    // the bottom of it.
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 60.h,
        child: Row(
          children: [
            _NavItem(
              icon: Assets.icons.shop.products,
              label: 'shop_tab_products'.tr(),
              selected: index == 0,
              onTap: () => onChanged(0),
            ),
            _NavItem(
              icon: Assets.icons.shop.cart,
              label: 'shop_tab_cart'.tr(),
              selected: index == 1,
              // Units rather than lines: two cups and a pen reads as 3,
              // which is what the buyer put in.
              badge: cartCount,
              onTap: () => onChanged(1),
            ),
            _NavItem(
              icon: Assets.icons.shop.orders,
              label: 'shop_tab_orders'.tr(),
              selected: index == 2,
              onTap: () => onChanged(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final SvgGenImage icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tint = selected ? AppColors.brandPurple : c.textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Tinted rather than swapped for a filled variant: the main
                // nav ships paired assets per tab, this one has a single glyph
                // per tab and leans on colour alone. See the note in the
                // commit — six files for three tabs was not worth it here.
                icon.svg(
                  width: 22.w,
                  height: 22.w,
                  colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
                ),
                if (badge > 0)
                  Positioned(
                    right: -8.w,
                    top: -4.h,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 1.h,
                      ),
                      constraints: BoxConstraints(minWidth: 16.w),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$badge',
                        textAlign: TextAlign.center,
                        style: AppText.bold10
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            4.kh,
            Text(
              label,
              style: AppText.medium10.copyWith(color: tint),
            ),
          ],
        ),
      ),
    );
  }
}

/// The buyer's coin balance, in the corner of the shop's app bar.
///
/// It used to be a card above the grid. In the app bar it survives the scroll,
/// which is the whole point of it: "what can I afford?" is a question that
/// comes up at the tenth product, not the first.
///
/// Nothing is drawn for a guest, or before the balance lands — "0 coins" and
/// "we don't know yet" are different claims, and only one of them is a reason
/// to stop shopping.
class _CoinBalanceChip extends StatelessWidget {
  const _CoinBalanceChip();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return BaseBuilder<ShopCubit, ShopBuildable, ShopListenable>(
      properties: (state) => [state.wallet],
      builder: (context, state) {
        final wallet = state.wallet;
        if (wallet == null) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Center(
            child: GestureDetector(
              // Straight to the wallet — the balance is also where somebody
              // goes when it is not big enough yet.
              onTap: () => context.router.push(const WalletRoute()),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: c.control,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: CoinAmount(
                  amount: wallet.available,
                  style: AppText.semibold14,
                  color: c.textPrimary,
                  iconSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
