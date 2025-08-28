// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flexobo/common/widget/display/display.dart' as _i542;
import 'package:flexobo/common/widget/display/display_impl.dart' as _i857;
import 'package:flexobo/data/base_model/default_theme_colors.dart' as _i106;
import 'package:flexobo/data/interceptor/auth_interceptor.dart' as _i61;
import 'package:flexobo/data/storage/storage.dart' as _i503;
import 'package:flexobo/di/app_module.dart' as _i581;
import 'package:flexobo/di/network_module.dart' as _i666;
import 'package:flexobo/domain/impl/auth_repository_impl.dart' as _i737;
import 'package:flexobo/domain/impl/booking_repository_impl.dart' as _i302;
import 'package:flexobo/domain/impl/chat_repository_impl.dart' as _i992;
import 'package:flexobo/domain/impl/extra_types_repo_impl.dart' as _i640;
import 'package:flexobo/domain/impl/profile_repository_impl.dart' as _i790;
import 'package:flexobo/domain/impl/search_repository_impl.dart' as _i583;
import 'package:flexobo/domain/repo/auth/auth_api.dart' as _i110;
import 'package:flexobo/domain/repo/auth/auth_repository.dart' as _i273;
import 'package:flexobo/domain/repo/booking/booking_api.dart' as _i879;
import 'package:flexobo/domain/repo/booking/booking_repository.dart' as _i297;
import 'package:flexobo/domain/repo/chat/chat_api.dart' as _i738;
import 'package:flexobo/domain/repo/chat/chat_repository.dart' as _i1047;
import 'package:flexobo/domain/repo/extra_types/extra_types_api.dart' as _i408;
import 'package:flexobo/domain/repo/extra_types/extra_types_repository.dart'
    as _i872;
import 'package:flexobo/domain/repo/profile/profile_api.dart' as _i316;
import 'package:flexobo/domain/repo/profile/profile_repository.dart' as _i212;
import 'package:flexobo/domain/repo/search/search_api.dart' as _i602;
import 'package:flexobo/domain/repo/search/search_repository.dart' as _i24;
import 'package:flexobo/presentation/app/cubit/app_cubit.dart' as _i578;
import 'package:flexobo/presentation/app/main/subscreens/add_post/add_car_cubit/add_car_cubit.dart'
    as _i521;
import 'package:flexobo/presentation/app/main/subscreens/add_post/cubit/add_post_cubit.dart'
    as _i883;
import 'package:flexobo/presentation/app/main/subscreens/chat/cubit/chat_cubit.dart'
    as _i628;
import 'package:flexobo/presentation/app/main/subscreens/document/cubit/document_cubit.dart'
    as _i188;
import 'package:flexobo/presentation/app/main/subscreens/profile/cubit/profile_cubit.dart'
    as _i825;
import 'package:flexobo/presentation/auth/check_user/cubit/check_user_cubit.dart'
    as _i157;
import 'package:flexobo/presentation/auth/forget_password/cubit/forget_password_cubit.dart'
    as _i178;
import 'package:flexobo/presentation/auth/login/bloc/login_cubit.dart' as _i941;
import 'package:flexobo/presentation/auth/register/cubit/register_cubit.dart'
    as _i174;
import 'package:flexobo/presentation/auth/verify/cubit/verify_cubit.dart'
    as _i238;
import 'package:flexobo/presentation/bidding/select_data/cubit/selecting_data_cubit.dart'
    as _i851;
import 'package:flexobo/presentation/profile/language/lang/language_service.dart'
    as _i538;
import 'package:flexobo/presentation/profile/my_garage/cubit/my_garage_cubit.dart'
    as _i227;
import 'package:flexobo/presentation/search/notification/cubit/notification_cubit.dart'
    as _i205;
import 'package:flexobo/presentation/search/shipping_detail/cubit/shipping_detail_cubit.dart'
    as _i630;
