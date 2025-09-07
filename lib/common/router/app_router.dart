import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:lumi_pass/common/router/initial_guard.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/home/booking_complete/booking_complete_page.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/class_detail_page.dart';
import 'package:lumi_pass/presentation/app/main/main_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/calendar_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/home_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/profile/profile_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/search_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/search_unified_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/wallet_page.dart';
import 'package:lumi_pass/presentation/app/profile/children/children_page.dart';
import 'package:lumi_pass/presentation/app/profile/payment/add_new_card_page.dart';
import 'package:lumi_pass/presentation/app/profile/payment/checkout_page.dart';
import 'package:lumi_pass/presentation/app/profile/payment/payment_cards_page.dart';
import 'package:lumi_pass/presentation/app/profile/payment/payment_page.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/profile_detail_page.dart';
import 'package:lumi_pass/presentation/auth/login/login_page.dart';
import 'package:lumi_pass/presentation/auth/register/register_page.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';
import 'package:lumi_pass/presentation/start/onboard/onboard_page.dart';

import '../../data/api_model/child_model/child_model.dart';
import '../../presentation/app/profile/children/add_child_page.dart';
import 'empty_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  final List<AutoRoute> routes = [
    AutoRoute(
      page: EmptyRouterRoute.page,
      path: '/',
      initial: true,
      guards: [InitialGuard()],
    ),

    /// Auth
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: VerifyRoute.page),

    /// Start
    AutoRoute(page: OnboardingRoute.page),

    /// Main
    AutoRoute(
      page: MainRoute.page,
      children: [
        AutoRoute(page: HomeRoute.page),
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: CalendarRoute.page),
        AutoRoute(page: WalletRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),

    ///Subscreens

    AutoRoute(page: ClassDetailRoute.page),
    AutoRoute(page: BookingCompleteRoute.page),
    AutoRoute(page: ProfileDetailRoute.page),
    AutoRoute(page: ChildrenRoute.page),
    AutoRoute(page: AddChildRoute.page),
    AutoRoute(page: PaymentRoute.page),
    AutoRoute(page: PaymentCardsRoute.page),
    AutoRoute(page: AddNewCardRoute.page),
    AutoRoute(page: CheckoutRoute.page),
    AutoRoute(page: SearchUnifiedRoute.page),
  ];
}
