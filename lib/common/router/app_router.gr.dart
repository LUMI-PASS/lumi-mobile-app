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
    AddChildRoute.name: (routeData) {
      final args = routeData.argsAs<AddChildRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AddChildPage(
          key: args.key,
          childModel: args.childModel,
          parentId: args.parentId,
        ),
      );
    },
    AddNewCardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AddNewCardPage(),
      );
    },
    AttendanceDetailRoute.name: (routeData) {
      final args = routeData.argsAs<AttendanceDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AttendanceDetailPage(
          key: args.key,
          childModel: args.childModel,
        ),
      );
    },
    AttendanceHistoryRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AttendanceHistoryPage(),
      );
    },
    BookingCompleteRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const BookingCompletePage(),
      );
    },
    BranchDetailRoute.name: (routeData) {
      final args = routeData.argsAs<BranchDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BranchDetailPage(
          key: args.key,
          branch: args.branch,
        ),
      );
    },
    CalendarRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CalendarPage(),
      );
    },
    CheckoutRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CheckoutPage(),
      );
    },
    ChildrenRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChildrenPage(),
      );
    },
    ClassDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ClassDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ClassDetailPage(
          key: args.key,
          classModel: args.classModel,
        ),
      );
    },
    EmptyRouterRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const EmptyRouterPage(),
      );
    },
    FaqRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const FaqPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
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
    OnboardingRoute.name: (routeData) {
      final args = routeData.argsAs<OnboardingRouteArgs>(
          orElse: () => const OnboardingRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: OnboardingPage(key: args.key),
      );
    },
    PaymentCardsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PaymentCardsPage(),
      );
    },
    PaymentRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PaymentPage(),
      );
    },
    ProfileDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileDetailRouteArgs>(
          orElse: () => const ProfileDetailRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProfileDetailPage(key: args.key),
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
    ScheduleDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ScheduleDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ScheduleDetailPage(
          key: args.key,
          scheduleItem: args.scheduleItem,
        ),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SearchPage(),
      );
    },
    SearchUnifiedRoute.name: (routeData) {
      final args = routeData.argsAs<SearchUnifiedRouteArgs>(
          orElse: () => const SearchUnifiedRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SearchUnifiedPage(
          key: args.key,
          initialCategory: args.initialCategory,
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
    WalletRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WalletPage(),
      );
    },
  };
}

/// generated route for
/// [AddChildPage]
class AddChildRoute extends PageRouteInfo<AddChildRouteArgs> {
  AddChildRoute({
    Key? key,
    required ChildModel? childModel,
    required String? parentId,
    List<PageRouteInfo>? children,
  }) : super(
          AddChildRoute.name,
          args: AddChildRouteArgs(
            key: key,
            childModel: childModel,
            parentId: parentId,
          ),
          initialChildren: children,
        );

  static const String name = 'AddChildRoute';

  static const PageInfo<AddChildRouteArgs> page =
      PageInfo<AddChildRouteArgs>(name);
}

class AddChildRouteArgs {
  const AddChildRouteArgs({
    this.key,
    required this.childModel,
    required this.parentId,
  });

  final Key? key;

  final ChildModel? childModel;

  final String? parentId;

  @override
  String toString() {
    return 'AddChildRouteArgs{key: $key, childModel: $childModel, parentId: $parentId}';
  }
}

