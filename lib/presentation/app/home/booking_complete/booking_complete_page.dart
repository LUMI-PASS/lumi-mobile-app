import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
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
  final SvgGenImage? iconAsset;
  final bool negative;
}

/// Order-status screen (Figma `Детали брони`, node 131:3581). Renders the
/// success, pending or failed variant plus the frosted order-details card when
/// [result] is given.
@RoutePage()
class BookingCompletePage extends StatefulWidget {
  const BookingCompletePage({
    super.key,
    this.status = BookingResultStatus.paid,
    this.result,
    this.lines = const [],
  });

  final BookingResultStatus status;

  /// Checkout result — supplies the grand total. When null the order-details
  /// card is hidden (e.g. legacy no-arg pushes).
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

  /// Per-outcome illustration, copy and the tint of the ambient corner glow
  /// (Figma `Ellipse 1260`).
  ({AssetGenImage image, Color glow, String title, String desc}) get _variant {
    switch (widget.status) {
      case BookingResultStatus.paid:
        return (
          image: Assets.images.paymentSuccess,
          glow: AppColors.green,
          title: 'order_paid_title'.tr(),
          desc: 'order_paid_desc'.tr(),
        );
      case BookingResultStatus.pending:
        return (
          image: Assets.images.paymentLoading,
          glow: AppColors.warning,
          title: 'order_pending_title'.tr(),
          desc: 'order_pending_desc'.tr(),
        );
      case BookingResultStatus.failed:
        return (
          image: Assets.images.paymentWarning,
          glow: AppColors.error,
          title: 'order_failed_title'.tr(),
          desc: 'order_failed_desc'.tr(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = _variant;
    final showCard = widget.result != null &&
        (widget.lines.isNotEmpty || (widget.result?.totalAmount ?? 0) > 0);

    return AnnotatedRegion(
      value: c.overlayStyle,
      child: Scaffold(
        backgroundColor: c.canvas,
        body: Stack(
          children: [
            _glow(v.glow),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Text(
                      'order_details'.tr(),
                      style: AppText.medium16.copyWith(color: c.textPrimary),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, box) => SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: box.maxHeight),
                          // IntrinsicHeight gives the Column a bounded height
                          // (max of its content and the viewport). Without it the
                          // SingleChildScrollView hands down an unbounded height
                          // and the Spacer/Expanded children below throw
                          // "RenderFlex … unbounded height", which cascades into a
                          // "RenderBox was not laid out" crash on this page.
                          child: IntrinsicHeight(
                            child: Column(
                              children: [
                                const Spacer(flex: 2),
                                _outcome(c, v),
                                const Spacer(flex: 2),
                                if (showCard)
                                  _OrderCard(
                                    result: widget.result!,
                                    lines: widget.lines,
                                  ),
                                16.verticalSpace,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _bottomBar(c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Soft corner halo tinted by the outcome — Figma's blurred `Ellipse 1260`.
  Widget _glow(Color color) => Positioned(
        left: -40.w,
        top: -40.h,
        child: IgnorePointer(
          child: Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.28),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      );

  /// Status illustration + title + description, animated in on first frame.
  Widget _outcome(
    AppColorScheme c,
    ({AssetGenImage image, Color glow, String title, String desc}) v,
  ) =>
      Column(
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 0.6, end: 1.0).animate(
              CurvedAnimation(
                parent: _ctrl,
                curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
              ),
            ),
            child: v.image.image(width: 48.w, height: 48.w),
          ),
          12.verticalSpace,
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _ctrl,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
            ),
            child: Column(
              children: [
                Text(
                  v.title,
                  textAlign: TextAlign.center,
                  style: AppText.heading20.copyWith(color: c.textPrimary),
                ),
                4.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(
                    v.desc,
                    textAlign: TextAlign.center,
                    style: AppText.regular14
                        .copyWith(color: AppColors.greeting),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  /// "Главный" CTA pinned above the home indicator on an opaque bar.
  Widget _bottomBar(AppColorScheme c) => Container(
        width: double.infinity,
        color: c.scaffoldBg,
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        child: SafeArea(
          top: false,
          child: GradientButton(text: 'nav_main'.tr(), onPressed: _goHome),
        ),
      );
}

/// "Детали брони" breakdown card: the same frosted summary the booking sheet
/// shows before payment — per-tier tickets, date, discounts and the grand total.
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.result, required this.lines});

  final CheckoutResult result;
  final List<OrderLine> lines;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: AppGradients.indigo,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Assets.icons.detail.iconsaxReceipt.svg(
                  width: 14.w,
                  height: 14.w,
                  colorFilter: const ColorFilter.mode(
                      AppColors.onBrand, BlendMode.srcIn),
                ),
              ),
              6.horizontalSpace,
              Text('order_details'.tr(),
                  style: AppText.semibold16.copyWith(color: AppColors.ink)),
            ],
          ),
          for (final l in lines) ...[
            16.verticalSpace,
            Row(
              children: [
                if (l.iconAsset != null) ...[
                  l.iconAsset!.svg(
                    width: 20.w,
                    height: 20.w,
                    colorFilter: const ColorFilter.mode(
                        AppColors.greeting, BlendMode.srcIn),
                  ),
                  8.horizontalSpace,
                ],
                Expanded(
                  child: Text(l.label,
                      style: AppText.regular14
                          .copyWith(color: AppColors.inkMuted)),
                ),
                Text(
                  l.value,
                  style: AppText.semibold14.copyWith(
                    color: l.negative ? AppColors.error : AppColors.ink,
                  ),
                ),
              ],
            ),
          ],
          16.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Text('book_grand_total'.tr(),
                    style: AppText.bold18.copyWith(color: AppColors.inkMuted)),
              ),
              Text(result.totalAmount.toRawUzsPrice(),
                  style: AppText.bold18.copyWith(color: AppColors.ink)),
            ],
          ),
        ],
      ),
    );
  }
}