import 'package:flexobo/presentation/start/onboard/cubit/onboarding_cubit.dart'
    as _i949;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:logger/web.dart' as _i120;

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
    gh.singleton<_i106.DefaultThemeColors>(() => _i106.DefaultThemeColors());
    gh.lazySingleton<_i974.Logger>(() => appModule.logger);
    await gh.lazySingletonAsync<_i503.Storage>(
      () => _i503.Storage.create(),
      preResolve: true,
    );
    gh.lazySingleton<_i538.LanguageService>(() => _i538.LanguageService());
    gh.factory<_i825.ProfileCubit>(
        () => _i825.ProfileCubit(gh<_i503.Storage>()));
    gh.factory<_i949.OnboardingCubit>(
        () => _i949.OnboardingCubit(gh<_i503.Storage>()));
    gh.singleton<_i542.Display>(() => _i857.DisplayImpl());
    gh.lazySingleton<_i61.AuthInterceptor>(() => _i61.AuthInterceptor(
          gh<_i503.Storage>(),
          gh<_i120.Logger>(),
        ));
    gh.factory<_i361.Dio>(() => networkModule.dio(gh<_i61.AuthInterceptor>()));
    gh.factory<_i110.AuthApi>(() => _i110.AuthApi(gh<_i361.Dio>()));
    gh.factory<_i879.BookingApi>(() => _i879.BookingApi(gh<_i361.Dio>()));
    gh.factory<_i602.SearchApi>(() => _i602.SearchApi(gh<_i361.Dio>()));
    gh.factory<_i408.ExtraTypesApi>(() => _i408.ExtraTypesApi(gh<_i361.Dio>()));
    gh.factory<_i316.ProfileApi>(() => _i316.ProfileApi(gh<_i361.Dio>()));
    gh.factory<_i738.ChatApi>(() => _i738.ChatApi(gh<_i361.Dio>()));
    gh.factory<_i212.ProfileRepository>(
        () => _i790.ProfileRepositoryImpl(gh<_i316.ProfileApi>()));
    gh.factory<_i297.BookingRepository>(
        () => _i302.BookingRepositoryImpl(gh<_i879.BookingApi>()));
    gh.factory<_i273.AuthRepository>(() => _i737.AuthRepositoryImpl(
          gh<_i110.AuthApi>(),
          gh<_i503.Storage>(),
        ));
    gh.factory<_i578.AppCubit>(
        () => _i578.AppCubit(gh<_i273.AuthRepository>()));
    gh.factory<_i157.CheckUserCubit>(
        () => _i157.CheckUserCubit(gh<_i273.AuthRepository>()));
    gh.factory<_i238.VerifyCubit>(
        () => _i238.VerifyCubit(gh<_i273.AuthRepository>()));
    gh.factory<_i178.ForgetPasswordCubit>(
        () => _i178.ForgetPasswordCubit(gh<_i273.AuthRepository>()));
    gh.factory<_i174.RegisterCubit>(
        () => _i174.RegisterCubit(gh<_i273.AuthRepository>()));
    gh.factory<_i941.LoginCubit>(
        () => _i941.LoginCubit(gh<_i273.AuthRepository>()));
    gh.factory<_i872.ExtraTypesRepository>(
        () => _i640.ExtraTypesRepositoryImpl(gh<_i408.ExtraTypesApi>()));
    gh.factory<_i24.SearchRepository>(() => _i583.SearchRepositoryImpl(
          gh<_i602.SearchApi>(),
          gh<_i503.Storage>(),
        ));
    gh.factory<_i630.ShippingDetailCubit>(() => _i630.ShippingDetailCubit(
          gh<_i24.SearchRepository>(),
          gh<_i297.BookingRepository>(),
        ));
    gh.factory<_i1047.ChatRepository>(
        () => _i992.ChatRepositoryImpl(gh<_i738.ChatApi>()));
    gh.factory<_i205.NotificationCubit>(
        () => _i205.NotificationCubit(gh<_i872.ExtraTypesRepository>()));
    gh.factory<_i227.MyGarageDetailCubit>(
        () => _i227.MyGarageDetailCubit(gh<_i872.ExtraTypesRepository>()));
    gh.factory<_i188.DocumentCubit>(() => _i188.DocumentCubit(
          gh<_i24.SearchRepository>(),
          gh<_i212.ProfileRepository>(),
        ));
    gh.factory<_i521.AddCarCubit>(() => _i521.AddCarCubit(
          gh<_i503.Storage>(),
          gh<_i872.ExtraTypesRepository>(),
        ));
    gh.factory<_i883.AddPostCubit>(() => _i883.AddPostCubit(
          gh<_i24.SearchRepository>(),
          gh<_i872.ExtraTypesRepository>(),
          gh<_i212.ProfileRepository>(),
        ));
    gh.factory<_i628.ChatCubit>(() => _i628.ChatCubit(
          gh<_i1047.ChatRepository>(),
          gh<_i503.Storage>(),
        ));
    gh.factory<_i851.SelectingDataCubit>(() => _i851.SelectingDataCubit(
          gh<_i872.ExtraTypesRepository>(),
          gh<_i24.SearchRepository>(),
          gh<_i297.BookingRepository>(),
          gh<_i503.Storage>(),
        ));
    return this;
  }
}

class _$AppModule extends _i581.AppModule {}

class _$NetworkModule extends _i666.NetworkModule {}
