import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/schedule_widget.dart';
import 'package:shimmer/shimmer.dart';

/// Profile → My Bookings. Tabs split the order list into Active (pending or
/// paid with a future ticket date) and Past (everything else, including
/// canceled). Uses the same [BookingCard] the Bookings tab renders.
@RoutePage()
class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<UserOrder> _orders = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await getIt<OrdersApi>().getOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
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

  bool _isActive(UserOrder o) {
    if (o.isCanceled) return false;
    // Pending orders stay "active" until the user cancels or pays; paid
    // orders stay active until they're in the past.
    final updated = o.updatedAt ?? o.createdAt;
    if (o.isPending) {
      // Pending older than 24h are effectively stale — still show as active;
      // the user might want to retry payment.
      return true;
    }
    if (updated == null) return o.isPaid;
    try {
      final d = DateTime.parse(updated);
      final now = DateTime.now();
      // Paid orders remain active for 24h after update as a coarse filter;
      // backend doesn't yet expose a per-order future/past flag.
      return d.isAfter(now.subtract(const Duration(days: 1))) || o.isPaid;
    } catch (_) {
      return o.isPaid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final active = _orders.where(_isActive).toList();
    final past = _orders.where((o) => !_isActive(o) || o.isCanceled).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: context.colors.window,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: const Color(0xFF1E293B),
          title: 'my_bookings'.tr().s(18).w(700),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: TabBar(
              labelColor: primary,
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: primary,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w700),
              unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp, fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: '${'active_bookings'.tr()} (${active.length})'),
                Tab(text: '${'past_bookings'.tr()} (${past.length})'),
              ],
            ),
          ),
        ),
        body: _loading
            ? _Shimmer()
            : (_error != null)
                ? _ErrorState(message: _error!, onRetry: _load)
                : TabBarView(
                    children: [
                      _OrdersList(orders: active, onRefresh: _load),
                      _OrdersList(orders: past, onRefresh: _load),
                    ],
                  ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.orders, required this.onRefresh});

  final List<UserOrder> orders;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        color: context.colors.primary,
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 120.h),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72.w,
                    height: 72.w,
                    decoration: BoxDecoration(
                      color: context.colors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_rounded,
                        size: 36.w,
                        color: context.colors.primary.withOpacity(0.4)),
                  ),
                  16.kh,
                  'no_bookings_yet'
                      .tr()
                      .s(15)
                      .w(600)
                      .c(const Color(0xFF1E293B)),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: context.colors.primary,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: orders.length,
        itemBuilder: (_, i) => BookingCard(order: orders[i]),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          width: double.infinity,
          height: 150.h,
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48.w, color: Colors.red.shade400),
            16.kh,
            'Could not load bookings'.s(16).w(600),
            8.kh,
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
            16.kh,
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
