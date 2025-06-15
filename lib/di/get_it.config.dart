// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i30;
import 'package:founders_academy/core/api/api_client_manager.dart' as _i29;
import 'package:founders_academy/core/api/environment/environment_manager.dart'
    as _i6;
import 'package:founders_academy/core/api/http_inspector.dart' as _i4;
import 'package:founders_academy/core/api/interceptor/user_session_interceptor.dart'
    as _i28;
import 'package:founders_academy/core/database/isar_provider.dart' as _i9;
import 'package:founders_academy/core/firebase/firebase_remote_config_manager.dart'
    as _i8;
import 'package:founders_academy/core/push_notification/push_notification_manager.dart'
    as _i12;
import 'package:founders_academy/core/safe_execution/domain/connectivity_handler.dart'
    as _i23;
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart'
    as _i27;
import 'package:founders_academy/core/safe_execution/presentation/connectivity_handler.dart'
    as _i24;
import 'package:founders_academy/core/version/version_manager.dart' as _i20;
import 'package:founders_academy/di/module/api_client_module.dart' as _i84;
import 'package:founders_academy/di/module/shared_pref_module.dart' as _i83;
import 'package:founders_academy/feature/app_init/cubit/app_init_cubit.dart'
    as _i22;
import 'package:founders_academy/feature/auth/data/data_source/auth_api_client.dart'
    as _i35;
import 'package:founders_academy/feature/auth/data/data_source/token_data_source.dart'
    as _i16;
import 'package:founders_academy/feature/auth/data/data_source/user_data_source.dart'
    as _i17;
import 'package:founders_academy/feature/auth/data/repository/auth_repository.dart'
    as _i37;
import 'package:founders_academy/feature/auth/domain/repository/base_auth_repository.dart'
    as _i36;
import 'package:founders_academy/feature/auth/domain/user_session_manager.dart'
    as _i18;
import 'package:founders_academy/feature/auth/presentation/cubit/auth/auth_cubit.dart'
    as _i75;
import 'package:founders_academy/feature/auth/presentation/cubit/country/country_cubit.dart'
    as _i5;
import 'package:founders_academy/feature/auth/presentation/cubit/otp/otp_cubit.dart'
    as _i11;
import 'package:founders_academy/feature/auth/presentation/cubit/profile_creation/profile_creation_cubit.dart'
    as _i61;
import 'package:founders_academy/feature/auth/presentation/cubit/registration/registration_cubit.dart'
    as _i13;
import 'package:founders_academy/feature/base_url/app_base_url_cubit.dart'
    as _i21;
import 'package:founders_academy/feature/courses/data/data_source/local_data_source/lesson_completion_database.dart'
    as _i10;
import 'package:founders_academy/feature/courses/data/data_source/remote_data_source/courses_api_client.dart'
    as _i50;
import 'package:founders_academy/feature/courses/data/repository/course_repository.dart'
    as _i77;
import 'package:founders_academy/feature/courses/domain/repository/base_course_repository.dart'
    as _i76;
import 'package:founders_academy/feature/courses/presentation/cubit/course_details/course_details_cubit.dart'
    as _i78;
import 'package:founders_academy/feature/courses/presentation/cubit/courses/courses_cubit.dart'
    as _i79;
import 'package:founders_academy/feature/courses/presentation/cubit/lesson/lesson_cubit.dart'
    as _i81;
import 'package:founders_academy/feature/courses/presentation/cubit/quiz/quiz_cubit.dart'
    as _i82;
import 'package:founders_academy/feature/home/data/data_source/local_data_source/search_isar_database.dart'
    as _i14;
import 'package:founders_academy/feature/home/data/data_source/remote_data_source/home_api_client.dart'
    as _i31;
import 'package:founders_academy/feature/home/data/data_source/remote_data_source/search_api_client.dart'
    as _i34;
import 'package:founders_academy/feature/home/data/repository/home_repository.dart'
    as _i39;
import 'package:founders_academy/feature/home/data/repository/search_repository.dart'
    as _i47;
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart'
    as _i38;
import 'package:founders_academy/feature/home/domain/repository/base_search_repository.dart'
    as _i46;
import 'package:founders_academy/feature/home/presentation/cubit/afisha_cubit/afisha_cubit.dart'
    as _i72;
import 'package:founders_academy/feature/home/presentation/cubit/afisha_item_cubit/afisha_item_cubit.dart'
    as _i73;
import 'package:founders_academy/feature/home/presentation/cubit/afisha_register_cubit/afisha_cubit.dart'
    as _i74;
import 'package:founders_academy/feature/home/presentation/cubit/book_cubit/book_cubit.dart'
    as _i48;
