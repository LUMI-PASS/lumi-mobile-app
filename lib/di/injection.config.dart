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
import 'package:lumi_pass/data/base_model/default_theme_colors.dart' as _i64;
import 'package:lumi_pass/data/interceptor/auth_interceptor.dart' as _i948;
import 'package:lumi_pass/data/storage/storage.dart' as _i279;
import 'package:lumi_pass/di/app_module.dart' as _i591;
import 'package:lumi_pass/di/network_module.dart' as _i85;
import 'package:lumi_pass/domain/impl/auth_repository_impl.dart' as _i98;
import 'package:lumi_pass/domain/impl/booking_repository_impl.dart' as _i808;
import 'package:lumi_pass/domain/impl/home_repository_impl.dart' as _i162;
import 'package:lumi_pass/domain/repo/auth/auth_api.dart' as _i79;
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart' as _i652;
import 'package:lumi_pass/domain/repo/booking/booking_api.dart' as _i261;
import 'package:lumi_pass/domain/repo/booking/booking_repository.dart' as _i760;
import 'package:lumi_pass/domain/repo/home/home_api.dart' as _i433;
import 'package:lumi_pass/domain/repo/home/home_repository.dart' as _i526;
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart' as _i915;
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/cubit/schedule_cubit.dart'
    as _i256;
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart'
    as _i386;
import 'package:lumi_pass/presentation/app/main/subscreens/profile/cubit/profile_cubit.dart'
    as _i868;
import 'package:lumi_pass/presentation/app/profile/children/cubit/children_cubit.dart'
    as _i239;
import 'package:lumi_pass/presentation/app/profile/profile_detail/cubit/profile_detail_cubit.dart'
    as _i133;
import 'package:lumi_pass/presentation/auth/login/bloc/login_cubit.dart'
    as _i296;
import 'package:lumi_pass/presentation/auth/register/cubit/register_cubit.dart'
    as _i567;
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
    gh.singleton<_i64.DefaultThemeColors>(() => _i64.DefaultThemeColors());
    gh.lazySingleton<_i974.Logger>(() => appModule.logger);
    await gh.lazySingletonAsync<_i279.Storage>(
      () => _i279.Storage.create(),
      preResolve: true,
    );
    gh.singleton<_i755.Display>(() => _i426.DisplayImpl());
    gh.lazySingleton<_i948.AuthInterceptor>(() => _i948.AuthInterceptor(
          gh<_i279.Storage>(),
          gh<_i120.Logger>(),
        ));
    gh.factory<_i361.Dio>(() => networkModule.dio(gh<_i948.AuthInterceptor>()));
    gh.factory<_i868.ProfileCubit>(
        () => _i868.ProfileCubit(gh<_i279.Storage>()));
    gh.factory<_i484.OnboardingCubit>(
        () => _i484.OnboardingCubit(gh<_i279.Storage>()));
    gh.factory<_i433.HomeApi>(() => _i433.HomeApi(gh<_i361.Dio>()));
    gh.factory<_i79.AuthApi>(() => _i79.AuthApi(gh<_i361.Dio>()));
    gh.factory<_i261.BookingApi>(() => _i261.BookingApi(gh<_i361.Dio>()));
    gh.factory<_i760.BookingRepository>(() => _i808.BookingRepositoryImpl(
          gh<_i261.BookingApi>(),
          gh<_i279.Storage>(),
        ));
    gh.factory<_i526.HomeRepository>(() => _i162.HomeRepositoryImpl(
          gh<_i433.HomeApi>(),
          gh<_i279.Storage>(),
        ));
    gh.factory<_i652.AuthRepository>(() => _i98.AuthRepositoryImpl(
          gh<_i79.AuthApi>(),
          gh<_i279.Storage>(),
        ));
    gh.factory<_i133.ProfileDetailCubit>(
        () => _i133.ProfileDetailCubit(gh<_i526.HomeRepository>()));
    gh.factory<_i239.ChildrenCubit>(
        () => _i239.ChildrenCubit(gh<_i526.HomeRepository>()));
    gh.factory<_i386.HomeCubit>(
        () => _i386.HomeCubit(gh<_i526.HomeRepository>()));
    gh.factory<_i256.ScheduleCubit>(
        () => _i256.ScheduleCubit(gh<_i526.HomeRepository>()));
    gh.factory<_i915.AppCubit>(
        () => _i915.AppCubit(gh<_i652.AuthRepository>()));
    gh.factory<_i749.VerifyCubit>(
        () => _i749.VerifyCubit(gh<_i652.AuthRepository>()));
    gh.factory<_i567.RegisterCubit>(
        () => _i567.RegisterCubit(gh<_i652.AuthRepository>()));
    gh.factory<_i296.LoginCubit>(
        () => _i296.LoginCubit(gh<_i652.AuthRepository>()));
    return this;
  }
}

class _$AppModule extends _i591.AppModule {}

class _$NetworkModule extends _i85.NetworkModule {}
