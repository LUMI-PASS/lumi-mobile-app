import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/multi_lang.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/shop/shop_order.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/shop/shop_repository.dart';
import 'package:lumi_pass/presentation/app/shop/shop_orders_page.dart';

/// One merch order: what was bought, where it is going, and where it has got
/// to.
///
/// The delivery promise is stated as a date rather than as "3 days", because
/// three days from the moment of payment is not three days from now, and the
/// question this screen answers is "when will it arrive".
@RoutePage()
class ShopOrderPage extends StatefulWidget {
  const ShopOrderPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<ShopOrderPage> createState() => _ShopOrderPageState();
}

class _ShopOrderPageState extends State<ShopOrderPage> {
  ShopOrder? _order;
  bool _loading = true;
  bool _canceling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final order = await getIt<ShopRepository>().getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('shop_cancel_title'.tr()),
        content: Text('shop_cancel_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('no'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('yes'.tr()),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _canceling = true);
    try {
      await getIt<ShopRepository>().cancelOrder(widget.orderId);
      await _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('shop_cancel_failed'.tr())),
      );
    } finally {
      if (mounted) setState(() => _canceling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final order = _order;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: order?.code ?? 'shop_my_orders'.tr()),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? Center(
                  child: Text(
                    'shop_error_title'.tr(),
                    style:
                        AppText.semibold16.copyWith(color: c.textPrimary),
                  ),
                )
              : ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                  children: [
                    Row(
                      children: [
                        ShopStatusChip(status: order.status),
                        const Spacer(),
                        if (order.promisedBy != null &&
                            !order.status.isFinished)
                          Text(
                            'shop_deliver_by'.tr(
                              args: [_formatDate(order.promisedBy!)],
                            ),
                            style: AppText.regular12
                                .copyWith(color: c.textSecondary),
                          ),
                      ],
                    ),
                    20.kh,

                    _Section('shop_items_title'.tr()),
                    8.kh,
                    FrostedCard(
                      borderRadius: BorderRadius.circular(16.r),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          for (final item in order.items) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    multiLang(item.name),
                                    style: AppText.medium14
                                        .copyWith(color: c.textPrimary),
                                  ),
                                ),
                                Text(
                                  '× ${item.count}',
                                  style: AppText.regular13
                                      .copyWith(color: c.textSecondary),
                                ),
                                12.kw,
                                Text(
                                  item.lineTotal.toRawUzsPrice(),
                                  style: AppText.semibold14
                                      .copyWith(color: c.textPrimary),
                                ),
                              ],
                            ),
                            12.kh,
                          ],
                          Divider(color: c.divider, height: 1),
                          12.kh,
                          // How it was actually funded, not just what it cost.
                          // "I paid with coins" is what a buyer remembers, and
                          // it should be here rather than only on our side.
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'shop_total'.tr(),
                                  style: AppText.semibold14
                                      .copyWith(color: c.textPrimary),
                                ),
                              ),
                              Text(
                                order.totalAmount.toRawUzsPrice(),
                                style: AppText.semibold14
                                    .copyWith(color: c.textPrimary),
                              ),
                            ],
                          ),
                          if (order.walletAmount > 0) ...[
                            8.kh,
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'shop_paid_with_coins'.tr(),
                                    style: AppText.regular13.copyWith(
                                      color: c.textSecondary,
                                    ),
                                  ),
                                ),
                                CoinAmount(
                                  amount: order.walletAmount,
                                  style: AppText.semibold14,
                                  color: AppColors.green,
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (order.delivery != null) ...[
                      20.kh,
                      _Section('shop_delivery_title'.tr()),
                      8.kh,
                      FrostedCard(
                        borderRadius: BorderRadius.circular(16.r),
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.delivery!.address,
                              style: AppText.medium14
                                  .copyWith(color: c.textPrimary),
                            ),
                            6.kh,
                            Text(
                              order.delivery!.contactPhone,
                              style: AppText.regular13
                                  .copyWith(color: c.textSecondary),
                            ),
                            if ((order.delivery!.comment ?? '')
                                .isNotEmpty) ...[
                              6.kh,
                              Text(
                                order.delivery!.comment!,
                                style: AppText.regular13
                                    .copyWith(color: c.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    if (order.timeline.isNotEmpty) ...[
                      20.kh,
                      _Section('shop_history_title'.tr()),
                      8.kh,
                      FrostedCard(
                        borderRadius: BorderRadius.circular(16.r),
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            for (final event in order.timeline) ...[
                              Row(
                                children: [
                                  ShopStatusChip(status: event.status),
                                  const Spacer(),
                                  if (event.at != null)
                                    Text(
                                      _formatDate(event.at!),
                                      style: AppText.regular12
                                          .copyWith(color: c.textSecondary),
                                    ),
                                ],
                              ),
                              8.kh,
                            ],
                          ],
                        ),
                      ),
                    ],

                    if (order.isCancelable) ...[
                      24.kh,
                      SizedBox(
                        height: 48.h,
                        child: OutlinedButton(
                          onPressed: _canceling ? null : _cancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'shop_cancel_order'.tr(),
                            style: AppText.semibold14
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ),
                    ] else if (!order.status.isFinished) ...[
                      24.kh,
                      // Past the point where a button can undo it. Saying so is
                      // better than hiding the option and leaving the buyer
                      // hunting for it.
                      Text(
                        'shop_cancel_call_us'.tr(),
                        textAlign: TextAlign.center,
                        style: AppText.regular12
                            .copyWith(color: c.textSecondary),
                      ),
                    ],
                  ],
                ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.'
        '${local.month.toString().padLeft(2, '0')}.${local.year}';
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style:
            AppText.semibold16.copyWith(color: context.colors.textPrimary),
      );
}
