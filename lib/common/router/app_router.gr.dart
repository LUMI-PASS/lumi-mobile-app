// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AddCarRoute.name: (routeData) {
      final args = routeData.argsAs<AddCarRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AddCarPage(
          key: args.key,
          addCarEffect: args.addCarEffect,
          transportModel: args.transportModel,
        ),
      );
    },
    AddPostRoute.name: (routeData) {
      final args = routeData.argsAs<AddPostRouteArgs>(
          orElse: () => const AddPostRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AddPostPage(
          key: args.key,
          id: args.id,
          isTruck: args.isTruck,
        ),
      );
    },
    ChatMessagingRoute.name: (routeData) {
      final args = routeData.argsAs<ChatMessagingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChatMessagingPage(
          key: args.key,
          roomId: args.roomId,
        ),
      );
    },
    ChatRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChatPage(),
      );
    },
    CheckUserRoute.name: (routeData) {
      final args = routeData.argsAs<CheckUserRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CheckUserPage(
          key: args.key,
          isRegister: args.isRegister,
        ),
      );
    },
    ContactCentreRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ContactCentrePage(),
      );
    },
    DocumentRoute.name: (routeData) {
      final args = routeData.argsAs<DocumentRouteArgs>(
          orElse: () => const DocumentRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DocumentPage(key: args.key),
      );
    },
    EmptyRouterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
      );
    },
    FilterRoute.name: (routeData) {
      final args = routeData.argsAs<FilterRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FilterPage(
          key: args.key,
          isTruck: args.isTruck,
        ),
      );
    },
    ForgetPasswordRoute.name: (routeData) {
      final args = routeData.argsAs<ForgetPasswordRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ForgetPasswordPage(
          key: args.key,
          phoneOrEmail: args.phoneOrEmail,
        ),
      );
    },
    IncomingRequestsRoute.name: (routeData) {
      final args = routeData.argsAs<IncomingRequestsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: IncomingRequestsPage(
          key: args.key,
          postId: args.postId,
          priceMode: args.priceMode,
          applications: args.applications,
        ),
      );
    },
    InputPaymentDataRoute.name: (routeData) {
      final args = routeData.argsAs<InputPaymentDataRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: InputPaymentDataPage(
          key: args.key,
          isTruck: args.isTruck,
          selectedId: args.selectedId,
          currentId: args.currentId,
          priceMode: args.priceMode,
          currencyData: args.currencyData,
          bidId: args.bidId,
        ),
      );
    },
    LanguagesRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LanguagesPage(),
      );
    },
    LoginRoute.name: (routeData) {
      final args = routeData.argsAs<LoginRouteArgs>(
          orElse: () => const LoginRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LoginPage(key: args.key),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MainPage(),
      );
    },
    MyGarageRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MyGaragePage(),
      );
    },
    NotificationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotificationPage(),
      );
    },
    OnboardingRoute.name: (routeData) {
      final args = routeData.argsAs<OnboardingRouteArgs>(
          orElse: () => const OnboardingRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: OnboardingPage(key: args.key),
      );
    },
    ProfileRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ProfilePage(),
      );
    },
    RegisterRoute.name: (routeData) {
      final args = routeData.argsAs<RegisterRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: RegisterPage(
          key: args.key,
          phoneOrMail: args.phoneOrMail,
        ),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchPage(),
      );
    },
    SelectDataRoute.name: (routeData) {
      final args = routeData.argsAs<SelectDataRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SelectDataPage(
          key: args.key,
          isTruck: args.isTruck,
          currentId: args.currentId,
          priceMode: args.priceMode,
          currencyData: args.currencyData,
        ),
      );
    },
    ShippingLoadDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ShippingLoadDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ShippingLoadDetailPage(
          key: args.key,
          id: args.id,
          isMine: args.isMine,
        ),
      );
    },
    ShippingTruckDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ShippingTruckDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ShippingTruckDetailPage(
          key: args.key,
          id: args.id,
          isMine: args.isMine,
        ),
      );
    },
    TransportDetailRoute.name: (routeData) {
      final args = routeData.argsAs<TransportDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TransportDetailPage(
          key: args.key,
          transportId: args.transportId,
        ),
      );
    },
    VerifyRoute.name: (routeData) {
      final args = routeData.argsAs<VerifyRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: VerifyPage(
          key: args.key,
          verifyStatus: args.verifyStatus,
          phoneOrEmail: args.phoneOrEmail,
          codeHash: args.codeHash,
          code: args.code,
        ),
      );
    },
  };
}

