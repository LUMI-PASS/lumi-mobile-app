// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i30;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:lumi_pass/core/api/api_client_manager.dart' as _i29;
import 'package:lumi_pass/core/api/environment/environment_manager.dart' as _i6;
import 'package:lumi_pass/core/api/http_inspector.dart' as _i4;
import 'package:lumi_pass/core/api/interceptor/user_session_interceptor.dart'
    as _i28;
import 'package:lumi_pass/core/database/isar_provider.dart' as _i9;
import 'package:lumi_pass/core/firebase/firebase_remote_config_manager.dart'
    as _i8;
import 'package:lumi_pass/core/push_notification/push_notification_manager.dart'
    as _i12;
import 'package:lumi_pass/core/safe_execution/domain/connectivity_handler.dart'
    as _i23;
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart'
    as _i27;
import 'package:lumi_pass/core/safe_execution/presentation/connectivity_handler.dart'
    as _i24;
import 'package:lumi_pass/core/version/version_manager.dart' as _i20;
import 'package:lumi_pass/di/module/api_client_module.dart' as _i76;
import 'package:lumi_pass/di/module/shared_pref_module.dart' as _i75;
import 'package:lumi_pass/feature/app_init/cubit/app_init_cubit.dart' as _i22;
import 'package:lumi_pass/feature/auth/data/data_source/auth_api_client.dart'
    as _i34;
import 'package:lumi_pass/feature/auth/data/data_source/token_data_source.dart'
    as _i16;
import 'package:lumi_pass/feature/auth/data/data_source/user_data_source.dart'
    as _i17;
import 'package:lumi_pass/feature/auth/data/repository/auth_repository.dart'
    as _i36;
import 'package:lumi_pass/feature/auth/domain/repository/base_auth_repository.dart'
    as _i35;
import 'package:lumi_pass/feature/auth/domain/user_session_manager.dart'
    as _i18;
import 'package:lumi_pass/feature/auth/presentation/cubit/auth/auth_cubit.dart'
    as _i67;
import 'package:lumi_pass/feature/auth/presentation/cubit/country/country_cubit.dart'
    as _i5;
import 'package:lumi_pass/feature/auth/presentation/cubit/otp/otp_cubit.dart'
    as _i11;
import 'package:lumi_pass/feature/auth/presentation/cubit/profile_creation/profile_creation_cubit.dart'
    as _i57;
import 'package:lumi_pass/feature/auth/presentation/cubit/registration/registration_cubit.dart'
    as _i13;
import 'package:lumi_pass/feature/base_url/app_base_url_cubit.dart' as _i21;
import 'package:lumi_pass/feature/courses/data/data_source/local_data_source/lesson_completion_database.dart'
    as _i10;
import 'package:lumi_pass/feature/courses/data/data_source/remote_data_source/courses_api_client.dart'
    as _i47;
import 'package:lumi_pass/feature/courses/data/repository/course_repository.dart'
    as _i69;
import 'package:lumi_pass/feature/courses/domain/repository/base_course_repository.dart'
    as _i68;
import 'package:lumi_pass/feature/courses/presentation/cubit/course_details/course_details_cubit.dart'
    as _i70;
import 'package:lumi_pass/feature/courses/presentation/cubit/courses/courses_cubit.dart'
    as _i71;
import 'package:lumi_pass/feature/courses/presentation/cubit/lesson/lesson_cubit.dart'
    as _i73;
import 'package:lumi_pass/feature/courses/presentation/cubit/quiz/quiz_cubit.dart'
    as _i74;
import 'package:lumi_pass/feature/home/data/data_source/local_data_source/search_isar_database.dart'
    as _i14;
import 'package:lumi_pass/feature/home/data/data_source/remote_data_source/home_api_client.dart'
    as _i31;
import 'package:lumi_pass/feature/home/data/data_source/remote_data_source/search_api_client.dart'
    as _i33;
import 'package:lumi_pass/feature/home/data/repository/home_repository.dart'
    as _i38;
import 'package:lumi_pass/feature/home/data/repository/search_repository.dart'
    as _i44;
import 'package:lumi_pass/feature/home/domain/repository/base_home_repository.dart'
    as _i37;
import 'package:lumi_pass/feature/home/domain/repository/base_search_repository.dart'
    as _i43;
import 'package:lumi_pass/feature/home/presentation/cubit/afisha_cubit/afisha_cubit.dart'
    as _i64;
import 'package:lumi_pass/feature/home/presentation/cubit/afisha_item_cubit/afisha_item_cubit.dart'
    as _i65;
