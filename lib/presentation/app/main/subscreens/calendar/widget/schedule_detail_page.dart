import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
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
  bool _cancelling = false;
  String? _error;
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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
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
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
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
      return bookingDt.difference(DateTime.now()).inHours >= 12;
    } catch (_) {
      return false;
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          'Cancel Booking',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel this booking?\nThis action cannot be undone.',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Keep Booking',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Cancel',
                style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _cancelling = true);
    try {
      await getIt<OrdersApi>().cancelOrder(_detail!.order.id);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not cancel: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        setState(() => _cancelling = false);
      }
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

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      const days = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
      ];
      return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes == 0) return '—';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '$h hour${h > 1 ? 's' : ''}';
    return '$m min';
  }

  String _genderLabel() {
    switch (_classFull?.gender?.toUpperCase()) {
      case 'MALE':
        return 'Boys only';
      case 'FEMALE':
        return 'Girls only';
      default:
        return 'Everyone';
    }
  }

  Color _genderColor() {
    switch (_classFull?.gender?.toUpperCase()) {
      case 'MALE':
        return const Color(0xFF3B82F6);
      case 'FEMALE':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFFA652C7);
    }
  }

  IconData _genderIcon() {
    switch (_classFull?.gender?.toUpperCase()) {
      case 'MALE':
        return Icons.male_rounded;
      case 'FEMALE':
        return Icons.female_rounded;
      default:
        return Icons.people_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    if (_loading) {
      return Scaffold(
        backgroundColor: context.colors.window,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _detail == null) {
      return Scaffold(
        backgroundColor: context.colors.window,
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
                'Could not load booking'.s(16).w(600),
                8.kh,
                Text(
                  _error ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                ),
                16.kh,
                TextButton(onPressed: _load, child: const Text('Retry')),
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
      backgroundColor: context.colors.window,
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
                                    errorWidget: (_, __, ___) => Assets
                                        .images.defaultImage
                                        .image(fit: BoxFit.cover),
                                  ),
                                )
                              : Assets.images.defaultImage.image(
                                  fit: BoxFit.cover),
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
                        child: _StatusBadge(status: order.status),
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
                    _buildQuickChips(),
                    20.kh,
                    _InfoCard(
                      icon: Icons.confirmation_number_outlined,
                      iconBg: primary.withOpacity(0.08),
                      iconColor: primary,
                      label: 'booking_id'.tr(),
                      value: '#${order.id.substring(
                          (order.id.length - 8).clamp(0, order.id.length))}',
                    ),
                    12.kh,
                    _InfoCard(
                      icon: Icons.people_alt_outlined,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: const Color(0xFF4338CA),
                      label: 'Seats',
                      value:
                          '${order.totalSeats} ${order.totalSeats == 1 ? 'person' : 'people'}',
                    ),
                    12.kh,
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
                      valueWidget: Text(
                        order.totalAmount.toRawUzsPrice(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: order.isPending
                              ? const Color(0xFFEA580C)
                              : const Color(0xFF059669),
                        ),
                      ),
                    ),
                    if (_branchTitle() != null) ...[
                      12.kh,
                      _InfoCard(
                        icon: Icons.location_on_outlined,
                        iconBg: const Color(0xFFF5F3FF),
                        iconColor: const Color(0xFF7C3AED),
                        label: 'Location',
                        value: _branchTitle()!,
                      ),
                    ],
                    if (_classFull?.duration() != null) ...[
                      20.kh,
                      Row(
                        children: [
                          Expanded(
                            child: _DetailCard(
                              icon: Icons.timer_outlined,
                              iconBg: const Color(0xFF3B82F6).withOpacity(0.1),
                              iconColor: const Color(0xFF3B82F6),
                              label: 'Duration',
                              value: _formatDuration(_classFull?.duration()),
                            ),
                          ),
                          12.kw,
                          Expanded(
                            child: _DetailCard(
                              icon: _genderIcon(),
                              iconBg: _genderColor().withOpacity(0.1),
                              iconColor: _genderColor(),
                              label: 'Gender & Age',
                              value: _genderLabel(),
                              subtitle:
                                  '${_classFull?.ageFrom ?? 0}-${_classFull?.ageTo ?? 0} years old',
                              subtitleColor: _genderColor(),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_classDescription() != null) ...[
                      24.kh,
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
                                'About this class'
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
                    if (detail.tickets.isNotEmpty) ...[
                      24.kh,
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
                              '${detail.tickets.length} tickets',
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
                      ...detail.tickets.map((t) => Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: _TicketRow(
                              ticket: t,
                              className:
                                  _classFullTitle() ?? order.activityName,
                              branch: _branchTitle(),
                              primary: primary,
                            ),
                          )),
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
                    context.colors.window.withOpacity(0),
                    context.colors.window.withOpacity(0.95),
                    context.colors.window,
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
    if (order.isPending) {
      return _CtaButton(
        label: _launchingPayment ? 'Opening...' : 'pay_now'.tr(),
        color: primary,
        icon: Icons.payments_rounded,
        enabled: !_launchingPayment,
        loading: _launchingPayment,
        onTap: _pay,
      );
    }
    if (order.isCanceled) {
      return _CtaButton(
        label: 'Cancelled',
        color: Colors.grey.shade400,
        icon: Icons.cancel_outlined,
        enabled: false,
      );
    }
    // Paid order: show cancel button only when ≥ 12 hours before the booking.
    if (_canCancel()) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CtaButton(
            label: _cancelling ? 'Cancelling...' : 'Cancel Booking',
            color: const Color(0xFFEF4444),
            icon: Icons.cancel_outlined,
            enabled: !_cancelling,
            loading: _cancelling,
            onTap: _cancel,
          ),
          8.kh,
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    color: const Color(0xFF16A34A), size: 16.w),
                6.kw,
                'Paid'.s(13).w(600).c(const Color(0xFF16A34A)),
              ],
            ),
          ),
        ],
      );
    }
    return _CtaButton(
      label: 'Paid',
      color: const Color(0xFF16A34A),
      icon: Icons.check_circle_outline,
      enabled: false,
    );
  }

  Widget _buildQuickChips() {
    final detail = _detail!;
    final firstTicket = detail.tickets.firstOrNull;
    final ticketDate = firstTicket?.ticketDate;
    final firstSchedule = _classFull?.schedule.firstOrNull;
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        if (ticketDate != null && ticketDate.isNotEmpty)
          _QuickChip(
            icon: Icons.calendar_today_rounded,
            label: _formatDate(ticketDate),
            bgColor: const Color(0xFFEEF2FF),
            iconColor: const Color(0xFF4338CA),
            textColor: const Color(0xFF4338CA),
          ),
        if (firstSchedule != null)
          _QuickChip(
            icon: Icons.access_time_rounded,
            label:
                '${firstSchedule.startTime} - ${firstSchedule.endTime}',
            bgColor: const Color(0xFFF8FAFC),
            iconColor: const Color(0xFF475569),
            textColor: const Color(0xFF475569),
          ),
        if (_classFull != null)
          _QuickChip(
            icon: Icons.child_care_rounded,
            label: '${_classFull!.ageFrom}-${_classFull!.ageTo} y.o',
            bgColor: const Color(0xFFF0FDF4),
            iconColor: const Color(0xFF16A34A),
            textColor: const Color(0xFF15803D),
          ),
        _QuickChip(
          icon: _genderIcon(),
          label: _genderLabel(),
          bgColor: _genderColor().withOpacity(0.08),
          iconColor: _genderColor(),
          textColor: _genderColor(),
        ),
      ],
    );
  }

  List<String> _resolveImages() {
    final imgs = <String>[];
    final classImages = _classFull?.images ?? const [];
    imgs.addAll(classImages);
    final activityId = _detail!.order.activityId;
    if (imgs.isEmpty && activityId != null) {
      imgs.add(PhotoService.getImageUrl(activityId));
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
    return (v != null && v.isNotEmpty) ? v : null;
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

extension _ClassFullDuration on ClassFullModel {
  int? duration() {
    // Prefer schedule-derived duration when slots exist.
    if (schedule.isNotEmpty) {
      final s = schedule.first;
      try {
        final start = s.startTime.split(':');
        final end = s.endTime.split(':');
        if (start.length >= 2 && end.length >= 2) {
          final startMin = int.parse(start[0]) * 60 + int.parse(start[1]);
          final endMin = int.parse(end[0]) * 60 + int.parse(end[1]);
          final diff = endMin - startMin;
          if (diff > 0) return diff;
        }
      } catch (_) {}
    }
    // Fallback: max finite duration across all age-tier duration options.
    final finiteDurations = ageTiers
        .expand((t) => t.durations)
        .where((d) => d.duration != null && d.duration! > 0)
        .map((d) => d.duration!)
        .toList();
    if (finiteDurations.isNotEmpty) {
      return finiteDurations.reduce((a, b) => a > b ? a : b);
    }
    return null;
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({
    required this.ticket,
    required this.className,
    required this.branch,
    required this.primary,
  });

  final OrderTicket ticket;
  final String? className;
  final String? branch;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router.push(TicketReceiptRoute(
        ticket: ticket,
        className: className,
        branch: branch,
      )),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.confirmation_number_rounded,
                  color: primary, size: 22.w),
            ),
            12.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ticket.ticketNo != null
                              ? '#${ticket.ticketNo}'
                              : 'Ticket pending',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'ID: ${ticket.id.substring((ticket.id.length - 6).clamp(0, ticket.id.length))}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  4.kh,
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 11.sp, color: const Color(0xFF94A3B8)),
                      4.kw,
                      Text(
                        ticket.ticketDate,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      10.kw,
                      Icon(Icons.payments_outlined,
                          size: 11.sp, color: const Color(0xFF94A3B8)),
                      4.kw,
                      Text(
                        ticket.price.toRawUzsPrice(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.sp, color: const Color(0xFF94A3B8)),
          ],
        ),
      ),
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
      case 'paid':
        color = const Color(0xFF16A34A);
        label = 'Paid';
        break;
      case 'canceled':
      case 'cancelled':
        color = const Color(0xFFEF4444);
        label = 'Cancelled';
        break;
      default:
        color = const Color(0xFFF59E0B);
        label = 'Pending';
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

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.textColor,
  });
  final IconData icon;
  final String label;
  final Color bgColor, iconColor, textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: iconColor),
          6.kw,
          Text(label,
              style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
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

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String label, value;
  final String? subtitle;
  final Color? subtitleColor;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12.r)),
            child: Icon(icon, color: iconColor, size: 20.w),
          ),
          10.kh,
          label.s(11).w(500).c(const Color(0xFF64748B)),
          4.kh,
          value.s(14).w(700).c(const Color(0xFF1E293B)),
          if (subtitle != null) ...[
            2.kh,
            subtitle!.s(12).w(500).c(subtitleColor ?? const Color(0xFF64748B))
          ],
        ],
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