/// generated route for
/// [AddCarPage]
class AddCarRoute extends PageRouteInfo<AddCarRouteArgs> {
  AddCarRoute({
    Key? key,
    required AddCarEffect addCarEffect,
    TransportData? transportModel,
    List<PageRouteInfo>? children,
  }) : super(
          AddCarRoute.name,
          args: AddCarRouteArgs(
            key: key,
            addCarEffect: addCarEffect,
            transportModel: transportModel,
          ),
          initialChildren: children,
        );

  static const String name = 'AddCarRoute';

  static const PageInfo<AddCarRouteArgs> page = PageInfo<AddCarRouteArgs>(name);
}

class AddCarRouteArgs {
  const AddCarRouteArgs({
    this.key,
    required this.addCarEffect,
    this.transportModel,
  });

  final Key? key;

  final AddCarEffect addCarEffect;

  final TransportData? transportModel;

  @override
  String toString() {
    return 'AddCarRouteArgs{key: $key, addCarEffect: $addCarEffect, transportModel: $transportModel}';
  }
}

/// generated route for
/// [AddPostPage]
class AddPostRoute extends PageRouteInfo<AddPostRouteArgs> {
  AddPostRoute({
    Key? key,
    String? id,
    bool? isTruck,
    List<PageRouteInfo>? children,
  }) : super(
          AddPostRoute.name,
          args: AddPostRouteArgs(
            key: key,
            id: id,
            isTruck: isTruck,
          ),
          initialChildren: children,
        );

  static const String name = 'AddPostRoute';

  static const PageInfo<AddPostRouteArgs> page =
      PageInfo<AddPostRouteArgs>(name);
}

class AddPostRouteArgs {
  const AddPostRouteArgs({
    this.key,
    this.id,
    this.isTruck,
  });

  final Key? key;

  final String? id;

  final bool? isTruck;

  @override
  String toString() {
    return 'AddPostRouteArgs{key: $key, id: $id, isTruck: $isTruck}';
  }
}

/// generated route for
/// [ChatMessagingPage]
class ChatMessagingRoute extends PageRouteInfo<ChatMessagingRouteArgs> {
  ChatMessagingRoute({
    Key? key,
    required String roomId,
    List<PageRouteInfo>? children,
  }) : super(
          ChatMessagingRoute.name,
          args: ChatMessagingRouteArgs(
            key: key,
            roomId: roomId,
          ),
          initialChildren: children,
        );

  static const String name = 'ChatMessagingRoute';

  static const PageInfo<ChatMessagingRouteArgs> page =
      PageInfo<ChatMessagingRouteArgs>(name);
}

class ChatMessagingRouteArgs {
  const ChatMessagingRouteArgs({
    this.key,
    required this.roomId,
  });

  final Key? key;

  final String roomId;

  @override
  String toString() {
    return 'ChatMessagingRouteArgs{key: $key, roomId: $roomId}';
  }
}

/// generated route for
/// [ChatPage]
class ChatRoute extends PageRouteInfo<void> {
  const ChatRoute({List<PageRouteInfo>? children})
      : super(
          ChatRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChatRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CheckUserPage]
class CheckUserRoute extends PageRouteInfo<CheckUserRouteArgs> {
  CheckUserRoute({
    Key? key,
    required bool isRegister,
    List<PageRouteInfo>? children,
  }) : super(
          CheckUserRoute.name,
          args: CheckUserRouteArgs(
            key: key,
            isRegister: isRegister,
          ),
          initialChildren: children,
        );

  static const String name = 'CheckUserRoute';

  static const PageInfo<CheckUserRouteArgs> page =
      PageInfo<CheckUserRouteArgs>(name);
}

class CheckUserRouteArgs {
  const CheckUserRouteArgs({
    this.key,
    required this.isRegister,
  });

  final Key? key;

  final bool isRegister;

  @override
  String toString() {
    return 'CheckUserRouteArgs{key: $key, isRegister: $isRegister}';
  }
}

/// generated route for
/// [ContactCentrePage]
class ContactCentreRoute extends PageRouteInfo<void> {
  const ContactCentreRoute({List<PageRouteInfo>? children})
      : super(
          ContactCentreRoute.name,
          initialChildren: children,
        );

