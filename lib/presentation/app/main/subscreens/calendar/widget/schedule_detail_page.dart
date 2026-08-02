import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_shadows.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/strip_html.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/stretchy_hero.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/schedule_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// Hero carousel height — also the distance the top scrim fades in over.
/// Matches the class/branch detail screens.
const double _kHeroHeight = 300;


/// Booking detail: shows full class context for one order (transaction). For
/// pending orders the sticky CTA relaunches Paycom; for paid orders it lists
/// every ticket inside the order so the user can open an individual receipt.
///
/// Built from the shared "Детали" blocks ([StretchyHero], [DetailCard],
/// [DetailControlButton], [DetailTopScrim]) so it reads as the same screen
/// family as class detail and branch detail.
@RoutePage()
class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  Timer? _slideTimer;

  OrderDetail? _detail;
  ClassFullModel? _classFull;
  bool _loading = true;
  bool _launchingPayment = false;
  bool _cancelledLocally = false;

  /// True while the cancel request is in flight — keeps the buyer from firing
  /// a second one and from tapping through to a stale screen.
  bool _cancelling = false;
  String? _error;
  bool _viewLogged = false;
  int _currentImageIndex = 0;

  /// 0 → hero fully visible, 1 → content scrolled under the top controls and
  /// the frosted scrim is fully on.
  double _topScrim = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _startAutoSlide();
    _load();
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Fade the top scrim in over the second half of the hero, so it is fully on
  /// by the time the first card slides under the back control.
  void _onScroll() {
    final start = _kHeroHeight.h * 0.45;
    final end = _kHeroHeight.h * 0.85;
    final t =
        ((_scrollController.offset - start) / (end - start)).clamp(0.0, 1.0);
    if (t != _topScrim) setState(() => _topScrim = t);
  }

  void _startAutoSlide() {
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final images = _images;
      if (!mounted || images.length <= 1) return;
      _pageController.animateToPage(
        (_currentImageIndex + 1) % images.length,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final api = getIt<OrdersApi>();
      final detail = await api.getOrderDetail(widget.orderId);
      ClassFullModel? full;
      if (detail.order.activityId != null) {
        try {
          full = await api.getClassFull(detail.order.activityId!);
        } catch (_) {/* soft-fail */}
      }
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _classFull = full;
        if (!silent) _loading = false;
      });
      if (!_viewLogged) {
        _viewLogged = true;
        getIt<AnalyticsService>().logEvent(
          AnalyticsEvent.activityDetailViewed,
          params: {
            'order_id': widget.orderId,
            if (detail.order.activityId != null)
              'activity_id': detail.order.activityId!,
            // The localized string, not the raw `name` map — analytics params
            // only carry scalars.
            if (_classFullTitle() != null) 'class_title': _classFullTitle()!,
            'status': detail.order.effectiveDisplayStatus,
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  /// Computed display status taking into account required_booking logic and
  /// local optimistic cancel state.
  String get _effectiveStatus {
    if (_cancelledLocally) return 'cancelled';
    final order = _detail!.order;
    final requiresBooking =
        _classFull?.category?.requiresBookingTimeSlot == true;
    if (requiresBooking && order.isPending) return 'in_process';
    if (requiresBooking && order.isCanceled) return 'canceled_by_centre';
    return order.effectiveDisplayStatus;
  }

  /// Immediately reflects cancellation in the UI then silently reloads.
  void _onCancelled() {
    setState(() => _cancelledLocally = true);
    _load(silent: true);
  }

  bool _canCancel() {
    if (_detail == null) return false;
    final order = _detail!.order;
    if (order.isCanceled || _cancelledLocally) return false;
    // A pending order was never charged — the buyer can drop it at any time,
    // which is the only way to clear an abandoned checkout out of their
    // bookings. The window below guards a PAID seat, so it doesn't apply.
    if (order.isPending) return true;
    if (!order.isPaid) return false;
    final dateStr = _detail!.earliestTicketDate;
    if (dateStr == null || dateStr.isEmpty) return false;
    final startTime = _detail!.tickets.firstOrNull?.startTime ??
        _classFull?.schedule.firstOrNull?.startTime;
    try {
      final date = DateTime.parse(dateStr);
      final DateTime bookingDt;
      if (startTime != null && startTime.contains(':')) {
        final parts = startTime.split(':');
        bookingDt = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      } else {
        bookingDt = date;
      }
      return bookingDt.difference(DateTime.now()).inMinutes >
          _detail!.cancellationWindowHours * 60;
    } catch (_) {
      return false;
    }
  }

  Future<void> _pay() async {
    if (_detail == null || _launchingPayment) return;
    setState(() => _launchingPayment = true);
    try {
      await payForOrder(context, _detail!.order);
    } finally {
      if (mounted) setState(() => _launchingPayment = false);
    }
  }

  /// Opens the OFD/Soliq fiscal receipt for a paid order. On mobile this pushes
  /// a full-page in-app WebView; on web (where webview_flutter has no renderer)
  /// it opens the receipt in a new browser tab.
  Future<void> _openReceipt() async {
    final url = _detail?.receiptUrl;
    if (kIsWeb) {
      var target = url;
      if (target == null || target.isEmpty) {
        try {
          target = await getIt<OrdersApi>().getOrderReceipt(widget.orderId);
        } catch (_) {/* handled below */}
      }
      if (target != null && target.isNotEmpty) {
        await launchUrl(
          Uri.parse(target),
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('fiscal_receipt_unavailable'.tr())),
        );
      }
      return;
    }
    if (!mounted) return;
    context.router.push(
      FiscalReceiptRoute(orderId: widget.orderId, initialUrl: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final safeTop = MediaQuery.of(context).viewPadding.top;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    if (_loading) {
      return Scaffold(
        backgroundColor: c.scaffoldBg,
        body: _BookingDetailShimmer(c: c),
      );
    }
    if (_error != null || _detail == null) {
      return Scaffold(
        backgroundColor: c.scaffoldBg,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8.h,
                left: 16.w,
                child: DetailControlButton(
                  onTap: () => context.router.maybePop(),
                  child: HomeIcon(Assets.icons.home.arrow,
                      size: 16, color: AppColors.ink),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'booking_could_not_load'.tr(),
                        textAlign: TextAlign.center,
                        style:
                            AppText.semibold16.copyWith(color: c.textPrimary),
                      ),
                      16.verticalSpace,
                      GestureDetector(
                        onTap: _load,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: c.primary,
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: Text('booking_retry'.tr(),
                              style: AppText.semibold14
                                  .copyWith(color: c.onPrimary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final detail = _detail!;
    final order = detail.order;
    final title = _classFullTitle() ?? order.activityName ?? '';
    final description = _classDescription();
    final branch = _branchTitle();
    final showReceipt =
        order.isPaid && !_cancelledLocally && !order.isCanceled;

    // Over the hero the status bar sits on a photo (light icons); once the
    // scrim takes over on a light background the icons have to flip to dark.
    final darkIcons = !c.isDark && _topScrim > 0.5;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
        statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: c.scaffoldBg,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _hero(c, safeTop)),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _mainCard(c, title, description, branch),
                      if (detail.tickets.isNotEmpty) ...[
                        6.verticalSpace,
                        _ticketsCard(c, detail, order),
                      ],
                      6.verticalSpace,
                      _paymentCard(c, order, showReceipt),
                    ],
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 100.h + safeBottom)),
              ],
            ),
            // Frosted scrim under the top controls.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: _topScrim,
                  child: DetailTopScrim(
                    color: c.scaffoldBg,
                    height: safeTop + 56.h,
                  ),
                ),
              ),
            ),
            // Top controls over the hero.
            Positioned(
              top: safeTop + 8.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  DetailControlButton(
                    onTap: () => context.router.maybePop(),
                    child: HomeIcon(Assets.icons.home.arrow,
                        size: 16, color: AppColors.ink),
                  ),
                  const Spacer(),
                  _StatusChip(status: _effectiveStatus),
                ],
              ),
            ),
            // Sticky CTA.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: c.scaffoldBg,
                  boxShadow: AppShadows.bottomBar,
                ),
                padding:
                    EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + safeBottom),
                child: _cta(c, order),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero image carousel ───────────────────────────────────────────────────
  Widget _hero(AppColorScheme c, double safeTop) {
    final images = _images;
    return StretchyHero(
      controller: _scrollController,
      height: _kHeroHeight.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
                placeholder: (_, __) => _imgShimmer(c),
                errorWidget: (_, __, ___) => _imgShimmer(c),
              ),
            )
          else
            _imgShimmer(c),
          // Top scrim — a soft dark fade so the light controls stay legible
          // over bright / near-white hero images.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: safeTop + 72.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.28),
                      Colors.black.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12.h,
              left: 0,
              right: 0,
              child: Center(
                child: FrostedCard(
                  hasBorder: false,
                  boxShadow: AppShadows.control,
                  borderRadius: BorderRadius.circular(32.r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(images.length, (i) {
                      final active = i == _currentImageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.ink : const Color(0xFFCECDD6),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imgShimmer(AppColorScheme c) => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
        child: Container(color: c.surface),
      );

  // ─── Title, description, venue ─────────────────────────────────────────────
  ///
  /// One card, like class detail: the class name *is* the section header, so
  /// there is no "About" header above the description.
  Widget _mainCard(
      AppColorScheme c, String title, String? description, String? branch) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.heading20.copyWith(color: c.textPrimary)),
          if (description != null) ...[
            6.verticalSpace,
            Text(
              description,
              textAlign: TextAlign.justify,
              style: AppText.regular14.copyWith(color: c.textPrimary),
            ),
          ],
          if (branch != null && branch.isNotEmpty) ...[
            20.verticalSpace,
            _DetailPill(
              c: c,
              icon: Assets.icons.detail.icLocation,
              label: 'booking_location'.tr(),
              value: branch,
            ),
          ],
        ],
      ),
    );
  }

  // ─── Tickets ───────────────────────────────────────────────────────────────
  Widget _ticketsCard(AppColorScheme c, OrderDetail detail, UserOrder order) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Figma 96:3667 — plain title on the left, the count as muted copy on
          // the right (no chip, no gradient badge on the card header).
          Row(
            children: [
              Expanded(
                child: Text(
                  'your_tickets'.tr(),
                  style: AppText.semibold16.copyWith(color: c.textPrimary),
                ),
              ),
              8.horizontalSpace,
              Text(
                'tickets_count'.tr(args: ['${detail.tickets.length}']),
                style: AppText.regular14.copyWith(color: c.textMuted),
              ),
            ],
          ),
          20.verticalSpace,
          ...List.generate(detail.tickets.length, (i) {
            final t = detail.tickets[i];
            final cancelled = _cancelledLocally ||
                order.isCanceled ||
                t.status.toLowerCase() == 'canceled';
            // Per-ticket paid price: scale ticket.price by the order-level
            // discount ratio so each age-tier gets the correct share.
            num? paidPerTicket;
            if (order.hasDiscount && order.subtotalAmount > 0) {
              paidPerTicket =
                  (t.price * order.totalAmount / order.subtotalAmount).round();
            }
            return Padding(
              padding: EdgeInsets.only(
                  bottom: i == detail.tickets.length - 1 ? 0 : 4.h),
              child: _TicketRow(
                c: c,
                ticket: t,
                className: _classFullTitle() ?? order.activityName,
                branch: _branchTitle(),
                orderId: order.id,
                canCancel: _canCancel(),
                isCancelled: cancelled,
                onCanceled: _onCancelled,
                paidPrice: paidPerTicket,
                fromPromocode: order.isPromocodeDiscount,
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Payment + fiscal receipt ──────────────────────────────────────────────
  /// Wordmark for a rail key. Brand names are not translated; an unknown key
  /// is shown as-is rather than hidden, so a new rail is visible immediately.
  String _providerLabel(String key) => switch (key.toLowerCase()) {
        'payme' || 'paycom' => 'Payme',
        'click' => 'Click',
        'uzum' => 'Uzum',
        'paylov' => 'Paylov',
        'card' => 'card_payment'.tr(),
        'saved_card' => 'card_payment'.tr(),
        _ => key,
      };

  Widget _paymentCard(AppColorScheme c, UserOrder order, bool showReceipt) {
    final amountColor = order.isPending ? AppColors.warning : AppColors.green;

    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.home.money,
            iconGradient: const LinearGradient(
              colors: [AppColors.brandPink, AppColors.brandPink],
            ),
            title: order.isPending ? 'amount_due'.tr() : 'amount_paid'.tr(),
          ),
          16.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.hasDiscount)
                      Text(
                        order.subtotalAmount.toRawUzsPrice(),
                        style: AppText.regular13.copyWith(
                          color: c.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      order.totalAmount.toRawUzsPrice(),
                      style: AppText.heading20.copyWith(color: amountColor),
                    ),
                  ],
                ),
              ),
              if (order.hasDiscount)
                Flexible(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Text(
                      '${'booking_coupon_saved'.tr()} '
                      '${order.discountAmount.toRawUzsPrice()}',
                      maxLines: 2,
                      style:
                          AppText.semibold12.copyWith(color: AppColors.green),
                    ),
                  ),
                ),
            ],
          ),
          // Which rail the money went out on — the first thing anyone asks
          // when a payment is queried, and previously only visible in the DB.
          if (order.paymentProvider != null) ...[
            12.verticalSpace,
            _DetailPill(
              c: c,
              icon: Assets.icons.home.money,
              label: 'payment_method'.tr(),
              value: _providerLabel(order.paymentProvider!),
            ),
          ],
          if (showReceipt) ...[
            12.verticalSpace,
            _DetailPill(
              c: c,
              icon: Assets.icons.detail.iconsaxReceipt,
              label: 'fiscal_receipt_subtitle'.tr(),
              value: 'fiscal_receipt'.tr(),
              action: 'view_all'.tr(),
              onTap: _openReceipt,
            ),
          ],
        ],
      ),
    );
  }

  // ─── Sticky CTA ────────────────────────────────────────────────────────────
  ///
  /// Only a pending order has an action ("pay now") — everything else is a
  /// terminal state, so the bar states it rather than offering a dead button.
  Widget _cta(AppColorScheme c, UserOrder order) {
    if (_cancelledLocally || order.isCanceled) {
      return _StatusBar(
        c: c,
        label: 'booking_cancelled_label'.tr(),
        color: AppColors.error,
      );
    }
    if (order.isPending) {
      final requiresBooking =
          _classFull?.category?.requiresBookingTimeSlot == true;
      // Unpaid either way, so the buyer can always drop it — an abandoned
      // checkout otherwise sits in their bookings forever.
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (requiresBooking)
            _StatusBar(
              c: c,
              label: 'status_in_process'.tr(),
              color: AppColors.brandPurple,
            )
          else
            GradientButton(
              text: _launchingPayment ? 'opening_payment'.tr() : 'pay_now'.tr(),
              loading: _launchingPayment,
              onPressed: _pay,
            ),
          _cancelLink(c),
        ],
      );
    }
    // Paid and still inside the cancellation window: state it, and offer the
    // way out right here. Cancelling used to be reachable only by tapping a
    // ticket through to the receipt screen, which nobody finds.
    if (_canCancel()) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusBar(c: c, label: 'order_paid'.tr(), color: AppColors.green),
          _cancelLink(c),
        ],
      );
    }
    return _StatusBar(c: c, label: 'order_paid'.tr(), color: AppColors.green);
  }

  /// The "Отменить бронирование" row under the status bar. Renders nothing when
  /// the order can't be cancelled (already past, already cancelled), so both
  /// call sites can include it unconditionally.
  Widget _cancelLink(AppColorScheme c) {
    if (!_canCancel()) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _cancelling ? null : _confirmCancel,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          alignment: Alignment.center,
          child: Text(
            _cancelling
                ? 'booking_cancelling'.tr()
                : 'booking_cancel_title'.tr(),
            style: AppText.semibold14.copyWith(
              color: _cancelling ? c.textSecondary : AppColors.error,
            ),
          ),
        ),
      ),
    );
  }

  /// Asks first — cancelling is irreversible and the money comes back on the
  /// gateway's schedule, not ours.
  Future<void> _confirmCancel() async {
    final c = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('booking_cancel_title'.tr(),
            style: AppText.semibold16.copyWith(color: c.textPrimary)),
        content: Text('booking_cancel_confirm'.tr(),
            style: AppText.regular14.copyWith(color: c.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('booking_keep'.tr(),
                style: TextStyle(color: c.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('booking_cancel_action'.tr(),
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      final refund =
          await getIt<OrdersApi>().cancelOrder(_detail!.order.id);
      if (!mounted) return;
      setState(() => _cancelling = false);
      _onCancelled();
      // Say which kind of refund to expect — "manual" means a Paylov payment,
      // which WLCM won't let us reverse over the API.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            refund == 'manual'
                ? 'booking_refund_manual'.tr()
                : 'booking_refund_auto'.tr(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _cancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('booking_cancel_failed'.tr(args: [_cancelMessage(e)])),
        ),
      );
    }
  }

  /// The server's reason (past the cancellation window, already cancelled, …)
  /// rather than a Dio stack string.
  String _cancelMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      final msg = data is Map ? data['message'] : null;
      if (msg != null && '$msg'.isNotEmpty) return '$msg';
      return e.message ?? e.toString();
    }
    return e.toString();
  }

  // ─── Data helpers ──────────────────────────────────────────────────────────
  List<String> get _images {
    final detail = _detail;
    if (detail == null) return const [];
    final imgs = <String>[];
    imgs.addAll((_classFull?.images ?? const []).where((s) => s.isNotEmpty));
    final cover = _classFull?.imageUrl;
    if (cover != null && cover.isNotEmpty && !imgs.contains(cover)) {
      imgs.insert(0, cover);
    }
    final orderImage = detail.order.activityImage;
    if (imgs.isEmpty && orderImage != null && orderImage.isNotEmpty) {
      imgs.add(orderImage);
    }
    return imgs;
  }

  String? _classFullTitle() {
    final name = _classFull?.name;
    if (name == null || name.isEmpty) return null;
    return _readLang(name);
  }

  String? _classDescription() {
    final desc = _classFull?.description;
    if (desc == null || desc.isEmpty) return null;
    final v = _readLang(desc);
    if (v == null || v.isEmpty) return null;
    final clean = stripHtml(v).trim();
    return clean.isEmpty ? null : clean;
  }

  String? _branchTitle() => _classFull?.branch?.title;

  String? _readLang(Map<String, dynamic> field) {
    final code = context.locale.languageCode;
    final v = field[code] ?? field['ru'] ?? field['en'] ?? field['uz'];
    return v?.toString();
  }
}

