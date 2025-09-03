import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/router/initial_guard.dart';
import 'package:lumi_pass/data/api_model/class_model/class_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/home/booking_complete/booking_complete_page.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/class_detail_page.dart';
import 'package:lumi_pass/presentation/app/main/main_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/calendar_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/home_page.dart';

import 'package:lumi_pass/presentation/app/main/subscreens/profile/profile_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/search_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/wallet/wallet_page.dart';
import 'package:lumi_pass/presentation/app/profile/children/children_page.dart';
import 'package:lumi_pass/presentation/app/profile/profile_detail/profile_detail_page.dart';
import 'package:lumi_pass/presentation/auth/login/login_page.dart';
import 'package:lumi_pass/presentation/auth/register/register_page.dart';
import 'package:lumi_pass/presentation/auth/verify/verify_page.dart';

import 'package:lumi_pass/presentation/start/onboard/onboard_page.dart';
import 'package:flutter/cupertino.dart';

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
  ];
}
