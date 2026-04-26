import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginBuildable, LoginListenable> {
  LoginCubit(this._repo) : super(const LoginBuildable());
  final AuthRepository _repo;

  Future<void> login(String phoneOrEmail) {
    final phone = phoneOrEmail.replaceAll("-", "");
    return callable(
      future: _repo.sendOtp(phone),
      buildOnStart: () => buildable.copyWith(isLoading: true),
      invokeOnData: (code) =>
          LoginListenable(effect: LoginEffect.verify, code: code),
      buildOnData: (_) => buildable.copyWith(isSelected: true),
      onErrorData: (error) {
        final status = (error as DioException);
        if (status.response?.statusCode == 500 ||
            status.response?.statusCode == 502) {
          display.error(Strings.serverErrorTryLater);
        } else if (status.type == DioExceptionType.connectionError ||
            status.type == DioExceptionType.connectionTimeout) {
          display.error(Strings.connectionError);
        }
        display.error(error);
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
