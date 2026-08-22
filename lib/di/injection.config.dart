// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:logger/web.dart' as _i120;
import 'package:lumi_pass/common/widget/display/display.dart' as _i755;
import 'package:lumi_pass/common/widget/display/display_impl.dart' as _i426;
import 'package:lumi_pass/data/interceptor/auth_interceptor.dart' as _i948;
import 'package:lumi_pass/data/interceptor/connectivity_interceptor.dart'
    as _i359;
import 'package:lumi_pass/data/interceptor/interest_source_interceptor.dart'
    as _i707;
import 'package:lumi_pass/data/service/analytics_service.dart' as _i594;
import 'package:lumi_pass/data/service/appsflyer_service.dart' as _i260;
import 'package:lumi_pass/data/service/interest_reporter.dart' as _i606;
import 'package:lumi_pass/data/service/push_notification_service.dart' as _i361;
import 'package:lumi_pass/data/storage/storage.dart' as _i279;
import 'package:lumi_pass/di/app_module.dart' as _i591;
import 'package:lumi_pass/di/network_module.dart' as _i85;
import 'package:lumi_pass/domain/impl/auth_repository_impl.dart' as _i98;
import 'package:lumi_pass/domain/impl/home_repository_impl.dart' as _i162;
import 'package:lumi_pass/domain/impl/wallet_repository_impl.dart' as _i728;
import 'package:lumi_pass/domain/repo/auth/auth_api.dart' as _i79;
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart' as _i652;
import 'package:lumi_pass/domain/repo/courses/courses_api.dart' as _i298;
import 'package:lumi_pass/domain/repo/home/home_api.dart' as _i433;
import 'package:lumi_pass/domain/repo/home/home_repository.dart' as _i526;
import 'package:lumi_pass/domain/repo/interests/interests_api.dart' as _i1041;
import 'package:lumi_pass/domain/repo/notifications/notifications_api.dart'
    as _i376;
import 'package:lumi_pass/domain/repo/orders/orders_api.dart' as _i748;
import 'package:lumi_pass/domain/repo/wallet/wallet_api.dart' as _i605;
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart' as _i890;
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart' as _i915;
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/cubit/schedule_cubit.dart'
    as _i256;
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart'
    as _i386;
import 'package:lumi_pass/presentation/app/main/subscreens/profile/cubit/profile_cubit.dart'
    as _i868;
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart'
    as _i999;
import 'package:lumi_pass/presentation/app/profile/attendance/cubit/attendance_cubit.dart'
    as _i24;
import 'package:lumi_pass/presentation/app/profile/cards/cubit/my_cards_cubit.dart'
    as _i571;
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart'
    as _i239;
import 'package:lumi_pass/presentation/app/profile/profile_detail/cubit/profile_detail_cubit.dart'
    as _i133;
import 'package:lumi_pass/presentation/app/profile/wallet/cubit/wallet_cubit.dart'
    as _i822;
import 'package:lumi_pass/presentation/auth/login/bloc/login_cubit.dart'
    as _i296;
import 'package:lumi_pass/presentation/auth/register/cubit/register_cubit.dart'
    as _i567;
import 'package:lumi_pass/presentation/auth/telegram/cubit/telegram_login_cubit.dart'
    as _i1012;
