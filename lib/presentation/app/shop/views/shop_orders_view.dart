import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
import 'package:lumi_pass/data/api_model/shop/shop_order.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/shop/shop_repository.dart';
import 'package:lumi_pass/presentation/app/shop/widgets/shop_status_chip.dart';

/// "Buyurtmalarim" — the buyer's merch purchases, newest first.
///
/// A view rather than a page: it is the shop shell's third tab. [justPaid] is
/// set when the buyer lands here straight from paying, and puts a "we'll call
/// you" banner above the list — a purchase should end on an explanation of
/// what happens next, not on a list.
class ShopOrdersView extends StatefulWidget {
  const ShopOrdersView({super.key, this.justPaid = false});

  final bool justPaid;

  @override
  State<ShopOrdersView> createState() => _ShopOrdersViewState();
}

class _ShopOrdersViewState extends State<ShopOrdersView> {
  List<ShopOrder> _orders = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = _orders.isEmpty);
    try {
      final page = await getIt<ShopRepository>().getOrders();
      if (!mounted) return;
      setState(() {
        _orders = page.items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return RefreshIndicator(
        color: AppColors.brandPurple,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  if (widget.justPaid) ...[
                    FrostedCard(
                      borderRadius: BorderRadius.circular(16.r),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'shop_paid_title'.tr(),
                            style: AppText.semibold16
                                .copyWith(color: c.textPrimary),
                          ),
                          6.kh,
                          Text(
                            'shop_paid_body'.tr(),
                            style: AppText.regular13
                                .copyWith(color: c.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    16.kh,
                  ],
                  if (_orders.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 64.h),
                      child: Center(
                        child: Text(
                          'shop_orders_empty'.tr(),
                          textAlign: TextAlign.center,
                          style: AppText.regular14
                              .copyWith(color: c.textSecondary),
                        ),
                      ),
                    )
                  else
                    for (final order in _orders) ...[
                      _OrderCard(
                        order: order,
                        onTap: () async {
                          await context.router
                              .push(ShopOrderRoute(orderId: order.id));
                          if (mounted) _load();
                        },
                      ),
                      12.kh,
                    ],
                ],
              ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final ShopOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final first = order.items.isNotEmpty ? order.items.first : null;
    final image = sanitizeImageUrl(first?.image);

    return GestureDetector(
      onTap: onTap,
      child: FrostedCard(
        borderRadius: BorderRadius.circular(16.r),
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 56.w,
                height: 56.w,
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
            12.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    first == null
                        ? order.code
                        : multiLang(first.name, fallback: order.code),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  2.kh,
                  Text(
                    order.itemCount > 1
                        ? '${order.code} · ${'shop_n_items'.tr(args: ['${order.itemCount}'])}'
                        : order.code,
                    style: AppText.regular12
                        .copyWith(color: c.textSecondary),
                  ),
                  6.kh,
                  ShopStatusChip(status: order.status),
                ],
              ),
            ),
            Text(
              order.totalAmount.toRawUzsPrice(),
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
