import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';

/// Outcome rendered by [BookingCompletePage] — matches the three Figma
/// "Детали брони" result frames (success / pending / failed).
enum BookingResultStatus { paid, pending, failed }

/// One row of the order-details breakdown card. [value] is pre-formatted
/// (price or date). [negative] paints it red (discounts). [iconAsset] is an
/// optional leading detail-dir SVG.
class OrderLine {
  const OrderLine({
    required this.label,
    required this.value,
    this.iconAsset,
    this.negative = false,
  });

  final String label;
  final String value;
  final String? iconAsset;
  final bool negative;
}

/// Order-status screen (Figma `Детали брони`). Renders the success, pending or
/// failed variant plus the order-details breakdown card when [result] is given.
@RoutePage()
class BookingCompletePage extends StatefulWidget {
  const BookingCompletePage({
    super.key,
    this.status = BookingResultStatus.paid,
    this.result,
    this.lines = const [],
  });

  final BookingResultStatus status;

  /// Checkout result — supplies the order id (badge) and grand total. When null
  /// the order-details card is hidden (e.g. legacy no-arg pushes).
  final CheckoutResult? result;

  /// Breakdown rows (date, per-tier tickets, discounts) shown above the total.
  final List<OrderLine> lines;

  @override
  State<BookingCompletePage> createState() => _BookingCompletePageState();
}

class _BookingCompletePageState extends State<BookingCompletePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goHome() {
    final tabs = context.router.root.innerRouterOf<TabsRouter>(MainRoute.name);
    tabs?.setActiveIndex(0);
    context.router.popUntil((r) => r.settings.name == MainRoute.name);
  }

  ({Color color, IconData icon, String title, String desc}) get _variant {
    switch (widget.status) {
      case BookingResultStatus.paid:
        return (
          color: AppColors.badgeGreen,
          icon: Icons.check_rounded,
          title: 'order_paid_title'.tr(),
          desc: 'order_paid_desc'.tr(),
        );
      case BookingResultStatus.pending:
        return (
          color: const Color(0xFFF6B53D),
          icon: Icons.hourglass_bottom_rounded,
          title: 'order_pending_title'.tr(),
          desc: 'order_pending_desc'.tr(),
        );
      case BookingResultStatus.failed:
        return (
          color: AppColors.error,
          icon: Icons.priority_high_rounded,
          title: 'order_failed_title'.tr(),
          desc: 'order_failed_desc'.tr(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final v = _variant;
    final showCard = widget.result != null &&
        (widget.lines.isNotEmpty || (widget.result?.totalAmount ?? 0) > 0);

    return AnnotatedRegion(
      value: c.overlayStyle,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Text('order_details'.tr(),
                    style: AppText.medium16.copyWith(color: c.textPrimary)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                  child: Column(
                    children: [
                      24.verticalSpace,
                      ScaleTransition(
                        scale: Tween<double>(begin: 0.6, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _ctrl,
                            curve:
                                const Interval(0, 0.7, curve: Curves.easeOutBack),
                          ),
                        ),
                        child: Container(
                          width: 72.w,
                          height: 72.w,
                          alignment: Alignment.center,
                          decoration:
                              BoxDecoration(shape: BoxShape.circle, color: v.color),
                          child: Icon(v.icon, size: 38.sp, color: Colors.white),
                        ),
                      ),
                      16.verticalSpace,
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _ctrl,
                          curve:
                              const Interval(0.3, 1.0, curve: Curves.easeOut),
                        ),
                        child: Column(
                          children: [
                            Text(
                              v.title,
                              textAlign: TextAlign.center,
                              style: AppText.heading20
                                  .copyWith(color: c.textPrimary),
                            ),
                            8.verticalSpace,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                v.desc,
                                textAlign: TextAlign.center,
                                style: AppText.regular14
                                    .copyWith(color: c.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showCard) ...[
                        28.verticalSpace,
                        _OrderCard(result: widget.result!, lines: widget.lines),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: c.bg,
                padding:
                    EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + safeBottom),
                child: GradientButton(
                  text: 'nav_main'.tr(),
                  onPressed: _goHome,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Детали брони" breakdown card: date + per-tier ticket rows + discounts, a
/// divider and the grand total.
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.result, required this.lines});

  final CheckoutResult result;
  final List<OrderLine> lines;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  gradient: AppGradients.brand,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.confirmation_number_rounded,
                    size: 14.sp, color: Colors.white),
              ),
              8.horizontalSpace,
              Text('order_details'.tr(),
                  style: AppText.semibold16.copyWith(color: c.textPrimary)),
            ],
          ),
          16.verticalSpace,
          for (final l in lines) _row(c, l),
          Divider(height: 1, color: c.controlBorder),
          10.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Text('book_grand_total'.tr(),
                    style: AppText.bold18.copyWith(color: c.textSecondary)),
              ),
              Text(result.totalAmount.toRawUzsPrice(),
                  style: AppText.bold18.copyWith(color: c.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(AppColors c, OrderLine l) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          if (l.iconAsset != null) ...[
            SvgPicture.asset(l.iconAsset!, width: 18.w, height: 18.w),
            10.horizontalSpace,
          ],
          Expanded(
            child: Text(l.label,
                style: AppText.regular14.copyWith(color: c.textSecondary)),
          ),
          Text(
            l.value,
            style: AppText.semibold14.copyWith(
              color: l.negative ? AppColors.error : c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
