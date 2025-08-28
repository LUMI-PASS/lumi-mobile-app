import 'package:auto_route/auto_route.dart';
import 'package:flexobo/common/router/initial_guard.dart';
import 'package:flexobo/data/api_model/application_item/application_item_model.dart';
import 'package:flexobo/data/storage/storage.dart';
import 'package:flexobo/di/injection.dart';
import 'package:flexobo/domain/repo/transport_model/transport_model.dart';
import 'package:flexobo/presentation/app/main/main_page.dart';
import 'package:flexobo/presentation/app/main/subscreens/add_post/add_car_cubit/add_car_state.dart';
import 'package:flexobo/presentation/app/main/subscreens/add_post/add_post_page.dart';
import 'package:flexobo/presentation/app/main/subscreens/add_post/cubit/add_post_state.dart';
import 'package:flexobo/presentation/app/main/subscreens/add_post/widgets/add_car_page.dart';
import 'package:flexobo/presentation/app/main/subscreens/chat/chat_messaging/chat_messaging_page.dart';
import 'package:flexobo/presentation/app/main/subscreens/chat/chat_page.dart';
import 'package:flexobo/presentation/app/main/subscreens/document/document_page.dart';
import 'package:flexobo/presentation/app/main/subscreens/profile/profile_page.dart';
import 'package:flexobo/presentation/app/main/subscreens/search/search_page.dart';
import 'package:flexobo/presentation/auth/check_user/check_user_page.dart';
import 'package:flexobo/presentation/auth/forget_password/forget_password_page.dart';
import 'package:flexobo/presentation/auth/login/login_page.dart';
import 'package:flexobo/presentation/auth/register/register_page.dart';
import 'package:flexobo/presentation/auth/verify/verify_page.dart';
import 'package:flexobo/presentation/bidding/incoming_requests/incoming_requests_page.dart';
import 'package:flexobo/presentation/bidding/select_data/input_payment_data_page.dart';
import 'package:flexobo/presentation/bidding/select_data/select_data_page.dart';
import 'package:flexobo/presentation/bidding/transport_detail/transport_detail_page.dart';
import 'package:flexobo/presentation/profile/contact_centre/contact_centre_page.dart';
import 'package:flexobo/presentation/profile/language/languages_page.dart';
import 'package:flexobo/presentation/profile/my_garage/my_garage_page.dart';
import 'package:flexobo/presentation/search/filter/filter_page.dart';
import 'package:flexobo/presentation/search/notification/notification_page.dart';
import 'package:flexobo/presentation/search/shipping_detail/shipping_load_detail_page.dart';
import 'package:flexobo/presentation/search/shipping_detail/shipping_truck_detail_page.dart';
import 'package:flexobo/presentation/start/onboard/onboard_page.dart';
import 'package:flutter/cupertino.dart';

import '../../data/api_model/currency/currency_model.dart';
import 'empty_route.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  // final bool isOnboardInitial = getIt<Storage>().showOnboard.call() ?? true;
  // final bool isLoginInitial = getIt<Storage>().showOnboard.call() == false &&
  //     getIt<Storage>().tokens.call() == null;
  // final bool isMainInitial = getIt<Storage>().tokens.call() != null;

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
    AutoRoute(page: CheckUserRoute.page),
    AutoRoute(page: VerifyRoute.page),
    AutoRoute(page: ForgetPasswordRoute.page),

    /// Start
    AutoRoute(page: OnboardingRoute.page),

    /// Main
    AutoRoute(
      page: MainRoute.page,
      children: [
        AutoRoute(page: SearchRoute.page),
        AutoRoute(page: DocumentRoute.page),
        AutoRoute(page: ChatRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),

    AutoRoute(page: AddPostRoute.page),
    AutoRoute(page: ShippingLoadDetailRoute.page),
    AutoRoute(page: ShippingTruckDetailRoute.page),
    AutoRoute(page: AddCarRoute.page),
    AutoRoute(page: FilterRoute.page),
    AutoRoute(page: MyGarageRoute.page),
    AutoRoute(page: LanguagesRoute.page),
    AutoRoute(page: NotificationRoute.page),
    AutoRoute(page: ContactCentreRoute.page),
    AutoRoute(page: SelectDataRoute.page),
    AutoRoute(page: InputPaymentDataRoute.page),
    AutoRoute(page: IncomingRequestsRoute.page),
    AutoRoute(page: TransportDetailRoute.page),
    AutoRoute(page: ChatMessagingRoute.page),
    // AutoRoute(page: AddSavingsRoute.page),
    // AutoRoute(page: AddGoalRoute.page),
    // AutoRoute(page: GoalTermsRoute.page),
    // AutoRoute(page: SavingsDescriptionRoute.page),
    // AutoRoute(page: TransferBankRoute.page),
    // AutoRoute(page: WithdrawalProfitRoute.page),
    // AutoRoute(page: HistoryTransactionsRoute.page),
    //
    // /// Payment
    // AutoRoute(page: PaymentRoute.page),
    //
    // /// Advice
    // AutoRoute(page: AdvicesRoute.page),
    // AutoRoute(page: InvestmentFundamentalsRoute.page),
  ];
}
