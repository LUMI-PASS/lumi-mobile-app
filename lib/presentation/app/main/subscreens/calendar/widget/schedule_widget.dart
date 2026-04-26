import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:shimmer/shimmer.dart';
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

/// One row in the Bookings tab. Represents a single order (transaction),
/// which may contain multiple seats (tickets). Tap to open [BookingDetailRoute].
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.order});

  final UserOrder order;

  String _formatDateTime(String? iso) {
    if (iso == null) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '${months[d.month - 1]} ${d.day}, $hh:$mm';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final imageUrl = order.activityId != null
        ? PhotoService.getImageUrl(order.activityId!)
        : null;
    final seats = order.totalSeats;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          context.router.push(BookingDetailRoute(orderId: order.id)),
      child: Padding(
        padding: EdgeInsets.only(bottom: 14.h),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3C539A).withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top row: image + title + status
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: SizedBox(
                        width: 72.w,
                        height: 72.w,
                        child: imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade50,
                                  child: Container(color: Colors.white),
                                ),
                                errorWidget: (_, __, ___) =>
                                    Assets.images.defaultImage.image(
                                        fit: BoxFit.cover),
                              )
                            : Assets.images.defaultImage.image(
                                fit: BoxFit.cover),
                      ),
                    ),
                    12.kw,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  order.activityName ?? 'Class',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              8.kw,
                              _OrderStatusPill(status: order.status),
                            ],
                          ),
                          6.kh,
                          Row(
                            children: [
                              Icon(Icons.people_alt_rounded,
                                  size: 12.sp, color: const Color(0xFF64748B)),
                              4.kw,
                              Text(
                                '$seats ${seats == 1 ? 'person' : 'people'}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              10.kw,
                              Icon(Icons.schedule_rounded,
                                  size: 12.sp, color: const Color(0xFF64748B)),
                              4.kw,
                              Flexible(
                                child: Text(
                                  _formatDateTime(order.createdAt),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: const Color(0xFF475569),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade100),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
                child: Row(
                  children: [
                    Text(
                      order.isPending ? 'Amount due' : 'Total',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      order.totalAmount.toRawUzsPrice(),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              if (order.isPending)
                _PayNowFooter(
                  order: order,
                  color: primary,
                )
              else
                Padding(
                  padding: EdgeInsets.only(
                      left: 14.w, right: 14.w, bottom: 12.h),
                  child: Row(
                    children: [
                      const Spacer(),
                      'View details'.s(12).w(600).c(primary),
                      4.kw,
                      Icon(Icons.arrow_forward_rounded,
                          size: 14.sp, color: primary),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayNowFooter extends StatefulWidget {
  const _PayNowFooter({required this.order, required this.color});

  final UserOrder order;
  final Color color;

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
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
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
                Icon(Icons.payments_rounded,
                    size: 16.sp, color: Colors.white),
              8.kw,
              (_launching ? 'Opening...' : 'Pay now')
                  .s(13)
                  .w(700)
                  .c(Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderStatusPill extends StatelessWidget {
  const _OrderStatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;
    switch (status.toLowerCase()) {
      case 'paid':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF16A34A);
        label = 'Paid';
        break;
      case 'canceled':
      case 'cancelled':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        label = 'Cancelled';
        break;
      default:
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFB45309);
        label = 'Pending';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
          ),
          6.kw,
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