import 'package:lumi_pass/feature/home/presentation/cubit/afisha_register_cubit/afisha_cubit.dart'
    as _i66;
import 'package:lumi_pass/feature/home/presentation/cubit/book_cubit/book_cubit.dart'
    as _i45;
import 'package:lumi_pass/feature/home/presentation/cubit/book_list_cubit/book_list_cubit.dart'
    as _i46;
import 'package:lumi_pass/feature/home/presentation/cubit/grandmaster_cubit/grandmaster_cubit.dart'
    as _i48;
import 'package:lumi_pass/feature/home/presentation/cubit/grandmaster_item_cubit/grandmaster_item_cubit.dart'
    as _i49;
import 'package:lumi_pass/feature/home/presentation/cubit/home_cubit/home_cubit.dart'
    as _i72;
import 'package:lumi_pass/feature/home/presentation/cubit/livestream_item_cubit/livestream_cubit.dart'
    as _i52;
import 'package:lumi_pass/feature/home/presentation/cubit/main_cubit/main_cubit.dart'
    as _i26;
import 'package:lumi_pass/feature/home/presentation/cubit/news_cubit/news_cubit.dart'
    as _i54;
import 'package:lumi_pass/feature/home/presentation/cubit/news_item_cubit/news_item_cubit.dart'
    as _i55;
import 'package:lumi_pass/feature/home/presentation/cubit/notification_cubit/notification_cubit.dart'
    as _i56;
import 'package:lumi_pass/feature/home/presentation/cubit/review_match_cubit/review_match_cubit.dart'
    as _i61;
import 'package:lumi_pass/feature/home/presentation/cubit/review_matches_list_cubit/review_matches_list_cubit.dart'
    as _i62;
import 'package:lumi_pass/feature/home/presentation/cubit/search_cubit/search_cubit.dart'
    as _i63;
import 'package:lumi_pass/feature/profile/data/data_source/profile_api_client.dart'
    as _i32;
import 'package:lumi_pass/feature/profile/data/repository/profile_repository.dart'
    as _i40;
import 'package:lumi_pass/feature/profile/domain/repository/base_profile_repository.dart'
    as _i39;
import 'package:lumi_pass/feature/profile/presentation/cubit/image_cubit/image_cubit.dart'
    as _i50;
import 'package:lumi_pass/feature/profile/presentation/cubit/leader_board_cubit/leader_board_cubit.dart'
    as _i51;
import 'package:lumi_pass/feature/profile/presentation/cubit/my_certificate_cubit/my_certificate_cubit.dart'
    as _i53;
import 'package:lumi_pass/feature/profile/presentation/cubit/profile_cubit/profile_cubit.dart'
    as _i58;
import 'package:lumi_pass/feature/profile/presentation/cubit/profile_delete_cubit/profile_delete_cubit.dart'
    as _i59;
import 'package:lumi_pass/feature/profile/presentation/cubit/version_cubit/version_cubit.dart'
    as _i19;
import 'package:lumi_pass/feature/shared/data/data_source/local_data_source/fcm_data_source.dart'
    as _i7;
import 'package:lumi_pass/feature/shared/data/repository/push_notification_repository.dart'
    as _i42;
import 'package:lumi_pass/feature/shared/domain/repository/base_push_notification_repository.dart'
    as _i41;
import 'package:lumi_pass/feature/shared/presentation/cubit/force_update_cubit/force_update_cubit.dart'
    as _i25;
import 'package:lumi_pass/feature/shared/presentation/cubit/push_notification_cubit/push_notification_cubit.dart'
    as _i60;
