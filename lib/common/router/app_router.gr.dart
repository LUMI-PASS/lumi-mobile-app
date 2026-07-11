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
      final args = routeData.argsAs<BookingCompleteRouteArgs>(
          orElse: () => const BookingCompleteRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BookingCompletePage(
          key: args.key,
          status: args.status,
          result: args.result,
          lines: args.lines,
        ),
      );
    },
    BookingDetailRoute.name: (routeData) {
      final args = routeData.argsAs<BookingDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BookingDetailPage(
          key: args.key,
          orderId: args.orderId,
        ),
      );
    },
    BookingRoute.name: (routeData) {
      final args = routeData.argsAs<BookingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BookingPage(
          key: args.key,
          clazz: args.clazz,
        ),
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
    BranchesMapRoute.name: (routeData) {
      final args = routeData.argsAs<BranchesMapRouteArgs>(
          orElse: () => const BranchesMapRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BranchesMapPage(
          key: args.key,
          branches: args.branches,
          categories: args.categories,
          selectedCategory: args.selectedCategory,
        ),
      );
    },
    CalendarRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CalendarPage(),
      );
    },
    ChangeLanguageRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ChangeLanguagePage(),
      );
    },
    CheckoutRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CheckoutPage(),
      );
    },
    ChildDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ChildDetailRouteArgs>(
          orElse: () => const ChildDetailRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ChildDetailPage(
          key: args.key,
          child: args.child,
        ),
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
    ClassesGridRoute.name: (routeData) {
      final args = routeData.argsAs<ClassesGridRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ClassesGridPage(
          key: args.key,
          title: args.title,
          list: args.list,
          initialClasses: args.initialClasses,
        ),
      );
    },
    ConnectionErrorRoute.name: (routeData) {
      return AutoRoutePage<bool>(
        routeData: routeData,
        child: const ConnectionErrorPage(),
      );
    },
    CouponsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CouponsPage(),
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
    FiscalReceiptRoute.name: (routeData) {
      final args = routeData.argsAs<FiscalReceiptRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FiscalReceiptPage(
          key: args.key,
          orderId: args.orderId,
          initialUrl: args.initialUrl,
        ),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    LanguageRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LanguagePage(),
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
    MyBookingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const MyBookingsPage(),
      );
    },
    NotificationsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotificationsPage(),
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
    PaymentHistoryRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PaymentHistoryPage(),
      );
    },
    PaymentRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PaymentPage(),
      );
    },
    PlansRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PlansPage(),
      );
    },
    ProfileDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProfileDetailPage(
          key: args.key,
          user: args.user,
        ),
      );
    },
    ProfileRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileRouteArgs>(
          orElse: () => const ProfileRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ProfilePage(key: args.key),
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
    SearchDiscoveryRoute.name: (routeData) {
      final args = routeData.argsAs<SearchDiscoveryRouteArgs>(
          orElse: () => const SearchDiscoveryRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SearchDiscoveryPage(
          key: args.key,
          initialCategory: args.initialCategory,
          classesOnly: args.classesOnly,
        ),
      );
    },
    SearchRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SearchPage(),
      );
    },
    ShortsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ShortsPage(),
      );
    },
    TicketReceiptRoute.name: (routeData) {
      final args = routeData.argsAs<TicketReceiptRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: TicketReceiptPage(
          key: args.key,
          ticket: args.ticket,
          className: args.className,
          branch: args.branch,
          orderId: args.orderId,
          canCancel: args.canCancel,
          paidPrice: args.paidPrice,
          fromPromocode: args.fromPromocode,
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
    WelcomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const WelcomePage(),
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
class BookingCompleteRoute extends PageRouteInfo<BookingCompleteRouteArgs> {
  BookingCompleteRoute({
    Key? key,
    BookingResultStatus status = BookingResultStatus.paid,
    CheckoutResult? result,
    List<OrderLine> lines = const [],
    List<PageRouteInfo>? children,
  }) : super(
          BookingCompleteRoute.name,
          args: BookingCompleteRouteArgs(
            key: key,
            status: status,
            result: result,
            lines: lines,
          ),
          initialChildren: children,
        );

  static const String name = 'BookingCompleteRoute';

  static const PageInfo<BookingCompleteRouteArgs> page =
      PageInfo<BookingCompleteRouteArgs>(name);
}

class BookingCompleteRouteArgs {
  const BookingCompleteRouteArgs({
    this.key,
    this.status = BookingResultStatus.paid,
    this.result,
    this.lines = const [],
  });

  final Key? key;

  final BookingResultStatus status;

  final CheckoutResult? result;

  final List<OrderLine> lines;

  @override
  String toString() {
    return 'BookingCompleteRouteArgs{key: $key, status: $status, result: $result, lines: $lines}';
  }
}

/// generated route for
/// [BookingDetailPage]
class BookingDetailRoute extends PageRouteInfo<BookingDetailRouteArgs> {
  BookingDetailRoute({
    Key? key,
    required String orderId,
    List<PageRouteInfo>? children,
  }) : super(
          BookingDetailRoute.name,
          args: BookingDetailRouteArgs(
            key: key,
            orderId: orderId,
          ),
          initialChildren: children,
        );

  static const String name = 'BookingDetailRoute';

  static const PageInfo<BookingDetailRouteArgs> page =
      PageInfo<BookingDetailRouteArgs>(name);
}

class BookingDetailRouteArgs {
  const BookingDetailRouteArgs({
    this.key,
    required this.orderId,
  });

  final Key? key;

  final String orderId;

  @override
  String toString() {
    return 'BookingDetailRouteArgs{key: $key, orderId: $orderId}';
  }
}

/// generated route for
/// [BookingPage]
class BookingRoute extends PageRouteInfo<BookingRouteArgs> {
  BookingRoute({
    Key? key,
    required ClassFullModel clazz,
    List<PageRouteInfo>? children,
  }) : super(
          BookingRoute.name,
          args: BookingRouteArgs(
            key: key,
            clazz: clazz,
          ),
          initialChildren: children,
        );

  static const String name = 'BookingRoute';

  static const PageInfo<BookingRouteArgs> page =
      PageInfo<BookingRouteArgs>(name);
}

class BookingRouteArgs {
  const BookingRouteArgs({
    this.key,
    required this.clazz,
  });

  final Key? key;

  final ClassFullModel clazz;

  @override
  String toString() {
    return 'BookingRouteArgs{key: $key, clazz: $clazz}';
  }
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
/// [BranchesMapPage]
class BranchesMapRoute extends PageRouteInfo<BranchesMapRouteArgs> {
  BranchesMapRoute({
    Key? key,
    List<HomBranch> branches = const [],
    List<HomCategory> categories = const [],
    HomCategory? selectedCategory,
    List<PageRouteInfo>? children,
  }) : super(
          BranchesMapRoute.name,
          args: BranchesMapRouteArgs(
            key: key,
            branches: branches,
            categories: categories,
            selectedCategory: selectedCategory,
          ),
          initialChildren: children,
        );

  static const String name = 'BranchesMapRoute';

  static const PageInfo<BranchesMapRouteArgs> page =
      PageInfo<BranchesMapRouteArgs>(name);
}

class BranchesMapRouteArgs {
  const BranchesMapRouteArgs({
    this.key,
    this.branches = const [],
    this.categories = const [],
    this.selectedCategory,
  });

  final Key? key;

  final List<HomBranch> branches;

  final List<HomCategory> categories;

  final HomCategory? selectedCategory;

  @override
  String toString() {
    return 'BranchesMapRouteArgs{key: $key, branches: $branches, categories: $categories, selectedCategory: $selectedCategory}';
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
/// [ChangeLanguagePage]
class ChangeLanguageRoute extends PageRouteInfo<void> {
  const ChangeLanguageRoute({List<PageRouteInfo>? children})
      : super(
          ChangeLanguageRoute.name,
          initialChildren: children,
        );

  static const String name = 'ChangeLanguageRoute';

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
/// [ChildDetailPage]
class ChildDetailRoute extends PageRouteInfo<ChildDetailRouteArgs> {
  ChildDetailRoute({
    Key? key,
    ChildModel? child,
    List<PageRouteInfo>? children,
  }) : super(
          ChildDetailRoute.name,
          args: ChildDetailRouteArgs(
            key: key,
            child: child,
          ),
          initialChildren: children,
        );

  static const String name = 'ChildDetailRoute';

  static const PageInfo<ChildDetailRouteArgs> page =
      PageInfo<ChildDetailRouteArgs>(name);
}

class ChildDetailRouteArgs {
  const ChildDetailRouteArgs({
    this.key,
    this.child,
  });

  final Key? key;

  final ChildModel? child;

  @override
  String toString() {
    return 'ChildDetailRouteArgs{key: $key, child: $child}';
  }
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
/// [ClassesGridPage]
class ClassesGridRoute extends PageRouteInfo<ClassesGridRouteArgs> {
  ClassesGridRoute({
    Key? key,
    required String title,
    required HomeClassList list,
    List<HomClass> initialClasses = const [],
    List<PageRouteInfo>? children,
  }) : super(
          ClassesGridRoute.name,
          args: ClassesGridRouteArgs(
            key: key,
            title: title,
            list: list,
            initialClasses: initialClasses,
          ),
          initialChildren: children,
        );

  static const String name = 'ClassesGridRoute';

  static const PageInfo<ClassesGridRouteArgs> page =
      PageInfo<ClassesGridRouteArgs>(name);
}

class ClassesGridRouteArgs {
  const ClassesGridRouteArgs({
    this.key,
    required this.title,
    required this.list,
    this.initialClasses = const [],
  });

  final Key? key;

  final String title;

  final HomeClassList list;

  final List<HomClass> initialClasses;

  @override
  String toString() {
    return 'ClassesGridRouteArgs{key: $key, title: $title, list: $list, initialClasses: $initialClasses}';
  }
}

/// generated route for
/// [ConnectionErrorPage]
class ConnectionErrorRoute extends PageRouteInfo<void> {
  const ConnectionErrorRoute({List<PageRouteInfo>? children})
      : super(
          ConnectionErrorRoute.name,
          initialChildren: children,
        );

  static const String name = 'ConnectionErrorRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [CouponsPage]
class CouponsRoute extends PageRouteInfo<void> {
  const CouponsRoute({List<PageRouteInfo>? children})
      : super(
          CouponsRoute.name,
          initialChildren: children,
        );

  static const String name = 'CouponsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
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
/// [FiscalReceiptPage]
class FiscalReceiptRoute extends PageRouteInfo<FiscalReceiptRouteArgs> {
  FiscalReceiptRoute({
    Key? key,
    required String orderId,
    String? initialUrl,
    List<PageRouteInfo>? children,
  }) : super(
          FiscalReceiptRoute.name,
          args: FiscalReceiptRouteArgs(
            key: key,
            orderId: orderId,
            initialUrl: initialUrl,
          ),
          initialChildren: children,
        );

  static const String name = 'FiscalReceiptRoute';

  static const PageInfo<FiscalReceiptRouteArgs> page =
      PageInfo<FiscalReceiptRouteArgs>(name);
}

class FiscalReceiptRouteArgs {
  const FiscalReceiptRouteArgs({
    this.key,
    required this.orderId,
    this.initialUrl,
  });

  final Key? key;

  final String orderId;

  final String? initialUrl;

  @override
  String toString() {
    return 'FiscalReceiptRouteArgs{key: $key, orderId: $orderId, initialUrl: $initialUrl}';
  }
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
/// [LanguagePage]
class LanguageRoute extends PageRouteInfo<void> {
  const LanguageRoute({List<PageRouteInfo>? children})
      : super(
          LanguageRoute.name,
          initialChildren: children,
        );

  static const String name = 'LanguageRoute';

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
/// [MyBookingsPage]
class MyBookingsRoute extends PageRouteInfo<void> {
  const MyBookingsRoute({List<PageRouteInfo>? children})
      : super(
          MyBookingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyBookingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NotificationsPage]
class NotificationsRoute extends PageRouteInfo<void> {
  const NotificationsRoute({List<PageRouteInfo>? children})
      : super(
          NotificationsRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationsRoute';

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
/// [PaymentHistoryPage]
class PaymentHistoryRoute extends PageRouteInfo<void> {
  const PaymentHistoryRoute({List<PageRouteInfo>? children})
      : super(
          PaymentHistoryRoute.name,
          initialChildren: children,
        );

  static const String name = 'PaymentHistoryRoute';

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
/// [PlansPage]
class PlansRoute extends PageRouteInfo<void> {
  const PlansRoute({List<PageRouteInfo>? children})
      : super(
          PlansRoute.name,
          initialChildren: children,
        );

  static const String name = 'PlansRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ProfileDetailPage]
class ProfileDetailRoute extends PageRouteInfo<ProfileDetailRouteArgs> {
  ProfileDetailRoute({
    Key? key,
    required HomForUser user,
    List<PageRouteInfo>? children,
  }) : super(
          ProfileDetailRoute.name,
          args: ProfileDetailRouteArgs(
            key: key,
            user: user,
          ),
          initialChildren: children,
        );

  static const String name = 'ProfileDetailRoute';

  static const PageInfo<ProfileDetailRouteArgs> page =
      PageInfo<ProfileDetailRouteArgs>(name);
}

class ProfileDetailRouteArgs {
  const ProfileDetailRouteArgs({
    this.key,
    required this.user,
  });

  final Key? key;

  final HomForUser user;

  @override
  String toString() {
    return 'ProfileDetailRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ProfileRoute.name,
          args: ProfileRouteArgs(key: key),
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const PageInfo<ProfileRouteArgs> page =
      PageInfo<ProfileRouteArgs>(name);
}

class ProfileRouteArgs {
  const ProfileRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ProfileRouteArgs{key: $key}';
  }
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
/// [SearchDiscoveryPage]
class SearchDiscoveryRoute extends PageRouteInfo<SearchDiscoveryRouteArgs> {
  SearchDiscoveryRoute({
    Key? key,
    HomCategory? initialCategory,
    bool classesOnly = false,
    List<PageRouteInfo>? children,
  }) : super(
          SearchDiscoveryRoute.name,
          args: SearchDiscoveryRouteArgs(
            key: key,
            initialCategory: initialCategory,
            classesOnly: classesOnly,
          ),
          initialChildren: children,
        );

  static const String name = 'SearchDiscoveryRoute';

  static const PageInfo<SearchDiscoveryRouteArgs> page =
      PageInfo<SearchDiscoveryRouteArgs>(name);
}

class SearchDiscoveryRouteArgs {
  const SearchDiscoveryRouteArgs({
    this.key,
    this.initialCategory,
    this.classesOnly = false,
  });

  final Key? key;

  final HomCategory? initialCategory;

  final bool classesOnly;

  @override
  String toString() {
    return 'SearchDiscoveryRouteArgs{key: $key, initialCategory: $initialCategory, classesOnly: $classesOnly}';
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
/// [ShortsPage]
class ShortsRoute extends PageRouteInfo<void> {
  const ShortsRoute({List<PageRouteInfo>? children})
      : super(
          ShortsRoute.name,
          initialChildren: children,
        );

  static const String name = 'ShortsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [TicketReceiptPage]
class TicketReceiptRoute extends PageRouteInfo<TicketReceiptRouteArgs> {
  TicketReceiptRoute({
    Key? key,
    required OrderTicket ticket,
    String? className,
    String? branch,
    String? orderId,
    bool canCancel = false,
    num? paidPrice,
    bool fromPromocode = false,
    List<PageRouteInfo>? children,
  }) : super(
          TicketReceiptRoute.name,
          args: TicketReceiptRouteArgs(
            key: key,
            ticket: ticket,
            className: className,
            branch: branch,
            orderId: orderId,
            canCancel: canCancel,
            paidPrice: paidPrice,
            fromPromocode: fromPromocode,
          ),
          initialChildren: children,
        );

  static const String name = 'TicketReceiptRoute';

  static const PageInfo<TicketReceiptRouteArgs> page =
      PageInfo<TicketReceiptRouteArgs>(name);
}

class TicketReceiptRouteArgs {
  const TicketReceiptRouteArgs({
    this.key,
    required this.ticket,
    this.className,
    this.branch,
    this.orderId,
    this.canCancel = false,
    this.paidPrice,
    this.fromPromocode = false,
  });

  final Key? key;

  final OrderTicket ticket;

  final String? className;

  final String? branch;

  final String? orderId;

  final bool canCancel;

  final num? paidPrice;

  final bool fromPromocode;

  @override
  String toString() {
    return 'TicketReceiptRouteArgs{key: $key, ticket: $ticket, className: $className, branch: $branch, orderId: $orderId, canCancel: $canCancel, paidPrice: $paidPrice, fromPromocode: $fromPromocode}';
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

/// generated route for
/// [WelcomePage]
class WelcomeRoute extends PageRouteInfo<void> {
  const WelcomeRoute({List<PageRouteInfo>? children})
      : super(
          WelcomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'WelcomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
