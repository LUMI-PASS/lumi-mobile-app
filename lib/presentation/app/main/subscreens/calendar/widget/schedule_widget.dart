import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/order/course_purchase.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/common/widget/purchase_kind_chip.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens Paycom for [order] from any surface. Falls back through several
/// [LaunchMode]s because some Android builds block `externalApplication` when
/// a matching browser isn't set as default, and iOS simulators sometimes
/// refuse `externalNonBrowserApplication`.
Future<void> payForOrder(BuildContext context, UserOrder order) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final api = getIt<OrdersApi>();
    final detail = await api.getOrderDetail(order.id);
    String? url = detail.checkoutUrl;
    if (url == null || url.isEmpty) {
      // GET /orders/:id doesn't return checkout_url, so re-initiate
      // checkout with the existing order's own data to get a fresh URL.
      final activityId = detail.order.activityId;
      final ticketDate = detail.earliestTicketDate;
      if (activityId != null &&
          ticketDate != null &&
          detail.order.items.isNotEmpty) {
        final result = await api.checkout(
          activityId: activityId,
          items: detail.order.items
              .map((i) => CheckoutItem(
                    ageFrom: i.ageFrom,
                    ageTo: i.ageTo,
                    count: i.count,
                  ))
              .toList(),
          ticketDate: ticketDate,
        );
        url = result.checkoutUrl.isNotEmpty ? result.checkoutUrl : null;
      }
    }
    if (url == null || url.isEmpty) {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Payment link is not available yet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    for (final mode in const [
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
      LaunchMode.inAppBrowserView,
    ]) {
      if (await launchUrl(uri, mode: mode)) return;
    }
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Could not open the payment page.'),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    messenger?.showSnackBar(
      SnackBar(
        content: Text('Payment failed to start: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// One card in the Bookings tab (redesign — Figma 96-3204). Represents a single
/// order (transaction), which may hold multiple seats. Tap → [BookingDetailRoute].
///
/// Dark reference, but rendered on the design-system tokens so it also works in
/// light. Shared with the profile "My bookings" screen.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.order});

  final UserOrder order;

  /// "22 апр" — day + short month.
  String _dateOnly(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day} ${'month_short_${d.month}'.tr()}';
    } catch (_) {
      return '';
    }
  }

  /// "22 апр 09:00 - 10:00" — first ticket's session date + the time to show.
  ///
  /// The time is whatever [UserOrder.displayTimeRange] resolves to: the slot
  /// the buyer picked, or the activity's own schedule when they picked none.
  String _sessionDateTime() {
    if (order.ticketSummaries.isEmpty) return '';
    final date = _dateOnly(order.ticketSummaries.first.ticketDate);
    final time = order.displayTimeRange ?? '';
    if (time.isEmpty) return date;
    return date.isEmpty ? time : '$date $time';
  }

  /// "22 апр 10:00" — a lesson's date, plus its own time when it has one and
  /// the order's resolved time otherwise.
  String _lessonWhen(OrderTicketSummary lesson) {
    final date = _dateOnly(lesson.ticketDate);
    final start = lesson.startTime ?? '';
    final time = start.isNotEmpty ? start : (order.displayTimeRange ?? '');
    if (time.isEmpty) return date;
    return date.isEmpty ? time : '$date $time';
  }

  /// "3-6 лет" — first item's age range.
  String _ageRange() {
    if (order.items.isEmpty) return '';
    final it = order.items.first;
    final to = it.ageTo >= 99 ? '∞' : '${it.ageTo}';
    return '${it.ageFrom}-$to ${'age_years_suffix'.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final imageUrl =
        (order.activityImage != null && order.activityImage!.isNotEmpty)
            ? order.activityImage
            : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router.push(BookingDetailRoute(orderId: order.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: thumbnail + title + status badge.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: SizedBox(
                    width: 60.w,
                    height: 60.w,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: c.control),
                            errorWidget: (_, __, ___) =>
                                Container(color: c.control),
                          )
                        : Container(color: c.control),
                  ),
                ),
                12.kw,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.activityName ?? 'Class',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            AppText.semibold16.copyWith(color: c.textPrimary),
                      ),
                      // The status sits under the title, not beside it: a pill
                      // at the row's end squeezed a two-line title into three.
                      // The kind chip joins it only for a course or a trial —
                      // a single lesson is the ordinary case, and a
                      // "Mashg'ulot" chip on every card said nothing.
                      6.kh,
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: [
                          _StatusBadge(status: order.effectiveDisplayStatus),
                          if (order.coursePurchase != CoursePurchase.none)
                            PurchaseKindChip(
                              kind: order.coursePurchase,
                              subcourseName: order.subcourseName,
                              compact: true,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            16.kh,
            // Seats, and who they are for — but only when the order actually
            // names an age bracket. A course order carries none, and the row
            // used to render with an empty label beside a seat count that
            // meant nothing on a term-long enrolment.
            if (order.hasAgeBracket && order.totalSeats > 0) ...[
              _InfoRow(
                icon: Assets.icons.detail.babyGirl,
                label: _ageRange(),
                value: '${order.totalSeats}',
              ),
              12.kh,
            ],
            // A course is not a date, it is a run of lessons — how many are
            // behind you, when the next one is, when it stops. Those are the
            // three things a parent asks between enrolling and renewing, and
            // a start/end/price card answered none of them.
            if (order.hasLessonProgress) ...[
              _CourseProgress(order: order),
              12.kh,
              if (order.nextLesson != null) ...[
                _InfoRow(
                  icon: Assets.icons.detail.icCalendar,
                  label: 'course_next_lesson'.tr(),
                  value: _lessonWhen(order.nextLesson!),
                ),
                12.kh,
              ],
              _InfoRow(
                icon: Assets.icons.time,
                label: 'course_ends_on'.tr(),
                value: _dateOnly(order.endDate),
              ),
              12.kh,
            ]
            // An order that runs over several days — a course, or a class
            // booked for a run of sessions — is a span, and the two dates a
            // parent plans around are when it starts and when it ends. One
            // date and a time window is right only when there is one session.
            else if (order.spansDates) ...[
              _InfoRow(
                icon: Assets.icons.detail.icCalendar,
                label: 'filter_start_date'.tr(),
                value: _dateOnly(order.startDate),
              ),
              12.kh,
              _InfoRow(
                icon: Assets.icons.detail.icCalendar,
                label: 'filter_end_date'.tr(),
                value: _dateOnly(order.endDate),
              ),
              12.kh,
              // A span states two dates but no clock, and the sessions inside
              // it still happen at one — so the time gets its own row here
              // rather than being dropped, which is what a course enrolment
              // used to show.
              if ((order.displayTimeRange ?? '').isNotEmpty) ...[
                _InfoRow(
                  icon: Assets.icons.time,
                  label: 'order_time'.tr(),
                  value: order.displayTimeRange!,
                ),
                12.kh,
              ],
            ] else if (_sessionDateTime().isNotEmpty) ...[
              _InfoRow(
                icon: Assets.icons.detail.icCalendar,
                label: 'order_date'.tr(),
                value: _sessionDateTime(),
              ),
              12.kh,
            ],
            // Where it is. Absent on an order the server returned without a
            // populated branch, and the row is then left out rather than
            // printed empty.
            if ((order.branchName ?? '').isNotEmpty) ...[
              _InfoRow(
                icon: Assets.icons.detail.icLocation,
                label: 'ticket_venue'.tr(),
                value: order.branchName!,
              ),
              12.kh,
            ],
            _InfoRow(
              // Coins were paid: the coin itself, not a receipt glyph.
              icon: order.paidWithNewCoins
                  ? null
                  : Assets.icons.detail.iconsaxReceipt,
              leading: order.paidWithNewCoins
                  ? Assets.icons.coinLumi.image(width: 22.w, height: 22.w)
                  : null,
              label: 'order_sum'.tr(),
              // A promocode or a wallet balance that covered the whole order
              // leaves nothing to charge, and "0 so'm" reads like a bug beside
              // a real booking. Name it for what it is.
              //
              // Paid with Lumi Coin: no so'm was charged, so the row quotes
              // the coins that were.
              value: order.paidWithNewCoins
                  ? 'new_coins_amount'
                      .tr(args: [order.newCoinAmount.toGrouped()])
                  : order.totalAmount <= 0
                      ? 'price_free'.tr()
                      : order.totalAmount.toRawUzsPrice(),
            ),
            // The enrolment is running out. A push can be missed or muted;
            // this is the same warning on the surface the buyer actually opens,
            // and it is the only place the renewal is one tap away.
            if (order.endsWithin(_kRenewalWindowDays)) ...[
              12.kh,
              _RenewBanner(order: order),
            ],
            if (order.isPending) ...[
              14.kh,
              _PayNowFooter(order: order),
            ],
          ],
        ),
      ),
    );
  }
}