import 'package:lumi_pass/presentation/auth/verify/cubit/verify_cubit.dart'
    as _i749;
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_cubit.dart'
    as _i484;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    final networkModule = _$NetworkModule();
    gh.factory<_i707.InterestSourceInterceptor>(
        () => _i707.InterestSourceInterceptor());
    gh.lazySingleton<_i974.Logger>(() => appModule.logger);
    await gh.lazySingletonAsync<_i279.Storage>(
      () => _i279.Storage.create(),
      preResolve: true,
    );
    gh.lazySingleton<_i359.ConnectivityInterceptor>(
        () => _i359.ConnectivityInterceptor());
    gh.singleton<_i755.Display>(() => _i426.DisplayImpl());
    gh.lazySingleton<_i948.AuthInterceptor>(() => _i948.AuthInterceptor(
          gh<_i279.Storage>(),
          gh<_i120.Logger>(),
        ));
    gh.factory<_i361.Dio>(() => networkModule.dio(
          gh<_i948.AuthInterceptor>(),
          gh<_i359.ConnectivityInterceptor>(),
          gh<_i707.InterestSourceInterceptor>(),
        ));
    gh.factory<_i433.HomeApi>(() => _i433.HomeApi(gh<_i361.Dio>()));
    gh.factory<_i79.AuthApi>(() => _i79.AuthApi(gh<_i361.Dio>()));
    gh.factory<_i298.CoursesApi>(() => _i298.CoursesApi(gh<_i361.Dio>()));
    gh.factory<_i605.WalletApi>(() => _i605.WalletApi(gh<_i361.Dio>()));
    gh.factory<_i748.OrdersApi>(() => _i748.OrdersApi(gh<_i361.Dio>()));
    gh.factory<_i376.NotificationsApi>(
        () => _i376.NotificationsApi(gh<_i361.Dio>()));
    gh.factory<_i1041.InterestsApi>(() => _i1041.InterestsApi(gh<_i361.Dio>()));
    gh.factory<_i256.ScheduleCubit>(
        () => _i256.ScheduleCubit(gh<_i748.OrdersApi>()));
    gh.lazySingleton<_i260.AppsFlyerService>(
        () => _i260.AppsFlyerService(gh<_i279.Storage>()));
    gh.factory<_i484.OnboardingCubit>(
        () => _i484.OnboardingCubit(gh<_i279.Storage>()));
    gh.factory<_i526.HomeRepository>(() => _i162.HomeRepositoryImpl(
          gh<_i433.HomeApi>(),
          gh<_i279.Storage>(),
        ));
    gh.lazySingleton<_i361.PushNotificationService>(
        () => _i361.PushNotificationService(
              gh<_i361.Dio>(),
              gh<_i279.Storage>(),
            ));
    gh.lazySingleton<_i606.InterestReporter>(() => _i606.InterestReporter(
          gh<_i1041.InterestsApi>(),
          gh<_i279.Storage>(),
        ));
    gh.factory<_i24.AttendanceCubit>(
        () => _i24.AttendanceCubit(gh<_i526.HomeRepository>()));
    gh.factory<_i133.ProfileDetailCubit>(
        () => _i133.ProfileDetailCubit(gh<_i526.HomeRepository>()));
    gh.factory<_i239.ChildrenCubit>(
        () => _i239.ChildrenCubit(gh<_i526.HomeRepository>()));
    gh.factory<_i999.SearchCubit>(
        () => _i999.SearchCubit(gh<_i526.HomeRepository>()));
    gh.factory<_i890.WalletRepository>(
        () => _i728.WalletRepositoryImpl(gh<_i605.WalletApi>()));
    gh.factory<_i571.MyCardsCubit>(
        () => _i571.MyCardsCubit(gh<_i748.OrdersApi>()));
    gh.factory<_i822.WalletCubit>(
        () => _i822.WalletCubit(gh<_i890.WalletRepository>()));
    gh.factory<_i868.ProfileCubit>(() => _i868.ProfileCubit(
          gh<_i279.Storage>(),
          gh<_i526.HomeRepository>(),
          gh<_i890.WalletRepository>(),
        ));
    gh.lazySingleton<_i594.AnalyticsService>(() => _i594.AnalyticsService(
          gh<_i279.Storage>(),
          gh<_i260.AppsFlyerService>(),
        ));
    gh.factory<_i386.HomeCubit>(() => _i386.HomeCubit(
          gh<_i526.HomeRepository>(),
          gh<_i279.Storage>(),
        ));
    gh.factory<_i652.AuthRepository>(() => _i98.AuthRepositoryImpl(
          gh<_i79.AuthApi>(),
          gh<_i279.Storage>(),
          gh<_i361.PushNotificationService>(),
          gh<_i594.AnalyticsService>(),
        ));
    gh.factory<_i749.VerifyCubit>(() => _i749.VerifyCubit(
          gh<_i652.AuthRepository>(),
          gh<_i279.Storage>(),
        ));
    gh.factory<_i1012.TelegramLoginCubit>(() => _i1012.TelegramLoginCubit(
          gh<_i652.AuthRepository>(),
          gh<_i279.Storage>(),
        ));
    gh.factory<_i567.RegisterCubit>(
        () => _i567.RegisterCubit(gh<_i652.AuthRepository>()));
    gh.factory<_i296.LoginCubit>(
        () => _i296.LoginCubit(gh<_i652.AuthRepository>()));
    gh.lazySingleton<_i915.AppCubit>(() => _i915.AppCubit(
          gh<_i652.AuthRepository>(),
          gh<_i361.PushNotificationService>(),
          gh<_i279.Storage>(),
        ));
    return this;
  }
}

class _$AppModule extends _i591.AppModule {}

class _$NetworkModule extends _i85.NetworkModule {}