import 'package:founders_academy/feature/home/presentation/cubit/book_list_cubit/book_list_cubit.dart'
    as _i49;
import 'package:founders_academy/feature/home/presentation/cubit/grandmaster_cubit/grandmaster_cubit.dart'
    as _i52;
import 'package:founders_academy/feature/home/presentation/cubit/grandmaster_item_cubit/grandmaster_item_cubit.dart'
    as _i53;
import 'package:founders_academy/feature/home/presentation/cubit/home_cubit/home_cubit.dart'
    as _i80;
import 'package:founders_academy/feature/home/presentation/cubit/livestream_item_cubit/livestream_cubit.dart'
    as _i56;
import 'package:founders_academy/feature/home/presentation/cubit/main_cubit/main_cubit.dart'
    as _i26;
import 'package:founders_academy/feature/home/presentation/cubit/news_cubit/news_cubit.dart'
    as _i58;
import 'package:founders_academy/feature/home/presentation/cubit/news_item_cubit/news_item_cubit.dart'
    as _i59;
import 'package:founders_academy/feature/home/presentation/cubit/notification_cubit/notification_cubit.dart'
    as _i60;
import 'package:founders_academy/feature/home/presentation/cubit/review_match_cubit/review_match_cubit.dart'
    as _i69;
import 'package:founders_academy/feature/home/presentation/cubit/review_matches_list_cubit/review_matches_list_cubit.dart'
    as _i70;
import 'package:founders_academy/feature/home/presentation/cubit/search_cubit/search_cubit.dart'
    as _i71;
import 'package:founders_academy/feature/profile/data/data_source/profile_api_client.dart'
    as _i32;
import 'package:founders_academy/feature/profile/data/repository/profile_repository.dart'
    as _i41;
import 'package:founders_academy/feature/profile/domain/repository/base_profile_repository.dart'
    as _i40;
import 'package:founders_academy/feature/profile/presentation/cubit/image_cubit/image_cubit.dart'
    as _i54;
import 'package:founders_academy/feature/profile/presentation/cubit/leader_board_cubit/leader_board_cubit.dart'
    as _i55;
import 'package:founders_academy/feature/profile/presentation/cubit/my_certificate_cubit/my_certificate_cubit.dart'
    as _i57;
import 'package:founders_academy/feature/profile/presentation/cubit/profile_cubit/profile_cubit.dart'
    as _i62;
import 'package:founders_academy/feature/profile/presentation/cubit/profile_delete_cubit/profile_delete_cubit.dart'
    as _i63;
import 'package:founders_academy/feature/profile/presentation/cubit/version_cubit/version_cubit.dart'
    as _i19;
import 'package:founders_academy/feature/puzzle/data/data_source/remote_data_source/puzzle_api_client.dart'
    as _i33;
import 'package:founders_academy/feature/puzzle/data/repository/puzzle_repository.dart'
    as _i45;
import 'package:founders_academy/feature/puzzle/domain/repository/base_puzzle_repository.dart'
    as _i44;
import 'package:founders_academy/feature/puzzle/presentation/cubit/grandmaster_bot/grandmaster_bot_cubit.dart'
    as _i51;
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle/puzzle_cubit.dart'
    as _i65;
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_module/puzzle_module_cubit.dart'
    as _i66;
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_quick/puzzle_quick_cubit.dart'
    as _i67;
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_report/puzzle_report_cubit.dart'
    as _i68;
import 'package:founders_academy/feature/shared/data/data_source/local_data_source/fcm_data_source.dart'
    as _i7;
import 'package:founders_academy/feature/shared/data/repository/push_notification_repository.dart'
    as _i43;
import 'package:founders_academy/feature/shared/domain/repository/base_push_notification_repository.dart'
    as _i42;
import 'package:founders_academy/feature/shared/presentation/cubit/force_update_cubit/force_update_cubit.dart'
    as _i25;
import 'package:founders_academy/feature/shared/presentation/cubit/push_notification_cubit/push_notification_cubit.dart'
    as _i64;
