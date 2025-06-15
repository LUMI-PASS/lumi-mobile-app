// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i52;
import 'package:flutter/cupertino.dart' as _i55;
import 'package:flutter/material.dart' as _i53;
import 'package:founders_academy/app_container_screen.dart' as _i6;
import 'package:founders_academy/feature/auth/data/model/otp_data.dart' as _i59;
import 'package:founders_academy/feature/auth/presentation/cubit/auth/auth_cubit.dart'
    as _i60;
import 'package:founders_academy/feature/auth/presentation/screen/otp_screen.dart'
    as _i27;
import 'package:founders_academy/feature/auth/presentation/screen/registration/registration_address_screen.dart'
    as _i42;
import 'package:founders_academy/feature/auth/presentation/screen/registration/registration_container_screen.dart'
    as _i43;
import 'package:founders_academy/feature/auth/presentation/screen/registration/registration_education_screen.dart'
    as _i44;
import 'package:founders_academy/feature/auth/presentation/screen/registration/registration_personal_info_screen.dart'
    as _i45;
import 'package:founders_academy/feature/auth/presentation/screen/registration/registration_success_screen.dart'
    as _i46;
import 'package:founders_academy/feature/auth/presentation/screen/sign_in_screen.dart'
    as _i49;
import 'package:founders_academy/feature/auth/presentation/screen/unauthorized_container_screen.dart'
    as _i51;
import 'package:founders_academy/feature/courses/data/model/course/course_data.dart'
    as _i56;
import 'package:founders_academy/feature/courses/data/model/lesson/lesson_data.dart'
    as _i57;
import 'package:founders_academy/feature/courses/data/model/module/module_data.dart'
    as _i58;
import 'package:founders_academy/feature/courses/presentation/screen/course_details_screen.dart'
    as _i12;
import 'package:founders_academy/feature/courses/presentation/screen/courses_screen.dart'
    as _i13;
import 'package:founders_academy/feature/courses/presentation/screen/lesson_details_screen.dart'
    as _i20;
import 'package:founders_academy/feature/courses/presentation/screen/quiz_result_screen.dart'
    as _i41;
import 'package:founders_academy/feature/courses/presentation/screen/quiz_screen_screen.dart'
    as _i40;
import 'package:founders_academy/feature/discussions/presentation/screen/add_post/add_post_page.dart'
    as _i1;
import 'package:founders_academy/feature/discussions/presentation/screen/discussion_main/discussion_main_page.dart'
    as _i14;
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart'
    as _i54;
import 'package:founders_academy/feature/home/presentation/screen/afisha_registration_result_screen.dart'
    as _i5;
import 'package:founders_academy/feature/home/presentation/screen/authorized_container_screen.dart'
    as _i7;
import 'package:founders_academy/feature/home/presentation/screen/book_pdf_screen/book_pdf_screen.dart'
    as _i10;
import 'package:founders_academy/feature/home/presentation/screen/details_screen/afisha_details_registration_screen.dart'
    as _i4;
import 'package:founders_academy/feature/home/presentation/screen/details_screen/afisha_details_screen.dart'
    as _i2;
import 'package:founders_academy/feature/home/presentation/screen/details_screen/book_details_screen.dart'
    as _i8;
import 'package:founders_academy/feature/home/presentation/screen/details_screen/grandmaster_details_screen.dart'
    as _i16;
import 'package:founders_academy/feature/home/presentation/screen/details_screen/news_details_screen.dart'
    as _i24;
import 'package:founders_academy/feature/home/presentation/screen/details_screen/review_matches_details_screen.dart'
    as _i47;
import 'package:founders_academy/feature/home/presentation/screen/home_screen.dart'
    as _i18;
import 'package:founders_academy/feature/home/presentation/screen/list_screen/afisha_list_screen.dart'
    as _i3;
import 'package:founders_academy/feature/home/presentation/screen/list_screen/book_list_screen.dart'
    as _i9;
import 'package:founders_academy/feature/home/presentation/screen/list_screen/grandmaster_list_screen.dart'
    as _i17;
import 'package:founders_academy/feature/home/presentation/screen/list_screen/news_list_screen.dart'
    as _i25;
import 'package:founders_academy/feature/home/presentation/screen/list_screen/review_matches_list_screen.dart'
    as _i48;
import 'package:founders_academy/feature/home/presentation/screen/main_screen.dart'
    as _i21;
import 'package:founders_academy/feature/home/presentation/screen/notification_screen.dart'
    as _i26;
import 'package:founders_academy/feature/profile/presentation/screen/leaderboard_screen.dart'
    as _i19;
import 'package:founders_academy/feature/profile/presentation/screen/my_certificate_pdf_screen.dart'
    as _i22;
import 'package:founders_academy/feature/profile/presentation/screen/my_certificate_screen.dart'
    as _i23;
import 'package:founders_academy/feature/profile/presentation/screen/profile_container_screen.dart'
    as _i28;
import 'package:founders_academy/feature/profile/presentation/screen/profile_delete_screen.dart'
    as _i29;
