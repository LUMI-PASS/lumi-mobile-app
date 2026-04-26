import 'dart:async';

import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'verify_state.dart';

@injectable
class VerifyCubit extends BaseCubit<VerifyBuildable, VerifyListenable> {
  VerifyCubit(this._repo, this._storage) : super(const VerifyBuildable()) {
    timerChange();
  }

  Timer? timer;
  final AuthRepository _repo;
  final Storage _storage;

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

  void setOtpCode(int? code) {
    if (code == null) return;
    build((buildable) => buildable.copyWith(otpCode: code));
  }

  void setError(String? error) {
    build((buildable) => buildable.copyWith(error: error));
  }

  Future<void> checkCode(String phoneNumber, String codeHash, bool isReg) =>
      callable(
        future: _repo.verifyOtp(phoneNumber.replaceAll("-", ""),
            (buildable.code ?? 0).toString()),
        buildOnStart: () => buildable.copyWith(loading: true),
        onData: (result) async {
          if (result.isNewUser) {
            await _storage.needsOnboarding.set(true);
            await _storage.pendingPhone.set(phoneNumber.replaceAll("-", ""));
          } else {
            await _storage.needsOnboarding.set(false);
          }
          invoke(const VerifyListenable(VerifyEffect.success));
        },
        onErrorData: (error) => display.error(error),
        buildOnError: (error) {
          return buildable.copyWith(error: Strings.invalidCode);
        },
        buildOnDone: () => buildable.copyWith(loading: false),
      );

  Future<void> resendOtp(String phoneNumber) => callable(
        future: _repo.sendOtp(phoneNumber.replaceAll("-", "")),
        buildOnStart: () => buildable.copyWith(resetLoading: true),
        onData: (code) {
          timerChange();
          if (code != null) {
            build((buildable) => buildable.copyWith(otpCode: code));
          }
        },
        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(resetLoading: false),
      );
}