/// One fact on a [BookingCard]: a plain glyph, then the answer with the
/// question under it.
///
/// The answer leads and the label follows in muted 12 — on a card the reader
/// is scanning for "when" and "where", the values are what the eye should
/// land on. The glyphs are one muted colour on no tile: a tinted square per
/// row, each a different colour, made the card louder than what it said.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.leading,
  });

  final SvgGenImage? icon;

  /// In place of [icon], for a glyph that is an image — the Lumi Coin.
  final Widget? leading;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final glyph = leading ??
        icon?.svg(
          width: 20.w,
          height: 20.w,
          colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (glyph != null) ...[
          SizedBox(width: 24.w, child: Center(child: glyph)),
          12.kw,
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
              2.kh,
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.regular12.copyWith(color: c.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Booking status pill, in the same soft style as the [PurchaseKindChip]
/// beside it: the status colour as text on a 12% tint of itself. Solid fills
/// next to a tinted chip read as two different design languages on one row.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color accent, String label) = switch (status.toLowerCase()) {
      'active' => (AppColors.green, 'status_active'.tr()),
      'visited' => (AppColors.statusVisited, 'status_visited'.tr()),
      'missed' => (AppColors.statusMissed, 'status_missed'.tr()),
      'canceled' || 'cancelled' => (AppColors.error, 'status_canceled'.tr()),
      _ => (AppColors.statusMissed, 'status_pending'.tr()),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: AppText.semibold12.copyWith(color: accent),
      ),
    );
  }
}