import 'package:founders_academy/feature/profile/presentation/screen/profile_details_screen.dart'
    as _i30;
import 'package:founders_academy/feature/profile/presentation/screen/profile_edit_details_screen.dart'
    as _i31;
import 'package:founders_academy/feature/profile/presentation/screen/profile_screen.dart'
    as _i32;
import 'package:founders_academy/feature/puzzle/data/model/puzzle_module/puzzle_module_data.dart'
    as _i61;
import 'package:founders_academy/feature/puzzle/presentation/screen/puzzle_bot_details.dart'
    as _i39;
import 'package:founders_academy/feature/puzzle/presentation/screen/puzzle_details_screen.dart'
    as _i33;
import 'package:founders_academy/feature/puzzle/presentation/screen/puzzle_list_bot.dart'
    as _i34;
import 'package:founders_academy/feature/puzzle/presentation/screen/puzzle_list_screen.dart'
    as _i35;
import 'package:founders_academy/feature/puzzle/presentation/screen/puzzle_quick_details_screen.dart'
    as _i36;
import 'package:founders_academy/feature/puzzle/presentation/screen/puzzle_quick_type_screen.dart'
    as _i37;
import 'package:founders_academy/feature/puzzle/presentation/screen/puzzle_result_screen.dart'
    as _i38;
import 'package:founders_academy/feature/shared/presentation/screen/connection_error_screen.dart'
    as _i11;
import 'package:founders_academy/feature/shared/presentation/screen/force_update_screen.dart'
    as _i15;
import 'package:founders_academy/feature/splash/screen/splash_screen.dart'
    as _i50;

abstract class $AppRouter extends _i52.RootStackRouter {
  $AppRouter({super.navigatorKey});

