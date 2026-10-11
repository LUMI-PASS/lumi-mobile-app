import 'dart:async';

import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/presentation/auth/sign_in_session.dart';
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
  final _analytics = getIt<AnalyticsService>();

  void timerChange() {
    timer?.cancel();
    build((buildable) => buildable.copyWith(timer: 60));
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

  Future<void> checkCode(String phoneNumber, String codeHash, bool isReg) {
    // The code is good for one use. Once it has signed the user in, a second
    // tap while the app is still on its way in must not send it again.
    if (_signedIn) return Future.value();
    return callable(
      future: _repo.verifyOtp(
          phoneNumber.replaceAll("-", ""), (buildable.code ?? 0).toString()),
      buildOnStart: () => buildable.copyWith(loading: true),
      onData: (result) async {
        // Set before the first await: `callable` does not wait for this
        // callback, so its `buildOnDone` runs while the session is still
        // being set up — the window a second submit used to slip through.
        _signedIn = true;
        await applySignedInSession(
          storage: _storage,
          result: result,
          phone: phoneNumber.replaceAll("-", ""),
        );
        invoke(const VerifyListenable(VerifyEffect.success));
      },
      onErrorData: (error) => display.error(error),
      buildOnError: (error) {
        return buildable.copyWith(error: Strings.invalidCode);
      },
      // Still busy after a success: the screen is about to be left.
      buildOnDone: () => buildable.copyWith(loading: _signedIn),
    );
  }

  bool _signedIn = false;

  Future<void> resendOtp(String phoneNumber) => callable(
        future: _repo.sendOtp(phoneNumber.replaceAll("-", "")),
        buildOnStart: () => buildable.copyWith(resetLoading: true),
        onData: (code) {
          timerChange();
          _analytics.logEvent(
            AnalyticsEvent.otpResent,
            params: {'phone_number': phoneNumber.replaceAll("-", "")},
          );
          if (code != null) {
            build((buildable) => buildable.copyWith(otpCode: code));
          }
        },
        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(resetLoading: false),
      );
}
