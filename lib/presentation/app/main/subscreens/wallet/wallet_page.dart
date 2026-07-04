import 'package:auto_route/annotations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/subwidgets/pocket_widget.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/about_pocket_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/cubit/wallet_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/cubit/wallet_state.dart';
import 'package:lumi_pass/presentation/app/widgets/empty_view.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class WalletPage
    extends BasePage<WalletCubit, WalletBuildable, WalletListenable> {
  const WalletPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<WalletCubit>().getWallet();
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    context.read<WalletCubit>().refreshIfLanguageChanged();
    super.onFocusGained(context);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: state.isLoading
          ? Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top + 16,
                  left: 16,
                  right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  'wallet_title'.tr().s(32).w(600),
                  24.kh,
                  Expanded(child: _WalletShimmer()),
                ],
              ),
            )
          : Stack(
              children: [
                Positioned(
                  bottom: -30,
                  left: -50,
                  child: Opacity(
                    opacity: 0.15,
                    child: Assets.icons.background.premiumMisc.svg(
                      width: 260.w,
                      height: 260.w,
                      colorFilter: ColorFilter.mode(
                        context.colors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).viewPadding.top + 16,
                      left: 16,
                      right: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      'wallet_title'.tr().s(32).w(600),
                      24.kh,

                      // Balance card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.colors.primary.withOpacity(0.08),
                              context.colors.primary.withOpacity(0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: context.colors.primary.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                'your_balance_label'.tr()
                                    .s(14)
                                    .w(500)
                                    .c(Colors.grey.shade600),
                                6.kh,
                                Row(
                                  children: [
                                    "${state.balance}".s(28).w(700),
                                    8.kw,
                                    Assets.icons.coinLumi
                                        .image(width: 32, height: 32),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      24.kh,

                      // Top up section
                      'choose_top_up'.tr().s(20).w(600),
                      16.kh,
                    ]),
                  ),
                ),

                // Tariffs grid
                if ((state.tariffs ?? []).isEmpty)
                  const SliverToBoxAdapter(child: EmptyView())
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tariff = (state.tariffs ?? [])[index];
                          return PocketWidget(
                            tariff: tariff,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return AboutPocketBottomsheet(
                                      tariff: tariff);
                                },
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                              );
                            },
                          );
                        },
                        childCount: (state.tariffs ?? []).length,
                      ),
                    ),
                  ),

                // Coin history section
                SliverPadding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      'transaction_history'.tr().s(20).w(600),
                      16.kh,
                    ]),
                  ),
                ),

                if (state.coinHistory.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.h),
                          child: 'no_transactions'.tr()
                              .s(14)
                              .w(500)
                              .c(const Color(0xFF94A3B8)),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final flow = state.coinHistory[index];
                          return _CoinHistoryItem(flow: flow);
                        },
                        childCount: state.coinHistory.length,
                      ),
                    ),
                  ),

                // Bottom padding
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h + 64.0 + MediaQuery.of(context).viewPadding.bottom),
                ),
              ],
            ),
              ],
            ),
    );
  }
}

// --- Coin history item ---

class _CoinHistoryItem extends StatelessWidget {
  const _CoinHistoryItem({required this.flow});
  final CoinFlow flow;

  @override
  Widget build(BuildContext context) {
    final type = flow.type?.toUpperCase() ?? '';
    final isIncoming = type == 'INCOMING';
    final isRefund = type == 'REFUND';
    final isPositive = isIncoming || isRefund;
    final amount = flow.amount ?? 0;
    final sign = isPositive ? '+' : '-';

    final Color color;
    final Color bgColor;
    final IconData icon;
    final String label;

    if (isRefund) {
      color = const Color(0xFF2563EB);
      bgColor = const Color(0xFFEFF6FF);
      icon = Icons.replay_rounded;
      label = 'refund'.tr();
    } else if (isIncoming) {
      color = const Color(0xFF16A34A);
      bgColor = const Color(0xFFF0FDF4);
      icon = Icons.arrow_downward_rounded;
      label = 'incoming'.tr();
    } else {
      color = const Color(0xFFEF4444);
      bgColor = const Color(0xFFFEF2F2);
      icon = Icons.arrow_upward_rounded;
      label = 'withdraw'.tr();
    }

    String formattedDate = '';
    String formattedTime = '';
    if (flow.createdAt != null) {
      try {
        final dt = DateTime.parse(flow.createdAt!);
        formattedDate = DateFormat('MMM d, yyyy').format(dt);
        formattedTime = DateFormat('h:mm a').format(dt);
      } catch (_) {
        formattedDate = flow.createdAt ?? '';
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 20.w),
              ),
            ),
            12.kw,
            // Date + time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  4.kh,
                  Text(
                    '$formattedDate  •  $formattedTime',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            // Amount
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$sign$amount',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                4.kw,
                Assets.icons.coinLumi.image(width: 18.w, height: 18.h),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Shimmer loading ---

class _WalletShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance shimmer
            Container(
              width: double.infinity,
              height: 80.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            24.kh,
            Container(width: 160.w, height: 20.h, color: Colors.white),
            16.kh,
            // Grid shimmer
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
            24.kh,
            Container(width: 180.w, height: 20.h, color: Colors.white),
            16.kh,
            // History shimmer
            ...List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Container(
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
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