  @override
  final Map<String, _i52.PageFactory> pagesMap = {
    AddPostRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i1.AddPostScreen(),
      );
    },
    AfishaDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<AfishaDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i2.AfishaDetailsScreen(
          id: args.id,
          key: args.key,
        ),
      );
    },
    AfishaListRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i3.AfishaListScreen(),
      );
    },
    AfishaRegistrationRoute.name: (routeData) {
      final args = routeData.argsAs<AfishaRegistrationRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i4.AfishaRegistrationScreen(
          afishaData: args.afishaData,
          uerId: args.uerId,
          key: args.key,
        ),
      );
    },
    AfishaResultRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i5.AfishaResultScreen(),
      );
    },
    AppContainerRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i6.AppContainerScreen(),
      );
    },
    AuthorizedContainerRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i7.AuthorizedContainerScreen(),
      );
    },
    BookDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<BookDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i8.BookDetailsScreen(
          key: args.key,
          id: args.id,
        ),
      );
    },
    BookListRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i9.BookListScreen(),
      );
    },
    BookPdfRoute.name: (routeData) {
      final args = routeData.argsAs<BookPdfRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i10.BookPdfScreen(
          bookName: args.bookName,
          bookUrl: args.bookUrl,
          key: args.key,
        ),
      );
    },
    ConnectionErrorRoute.name: (routeData) {
      return _i52.AutoRoutePage<bool>(
        routeData: routeData,
        child: const _i11.ConnectionErrorScreen(),
      );
    },
    CourseDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<CourseDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i12.CourseDetailsScreen(
          course: args.course,
          key: args.key,
        ),
      );
    },
    CoursesRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i13.CoursesScreen(),
      );
    },
    DiscussionsRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i14.DiscussionsScreen(),
      );
    },
    ForceUpdateRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i15.ForceUpdateScreen(),
      );
    },
    GrandmasterDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<GrandmasterDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i16.GrandmasterDetailsScreen(
          key: args.key,
          id: args.id,
        ),
      );
    },
    GrandmastersListRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i17.GrandmastersListScreen(),
      );
    },
    HomeRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i18.HomeScreen(),
      );
    },
    LeaderboardRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i19.LeaderboardScreen(),
      );
    },
    LessonDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<LessonDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i20.LessonDetailsScreen(
          key: args.key,
          lesson: args.lesson,
          module: args.module,
        ),
      );
    },
    MainRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i21.MainScreen(),
      );
    },
    MyCertificatePdfRoute.name: (routeData) {
      final args = routeData.argsAs<MyCertificatePdfRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i22.MyCertificatePdfScreen(
          bookName: args.bookName,
          bookUrl: args.bookUrl,
          key: args.key,
        ),
      );
    },
    MyCertificateRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i23.MyCertificateScreen(),
      );
    },
    NewsDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<NewsDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i24.NewsDetailsScreen(
          id: args.id,
          key: args.key,
        ),
      );
    },
    NewsListRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i25.NewsListScreen(),
      );
    },
    NotificationRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i26.NotificationScreen(),
      );
    },
    OtpRoute.name: (routeData) {
      final args = routeData.argsAs<OtpRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i52.WrappedRoute(
            child: _i27.OtpScreen(
          key: args.key,
          otpData: args.otpData,
          userType: args.userType,
        )),
      );
    },
    ProfileContainerRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i28.ProfileContainerScreen(),
      );
    },
    ProfileDeleteRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i29.ProfileDeleteScreen(),
      );
    },
    ProfileDetailRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i30.ProfileDetailScreen(),
      );
    },
    ProfileEditDetailRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileEditDetailRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i31.ProfileEditDetailScreen(
          firstName: args.firstName,
          lastName: args.lastName,
          phoneNumber: args.phoneNumber,
          imageUrl: args.imageUrl,
          key: args.key,
        ),
      );
    },
    ProfileRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i32.ProfileScreen(),
      );
    },
    PuzzleDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<PuzzleDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i33.PuzzleDetailsScreen(
          key: args.key,
          puzzleModule: args.puzzleModule,
        ),
      );
    },
    PuzzleListBotRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i34.PuzzleListBotScreen(),
      );
    },
    PuzzleListRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i35.PuzzleListScreen(),
      );
    },
    PuzzleQuickDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<PuzzleQuickDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i36.PuzzleQuickDetailsScreen(
          selectedCount: args.selectedCount,
          puzzleType: args.puzzleType,
          limit: args.limit,
          key: args.key,
        ),
      );
    },
    PuzzleQuickTypeRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i37.PuzzleQuickTypeScreen(),
      );
    },
    PuzzleResultRoute.name: (routeData) {
      final args = routeData.argsAs<PuzzleResultRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i38.PuzzleResultScreen(
          currentIndex: args.currentIndex,
          score: args.score,
          correctPuzzleCount: args.correctPuzzleCount,
          key: args.key,
        ),
      );
    },
    PuzzleWithBotRoute.name: (routeData) {
      final args = routeData.argsAs<PuzzleWithBotRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i39.PuzzleWithBotScreen(
          url: args.url,
          key: args.key,
        ),
      );
    },
    QuizDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<QuizDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i40.QuizDetailsScreen(
          id: args.id,
          key: args.key,
        ),
      );
    },
    QuizResultRoute.name: (routeData) {
      final args = routeData.argsAs<QuizResultRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i41.QuizResultScreen(
          correctAnswersCount: args.correctAnswersCount,
          totalQuizzesCount: args.totalQuizzesCount,
          earnedPoints: args.earnedPoints,
          key: args.key,
        ),
      );
    },
    RegistrationAddressRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i42.RegistrationAddressScreen(),
      );
    },
    RegistrationContainerRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i43.RegistrationContainerScreen(),
      );
    },
    RegistrationEducationRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i44.RegistrationEducationScreen(),
      );
    },
    RegistrationPersonalInfoRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i45.RegistrationPersonalInfoScreen(),
      );
    },
    RegistrationSuccessRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i46.RegistrationSuccessScreen(),
      );
    },
    ReviewMatchDetailsRoute.name: (routeData) {
      final args = routeData.argsAs<ReviewMatchDetailsRouteArgs>();
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i47.ReviewMatchDetailsScreen(
          key: args.key,
          id: args.id,
        ),
      );
    },
    ReviewMatchesListRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i48.ReviewMatchesListScreen(),
      );
    },
    SignInRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: _i52.WrappedRoute(child: const _i49.SignInScreen()),
      );
    },
    SplashRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i50.SplashScreen(),
      );
    },
    UnauthorizedContainerRoute.name: (routeData) {
      return _i52.AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const _i51.UnauthorizedContainerScreen(),
      );
    },
  };
}

/// generated route for
/// [_i1.AddPostScreen]
class AddPostRoute extends _i52.PageRouteInfo<void> {
  const AddPostRoute({List<_i52.PageRouteInfo>? children})
      : super(
          AddPostRoute.name,
          initialChildren: children,
        );

