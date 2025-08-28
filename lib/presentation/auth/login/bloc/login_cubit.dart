import 'package:dio/dio.dart';
import 'package:flexobo/common/base/base_cubit.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flexobo/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginBuildable, LoginListenable> {
  LoginCubit(this._repo) : super(const LoginBuildable());
  final AuthRepository _repo;

  Future<void> login(String phoneOrEmail, String password) {
    if (!buildable.isSelected && password.length >= 6) {
      build((buildable) => buildable.copyWith(
          errorPhone: Strings.invalidInputFormat, errorPassword: null));
      return Future.value();
    } else if (buildable.isSelected && password.length < 6) {
      build((buildable) => buildable.copyWith(
          errorPassword: Strings.passwordMinLength, errorPhone: null));
      return Future.value();
    } else if (!buildable.isSelected && password.length < 6) {
      build((buildable) => buildable.copyWith(
          errorPhone: Strings.invalidInputFormat,
          errorPassword: Strings.passwordMinLength));
      return Future.value();
    }
    return callable(
      future: _repo.login(phoneOrEmail, password),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      invokeOnData: (data) => const LoginListenable(
        effect: LoginEffect.main,
      ),
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        }
      },
      buildOnError: (error) {
        final status = (error as DioException);
        if (status.type == DioExceptionType.badResponse &&
            status.response?.statusCode == 401) {
          return buildable.copyWith(
              errorPassword: Strings.invalidCredentials, errorPhone: null);
        } else {
          return buildable;
        }
      },
      buildOnDone: () => buildable.copyWith(isLoading: false),
    );
  }

  void changePhoneState(bool isMatched) {
    build((buildable) => buildable.copyWith(isSelected: isMatched));
  }
}