// ─── Reusable pieces ─────────────────────────────────────────────────────────

/// Status colours + label for an order's display status. Kept in one place so
/// the hero chip and the sticky bar can't drift apart.
({Color color, String label}) _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'active':
    case 'paid':
      return (color: AppColors.green, label: 'status_active'.tr());
    case 'visited':
      return (color: AppColors.link, label: 'status_visited'.tr());
    case 'missed':
      return (color: AppColors.warning, label: 'status_missed'.tr());
    case 'in_process':
      return (color: AppColors.brandPurple, label: 'status_in_process'.tr());
    case 'canceled_by_centre':
      return (
        color: AppColors.error,
        label: 'status_canceled_by_centre'.tr(),
      );
    case 'canceled':
    case 'cancelled':
      return (color: AppColors.error, label: 'order_cancelled'.tr());
    default:
      return (color: AppColors.warning, label: 'order_pending'.tr());
  }
}

/// Status chip floating over the hero. Frosted (always light) because it sits
/// on the photo — only the dot and the label carry the status colour.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle(status);
    return FrostedCard(
      hasBorder: false,
      boxShadow: AppShadows.control,
      borderRadius: BorderRadius.circular(40.r),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: s.color),
          ),
          6.horizontalSpace,
          Text(s.label, style: AppText.semibold12.copyWith(color: s.color)),
        ],
      ),
    );
  }
}