  static const String name = 'AddPostRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i2.AfishaDetailsScreen]
class AfishaDetailsRoute extends _i52.PageRouteInfo<AfishaDetailsRouteArgs> {
  AfishaDetailsRoute({
    required String id,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          AfishaDetailsRoute.name,
          args: AfishaDetailsRouteArgs(
            id: id,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AfishaDetailsRoute';

  static const _i52.PageInfo<AfishaDetailsRouteArgs> page =
      _i52.PageInfo<AfishaDetailsRouteArgs>(name);
}

class AfishaDetailsRouteArgs {
  const AfishaDetailsRouteArgs({
    required this.id,
    this.key,
  });

  final String id;

  final _i53.Key? key;

  @override
  String toString() {
    return 'AfishaDetailsRouteArgs{id: $id, key: $key}';
  }
}

/// generated route for
/// [_i3.AfishaListScreen]
class AfishaListRoute extends _i52.PageRouteInfo<void> {
  const AfishaListRoute({List<_i52.PageRouteInfo>? children})
      : super(
          AfishaListRoute.name,
          initialChildren: children,
        );

  static const String name = 'AfishaListRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i4.AfishaRegistrationScreen]
class AfishaRegistrationRoute
    extends _i52.PageRouteInfo<AfishaRegistrationRouteArgs> {
  AfishaRegistrationRoute({
    required _i54.AfishaData afishaData,
    required String uerId,
    _i55.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          AfishaRegistrationRoute.name,
          args: AfishaRegistrationRouteArgs(
            afishaData: afishaData,
            uerId: uerId,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AfishaRegistrationRoute';

  static const _i52.PageInfo<AfishaRegistrationRouteArgs> page =
      _i52.PageInfo<AfishaRegistrationRouteArgs>(name);
}

class AfishaRegistrationRouteArgs {
  const AfishaRegistrationRouteArgs({
    required this.afishaData,
    required this.uerId,
    this.key,
  });

  final _i54.AfishaData afishaData;

  final String uerId;

  final _i55.Key? key;

  @override
  String toString() {
    return 'AfishaRegistrationRouteArgs{afishaData: $afishaData, uerId: $uerId, key: $key}';
  }
}

/// generated route for
/// [_i5.AfishaResultScreen]
class AfishaResultRoute extends _i52.PageRouteInfo<void> {
  const AfishaResultRoute({List<_i52.PageRouteInfo>? children})
      : super(
          AfishaResultRoute.name,
          initialChildren: children,
        );

  static const String name = 'AfishaResultRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i6.AppContainerScreen]
class AppContainerRoute extends _i52.PageRouteInfo<void> {
  const AppContainerRoute({List<_i52.PageRouteInfo>? children})
      : super(
          AppContainerRoute.name,
          initialChildren: children,
        );

  static const String name = 'AppContainerRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i7.AuthorizedContainerScreen]
class AuthorizedContainerRoute extends _i52.PageRouteInfo<void> {
  const AuthorizedContainerRoute({List<_i52.PageRouteInfo>? children})
      : super(
          AuthorizedContainerRoute.name,
          initialChildren: children,
        );

  static const String name = 'AuthorizedContainerRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i8.BookDetailsScreen]
class BookDetailsRoute extends _i52.PageRouteInfo<BookDetailsRouteArgs> {
  BookDetailsRoute({
    _i53.Key? key,
    required String id,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          BookDetailsRoute.name,
          args: BookDetailsRouteArgs(
            key: key,
            id: id,
          ),
          initialChildren: children,
        );

  static const String name = 'BookDetailsRoute';

  static const _i52.PageInfo<BookDetailsRouteArgs> page =
      _i52.PageInfo<BookDetailsRouteArgs>(name);
}

class BookDetailsRouteArgs {
  const BookDetailsRouteArgs({
    this.key,
    required this.id,
  });

  final _i53.Key? key;

  final String id;

  @override
  String toString() {
    return 'BookDetailsRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i9.BookListScreen]
class BookListRoute extends _i52.PageRouteInfo<void> {
  const BookListRoute({List<_i52.PageRouteInfo>? children})
      : super(
          BookListRoute.name,
          initialChildren: children,
        );

  static const String name = 'BookListRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i10.BookPdfScreen]
class BookPdfRoute extends _i52.PageRouteInfo<BookPdfRouteArgs> {
  BookPdfRoute({
    required String bookName,
    required String bookUrl,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          BookPdfRoute.name,
          args: BookPdfRouteArgs(
            bookName: bookName,
            bookUrl: bookUrl,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'BookPdfRoute';

  static const _i52.PageInfo<BookPdfRouteArgs> page =
      _i52.PageInfo<BookPdfRouteArgs>(name);
}

class BookPdfRouteArgs {
  const BookPdfRouteArgs({
    required this.bookName,
    required this.bookUrl,
    this.key,
  });

  final String bookName;

  final String bookUrl;

  final _i53.Key? key;

  @override
  String toString() {
    return 'BookPdfRouteArgs{bookName: $bookName, bookUrl: $bookUrl, key: $key}';
  }
}

/// generated route for
/// [_i11.ConnectionErrorScreen]
class ConnectionErrorRoute extends _i52.PageRouteInfo<void> {
  const ConnectionErrorRoute({List<_i52.PageRouteInfo>? children})
      : super(
          ConnectionErrorRoute.name,
          initialChildren: children,
        );

  static const String name = 'ConnectionErrorRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i12.CourseDetailsScreen]
class CourseDetailsRoute extends _i52.PageRouteInfo<CourseDetailsRouteArgs> {
  CourseDetailsRoute({
    required _i56.CourseData course,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          CourseDetailsRoute.name,
          args: CourseDetailsRouteArgs(
            course: course,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'CourseDetailsRoute';

  static const _i52.PageInfo<CourseDetailsRouteArgs> page =
      _i52.PageInfo<CourseDetailsRouteArgs>(name);
}

class CourseDetailsRouteArgs {
  const CourseDetailsRouteArgs({
    required this.course,
    this.key,
  });

  final _i56.CourseData course;

  final _i53.Key? key;

  @override
  String toString() {
    return 'CourseDetailsRouteArgs{course: $course, key: $key}';
  }
}

/// generated route for
/// [_i13.CoursesScreen]
class CoursesRoute extends _i52.PageRouteInfo<void> {
  const CoursesRoute({List<_i52.PageRouteInfo>? children})
      : super(
          CoursesRoute.name,
          initialChildren: children,
        );

  static const String name = 'CoursesRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i14.DiscussionsScreen]
class DiscussionsRoute extends _i52.PageRouteInfo<void> {
  const DiscussionsRoute({List<_i52.PageRouteInfo>? children})
      : super(
          DiscussionsRoute.name,
          initialChildren: children,
        );

  static const String name = 'DiscussionsRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i15.ForceUpdateScreen]
class ForceUpdateRoute extends _i52.PageRouteInfo<void> {
  const ForceUpdateRoute({List<_i52.PageRouteInfo>? children})
      : super(
          ForceUpdateRoute.name,
          initialChildren: children,
        );

  static const String name = 'ForceUpdateRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i16.GrandmasterDetailsScreen]
class GrandmasterDetailsRoute
    extends _i52.PageRouteInfo<GrandmasterDetailsRouteArgs> {
  GrandmasterDetailsRoute({
    _i53.Key? key,
    required String id,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          GrandmasterDetailsRoute.name,
          args: GrandmasterDetailsRouteArgs(
            key: key,
            id: id,
          ),
          initialChildren: children,
        );

  static const String name = 'GrandmasterDetailsRoute';

  static const _i52.PageInfo<GrandmasterDetailsRouteArgs> page =
      _i52.PageInfo<GrandmasterDetailsRouteArgs>(name);
}

class GrandmasterDetailsRouteArgs {
  const GrandmasterDetailsRouteArgs({
    this.key,
    required this.id,
  });

  final _i53.Key? key;

  final String id;

  @override
  String toString() {
    return 'GrandmasterDetailsRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i17.GrandmastersListScreen]
class GrandmastersListRoute extends _i52.PageRouteInfo<void> {
  const GrandmastersListRoute({List<_i52.PageRouteInfo>? children})
      : super(
          GrandmastersListRoute.name,
          initialChildren: children,
        );

  static const String name = 'GrandmastersListRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i18.HomeScreen]
class HomeRoute extends _i52.PageRouteInfo<void> {
  const HomeRoute({List<_i52.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i19.LeaderboardScreen]
class LeaderboardRoute extends _i52.PageRouteInfo<void> {
  const LeaderboardRoute({List<_i52.PageRouteInfo>? children})
      : super(
          LeaderboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'LeaderboardRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i20.LessonDetailsScreen]
class LessonDetailsRoute extends _i52.PageRouteInfo<LessonDetailsRouteArgs> {
  LessonDetailsRoute({
    _i53.Key? key,
    required _i57.LessonData lesson,
    required _i58.ModuleData module,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          LessonDetailsRoute.name,
          args: LessonDetailsRouteArgs(
            key: key,
            lesson: lesson,
            module: module,
          ),
          initialChildren: children,
        );

  static const String name = 'LessonDetailsRoute';

  static const _i52.PageInfo<LessonDetailsRouteArgs> page =
      _i52.PageInfo<LessonDetailsRouteArgs>(name);
}

class LessonDetailsRouteArgs {
  const LessonDetailsRouteArgs({
    this.key,
    required this.lesson,
    required this.module,
  });

  final _i53.Key? key;

  final _i57.LessonData lesson;

  final _i58.ModuleData module;

  @override
  String toString() {
    return 'LessonDetailsRouteArgs{key: $key, lesson: $lesson, module: $module}';
  }
}

/// generated route for
/// [_i21.MainScreen]
class MainRoute extends _i52.PageRouteInfo<void> {
  const MainRoute({List<_i52.PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i22.MyCertificatePdfScreen]
class MyCertificatePdfRoute
    extends _i52.PageRouteInfo<MyCertificatePdfRouteArgs> {
  MyCertificatePdfRoute({
    required String bookName,
    required String bookUrl,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          MyCertificatePdfRoute.name,
          args: MyCertificatePdfRouteArgs(
            bookName: bookName,
            bookUrl: bookUrl,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'MyCertificatePdfRoute';

  static const _i52.PageInfo<MyCertificatePdfRouteArgs> page =
      _i52.PageInfo<MyCertificatePdfRouteArgs>(name);
}

class MyCertificatePdfRouteArgs {
  const MyCertificatePdfRouteArgs({
    required this.bookName,
    required this.bookUrl,
    this.key,
  });

  final String bookName;

  final String bookUrl;

  final _i53.Key? key;

  @override
  String toString() {
    return 'MyCertificatePdfRouteArgs{bookName: $bookName, bookUrl: $bookUrl, key: $key}';
  }
}

/// generated route for
/// [_i23.MyCertificateScreen]
class MyCertificateRoute extends _i52.PageRouteInfo<void> {
  const MyCertificateRoute({List<_i52.PageRouteInfo>? children})
      : super(
          MyCertificateRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyCertificateRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i24.NewsDetailsScreen]
class NewsDetailsRoute extends _i52.PageRouteInfo<NewsDetailsRouteArgs> {
  NewsDetailsRoute({
    required String id,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          NewsDetailsRoute.name,
          args: NewsDetailsRouteArgs(
            id: id,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'NewsDetailsRoute';

  static const _i52.PageInfo<NewsDetailsRouteArgs> page =
      _i52.PageInfo<NewsDetailsRouteArgs>(name);
}

class NewsDetailsRouteArgs {
  const NewsDetailsRouteArgs({
    required this.id,
    this.key,
  });

  final String id;

  final _i53.Key? key;

  @override
  String toString() {
    return 'NewsDetailsRouteArgs{id: $id, key: $key}';
  }
}

/// generated route for
/// [_i25.NewsListScreen]
class NewsListRoute extends _i52.PageRouteInfo<void> {
  const NewsListRoute({List<_i52.PageRouteInfo>? children})
      : super(
          NewsListRoute.name,
          initialChildren: children,
        );

  static const String name = 'NewsListRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i26.NotificationScreen]
class NotificationRoute extends _i52.PageRouteInfo<void> {
  const NotificationRoute({List<_i52.PageRouteInfo>? children})
      : super(
          NotificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotificationRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i27.OtpScreen]
class OtpRoute extends _i52.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    _i53.Key? key,
    required _i59.OtpData otpData,
    required _i60.UserType userType,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          OtpRoute.name,
          args: OtpRouteArgs(
            key: key,
            otpData: otpData,
            userType: userType,
          ),
          initialChildren: children,
        );

  static const String name = 'OtpRoute';

  static const _i52.PageInfo<OtpRouteArgs> page =
      _i52.PageInfo<OtpRouteArgs>(name);
}

class OtpRouteArgs {
  const OtpRouteArgs({
    this.key,
    required this.otpData,
    required this.userType,
  });

  final _i53.Key? key;

  final _i59.OtpData otpData;

  final _i60.UserType userType;

  @override
  String toString() {
    return 'OtpRouteArgs{key: $key, otpData: $otpData, userType: $userType}';
  }
}

/// generated route for
/// [_i28.ProfileContainerScreen]
class ProfileContainerRoute extends _i52.PageRouteInfo<void> {
  const ProfileContainerRoute({List<_i52.PageRouteInfo>? children})
      : super(
          ProfileContainerRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileContainerRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i29.ProfileDeleteScreen]
class ProfileDeleteRoute extends _i52.PageRouteInfo<void> {
  const ProfileDeleteRoute({List<_i52.PageRouteInfo>? children})
      : super(
          ProfileDeleteRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileDeleteRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i30.ProfileDetailScreen]
class ProfileDetailRoute extends _i52.PageRouteInfo<void> {
  const ProfileDetailRoute({List<_i52.PageRouteInfo>? children})
      : super(
          ProfileDetailRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileDetailRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i31.ProfileEditDetailScreen]
class ProfileEditDetailRoute
    extends _i52.PageRouteInfo<ProfileEditDetailRouteArgs> {
  ProfileEditDetailRoute({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String imageUrl,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          ProfileEditDetailRoute.name,
          args: ProfileEditDetailRouteArgs(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            imageUrl: imageUrl,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ProfileEditDetailRoute';

  static const _i52.PageInfo<ProfileEditDetailRouteArgs> page =
      _i52.PageInfo<ProfileEditDetailRouteArgs>(name);
}

class ProfileEditDetailRouteArgs {
  const ProfileEditDetailRouteArgs({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.imageUrl,
    this.key,
  });

  final String firstName;

  final String lastName;

  final String phoneNumber;

  final String imageUrl;

  final _i53.Key? key;

  @override
  String toString() {
    return 'ProfileEditDetailRouteArgs{firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, imageUrl: $imageUrl, key: $key}';
  }
}

/// generated route for
/// [_i32.ProfileScreen]
class ProfileRoute extends _i52.PageRouteInfo<void> {
  const ProfileRoute({List<_i52.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i33.PuzzleDetailsScreen]
class PuzzleDetailsRoute extends _i52.PageRouteInfo<PuzzleDetailsRouteArgs> {
  PuzzleDetailsRoute({
    _i53.Key? key,
    required _i61.PuzzleModuleData puzzleModule,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          PuzzleDetailsRoute.name,
          args: PuzzleDetailsRouteArgs(
            key: key,
            puzzleModule: puzzleModule,
          ),
          initialChildren: children,
        );

  static const String name = 'PuzzleDetailsRoute';

  static const _i52.PageInfo<PuzzleDetailsRouteArgs> page =
      _i52.PageInfo<PuzzleDetailsRouteArgs>(name);
}

class PuzzleDetailsRouteArgs {
  const PuzzleDetailsRouteArgs({
    this.key,
    required this.puzzleModule,
  });

  final _i53.Key? key;

  final _i61.PuzzleModuleData puzzleModule;

  @override
  String toString() {
    return 'PuzzleDetailsRouteArgs{key: $key, puzzleModule: $puzzleModule}';
  }
}

/// generated route for
/// [_i34.PuzzleListBotScreen]
class PuzzleListBotRoute extends _i52.PageRouteInfo<void> {
  const PuzzleListBotRoute({List<_i52.PageRouteInfo>? children})
      : super(
          PuzzleListBotRoute.name,
          initialChildren: children,
        );

  static const String name = 'PuzzleListBotRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i35.PuzzleListScreen]
class PuzzleListRoute extends _i52.PageRouteInfo<void> {
  const PuzzleListRoute({List<_i52.PageRouteInfo>? children})
      : super(
          PuzzleListRoute.name,
          initialChildren: children,
        );

  static const String name = 'PuzzleListRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i36.PuzzleQuickDetailsScreen]
class PuzzleQuickDetailsRoute
    extends _i52.PageRouteInfo<PuzzleQuickDetailsRouteArgs> {
  PuzzleQuickDetailsRoute({
    required String selectedCount,
    required List<String> puzzleType,
    required int limit,
    _i55.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          PuzzleQuickDetailsRoute.name,
          args: PuzzleQuickDetailsRouteArgs(
            selectedCount: selectedCount,
            puzzleType: puzzleType,
            limit: limit,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'PuzzleQuickDetailsRoute';

  static const _i52.PageInfo<PuzzleQuickDetailsRouteArgs> page =
      _i52.PageInfo<PuzzleQuickDetailsRouteArgs>(name);
}

class PuzzleQuickDetailsRouteArgs {
  const PuzzleQuickDetailsRouteArgs({
    required this.selectedCount,
    required this.puzzleType,
    required this.limit,
    this.key,
  });

  final String selectedCount;

  final List<String> puzzleType;

  final int limit;

  final _i55.Key? key;

  @override
  String toString() {
    return 'PuzzleQuickDetailsRouteArgs{selectedCount: $selectedCount, puzzleType: $puzzleType, limit: $limit, key: $key}';
  }
}

/// generated route for
/// [_i37.PuzzleQuickTypeScreen]
class PuzzleQuickTypeRoute extends _i52.PageRouteInfo<void> {
  const PuzzleQuickTypeRoute({List<_i52.PageRouteInfo>? children})
      : super(
          PuzzleQuickTypeRoute.name,
          initialChildren: children,
        );

  static const String name = 'PuzzleQuickTypeRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i38.PuzzleResultScreen]
class PuzzleResultRoute extends _i52.PageRouteInfo<PuzzleResultRouteArgs> {
  PuzzleResultRoute({
    required int currentIndex,
    required int score,
    required int correctPuzzleCount,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          PuzzleResultRoute.name,
          args: PuzzleResultRouteArgs(
            currentIndex: currentIndex,
            score: score,
            correctPuzzleCount: correctPuzzleCount,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'PuzzleResultRoute';

  static const _i52.PageInfo<PuzzleResultRouteArgs> page =
      _i52.PageInfo<PuzzleResultRouteArgs>(name);
}

class PuzzleResultRouteArgs {
  const PuzzleResultRouteArgs({
    required this.currentIndex,
    required this.score,
    required this.correctPuzzleCount,
    this.key,
  });

  final int currentIndex;

  final int score;

  final int correctPuzzleCount;

  final _i53.Key? key;

  @override
  String toString() {
    return 'PuzzleResultRouteArgs{currentIndex: $currentIndex, score: $score, correctPuzzleCount: $correctPuzzleCount, key: $key}';
  }
}

/// generated route for
/// [_i39.PuzzleWithBotScreen]
class PuzzleWithBotRoute extends _i52.PageRouteInfo<PuzzleWithBotRouteArgs> {
  PuzzleWithBotRoute({
    required String url,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          PuzzleWithBotRoute.name,
          args: PuzzleWithBotRouteArgs(
            url: url,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'PuzzleWithBotRoute';

  static const _i52.PageInfo<PuzzleWithBotRouteArgs> page =
      _i52.PageInfo<PuzzleWithBotRouteArgs>(name);
}

class PuzzleWithBotRouteArgs {
  const PuzzleWithBotRouteArgs({
    required this.url,
    this.key,
  });

  final String url;

  final _i53.Key? key;

  @override
  String toString() {
    return 'PuzzleWithBotRouteArgs{url: $url, key: $key}';
  }
}

/// generated route for
/// [_i40.QuizDetailsScreen]
class QuizDetailsRoute extends _i52.PageRouteInfo<QuizDetailsRouteArgs> {
  QuizDetailsRoute({
    required String id,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          QuizDetailsRoute.name,
          args: QuizDetailsRouteArgs(
            id: id,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'QuizDetailsRoute';

  static const _i52.PageInfo<QuizDetailsRouteArgs> page =
      _i52.PageInfo<QuizDetailsRouteArgs>(name);
}

class QuizDetailsRouteArgs {
  const QuizDetailsRouteArgs({
    required this.id,
    this.key,
  });

  final String id;

  final _i53.Key? key;

  @override
  String toString() {
    return 'QuizDetailsRouteArgs{id: $id, key: $key}';
  }
}

/// generated route for
/// [_i41.QuizResultScreen]
class QuizResultRoute extends _i52.PageRouteInfo<QuizResultRouteArgs> {
  QuizResultRoute({
    required int correctAnswersCount,
    required int totalQuizzesCount,
    required int earnedPoints,
    _i53.Key? key,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          QuizResultRoute.name,
          args: QuizResultRouteArgs(
            correctAnswersCount: correctAnswersCount,
            totalQuizzesCount: totalQuizzesCount,
            earnedPoints: earnedPoints,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'QuizResultRoute';

  static const _i52.PageInfo<QuizResultRouteArgs> page =
      _i52.PageInfo<QuizResultRouteArgs>(name);
}

class QuizResultRouteArgs {
  const QuizResultRouteArgs({
    required this.correctAnswersCount,
    required this.totalQuizzesCount,
    required this.earnedPoints,
    this.key,
  });

  final int correctAnswersCount;

  final int totalQuizzesCount;

  final int earnedPoints;

  final _i53.Key? key;

  @override
  String toString() {
    return 'QuizResultRouteArgs{correctAnswersCount: $correctAnswersCount, totalQuizzesCount: $totalQuizzesCount, earnedPoints: $earnedPoints, key: $key}';
  }
}

/// generated route for
/// [_i42.RegistrationAddressScreen]
class RegistrationAddressRoute extends _i52.PageRouteInfo<void> {
  const RegistrationAddressRoute({List<_i52.PageRouteInfo>? children})
      : super(
          RegistrationAddressRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegistrationAddressRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i43.RegistrationContainerScreen]
class RegistrationContainerRoute extends _i52.PageRouteInfo<void> {
  const RegistrationContainerRoute({List<_i52.PageRouteInfo>? children})
      : super(
          RegistrationContainerRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegistrationContainerRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i44.RegistrationEducationScreen]
class RegistrationEducationRoute extends _i52.PageRouteInfo<void> {
  const RegistrationEducationRoute({List<_i52.PageRouteInfo>? children})
      : super(
          RegistrationEducationRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegistrationEducationRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i45.RegistrationPersonalInfoScreen]
class RegistrationPersonalInfoRoute extends _i52.PageRouteInfo<void> {
  const RegistrationPersonalInfoRoute({List<_i52.PageRouteInfo>? children})
      : super(
          RegistrationPersonalInfoRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegistrationPersonalInfoRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i46.RegistrationSuccessScreen]
class RegistrationSuccessRoute extends _i52.PageRouteInfo<void> {
  const RegistrationSuccessRoute({List<_i52.PageRouteInfo>? children})
      : super(
          RegistrationSuccessRoute.name,
          initialChildren: children,
        );

  static const String name = 'RegistrationSuccessRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i47.ReviewMatchDetailsScreen]
class ReviewMatchDetailsRoute
    extends _i52.PageRouteInfo<ReviewMatchDetailsRouteArgs> {
  ReviewMatchDetailsRoute({
    _i53.Key? key,
    required String id,
    List<_i52.PageRouteInfo>? children,
  }) : super(
          ReviewMatchDetailsRoute.name,
          args: ReviewMatchDetailsRouteArgs(
            key: key,
            id: id,
          ),
          initialChildren: children,
        );

  static const String name = 'ReviewMatchDetailsRoute';

  static const _i52.PageInfo<ReviewMatchDetailsRouteArgs> page =
      _i52.PageInfo<ReviewMatchDetailsRouteArgs>(name);
}

class ReviewMatchDetailsRouteArgs {
  const ReviewMatchDetailsRouteArgs({
    this.key,
    required this.id,
  });

  final _i53.Key? key;

  final String id;

  @override
  String toString() {
    return 'ReviewMatchDetailsRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i48.ReviewMatchesListScreen]
class ReviewMatchesListRoute extends _i52.PageRouteInfo<void> {
  const ReviewMatchesListRoute({List<_i52.PageRouteInfo>? children})
      : super(
          ReviewMatchesListRoute.name,
          initialChildren: children,
        );

  static const String name = 'ReviewMatchesListRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i49.SignInScreen]
class SignInRoute extends _i52.PageRouteInfo<void> {
  const SignInRoute({List<_i52.PageRouteInfo>? children})
      : super(
          SignInRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignInRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i50.SplashScreen]
class SplashRoute extends _i52.PageRouteInfo<void> {
  const SplashRoute({List<_i52.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}

/// generated route for
/// [_i51.UnauthorizedContainerScreen]
class UnauthorizedContainerRoute extends _i52.PageRouteInfo<void> {
  const UnauthorizedContainerRoute({List<_i52.PageRouteInfo>? children})
      : super(
          UnauthorizedContainerRoute.name,
          initialChildren: children,
        );

  static const String name = 'UnauthorizedContainerRoute';

  static const _i52.PageInfo<void> page = _i52.PageInfo<void>(name);
}
