import 'dart:async';

import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
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
    build((buildable) => buildable.copyWith(timer: 270));
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

  Future<void> checkCode(String phoneNumber, String codeHash, bool isReg) =>
      callable(
        future: _repo.verifyNumber(phoneNumber.replaceAll("-", ""),
            (buildable.code ?? 0).toString(), isReg),
        buildOnStart: () => buildable.copyWith(loading: true),
        invokeOnData: (data) => const VerifyListenable(
          VerifyEffect.success,
        ),
        onErrorData: (error) => display.error(error),
        buildOnError: (error) {
          return buildable.copyWith(error: Strings.invalidCode);
        },
        buildOnDone: () => buildable.copyWith(loading: false),
      );

  Future<void> resendOtp(String phoneNumber) => callable(
        future: _repo.resendOtp(phoneNumber.replaceAll("-", "")),
        buildOnStart: () => buildable.copyWith(resetLoading: true),
        onData: (data) => timerChange(),
        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(resetLoading: false),
      );
}