class _PayNowFooter extends StatefulWidget {
  const _PayNowFooter({required this.order});

  final UserOrder order;

  @override
  State<_PayNowFooter> createState() => _PayNowFooterState();
}

class _PayNowFooterState extends State<_PayNowFooter> {
  bool _launching = false;

  Future<void> _onTap() async {
    if (_launching) return;
    setState(() => _launching = true);
    try {
      await payForOrder(context, widget.order);
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _launching ? null : _onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_launching)
                SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(Icons.payments_rounded, size: 16.sp, color: Colors.white),
              8.kw,
              Text(
                _launching ? 'opening_payment'.tr() : 'pay_now'.tr(),
                style: AppText.semibold14.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// How close to the last lesson a course starts asking to be renewed. Matches
/// the first step of the expiry notification ladder, so the card and the push
/// never disagree about whether a course is ending.
const int _kRenewalWindowDays = 7;

/// "Lessons 8 / 24" with a bar underneath — the one line that says where a
/// course enrolment actually stands.
class _CourseProgress extends StatelessWidget {
  const _CourseProgress({required this.order});

  final UserOrder order;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = order.totalLessons;
    final done = order.lessonsDone.clamp(0, total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24.w,
              child: Icon(
                Icons.school_rounded,
                size: 20.w,
                color: c.textSecondary,
              ),
            ),
            12.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$done / $total',
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  2.kh,
                  Text(
                    'course_lessons_progress'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.regular12.copyWith(color: c.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        10.kh,
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Stack(
            children: [
              Container(height: 6.h, color: c.control),
              FractionallySizedBox(
                widthFactor: total == 0 ? 0 : done / total,
                child: Container(
                  height: 6.h,
                  decoration: const BoxDecoration(gradient: AppGradients.brand),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The "this course is ending" strip on a course card. Tapping it opens the
/// course, which is where enrolling again happens — the card itself cannot
/// know which group or price the buyer wants next.
class _RenewBanner extends StatelessWidget {
  const _RenewBanner({required this.order});

  final UserOrder order;

  String _message() {
    final left = order.daysUntilEnd ?? 0;
    if (left <= 0) return 'course_ends_today'.tr();
    if (left == 1) return 'course_ends_tomorrow'.tr();
    return 'course_ends_in_days'.tr(args: ['$left']);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final activityId = order.activityId;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: activityId == null || activityId.isEmpty
          ? null
          : () => context.router.push(
                ClassDetailRoute(classModel: HomClass(id: activityId)),
              ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, size: 18.sp, color: AppColors.warning),
            8.kw,
            Expanded(
              child: Text(
                _message(),
                style: AppText.medium12.copyWith(color: c.textPrimary),
              ),
            ),
            8.kw,
            Text(
              'course_renew_cta'.tr(),
              style: AppText.semibold12.copyWith(color: AppColors.warning),
            ),
          ],
        ),
      ),
    );
  }
}
