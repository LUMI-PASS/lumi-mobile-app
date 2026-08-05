import 'dart:async';

import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/avatar_notifier.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
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

  Future<void> checkCode(String phoneNumber, String codeHash, bool isReg) =>
      callable(
        future: _repo.verifyOtp(phoneNumber.replaceAll("-", ""),
            (buildable.code ?? 0).toString()),
        buildOnStart: () => buildable.copyWith(loading: true),
        onData: (result) async {
          // Signing in is the authoritative sync point for who this device
          // belongs to. The server's answer wins outright — including when the
          // answer is "this account has no name yet". Only *setting* a name here
          // left the previous account's name in the box for anyone who signs in
          // without having explicitly logged out first, and Home then greeted
          // the new user by the old user's name.
          final name = result.user?.firstName;
          if (name != null && name.isNotEmpty) {
            await _storage.parentName.set(name);
            displayNameNotifier.value = name;
          } else {
            await _storage.parentName.set(null);
            displayNameNotifier.value = null;
          }

          if (result.isNewUser) {
            // Nothing on this device belongs to a brand-new account — drop the
            // last user's child and avatar, and let the profile prompt come back.
            await _storage.childName.set(null);
            await _storage.childAge.set(null);
            await _storage.avatarPath.set(null);
            await _storage.profilePromptDismissed.set(null);
            parentAvatarNotifier.value = null;

            await _storage.needsOnboarding.set(true);
            await _storage.pendingPhone.set(phoneNumber.replaceAll("-", ""));
          } else {
            await _storage.needsOnboarding.set(false);
          }
          // Pull this account's plan now. AppCubit lives for the whole run and
          // synced at cold start — when that happened before sign-in it found
          // no session, so without this the buyer's coupon prices wouldn't
          // appear until the next launch.
          await getIt<AppCubit>().onSignedIn();
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