import 'package:founders_academy/routing/app_router.dart' as _i3;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i15;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final sharedPrefsModule = _$SharedPrefsModule();
    final apiClientModule = _$ApiClientModule();
    gh.lazySingleton<_i3.AppRouter>(() => _i3.AppRouter());
    gh.lazySingleton<_i4.BaseHttpInspector>(
        () => _i4.BaseHttpInspector.fromEnvironment());
    gh.factory<_i5.CountryCubit>(() => _i5.CountryCubit());
    gh.factory<_i6.EnvironmentManager>(() => _i6.EnvironmentManager());
    gh.factory<_i7.FcmDataSource>(() => _i7.FcmDataSource());
    gh.factory<_i8.FirebaseRemoteConfigManager>(
        () => _i8.FirebaseRemoteConfigManager());
    gh.lazySingleton<_i9.IsarProvider>(() => _i9.IsarProvider());
    gh.factory<_i10.LessonCompletionDatabase>(
        () => _i10.LessonCompletionDatabase(gh<_i9.IsarProvider>()));
    gh.factory<_i11.OtpCubit>(() => _i11.OtpCubit());
    gh.factory<_i12.PushNotificationManager>(() => _i12.PushNotificationManager(
          gh<_i7.FcmDataSource>(),
          gh<_i3.AppRouter>(),
        ));
    gh.factory<_i13.RegistrationCubit>(() => _i13.RegistrationCubit());
    gh.factory<_i14.SearchIsarDatabase>(
        () => _i14.SearchIsarDatabase(gh<_i9.IsarProvider>()));
    await gh.singletonAsync<_i15.SharedPreferences>(
      () => sharedPrefsModule.provideSharedPreferences(),
      preResolve: true,
    );
    gh.factory<_i16.TokenDataSource>(() => _i16.TokenDataSource());
    gh.factory<_i17.UserDataDataSource>(
        () => _i17.UserDataDataSource(gh<_i15.SharedPreferences>()));
    gh.singleton<_i18.UserSessionManager>(_i18.UserSessionManager(
      gh<_i16.TokenDataSource>(),
      gh<_i17.UserDataDataSource>(),
    ));
    gh.factory<_i19.VersionCubit>(() => _i19.VersionCubit());
    gh.factory<_i20.VersionManager>(
        () => _i20.VersionManager(gh<_i8.FirebaseRemoteConfigManager>()));
    gh.factory<_i21.AppBaseUrlCubit>(
        () => _i21.AppBaseUrlCubit(gh<_i6.EnvironmentManager>()));
    gh.factory<_i22.AppInitCubit>(() => _i22.AppInitCubit(
          gh<_i18.UserSessionManager>(),
          gh<_i20.VersionManager>(),
        ));
    gh.factory<_i23.ConnectivityHandler>(() => _i24.AutoRouteConnectivtyHandler(
          gh<_i3.AppRouter>(),
          gh<_i18.UserSessionManager>(),
        ));
    gh.factory<_i25.ForceUpdateCubit>(
        () => _i25.ForceUpdateCubit(gh<_i20.VersionManager>()));
    gh.factory<_i26.MainCubit>(() => _i26.MainCubit(
          gh<_i20.VersionManager>(),
          gh<_i12.PushNotificationManager>(),
        ));
    gh.factory<_i27.SafeExecutionManager>(
        () => _i27.SafeExecutionManager(gh<_i23.ConnectivityHandler>()));
    gh.factory<_i28.UserSessionInterceptor>(
        () => _i28.UserSessionInterceptor(gh<_i18.UserSessionManager>()));
    gh.lazySingleton<_i29.ApiClientManager>(() => _i29.ApiClientManager(
          gh<_i28.UserSessionInterceptor>(),
          gh<_i4.BaseHttpInspector>(),
          gh<_i6.EnvironmentManager>(),
        ));
    gh.factory<_i30.Dio>(
      () =>
          apiClientModule.getUnauthorizedApiClient(gh<_i29.ApiClientManager>()),
      instanceName: 'UnauthorizedApiClient',
    );
    gh.factory<_i30.Dio>(
      () => apiClientModule.getAuthorizedApiClient(gh<_i29.ApiClientManager>()),
      instanceName: 'AuthorizedApiClient',
    );
    gh.factory<_i31.HomeApiClient>(() =>
        _i31.HomeApiClient(gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i32.ProfileApiClient>(() => _i32.ProfileApiClient(
        gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i33.PuzzleApiClient>(() => _i33.PuzzleApiClient(
        gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i34.SearchApiClient>(() => _i34.SearchApiClient(
        gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i35.AuthApiClient>(() => _i35.AuthApiClient(
        gh<_i30.Dio>(instanceName: 'UnauthorizedApiClient')));
    gh.factory<_i36.BaseAuthRepository>(
        () => _i37.AuthRepository(gh<_i35.AuthApiClient>()));
    gh.factory<_i38.BaseHomeRepository>(
        () => _i39.HomeRepository(gh<_i31.HomeApiClient>()));
    gh.factory<_i40.BaseProfileRepository>(() => _i41.ProfileRepository(
          gh<_i32.ProfileApiClient>(),
          gh<_i10.LessonCompletionDatabase>(),
        ));
    gh.factory<_i42.BasePushNotifiactionRepository>(
        () => _i43.PushNotificationRepository(gh<_i31.HomeApiClient>()));
    gh.factory<_i44.BasePuzzleRepository>(
        () => _i45.PuzzleRepository(gh<_i33.PuzzleApiClient>()));
    gh.factory<_i46.BaseSearchRepository>(() => _i47.SearchRepository(
          gh<_i14.SearchIsarDatabase>(),
          gh<_i34.SearchApiClient>(),
        ));
    gh.factory<_i48.BookCubit>(() => _i48.BookCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i49.BookListCubit>(() => _i49.BookListCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i50.CoursesApiClient>(() => _i50.CoursesApiClient(
        gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i51.GrandMasterBotCubit>(() => _i51.GrandMasterBotCubit(
          gh<_i44.BasePuzzleRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i52.GrandmasterCubit>(() => _i52.GrandmasterCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i53.GrandmasterItemCubit>(() => _i53.GrandmasterItemCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i54.ImageCubit>(() => _i54.ImageCubit(
          gh<_i40.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i55.LeaderBoardCubit>(() => _i55.LeaderBoardCubit(
          gh<_i40.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i56.LiveStreamItemCubit>(() => _i56.LiveStreamItemCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i57.MyCertificateCubit>(() => _i57.MyCertificateCubit(
          gh<_i40.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i58.NewsCubit>(() => _i58.NewsCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i59.NewsItemCubit>(() => _i59.NewsItemCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i60.NotificationCubit>(() => _i60.NotificationCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i61.ProfileCreationCubit>(() => _i61.ProfileCreationCubit(
          gh<_i40.BaseProfileRepository>(),
          gh<_i18.UserSessionManager>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i62.ProfileCubit>(() => _i62.ProfileCubit(
          gh<_i18.UserSessionManager>(),
          gh<_i40.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i63.ProfileDeleteCubit>(() => _i63.ProfileDeleteCubit(
          gh<_i18.UserSessionManager>(),
          gh<_i27.SafeExecutionManager>(),
          gh<_i40.BaseProfileRepository>(),
        ));
    gh.factory<_i64.PushNotificationCubit>(() => _i64.PushNotificationCubit(
          gh<_i7.FcmDataSource>(),
          gh<_i42.BasePushNotifiactionRepository>(),
        ));
    gh.factory<_i65.PuzzleCubit>(
        () => _i65.PuzzleCubit(gh<_i44.BasePuzzleRepository>()));
    gh.factory<_i66.PuzzleModuleCubit>(
        () => _i66.PuzzleModuleCubit(gh<_i44.BasePuzzleRepository>()));
    gh.factory<_i67.PuzzleQuickCubit>(() => _i67.PuzzleQuickCubit(
          gh<_i44.BasePuzzleRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i68.PuzzleReportCubit>(() => _i68.PuzzleReportCubit(
          gh<_i44.BasePuzzleRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i69.ReviewMatchCubit>(() => _i69.ReviewMatchCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i70.ReviewMatchesListCubit>(() => _i70.ReviewMatchesListCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i71.SearchCubit>(() => _i71.SearchCubit(
          gh<_i46.BaseSearchRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i72.AfishaCubit>(() => _i72.AfishaCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i73.AfishaItemCubit>(() => _i73.AfishaItemCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i74.AfishaRegistrationCubit>(() => _i74.AfishaRegistrationCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i75.AuthCubit>(() => _i75.AuthCubit(
          gh<_i36.BaseAuthRepository>(),
          gh<_i18.UserSessionManager>(),
          gh<_i40.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i76.BaseCourseRepository>(() => _i77.CourseRepository(
          gh<_i50.CoursesApiClient>(),
          gh<_i10.LessonCompletionDatabase>(),
        ));
    gh.factory<_i78.CourseDetailsCubit>(() => _i78.CourseDetailsCubit(
          gh<_i76.BaseCourseRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i79.CoursesCubit>(() => _i79.CoursesCubit(
          gh<_i76.BaseCourseRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i80.HomeCubit>(() => _i80.HomeCubit(
          gh<_i38.BaseHomeRepository>(),
          gh<_i76.BaseCourseRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i81.LessonCubit>(() => _i81.LessonCubit(
          gh<_i76.BaseCourseRepository>(),
          gh<_i18.UserSessionManager>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i82.QuizCubit>(() => _i82.QuizCubit(
          gh<_i76.BaseCourseRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    return this;
  }
}

class _$SharedPrefsModule extends _i83.SharedPrefsModule {}

class _$ApiClientModule extends _i84.ApiClientModule {}