  static const String name = 'ContactCentreRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DocumentPage]
class DocumentRoute extends PageRouteInfo<DocumentRouteArgs> {
  DocumentRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          DocumentRoute.name,
          args: DocumentRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'DocumentRoute';

  static const PageInfo<DocumentRouteArgs> page =
      PageInfo<DocumentRouteArgs>(name);
}

class DocumentRouteArgs {
  const DocumentRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'DocumentRouteArgs{key: $key}';
  }
}

/// generated route for
/// [EmptyRouterPage]
class EmptyRouterRoute extends PageRouteInfo<void> {
  const EmptyRouterRoute({List<PageRouteInfo>? children})
      : super(
          EmptyRouterRoute.name,
          initialChildren: children,
        );

  static const String name = 'EmptyRouterRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [FilterPage]
class FilterRoute extends PageRouteInfo<FilterRouteArgs> {
  FilterRoute({
    Key? key,
    required bool isTruck,
    List<PageRouteInfo>? children,
  }) : super(
          FilterRoute.name,
          args: FilterRouteArgs(
            key: key,
            isTruck: isTruck,
          ),
          initialChildren: children,
        );

  static const String name = 'FilterRoute';

  static const PageInfo<FilterRouteArgs> page = PageInfo<FilterRouteArgs>(name);
}

class FilterRouteArgs {
  const FilterRouteArgs({
    this.key,
    required this.isTruck,
  });

  final Key? key;

  final bool isTruck;

  @override
  String toString() {
    return 'FilterRouteArgs{key: $key, isTruck: $isTruck}';
  }
}

/// generated route for
/// [ForgetPasswordPage]
class ForgetPasswordRoute extends PageRouteInfo<ForgetPasswordRouteArgs> {
  ForgetPasswordRoute({
    Key? key,
    required String phoneOrEmail,
    List<PageRouteInfo>? children,
  }) : super(
          ForgetPasswordRoute.name,
          args: ForgetPasswordRouteArgs(
            key: key,
            phoneOrEmail: phoneOrEmail,
          ),
          initialChildren: children,
        );

  static const String name = 'ForgetPasswordRoute';

  static const PageInfo<ForgetPasswordRouteArgs> page =
      PageInfo<ForgetPasswordRouteArgs>(name);
}

class ForgetPasswordRouteArgs {
  const ForgetPasswordRouteArgs({
    this.key,
    required this.phoneOrEmail,
  });

  final Key? key;

  final String phoneOrEmail;

  @override
  String toString() {
    return 'ForgetPasswordRouteArgs{key: $key, phoneOrEmail: $phoneOrEmail}';
  }
}

/// generated route for
/// [IncomingRequestsPage]
class IncomingRequestsRoute extends PageRouteInfo<IncomingRequestsRouteArgs> {
  IncomingRequestsRoute({
    Key? key,
    required String postId,
    required PriceMode priceMode,
    List<ApplicationItemModel>? applications,
    List<PageRouteInfo>? children,
  }) : super(
          IncomingRequestsRoute.name,
          args: IncomingRequestsRouteArgs(
            key: key,
            postId: postId,
            priceMode: priceMode,
            applications: applications,
          ),
          initialChildren: children,
        );

  static const String name = 'IncomingRequestsRoute';

  static const PageInfo<IncomingRequestsRouteArgs> page =
      PageInfo<IncomingRequestsRouteArgs>(name);
}

class IncomingRequestsRouteArgs {
  const IncomingRequestsRouteArgs({
    this.key,
    required this.postId,
    required this.priceMode,
    this.applications,
  });

  final Key? key;

  final String postId;

  final PriceMode priceMode;

  final List<ApplicationItemModel>? applications;

  @override
  String toString() {
    return 'IncomingRequestsRouteArgs{key: $key, postId: $postId, priceMode: $priceMode, applications: $applications}';
  }
}

/// generated route for
/// [InputPaymentDataPage]
class InputPaymentDataRoute extends PageRouteInfo<InputPaymentDataRouteArgs> {
  InputPaymentDataRoute({
    Key? key,
    required bool isTruck,
    required String selectedId,
    required String currentId,
    required PriceMode priceMode,
    required CurrencyData currencyData,
    String? bidId,
    List<PageRouteInfo>? children,
  }) : super(
          InputPaymentDataRoute.name,
          args: InputPaymentDataRouteArgs(
            key: key,
            isTruck: isTruck,
            selectedId: selectedId,
            currentId: currentId,
            priceMode: priceMode,
            currencyData: currencyData,
            bidId: bidId,
          ),
          initialChildren: children,
        );

