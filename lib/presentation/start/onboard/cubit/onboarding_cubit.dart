import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OnboardingCubit
    extends BaseCubit<OnboardingBuildable, OnboardingListenable> {
  OnboardingCubit(this._storage) : super(const OnboardingBuildable());

  final Storage _storage;

  /// Number of slides in the onboarding carousel.
  static const pageCount = 4;

  void changeIndex(int index) {
    build((buildable) => buildable.copyWith(index: index));
  }

  /// Set once [finish] starts, so a double tap (or Skip tapped while the last
  /// slide's button is also pressed) navigates away only once.
  bool _finishing = false;

  /// Leaves onboarding for good — reached from "Skip" and from the last
  /// slide's button alike.
  Future<void> finish() async {
    if (_finishing) return;
    _finishing = true;
    await _storage.showOnboard.set(false);
    final tokens = _storage.tokens.call();
    if (tokens == null && !RemoteConfigService.instance.isInReview) {
      invoke(const OnboardingListenable(effect: OnboardEffect.login));
      return;
    }
    invoke(const OnboardingListenable(effect: OnboardEffect.home));
  }
}
