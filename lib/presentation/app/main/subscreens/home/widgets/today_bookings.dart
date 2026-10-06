import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/order/day_booking.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_common.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';

/// "Bugun borilishi kerak" — what the user has to attend today, soonest first.
///
/// The first thing on the home feed, ahead of the banner carousel: a parent
/// opening the app in the morning is answering "where do we have to be today",
/// and that question outranks every promo on the screen. It used to be
/// answerable only by opening the bookings list and reading dates off cards.
///
/// Renders NOTHING — not even its gap — when there is nothing due, which is
/// the ordinary case on most days, and when everything due has already
/// finished. The clock is read at build time rather than at fetch time (see
/// [DayBooking.stillToCome]) so a lesson drops off the shelf as it ends,
/// without waiting for a refresh.
class TodayBookingsShelf extends StatelessWidget {
  const TodayBookingsShelf({super.key, required this.bookings, this.now});

  /// Everything due today, in the cubit's order. Filtered against the clock
  /// here.
  final List<DayBooking> bookings;

  /// Overridable only for tests; the shelf otherwise reads the real clock.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final at = now ?? DateTime.now();
    final due = DayBooking.stillToCome(bookings, at);
    if (due.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.verticalSpace,
        HomeSectionHeader(
          title: 'today_to_attend'.tr(),
          // Today is a slice of the bookings list, so "see all" lands on the
          // whole of it rather than on a filtered copy of this shelf.
          onViewAll: () => context.router.push(const MyBookingsRoute()),
          viewAllLabel: 'view_all_bookings'.tr(),
        ),
        10.verticalSpace,
        for (final booking in due)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _TodayBookingCard(booking: booking, now: at),
          ),
        4.verticalSpace,
      ],
    );
  }
}

/// One visit: the clock on the left, what and where on the right.
///
/// The time leads because the shelf is read as a timetable — the question is
/// "what is next", and the answer has to be legible without reading the
/// activity names.
class _TodayBookingCard extends StatelessWidget {
  const _TodayBookingCard({required this.booking, required this.now});

  final DayBooking booking;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final order = booking.order;
    final underway = booking.isUnderwayAt(now);
    final image = (order.activityImage?.isNotEmpty ?? false)
        ? order.activityImage
        : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: FrostedCard(
        onTap: () =>
            context.router.push(BookingDetailRoute(orderId: order.id)),
        padding: EdgeInsets.all(10.w),
        borderRadius: BorderRadius.circular(20.r),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: SizedBox(
                width: 52.w,
                height: 52.w,
                child: image != null
                    ? CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: c.control),
                        errorWidget: (_, __, ___) => Container(color: c.control),
                      )
                    : Container(color: c.control),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          order.activityName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.semibold14
                              .copyWith(color: c.textPrimary),
                        ),
                      ),
                      // "Now", while the lesson is actually running — the one
                      // state worth colouring, because it changes what the
                      // reader does about it.
                      if (underway) ...[
                        6.horizontalSpace,
                        const _NowPill(),
                      ],
                    ],
                  ),
                  4.verticalSpace,
                  Row(
                    children: [
                      HomeIcon(Assets.icons.time, size: 14, color: c.primary),
                      4.horizontalSpace,
                      Text(
                        // A booking whose activity sent no timetable and whose
                        // seat recorded no slot still belongs here — it has
                        // been paid for and it is today — so the clock falls
                        // back to naming the day rather than printing nothing.
                        booking.timeLabel.isEmpty
                            ? 'today'.tr()
                            : booking.timeLabel,
                        style: AppText.semibold12.copyWith(color: c.primary),
                      ),
                      // Seats, when the order booked more than one place on
                      // this slot — two children at the same morning is one
                      // place to be, but it is still two tickets to carry.
                      if (booking.seats > 1) ...[
                        6.horizontalSpace,
                        Text(
                          '×${booking.seats}',
                          style: AppText.medium12
                              .copyWith(color: c.textSecondary),
                        ),
                      ],
                    ],
                  ),
                  if ((order.branchName ?? '').isNotEmpty) ...[
                    2.verticalSpace,
                    Row(
                      children: [
                        HomeIcon(
                          Assets.icons.detail.icLocation,
                          size: 14,
                          color: c.textSecondary,
                        ),
                        4.horizontalSpace,
                        Expanded(
                          child: Text(
                            order.branchName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.regular12
                                .copyWith(color: c.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            6.horizontalSpace,
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: c.textPlaceholder,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Hozir" — the lesson is happening right now.
class _NowPill extends StatelessWidget {
  const _NowPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColors.green.withOpacity(0.12),
        borderRadius: BorderRadius.circular(48.r),
        border: Border.all(color: AppColors.green.withOpacity(0.32)),
      ),
      child: Text(
        'booking_now'.tr(),
        style: AppText.medium10.copyWith(color: AppColors.green),
      ),
    );
  }
}