  static const String name = 'InputPaymentDataRoute';

  static const PageInfo<InputPaymentDataRouteArgs> page =
      PageInfo<InputPaymentDataRouteArgs>(name);
}

class InputPaymentDataRouteArgs {
  const InputPaymentDataRouteArgs({
    this.key,
    required this.isTruck,
    required this.selectedId,
    required this.currentId,
    required this.priceMode,
    required this.currencyData,
    this.bidId,
  });

  final Key? key;

  final bool isTruck;

  final String selectedId;

  final String currentId;

  final PriceMode priceMode;

  final CurrencyData currencyData;

  final String? bidId;

  @override
  String toString() {
    return 'InputPaymentDataRouteArgs{key: $key, isTruck: $isTruck, selectedId: $selectedId, currentId: $currentId, priceMode: $priceMode, currencyData: $currencyData, bidId: $bidId}';
  }
}

/// generated route for
/// [LanguagesPage]
class LanguagesRoute extends PageRouteInfo<void> {
  const LanguagesRoute({List<PageRouteInfo>? children})
      : super(
          LanguagesRoute.name,
          initialChildren: children,
        );

  static const String name = 'LanguagesRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          LoginRoute.name,
          args: LoginRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<LoginRouteArgs> page = PageInfo<LoginRouteArgs>(name);
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key}';
  }
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MyGaragePage]
class MyGarageRoute extends PageRouteInfo<void> {
  const MyGarageRoute({List<PageRouteInfo>? children})
      : super(
          MyGarageRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyGarageRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationPage]
class NotificationRoute extends PageRouteInfo<void> {
  const NotificationRoute({List<PageRouteInfo>? children})
      : super(
          NotificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          OnboardingRoute.name,
          args: OnboardingRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static const PageInfo<OnboardingRouteArgs> page =
      PageInfo<OnboardingRouteArgs>(name);
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'OnboardingRouteArgs{key: $key}';
  }
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({
    Key? key,
    required String phoneOrMail,
    List<PageRouteInfo>? children,
  }) : super(
          RegisterRoute.name,
          args: RegisterRouteArgs(
            key: key,
            phoneOrMail: phoneOrMail,
          ),
          initialChildren: children,
        );

  static const String name = 'RegisterRoute';

  static const PageInfo<RegisterRouteArgs> page =
      PageInfo<RegisterRouteArgs>(name);
}

class RegisterRouteArgs {
  const RegisterRouteArgs({
    this.key,
    required this.phoneOrMail,
  });

  final Key? key;

  final String phoneOrMail;

