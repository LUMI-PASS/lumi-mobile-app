import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart' hide CupertinoPageTransition;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/router/initial_guard.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/presentation/app/connection_error/connection_error_page.dart';
import 'package:lumi_pass/presentation/app/home/booking_complete/booking_complete_page.dart';
import 'package:lumi_pass/presentation/app/home/branch_detail/branch_detail_page.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/class_detail_page.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/booking_page.dart';
import 'package:lumi_pass/presentation/app/home/coupons/coupons_page.dart';
import 'package:lumi_pass/presentation/app/home/plans/payment_history_page.dart';
import 'package:lumi_pass/presentation/app/home/plans/plans_page.dart';
import 'package:lumi_pass/presentation/app/home/see_all/classes_grid_page.dart';
import 'package:lumi_pass/presentation/app/main/main_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/calendar_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/home_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/profile/profile_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/branches_map_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/search_discovery_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/search_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/shorts/shorts_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/wallet_page.dart';
import 'package:lumi_pass/presentation/app/profile/children/child_detail_page.dart';
import 'package:lumi_pass/presentation/app/profile/language/change_language_page.dart';
import 'package:lumi_pass/presentation/app/profile/payment/add_new_card_page.dart';
import 'package:lumi_pass/presentation/app/profile/payment/checkout_page.dart';
import 'package:lumi_pass/presentation/app/profile/payment/payment_cards_page.dart';
import 'package:lumi_pass/presentation/app/profile/payment/payment_page.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/profile_detail_page.dart';
import 'package:lumi_pass/presentation/auth/login/login_page.dart';
import 'package:lumi_pass/presentation/auth/register/register_page.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';
import 'package:lumi_pass/presentation/start/onboard/onboard_page.dart';
import 'package:lumi_pass/presentation/start/welcome/welcome_page.dart';
import 'package:lumi_pass/presentation/start/language/language_page.dart';

import '../../data/api_model/child_model/child_model.dart';
import '../../data/api_model/order/user_order.dart';
import '../../presentation/app/profile/attendance/attendance_detail_page.dart';
import '../../presentation/app/profile/attendance/attendance_history_page.dart';
import '../../presentation/app/profile/children/add_child_page.dart';
import '../../presentation/app/profile/faq/faq_page.dart';
import '../../presentation/app/profile/my_bookings/my_bookings_page.dart';
import '../../presentation/app/main/subscreens/calendar/widget/schedule_detail_page.dart';
import '../../presentation/app/main/subscreens/calendar/widget/ticket_receipt_page.dart';
import '../../presentation/app/main/subscreens/calendar/widget/fiscal_receipt_page.dart';
import '../../presentation/app/notifications/notifications_page.dart';
import 'empty_route.dart';

part 'app_router.gr.dart';

/// Fade transition for web (fast), slide for mobile.
Widget _webTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  if (kIsWeb) return FadeTransition(opacity: animation, child: child);
  final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
      .chain(CurveTween(curve: Curves.fastOutSlowIn));
  return SlideTransition(position: animation.drive(tween), child: child);
}

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => kIsWeb
      ? const RouteType.custom(
          transitionsBuilder: _webTransition,
          durationInMilliseconds: 120,
          reverseDurationInMilliseconds: 100,
        )
      : const RouteType.cupertino();

  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      page: EmptyRouterRoute.page,
      path: '/',
      guards: [InitialGuard()],
    ),

    /// Auth
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: VerifyRoute.page),

    /// Start
    AutoRoute(page: WelcomeRoute.page),
    AutoRoute(page: LanguageRoute.page),
    AutoRoute(page: OnboardingRoute.page),

    /// Main
    AutoRoute(
      page: MainRoute.page,
      children: [
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: ShortsRoute.page),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: CalendarRoute.page),
        AutoRoute(page: WalletRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),

    ///Subscreens

    AutoRoute(page: ClassDetailRoute.page),
    AutoRoute(page: BranchDetailRoute.page),
    AutoRoute(page: BookingRoute.page),
    AutoRoute(page: BookingCompleteRoute.page),
    AutoRoute(page: ProfileDetailRoute.page),
    AutoRoute(page: ChildDetailRoute.page),
    AutoRoute(page: AddChildRoute.page),
    AutoRoute(page: ChangeLanguageRoute.page),
    AutoRoute(page: PaymentRoute.page),
    AutoRoute(page: PaymentCardsRoute.page),
    AutoRoute(page: AddNewCardRoute.page),
    AutoRoute(page: CheckoutRoute.page),
    AutoRoute(page: SearchDiscoveryRoute.page),
    AutoRoute(page: BranchesMapRoute.page),
    AutoRoute(page: AttendanceHistoryRoute.page),
    AutoRoute(page: AttendanceDetailRoute.page),
    AutoRoute(page: FaqRoute.page),
    AutoRoute(page: BookingDetailRoute.page),
    AutoRoute(page: TicketReceiptRoute.page),
    AutoRoute(page: FiscalReceiptRoute.page),
    AutoRoute(page: MyBookingsRoute.page),
    AutoRoute(page: PlansRoute.page),
    AutoRoute(page: PaymentHistoryRoute.page),
    AutoRoute(page: ClassesGridRoute.page),
    AutoRoute(page: CouponsRoute.page),
    AutoRoute(page: NotificationsRoute.page),
    AutoRoute(page: ConnectionErrorRoute.page),
  ];
}
