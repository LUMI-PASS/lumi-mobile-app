import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flexobo/common/base/base_cubit.dart';
import 'package:flexobo/common/gen/strings.dart';
import 'package:flexobo/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'verify_state.dart';

@injectable
class VerifyCubit extends BaseCubit<VerifyBuildable, VerifyListenable> {
  VerifyCubit(this._repo) : super(const VerifyBuildable()) {
    timerChange();
  }

  Timer? timer;
  final AuthRepository _repo;

  void timerChange() {
    timer?.cancel();
    build((buildable) => buildable.copyWith(timer: 59));
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (buildable.timer > 0) {
          build((buildable) => buildable.copyWith(timer: buildable.timer - 1));
        } else {
          timer?.cancel();
        }
      },
    );
  }

  void changeCode(int? code) {
    build((buildable) => buildable.copyWith(code: code));
  }

  void setError(String? error) {
    build((buildable) => buildable.copyWith(error: error));
  }

  Future<void> checkCode(String phoneNumber, String codeHash) => callable(
        future: _repo.verifyCode(
            phoneNumber.replaceAll("-", ""), buildable.code ?? 0, codeHash),
        buildOnStart: () => buildable.copyWith(loading: true),
        invokeOnData: (data) => const VerifyListenable(
          VerifyEffect.success,
        ),
        onErrorData: (error) => display.error(error),
        buildOnError: (error) {
          final status = (error as DioException).response?.data['message'];
          return buildable.copyWith(error: Strings.invalidCode);
        },
        buildOnDone: () => buildable.copyWith(loading: false),
      );

  Future<void> checkPhone(String phoneOrMail, bool isRegister) => callable(
        future: isRegister
            ? _repo.verifyPhoneNumber(
                phoneOrMail.replaceAll("-", ""), isRegister)
            : _repo.resetPasswordSendCode(phoneOrMail),
        buildOnStart: () => buildable.copyWith(resetLoading: true),
        invokeOnData: (data) {
          return const VerifyListenable(
            VerifyEffect.success,
          );
        },
        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(resetLoading: false),
      );
}

//
//   Future<void> registerVerify(String phone, String code) => callable(
//         future: _repo.verifyCode(phone, code),
//         buildOnStart: () => buildable.copyWith(loading: true),
//         invokeOnData: (data) => VerifyListenable(VerifyEffect.register),
//         onErrorData: (error) => display.error(error, ),
//         buildOnDone: () => buildable.copyWith(loading: false),
//       );
//
//   Future<void> forgetPasswordVerify(String email, String code) => callable(
//         future: _repo.resetPasswordConfirm(email, code),
//         buildOnStart: () => buildable.copyWith(loading: true),
//         invokeOnData: (data) => VerifyListenable(VerifyEffect.password),
//         onErrorData: (error) => display.error(error,),
//         buildOnDone: () => buildable.copyWith(loading: false),
//       );
//
