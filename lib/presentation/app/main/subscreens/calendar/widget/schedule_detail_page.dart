import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/strip_html.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/schedule_widget.dart';

/// Booking detail: shows full class context for one order (transaction). For
/// pending orders the sticky CTA relaunches Paycom; for paid orders it lists
/// every ticket inside the order so the user can open an individual receipt.
@RoutePage()
class BookingDetailPage extends StatefulWidget {
  const BookingDetailPage({super.key, required this.orderId});

  final String orderId;

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  OrderDetail? _detail;
  ClassFullModel? _classFull;
  bool _loading = true;
  bool _launchingPayment = false;
  bool _cancelledLocally = false;
  String? _error;
  bool _viewLogged = false;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            if (full?.name != null) 'class_title': full!.name!,
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
    if (!_detail!.order.isPaid) return false;
    final dateStr = _detail!.earliestTicketDate;
    if (dateStr == null || dateStr.isEmpty) return false;
    final startTime = _detail!.tickets.firstOrNull?.startTime
        ?? _classFull?.schedule.firstOrNull?.startTime;
    try {
      final date = DateTime.parse(dateStr);
      final DateTime bookingDt;
      if (startTime != null && startTime.contains(':')) {
        final parts = startTime.split(':');
        bookingDt = DateTime(
          date.year, date.month, date.day,
          int.parse(parts[0]), int.parse(parts[1]),
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
    final primary = context.colors.primary;

    if (_loading) {
      return Scaffold(
        body: const _BookingDetailShimmer(),
      );
    }
    if (_error != null || _detail == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.maybePop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    size: 48.w, color: Colors.red.shade400),
                16.kh,
                'booking_could_not_load'.tr().s(16).w(600),
                8.kh,
                Text(
                  _error ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
                16.kh,
                TextButton(
                  onPressed: _load,
                  child: Text('booking_retry'.tr()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final detail = _detail!;
    final order = detail.order;
    final images = _resolveImages();

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  width: 1.sw,
                  height: 300.h,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(28.r),
                            bottomRight: Radius.circular(28.r),
                          ),
                          child: images.isNotEmpty
                              ? PageView.builder(
                                  controller: _pageController,
                                  itemCount: images.length,
                                  onPageChanged: (i) =>
                                      setState(() => _currentImageIndex = i),
                                  itemBuilder: (_, i) => CachedNetworkImage(
                                    imageUrl: images[i],
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Shimmer.fromColors(
                                      baseColor: Colors.grey.shade200,
                                      highlightColor: Colors.grey.shade50,
                                      child: Container(color: Colors.white),
                                    ),
                                    errorWidget: (_, __, ___) => Shimmer.fromColors(
                                      baseColor: Colors.grey.shade200,
                                      highlightColor: Colors.grey.shade50,
                                      child: Container(color: Colors.white),
                                    ),
                                  ),
                                )
                              : Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade50,
                                  child: Container(color: Colors.white),
                                ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(28.r),
                              bottomRight: Radius.circular(28.r),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.55),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).viewPadding.top + 10.h,
                        left: 16.w,
                        child: _CircleBackButton(primary: primary),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).viewPadding.top + 14.h,
                        right: 16.w,
                        child: _StatusBadge(status: _effectiveStatus),
                      ),
                      if (images.length > 1)
                        Positioned(
                          bottom: 60.h,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentImageIndex == i ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == i
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.45),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 16.h,
                        left: 20.w,
                        right: 20.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: (_classFullTitle() ??
                                  order.activityName ??
                                  'Class')
                              .s(20)
                              .w(700)
                              .c(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    16.kh,
                    if (detail.tickets.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(Icons.confirmation_number_rounded,
                              color: primary, size: 20.w),
                          8.kw,
                          'your_tickets'
                              .tr()
                              .s(16)
                              .w(700)
                              .c(const Color(0xFF1E293B)),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'tickets_count'
                                  .tr(args: ['${detail.tickets.length}']),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      12.kh,
                      ...detail.tickets.map((t) {
                            final ticketCancelled = _cancelledLocally ||
                                order.isCanceled ||
                                t.status.toLowerCase() == 'canceled';
                            // Per-ticket paid price: scale ticket.price by the
                            // order-level discount ratio so each age-tier gets
                            // the correct share.
                            num? paidPerTicket;
                            if (order.hasDiscount &&
                                order.subtotalAmount > 0) {
                              paidPerTicket = (t.price *
                                      order.totalAmount /
                                      order.subtotalAmount)
                                  .round();
                            }
                            return Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _TicketRow(
                                ticket: t,
                                className:
                                    _classFullTitle() ?? order.activityName,
                                branch: _branchTitle(),
                                primary: primary,
                                orderId: order.id,
                                canCancel: _canCancel(),
                                isCancelled: ticketCancelled,
                                onCanceled: _onCancelled,
                                paidPrice: paidPerTicket,
                                fromPromocode: order.isPromocodeDiscount,
                              ),
                            );
                          }),
                      8.kh,
                    ],
                    _InfoCard(
                      icon: Icons.payments_outlined,
                      iconBg: order.isPending
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFECFDF5),
                      iconColor: order.isPending
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF059669),
                      label: order.isPending
                          ? 'amount_due'.tr()
                          : 'amount_paid'.tr(),
                      valueWidget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (order.hasDiscount)
                            Text(
                              order.subtotalAmount.toRawUzsPrice(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            order.totalAmount.toRawUzsPrice(),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: order.isPending
                                  ? const Color(0xFFEA580C)
                                  : const Color(0xFF059669),
                            ),
                          ),
                          if (order.hasDiscount)
                            Container(
                              margin: EdgeInsets.only(top: 4.h),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_offer_rounded,
                                      size: 11.sp,
                                      color: const Color(0xFF16A34A)),
                                  4.kw,
                                  Text(
                                    '${'booking_coupon_saved'.tr()} ${order.discountAmount.toRawUzsPrice()}',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF16A34A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (order.isPaid &&
                        !_cancelledLocally &&
                        !order.isCanceled) ...[
                      12.kh,
                      _ReceiptCard(primary: primary, onTap: _openReceipt),
                    ],
                    if (_branchTitle() != null) ...[
                      12.kh,
                      _InfoCard(
                        icon: Icons.location_on_outlined,
                        iconBg: const Color(0xFFF5F3FF),
                        iconColor: const Color(0xFF7C3AED),
                        label: 'booking_location'.tr(),
                        value: _branchTitle()!,
                      ),
                    ],
                    if (_classDescription() != null) ...[
                      20.kh,
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3C539A).withOpacity(0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36.w,
                                  height: 36.h,
                                  decoration: BoxDecoration(
                                    color: primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(Icons.info_outline_rounded,
                                      color: primary, size: 18.w),
                                ),
                                10.kw,
                                'booking_about'
                                    .tr()
                                    .s(16)
                                    .w(700)
                                    .c(const Color(0xFF1E293B)),
                              ],
                            ),
                            14.kh,
                            Text(
                              _classDescription()!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF4B5563),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    140.kh,
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: MediaQuery.of(context).viewPadding.bottom + 16.h,
                top: 20.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.scaffoldBg.withOpacity(0),
                    context.colors.scaffoldBg.withOpacity(0.95),
                    context.colors.scaffoldBg,
                  ],
                  stops: const [0.0, 0.35, 0.6],
                ),
              ),
              child: _buildCta(primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCta(Color primary) {
    final order = _detail!.order;

    if (_cancelledLocally || order.isCanceled) {
      return _CtaButton(
        label: 'booking_cancelled_label'.tr(),
        color: Colors.grey.shade400,
        icon: Icons.cancel_outlined,
        enabled: false,
      );
    }

    if (order.isPending) {
      final requiresBooking =
          _classFull?.category?.requiresBookingTimeSlot == true;
      if (requiresBooking) {
        return _CtaButton(
          label: 'status_in_process'.tr(),
          color: const Color(0xFF7C3AED),
          icon: Icons.hourglass_empty_rounded,
          enabled: false,
        );
      }
      return _CtaButton(
        label: _launchingPayment ? 'opening_payment'.tr() : 'pay_now'.tr(),
        color: primary,
        icon: Icons.payments_rounded,
        enabled: !_launchingPayment,
        loading: _launchingPayment,
        onTap: _pay,
      );
    }

    return _CtaButton(
      label: 'order_paid'.tr(),
      color: const Color(0xFF16A34A),
      icon: Icons.check_circle_outline,
      enabled: false,
    );
  }

  List<String> _resolveImages() {
    final imgs = <String>[];
    final classImages = _classFull?.images ?? const [];
    imgs.addAll(classImages.where((s) => s.isNotEmpty));
    final classCover = _classFull?.imageUrl;
    if (classCover != null && classCover.isNotEmpty && !imgs.contains(classCover)) {
      imgs.insert(0, classCover);
    }
    final orderImage = _detail!.order.activityImage;
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

  String? _branchTitle() {
    return _classFull?.branch?.title;
  }

  String? _readLang(Map<String, dynamic> field) {
    final code = context.locale.languageCode;
    final v = field[code] ?? field['ru'] ?? field['en'] ?? field['uz'];
    return v?.toString();
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.ticket,
    required this.className,
    required this.branch,
    required this.primary,
    this.orderId,
    this.canCancel = false,
    this.isCancelled = false,
    this.onCanceled,
    this.paidPrice,
    this.fromPromocode = false,
  });

  final OrderTicket ticket;
  final String? className;
  final String? branch;
  final Color primary;
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
    final iconColor =
        isCancelled ? Colors.grey.shade400 : primary;
    final iconBg = isCancelled
        ? Colors.grey.shade100
        : primary.withOpacity(0.08);
    final titleColor = isCancelled
        ? const Color(0xFF94A3B8)
        : const Color(0xFF1E293B);
    final subColor = isCancelled
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);

    final card = Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCancelled
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.confirmation_number_rounded,
                color: iconColor, size: 22.w),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.ticketNo != null
                      ? '#${ticket.ticketNo}'
                      : 'ticket_pending_label'.tr(),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                4.kh,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11.sp, color: subColor),
                    4.kw,
                    Text(
                      ticket.ticketDate,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: subColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    10.kw,
                    Icon(Icons.payments_outlined,
                        size: 11.sp, color: subColor),
                    4.kw,
                    if (paidPrice != null && paidPrice != ticket.price) ...[
                      Text(
                        ticket.price.toRawUzsPrice(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: subColor,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      4.kw,
                      Text(
                        paidPrice!.toRawUzsPrice(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF16A34A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else
                      Text(
                        ticket.price.toRawUzsPrice(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: subColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                if (ticket.startTime != null && ticket.endTime != null) ...[
                  4.kh,
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 11.sp, color: subColor),
                      4.kw,
                      Text(
                        '${ticket.startTime} – ${ticket.endTime}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: subColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (isCancelled)
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'order_cancelled'.tr(),
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            )
          else
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: const Color(0xFF94A3B8)),
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

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.primary});
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => context.router.maybePop(),
        child: Container(
          width: 42.w,
          height: 42.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Center(
            child: Icon(Icons.arrow_back_ios_new,
                color: primary, size: 18.w),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
        color = const Color(0xFF16A34A);
        label = 'status_active'.tr();
        break;
      case 'visited':
        color = const Color(0xFF2563EB);
        label = 'status_visited'.tr();
        break;
      case 'missed':
        color = const Color(0xFFF59E0B);
        label = 'status_missed'.tr();
        break;
      case 'in_process':
        color = const Color(0xFF7C3AED);
        label = 'status_in_process'.tr();
        break;
      case 'canceled_by_centre':
        color = const Color(0xFFEF4444);
        label = 'status_canceled_by_centre'.tr();
        break;
      case 'canceled':
      case 'cancelled':
        color = const Color(0xFFEF4444);
        label = 'order_cancelled'.tr();
        break;
      default:
        color = const Color(0xFFF59E0B);
        label = 'order_pending'.tr();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8.w,
              height: 8.w,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: color)),
          6.kw,
          label.s(12).w(600).c(color),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.value,
    this.valueWidget,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String label;
  final String? value;
  final Widget? valueWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF3C539A).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(14.r)),
            child: Icon(icon, color: iconColor, size: 22.w),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label.s(11).w(500).c(const Color(0xFF64748B)),
                4.kh,
                valueWidget ?? (value ?? '').s(14).w(600).c(const Color(0xFF1E293B)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable card on the paid-order detail that opens the official OFD/Soliq
/// fiscal receipt (full page on mobile, new tab on web).
class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.primary, required this.onTap});
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3C539A).withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.receipt_long_rounded,
                    color: const Color(0xFF2563EB), size: 22.w),
              ),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    'fiscal_receipt'.tr().s(14).w(700).c(const Color(0xFF1E293B)),
                    4.kh,
                    'fiscal_receipt_subtitle'
                        .tr()
                        .s(11)
                        .w(500)
                        .c(const Color(0xFF64748B)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14.sp, color: const Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingDetailShimmer extends StatelessWidget {
  const _BookingDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28.r),
                  bottomRight: Radius.circular(28.r),
                ),
              ),
            ),
            16.kh,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: List.generate(
                  4,
                  (_) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Container(
                      height: 76.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
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

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.label,
    required this.color,
    this.icon,
    this.enabled = true,
    this.loading = false,
    this.onTap,
  });
  final String label;
  final Color color;
  final IconData? icon;
  final bool enabled, loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? color : color.withOpacity(0.5),
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: enabled
                ? [
                    BoxShadow(
                        color: color.withOpacity(0.34),
                        blurRadius: 26,
                        offset: const Offset(0, 14))
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              else ...[
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: 20.w),
                  8.kw,
                ],
                label.s(16).w(700).c(Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