  @override
  String toString() {
    return 'RegisterRouteArgs{key: $key, phoneOrMail: $phoneOrMail}';
  }
}

/// generated route for
/// [SearchPage]
class SearchRoute extends PageRouteInfo<void> {
  const SearchRoute({List<PageRouteInfo>? children})
      : super(
          SearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'SearchRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SelectDataPage]
class SelectDataRoute extends PageRouteInfo<SelectDataRouteArgs> {
  SelectDataRoute({
    Key? key,
    required bool isTruck,
    required String currentId,
    required PriceMode priceMode,
    required CurrencyData currencyData,
    List<PageRouteInfo>? children,
  }) : super(
          SelectDataRoute.name,
          args: SelectDataRouteArgs(
            key: key,
            isTruck: isTruck,
            currentId: currentId,
            priceMode: priceMode,
            currencyData: currencyData,
          ),
          initialChildren: children,
        );

  static const String name = 'SelectDataRoute';

  static const PageInfo<SelectDataRouteArgs> page =
      PageInfo<SelectDataRouteArgs>(name);
}

class SelectDataRouteArgs {
  const SelectDataRouteArgs({
    this.key,
    required this.isTruck,
    required this.currentId,
    required this.priceMode,
    required this.currencyData,
  });

  final Key? key;

  final bool isTruck;

  final String currentId;

  final PriceMode priceMode;

  final CurrencyData currencyData;

  @override
  String toString() {
    return 'SelectDataRouteArgs{key: $key, isTruck: $isTruck, currentId: $currentId, priceMode: $priceMode, currencyData: $currencyData}';
  }
}

/// generated route for
/// [ShippingLoadDetailPage]
class ShippingLoadDetailRoute
    extends PageRouteInfo<ShippingLoadDetailRouteArgs> {
  ShippingLoadDetailRoute({
    Key? key,
    required String id,
    required bool isMine,
    List<PageRouteInfo>? children,
  }) : super(
          ShippingLoadDetailRoute.name,
          args: ShippingLoadDetailRouteArgs(
            key: key,
            id: id,
            isMine: isMine,
          ),
          initialChildren: children,
        );

  static const String name = 'ShippingLoadDetailRoute';

  static const PageInfo<ShippingLoadDetailRouteArgs> page =
      PageInfo<ShippingLoadDetailRouteArgs>(name);
}

class ShippingLoadDetailRouteArgs {
  const ShippingLoadDetailRouteArgs({
    this.key,
    required this.id,
    required this.isMine,
  });

  final Key? key;

  final String id;

  final bool isMine;

  @override
  String toString() {
    return 'ShippingLoadDetailRouteArgs{key: $key, id: $id, isMine: $isMine}';
  }
}

/// generated route for
/// [ShippingTruckDetailPage]
class ShippingTruckDetailRoute
    extends PageRouteInfo<ShippingTruckDetailRouteArgs> {
  ShippingTruckDetailRoute({
    Key? key,
    required String id,
    required bool isMine,
    List<PageRouteInfo>? children,
  }) : super(
          ShippingTruckDetailRoute.name,
          args: ShippingTruckDetailRouteArgs(
            key: key,
            id: id,
            isMine: isMine,
          ),
          initialChildren: children,
        );

  static const String name = 'ShippingTruckDetailRoute';

  static const PageInfo<ShippingTruckDetailRouteArgs> page =
      PageInfo<ShippingTruckDetailRouteArgs>(name);
}

class ShippingTruckDetailRouteArgs {
  const ShippingTruckDetailRouteArgs({
    this.key,
    required this.id,
    required this.isMine,
  });

  final Key? key;

  final String id;

  final bool isMine;

  @override
  String toString() {
    return 'ShippingTruckDetailRouteArgs{key: $key, id: $id, isMine: $isMine}';
  }
}

/// generated route for
/// [TransportDetailPage]
class TransportDetailRoute extends PageRouteInfo<TransportDetailRouteArgs> {
  TransportDetailRoute({
    Key? key,
    required String transportId,
    List<PageRouteInfo>? children,
  }) : super(
          TransportDetailRoute.name,
          args: TransportDetailRouteArgs(
            key: key,
            transportId: transportId,
          ),
          initialChildren: children,
        );

  static const String name = 'TransportDetailRoute';

  static const PageInfo<TransportDetailRouteArgs> page =
      PageInfo<TransportDetailRouteArgs>(name);
}

class TransportDetailRouteArgs {
  const TransportDetailRouteArgs({
    this.key,
    required this.transportId,
  });

  final Key? key;

  final String transportId;

  @override
  String toString() {
    return 'TransportDetailRouteArgs{key: $key, transportId: $transportId}';
  }
}

/// generated route for
/// [VerifyPage]
class VerifyRoute extends PageRouteInfo<VerifyRouteArgs> {
  VerifyRoute({
    Key? key,
    required VerifyStatus verifyStatus,
    required String phoneOrEmail,
    String? codeHash,
    int? code,
    List<PageRouteInfo>? children,
  }) : super(
          VerifyRoute.name,
          args: VerifyRouteArgs(
            key: key,
            verifyStatus: verifyStatus,
            phoneOrEmail: phoneOrEmail,
            codeHash: codeHash,
            code: code,
          ),
          initialChildren: children,
        );

  static const String name = 'VerifyRoute';

  static const PageInfo<VerifyRouteArgs> page = PageInfo<VerifyRouteArgs>(name);
}

class VerifyRouteArgs {
  const VerifyRouteArgs({
    this.key,
    required this.verifyStatus,
    required this.phoneOrEmail,
    this.codeHash,
    this.code,
  });

  final Key? key;

  final VerifyStatus verifyStatus;

  final String phoneOrEmail;

  final String? codeHash;

  final int? code;

  @override
  String toString() {
    return 'VerifyRouteArgs{key: $key, verifyStatus: $verifyStatus, phoneOrEmail: $phoneOrEmail, codeHash: $codeHash, code: $code}';
  }
}