import 'package:lumi_pass/routing/app_router.dart' as _i3;
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
      () => apiClientModule.getAuthorizedApiClient(gh<_i29.ApiClientManager>()),
      instanceName: 'AuthorizedApiClient',
    );
    gh.factory<_i30.Dio>(
      () =>
          apiClientModule.getUnauthorizedApiClient(gh<_i29.ApiClientManager>()),
      instanceName: 'UnauthorizedApiClient',
    );
    gh.factory<_i31.HomeApiClient>(() =>
        _i31.HomeApiClient(gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i32.ProfileApiClient>(() => _i32.ProfileApiClient(
        gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i33.SearchApiClient>(() => _i33.SearchApiClient(
        gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i34.AuthApiClient>(() => _i34.AuthApiClient(
        gh<_i30.Dio>(instanceName: 'UnauthorizedApiClient')));
    gh.factory<_i35.BaseAuthRepository>(
        () => _i36.AuthRepository(gh<_i34.AuthApiClient>()));
    gh.factory<_i37.BaseHomeRepository>(
        () => _i38.HomeRepository(gh<_i31.HomeApiClient>()));
    gh.factory<_i39.BaseProfileRepository>(() => _i40.ProfileRepository(
          gh<_i32.ProfileApiClient>(),
          gh<_i10.LessonCompletionDatabase>(),
        ));
    gh.factory<_i41.BasePushNotifiactionRepository>(
        () => _i42.PushNotificationRepository(gh<_i31.HomeApiClient>()));
    gh.factory<_i43.BaseSearchRepository>(() => _i44.SearchRepository(
          gh<_i14.SearchIsarDatabase>(),
          gh<_i33.SearchApiClient>(),
        ));
    gh.factory<_i45.BookCubit>(() => _i45.BookCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i46.BookListCubit>(() => _i46.BookListCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i47.CoursesApiClient>(() => _i47.CoursesApiClient(
        gh<_i30.Dio>(instanceName: 'AuthorizedApiClient')));
    gh.factory<_i48.GrandmasterCubit>(() => _i48.GrandmasterCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i49.GrandmasterItemCubit>(() => _i49.GrandmasterItemCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i50.ImageCubit>(() => _i50.ImageCubit(
          gh<_i39.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i51.LeaderBoardCubit>(() => _i51.LeaderBoardCubit(
          gh<_i39.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i52.LiveStreamItemCubit>(() => _i52.LiveStreamItemCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i53.MyCertificateCubit>(() => _i53.MyCertificateCubit(
          gh<_i39.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i54.NewsCubit>(() => _i54.NewsCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i55.NewsItemCubit>(() => _i55.NewsItemCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i56.NotificationCubit>(() => _i56.NotificationCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i57.ProfileCreationCubit>(() => _i57.ProfileCreationCubit(
          gh<_i39.BaseProfileRepository>(),
          gh<_i18.UserSessionManager>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i58.ProfileCubit>(() => _i58.ProfileCubit(
          gh<_i18.UserSessionManager>(),
          gh<_i39.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i59.ProfileDeleteCubit>(() => _i59.ProfileDeleteCubit(
          gh<_i18.UserSessionManager>(),
          gh<_i27.SafeExecutionManager>(),
          gh<_i39.BaseProfileRepository>(),
        ));
    gh.factory<_i60.PushNotificationCubit>(() => _i60.PushNotificationCubit(
          gh<_i7.FcmDataSource>(),
          gh<_i41.BasePushNotifiactionRepository>(),
        ));
    gh.factory<_i61.ReviewMatchCubit>(() => _i61.ReviewMatchCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i62.ReviewMatchesListCubit>(() => _i62.ReviewMatchesListCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i63.SearchCubit>(() => _i63.SearchCubit(
          gh<_i43.BaseSearchRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i64.AfishaCubit>(() => _i64.AfishaCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i65.AfishaItemCubit>(() => _i65.AfishaItemCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i66.AfishaRegistrationCubit>(() => _i66.AfishaRegistrationCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i67.AuthCubit>(() => _i67.AuthCubit(
          gh<_i35.BaseAuthRepository>(),
          gh<_i18.UserSessionManager>(),
          gh<_i39.BaseProfileRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i68.BaseCourseRepository>(() => _i69.CourseRepository(
          gh<_i47.CoursesApiClient>(),
          gh<_i10.LessonCompletionDatabase>(),
        ));
    gh.factory<_i70.CourseDetailsCubit>(() => _i70.CourseDetailsCubit(
          gh<_i68.BaseCourseRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i71.CoursesCubit>(() => _i71.CoursesCubit(
          gh<_i68.BaseCourseRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i72.HomeCubit>(() => _i72.HomeCubit(
          gh<_i37.BaseHomeRepository>(),
          gh<_i68.BaseCourseRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i73.LessonCubit>(() => _i73.LessonCubit(
          gh<_i68.BaseCourseRepository>(),
          gh<_i18.UserSessionManager>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    gh.factory<_i74.QuizCubit>(() => _i74.QuizCubit(
          gh<_i68.BaseCourseRepository>(),
          gh<_i27.SafeExecutionManager>(),
        ));
    return this;
  }
}

class _$SharedPrefsModule extends _i75.SharedPrefsModule {}

class _$ApiClientModule extends _i76.ApiClientModule {}