/// generated route for
/// [AddNewCardPage]
class AddNewCardRoute extends PageRouteInfo<void> {
  const AddNewCardRoute({List<PageRouteInfo>? children})
      : super(
          AddNewCardRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddNewCardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [AttendanceDetailPage]
class AttendanceDetailRoute extends PageRouteInfo<AttendanceDetailRouteArgs> {
  AttendanceDetailRoute({
    Key? key,
    required ChildModel childModel,
    List<PageRouteInfo>? children,
  }) : super(
          AttendanceDetailRoute.name,
          args: AttendanceDetailRouteArgs(
            key: key,
            childModel: childModel,
          ),
          initialChildren: children,
        );

  static const String name = 'AttendanceDetailRoute';

  static const PageInfo<AttendanceDetailRouteArgs> page =
      PageInfo<AttendanceDetailRouteArgs>(name);
}

class AttendanceDetailRouteArgs {
  const AttendanceDetailRouteArgs({
    this.key,
    required this.childModel,
  });

  final Key? key;

  final ChildModel childModel;

  @override
  String toString() {
    return 'AttendanceDetailRouteArgs{key: $key, childModel: $childModel}';
  }
}

/// generated route for
/// [AttendanceHistoryPage]
class AttendanceHistoryRoute extends PageRouteInfo<void> {
  const AttendanceHistoryRoute({List<PageRouteInfo>? children})
      : super(
          AttendanceHistoryRoute.name,
          initialChildren: children,
        );

  static const String name = 'AttendanceHistoryRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [BookingCompletePage]
class BookingCompleteRoute extends PageRouteInfo<void> {
  const BookingCompleteRoute({List<PageRouteInfo>? children})
      : super(
          BookingCompleteRoute.name,
          initialChildren: children,
        );

  static const String name = 'BookingCompleteRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [BranchDetailPage]
class BranchDetailRoute extends PageRouteInfo<BranchDetailRouteArgs> {
  BranchDetailRoute({
    Key? key,
    required HomBranch branch,
    List<PageRouteInfo>? children,
  }) : super(
          BranchDetailRoute.name,
          args: BranchDetailRouteArgs(
            key: key,
            branch: branch,
          ),
          initialChildren: children,
        );

  static const String name = 'BranchDetailRoute';

  static const PageInfo<BranchDetailRouteArgs> page =
      PageInfo<BranchDetailRouteArgs>(name);
}

class BranchDetailRouteArgs {
  const BranchDetailRouteArgs({
    this.key,
    required this.branch,
  });

  final Key? key;

  final HomBranch branch;

  @override
  String toString() {
    return 'BranchDetailRouteArgs{key: $key, branch: $branch}';
  }
}

/// generated route for
/// [CalendarPage]
class CalendarRoute extends PageRouteInfo<void> {
  const CalendarRoute({List<PageRouteInfo>? children})
      : super(
          CalendarRoute.name,
          initialChildren: children,
        );

  static const String name = 'CalendarRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CheckoutPage]
class CheckoutRoute extends PageRouteInfo<void> {
  const CheckoutRoute({List<PageRouteInfo>? children})
      : super(
          CheckoutRoute.name,
          initialChildren: children,
        );

  static const String name = 'CheckoutRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ChildrenPage]
class ChildrenRoute extends PageRouteInfo<void> {
  const ChildrenRoute({List<PageRouteInfo>? children})
      : super(
          ChildrenRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChildrenRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ClassDetailPage]
class ClassDetailRoute extends PageRouteInfo<ClassDetailRouteArgs> {
  ClassDetailRoute({
    Key? key,
    required HomClass classModel,
    List<PageRouteInfo>? children,
  }) : super(
          ClassDetailRoute.name,
          args: ClassDetailRouteArgs(
            key: key,
            classModel: classModel,
          ),
          initialChildren: children,
        );

  static const String name = 'ClassDetailRoute';

  static const PageInfo<ClassDetailRouteArgs> page =
      PageInfo<ClassDetailRouteArgs>(name);
}

class ClassDetailRouteArgs {
  const ClassDetailRouteArgs({
    this.key,
    required this.classModel,
  });

  final Key? key;

  final HomClass classModel;

  @override
  String toString() {
    return 'ClassDetailRouteArgs{key: $key, classModel: $classModel}';
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
/// [FaqPage]
class FaqRoute extends PageRouteInfo<void> {
  const FaqRoute({List<PageRouteInfo>? children})
      : super(
          FaqRoute.name,
          initialChildren: children,
        );

  static const String name = 'FaqRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

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
/// [PaymentCardsPage]
class PaymentCardsRoute extends PageRouteInfo<void> {
  const PaymentCardsRoute({List<PageRouteInfo>? children})
      : super(
          PaymentCardsRoute.name,
          initialChildren: children,
        );

  static const String name = 'PaymentCardsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PaymentPage]
class PaymentRoute extends PageRouteInfo<void> {
  const PaymentRoute({List<PageRouteInfo>? children})
      : super(
          PaymentRoute.name,
          initialChildren: children,
        );

  static const String name = 'PaymentRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfileDetailPage]
class ProfileDetailRoute extends PageRouteInfo<ProfileDetailRouteArgs> {
  ProfileDetailRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ProfileDetailRoute.name,
          args: ProfileDetailRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ProfileDetailRoute';

  static const PageInfo<ProfileDetailRouteArgs> page =
      PageInfo<ProfileDetailRouteArgs>(name);
}

class ProfileDetailRouteArgs {
  const ProfileDetailRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ProfileDetailRouteArgs{key: $key}';
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
/// [ScheduleDetailPage]
class ScheduleDetailRoute extends PageRouteInfo<ScheduleDetailRouteArgs> {
  ScheduleDetailRoute({
    Key? key,
    required ScheduleItem scheduleItem,
    List<PageRouteInfo>? children,
  }) : super(
          ScheduleDetailRoute.name,
          args: ScheduleDetailRouteArgs(
            key: key,
            scheduleItem: scheduleItem,
          ),
          initialChildren: children,
        );

  static const String name = 'ScheduleDetailRoute';

  static const PageInfo<ScheduleDetailRouteArgs> page =
      PageInfo<ScheduleDetailRouteArgs>(name);
}

class ScheduleDetailRouteArgs {
  const ScheduleDetailRouteArgs({
    this.key,
    required this.scheduleItem,
  });

  final Key? key;

  final ScheduleItem scheduleItem;

  @override
  String toString() {
    return 'ScheduleDetailRouteArgs{key: $key, scheduleItem: $scheduleItem}';
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
/// [SearchUnifiedPage]
class SearchUnifiedRoute extends PageRouteInfo<SearchUnifiedRouteArgs> {
  SearchUnifiedRoute({
    Key? key,
    String? initialCategory,
    List<PageRouteInfo>? children,
  }) : super(
          SearchUnifiedRoute.name,
          args: SearchUnifiedRouteArgs(
            key: key,
            initialCategory: initialCategory,
          ),
          initialChildren: children,
        );

  static const String name = 'SearchUnifiedRoute';

  static const PageInfo<SearchUnifiedRouteArgs> page =
      PageInfo<SearchUnifiedRouteArgs>(name);
}

class SearchUnifiedRouteArgs {
  const SearchUnifiedRouteArgs({
    this.key,
    this.initialCategory,
  });

  final Key? key;

  final String? initialCategory;

  @override
  String toString() {
    return 'SearchUnifiedRouteArgs{key: $key, initialCategory: $initialCategory}';
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

/// generated route for
/// [WalletPage]
class WalletRoute extends PageRouteInfo<void> {
  const WalletRoute({List<PageRouteInfo>? children})
      : super(
          WalletRoute.name,
          initialChildren: children,
        );

  static const String name = 'WalletRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
