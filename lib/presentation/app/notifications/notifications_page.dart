import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/notification_model/notification_model.dart';
import 'package:lumi_pass/data/api_model/notification_model/notification_type.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/notifications/notifications_api.dart';

class _DateSeparator {
  const _DateSeparator(this.label);
  final String label;
}

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
    if (n.notificationType.isBooking) {
      context.router.push(const MyBookingsRoute());
    }
  }

  Future<void> _delete(NotificationModel n) async {
    setState(() =>
        _notifications = _notifications.where((i) => i.id != n.id).toList());
    _api.deleteNotification(n.id).catchError((_) {});
  }

  bool get _hasUnread => _notifications.any((n) => !n.isRead);

  /// Builds the flat list of rows, inserting a date separator before each
  /// new calendar day (newest first).
  List<Object> _buildRows() {
    final sorted = [..._notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final rows = <Object>[];
    String? lastKey;
    for (final n in sorted) {
      final d = n.createdAt;
      final key = '${d.year}-${d.month}-${d.day}';
      if (key != lastKey) {
        rows.add(_DateSeparator(_dateLabel(d)));
        lastKey = key;
      }
      rows.add(n);
    }
    return rows;
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return Strings.notificationToday;
    if (date == yesterday) return Strings.notificationYesterday;
    return DateFormat('MMMM d, yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top + 8.h,
        left: 16.w,
        right: 16.w,
        bottom: 12.h,
      ),
      child: SizedBox(
        height: 40.h,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                Strings.notificationsTitle,
                style: AppText.semibold16.copyWith(color: AppColors.ink),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FrostedCard(
                onTap: () => context.router.maybePop(),
                width: 36.w,
                height: 36.w,
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                borderWidth: 1.5,
                child: Assets.icons.arrowLeftRounded.svg(
                  width: 18.w,
                  height: 18.w,
                  colorFilter:
                      const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
                ),
              ),
            ),
            if (_hasUnread)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _markAllRead,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(48.r),
                    ),
                    child: Text(
                      Strings.notificationsMarkAllRead,
                      style: AppText.medium12.copyWith(color: AppColors.greeting),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: const CircularProgressIndicator(
            color: AppColors.ink,
            strokeWidth: 2.5,
          ),
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
                color: AppColors.error.withAlpha(24),
                shape: BoxShape.circle,
              ),
              child: Assets.icons.notification.close.svg(
                width: 30.w,
                height: 30.w,
                colorFilter:
                    const ColorFilter.mode(AppColors.error, BlendMode.srcIn),
                fit: BoxFit.scaleDown,
              ),
            ),
            16.verticalSpace,
            GestureDetector(
              onTap: _load,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(48.r),
                ),
                child: Text(
                  'retry'.tr(),
                  style: AppText.medium14.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 46.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.icons.notification.bell.svg(
                width: 40.w,
                height: 40.w,
                colorFilter:
                    const ColorFilter.mode(Color(0xFFA5A6BB), BlendMode.srcIn),
              ),
              12.verticalSpace,
              Text(
                Strings.notificationsEmpty,
                textAlign: TextAlign.center,
                style: AppText.semibold16
                    .copyWith(fontSize: 20.sp, color: AppColors.ink),
              ),
              4.verticalSpace,
              Text(
                'notifications_empty_sub'.tr(),
                textAlign: TextAlign.center,
                style: AppText.regular14.copyWith(color: AppColors.greeting),
              ),
            ],
          ),
        ),
      );
    }

    final rows = _buildRows();
    return RefreshIndicator(
      color: AppColors.ink,
      backgroundColor: Colors.white,
      onRefresh: _load,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          if (row is _DateSeparator) {
            return _DateHeader(label: row.label);
          }
          final n = row as NotificationModel;
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _NotificationCard(
              notification: n,
              onTap: () => _onTap(n),
              onDismiss: () => _delete(n),
            ),
          );
        },
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(48.r),
          ),
          child: Text(
            label,
            style: AppText.medium12.copyWith(color: AppColors.greeting),
          ),
        ),
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

  SvgGenImage get _icon {
    switch (notification.notificationType) {
      case NotificationType.bookingApproved:
        return Assets.icons.notification.tick;
      case NotificationType.bookingRejected:
        return Assets.icons.notification.close;
      case NotificationType.bookingTimeSuggestion:
        return Assets.icons.notification.idea;
      case NotificationType.bookingRequestPending:
        return Assets.icons.notification.clock;
      case NotificationType.unknown:
        return Assets.icons.notification.bell;
    }
  }

  Color get _iconColor {
    switch (notification.notificationType) {
      case NotificationType.bookingApproved:
        return AppColors.tagGreen;
      case NotificationType.bookingRejected:
        return AppColors.error;
      case NotificationType.bookingTimeSuggestion:
      case NotificationType.bookingRequestPending:
        return const Color(0xFFEF8E48);
      case NotificationType.unknown:
        return const Color(0xFFA5A6BB);
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
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Assets.icons.notification.close.svg(
          width: 22.w,
          height: 22.w,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: FrostedCard(
        onTap: onTap,
        padding: EdgeInsets.all(16.w),
        alignment: Alignment.topLeft,
        borderWidth: 2,
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEDF4),
                shape: BoxShape.circle,
              ),
              child: _icon.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(_iconColor, BlendMode.srcIn),
                fit: BoxFit.scaleDown,
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style:
                              AppText.semibold14.copyWith(color: AppColors.ink),
                        ),
                      ),
                      if (!notification.isRead) ...[
                        8.horizontalSpace,
                        Container(
                          margin: EdgeInsets.only(top: 6.h),
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  6.verticalSpace,
                  Text(
                    notification.body,
                    style: AppText.regular13.copyWith(color: AppColors.greeting),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.verticalSpace,
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateFormat('d MMM, HH:mm').format(notification.createdAt),
                      style: AppText.medium10.copyWith(color: AppColors.greeting),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
