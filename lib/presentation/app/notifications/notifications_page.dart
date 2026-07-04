import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/notification_model/notification_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/notifications/notifications_api.dart';

const _kBookingTypes = {
  'booking_approved',
  'booking_rejected',
  'booking_time_suggestion',
  'booking_request_pending',
};

@RoutePage()
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _api = getIt<NotificationsApi>();

  List<NotificationModel> _notifications = const [];
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
      final items = await _api.getNotifications(limit: 50);
      if (!mounted) return;
      setState(() {
        _notifications = items;
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

  Future<void> _markAllRead() async {
    try {
      await _api.markAllRead();
      if (!mounted) return;
      setState(() {
        _notifications =
            _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    } catch (_) {}
  }

  Future<void> _onTap(NotificationModel n) async {
    if (!n.isRead) {
      setState(() {
        _notifications = _notifications
            .map((item) => item.id == n.id ? item.copyWith(isRead: true) : item)
            .toList();
      });
      _api.markRead(n.id).catchError((_) {});
    }
    if (_kBookingTypes.contains(n.type)) {
      context.router.push(const MyBookingsRoute());
    }
  }

  Future<void> _delete(NotificationModel n) async {
    setState(() =>
        _notifications = _notifications.where((i) => i.id != n.id).toList());
    _api.deleteNotification(n.id).catchError((_) {});
  }

  bool get _hasUnread => _notifications.any((n) => !n.isRead);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top + 8.h,
        left: 16.w,
        right: 16.w,
        bottom: 12.h,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.router.maybePop(),
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EEFF),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16.sp,
                color: const Color(0xFF6C4EF2),
              ),
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Text(
              Strings.notificationsTitle,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E3D5D),
                letterSpacing: -0.3,
              ),
            ),
          ),
          if (_hasUnread)
            GestureDetector(
              onTap: _markAllRead,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFF),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  Strings.notificationsMarkAllRead,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6C4EF2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: const CircularProgressIndicator(
                color: Color(0xFF6C4EF2),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  color: Colors.red.shade300, size: 32.sp),
            ),
            16.verticalSpace,
            GestureDetector(
              onTap: _load,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C4EF2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'retry'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFEDE7FF), Color(0xFFE8F5FF)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 36.sp,
                color: const Color(0xFF6C4EF2),
              ),
            ),
            20.verticalSpace,
            Text(
              Strings.notificationsEmpty,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3D5D),
              ),
            ),
            8.verticalSpace,
            Text(
              'notifications_empty_sub'.tr(),
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF91A2C3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF6C4EF2),
      backgroundColor: Colors.white,
      onRefresh: _load,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => 8.verticalSpace,
        itemBuilder: (context, index) {
          return _NotificationCard(
            notification: _notifications[index],
            onTap: () => _onTap(_notifications[index]),
            onDismiss: () => _delete(_notifications[index]),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  IconData get _icon {
    switch (notification.type) {
      case 'booking_approved':
        return Icons.check_circle_outline_rounded;
      case 'booking_rejected':
        return Icons.cancel_outlined;
      case 'booking_time_suggestion':
        return Icons.access_time_rounded;
      case 'booking_request_pending':
        return Icons.hourglass_bottom_rounded;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'booking_approved':
        return const Color(0xFF22C55E);
      case 'booking_rejected':
        return const Color(0xFFEF4444);
      case 'booking_time_suggestion':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6C4EF2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22.sp),
      ),
      onDismissed: (_) => onDismiss(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notification.isRead
                  ? const Color(0xFFE8EAF0)
                  : const Color(0xFFD4CCFF),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: notification.isRead
                    ? const Color(0x06000000)
                    : const Color(0x0F6C4EF2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: _iconColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(_icon, color: _iconColor, size: 20.sp),
              ),
              12.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                              color: const Color(0xFF2E3D5D),
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          6.horizontalSpace,
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6C4EF2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    6.verticalSpace,
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFF6B7A99),
                        height: 1.45,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.verticalSpace,
                    Text(
                      _formatTime(notification.createdAt, context),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFFB0BEC5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt, BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    final hm =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

    if (date == today) return '${Strings.notificationToday}, $hm';
    if (date == yesterday) return '${Strings.notificationYesterday}, $hm';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}, $hm';
  }
}