/// Terminal-state bar in the CTA slot — states what happened to the order
/// instead of offering a button that does nothing.
class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.c, required this.label, required this.color});

  final AppColorScheme c;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(44.r),
      ),
      child: Text(label, style: AppText.semibold16.copyWith(color: color)),
    );
  }
}

/// Rounded pill row inside a detail card: a circular icon tile, a muted label
/// with its value, and an optional trailing action chip.
class _DetailPill extends StatelessWidget {
  const _DetailPill({
    required this.c,
    required this.icon,
    required this.label,
    required this.value,
    this.action,
    this.onTap,
  });

  final AppColorScheme c;
  final SvgGenImage icon;
  final String label;
  final String value;

  /// Trailing chip. Purely an affordance — the tap target is the whole pill.
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final act = action;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: c.surface, shape: BoxShape.circle),
              child: HomeIcon(icon, size: 16, color: c.textPrimary),
            ),
            8.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppText.regular12.copyWith(color: c.textSecondary)),
                  4.verticalSpace,
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                ],
              ),
            ),
            if (act != null) ...[
              8.horizontalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: detailChipFill(c),
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Text(act,
                    style: AppText.regular12.copyWith(color: c.textPrimary)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One ticket inside the order. Tapping opens its receipt; a cancelled ticket
/// is inert and reads as a muted row with a red status chip.
class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.c,
    required this.ticket,
    required this.className,
    required this.branch,
    this.orderId,
    this.canCancel = false,
    this.isCancelled = false,
    this.onCanceled,
    this.paidPrice,
    this.fromPromocode = false,
  });

  final AppColorScheme c;
  final OrderTicket ticket;
  final String? className;
  final String? branch;
  final String? orderId;
  final bool canCancel;
  final bool isCancelled;
  final VoidCallback? onCanceled;

  /// True when the discount came from a promocode (vs an auto coupon plan).
  final bool fromPromocode;

  /// Per-ticket amount actually paid (after coupon discount). Null = no discount.
  final num? paidPrice;

  @override
  Widget build(BuildContext context) {
    final titleColor = isCancelled ? c.textMuted : c.textPrimary;
    final discounted = paidPrice != null && paidPrice != ticket.price;
    final paid = discounted ? paidPrice! : ticket.price;

    // Figma 96:3667: green gradient glyph badge + "Билет №N" on the left, the
    // price on the right, and the metadata as pills on a second row — so a
    // long date + time window wraps instead of overflowing.
    final card = Container(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Green badge in every state — a cancelled ticket is signalled by
              // the red chip below, not by draining the glyph.
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: AppGradients.green,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: HomeIcon(
                  Assets.icons.detail.iconsaxTicketDiscount,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: Text(
                  ticket.ticketNo != null
                      ? 'ticket_number'.tr(args: ['${ticket.ticketNo}'])
                      : 'ticket_pending_label'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.semibold14.copyWith(color: titleColor),
                ),
              ),
              8.horizontalSpace,
              if (discounted)
                Text(
                  ticket.price.toRawUzsPrice(),
                  style: AppText.regular12.copyWith(
                    color: c.textMuted,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              if (discounted) 4.horizontalSpace,
              Text(
                paid.toRawUzsPrice(),
                style: AppText.semibold14.copyWith(
                  color: isCancelled
                      ? c.textMuted
                      : discounted
                          ? AppColors.green
                          : c.textPrimary,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Wrap(
            spacing: 4.w,
            runSpacing: 4.h,
            children: [
              _TicketMetaChip(
                c: c,
                label: 'ticket_date_label'.tr(),
                value: ticket.ticketDate,
                muted: isCancelled,
              ),
              if (ticket.startTime != null && ticket.endTime != null)
                _TicketMetaChip(
                  c: c,
                  label: 'ticket_time_label'.tr(),
                  value: '${ticket.startTime} – ${ticket.endTime}',
                  muted: isCancelled,
                ),
              if (isCancelled)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Text('order_cancelled'.tr(),
                      style:
                          AppText.semibold14.copyWith(color: AppColors.error)),
                ),
            ],
          ),
        ],
      ),
    );

    if (isCancelled) return card;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final result = await context.router.push(TicketReceiptRoute(
          ticket: ticket,
          className: className,
          branch: branch,
          orderId: orderId,
          canCancel: canCancel,
          paidPrice: paidPrice,
          fromPromocode: fromPromocode,
        ));
        if (result == true) onCanceled?.call();
      },
      child: card,
    );
  }
}

/// "Дата: 22 апр. 2026" pill under a ticket — muted label, primary value.
class _TicketMetaChip extends StatelessWidget {
  const _TicketMetaChip({
    required this.c,
    required this.label,
    required this.value,
    this.muted = false,
  });

  final AppColorScheme c;
  final String label;
  final String value;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: detailChipFill(c),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: AppText.semibold14.copyWith(color: c.textMuted),
            ),
            TextSpan(
              text: value,
              style: AppText.semibold14
                  .copyWith(color: muted ? c.textMuted : c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingDetailShimmer extends StatelessWidget {
  const _BookingDetailShimmer({required this.c});

  final AppColorScheme c;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: c.surface,
      highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: _kHeroHeight.h, color: c.surface),
            6.verticalSpace,
            ...List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Container(
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(12.r),
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
