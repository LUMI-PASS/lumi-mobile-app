import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OnboardingCubit
    extends BaseCubit<OnboardingBuildable, OnboardingListenable> {
  OnboardingCubit(this._storage) : super(const OnboardingBuildable());

  final Storage _storage;

  void changeIndex(int index) async {
    if (index == 3) {
      await _storage.showOnboard.set(false);
      final tokens = _storage.tokens.call();
      if (tokens == null && !RemoteConfigService.instance.isInReview) {
        invoke(const OnboardingListenable(effect: OnboardEffect.login));
        return;
      }
      invoke(const OnboardingListenable(effect: OnboardEffect.home));
      return;
    }
    build((buildable) => buildable.copyWith(index: index));
  }

  void skipAll() async {
    await _storage.showOnboard.set(false);
    final tokens = _storage.tokens.call();
    if (tokens == null && !RemoteConfigService.instance.isInReview) {
      invoke(const OnboardingListenable(effect: OnboardEffect.login));
      return;
    }
    invoke(const OnboardingListenable(effect: OnboardEffect.home));
    return;
  }
}

enum Onboard {
  first,
  second,
  third,
}

extension LanguageExtensions on Onboard {
  String get title {
    switch (this) {
      case Onboard.first:
        return Strings.onboard1Title;
      case Onboard.second:
        return Strings.onboard2Title;
      case Onboard.third:
        return Strings.onboard3Title;
    }
  }

  String get description {
    switch (this) {
      case Onboard.first:
        return Strings.onboard1Subtitle;
      case Onboard.second:
        return Strings.onboard2Subtitle;
      case Onboard.third:
        return Strings.onboard3Subtitle;
    }
  }
}
