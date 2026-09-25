import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/service/referral/referral_coordinator.dart';
import 'package:lumi_pass/domain/repo/referrals/referral_repository.dart';

import 'referral_state.dart';

/// The referral screen: the user's code, how the programme works, the friends
/// they invited and the vouchers they earned — all from `GET /referrals/me`.
@injectable
class ReferralCubit extends BaseCubit<ReferralBuildable, ReferralListenable> {
  ReferralCubit(this._repo, this._coordinator)
      : super(const ReferralBuildable());

  final ReferralRepository _repo;
  final ReferralCoordinator _coordinator;

  Future<void> load() async {
    // No session (the App Review guest): nothing to show, and an
    // unauthenticated `referrals/me` would 401 into a forced sign-out.
    if (!_coordinator.isSignedIn) {
      build((s) => s.copyWith(isLoading: false, hasError: s.me == null));
      return;
    }
    if (buildable.me == null) {
      build((s) => s.copyWith(isLoading: true, hasError: false));
    }
    // A code left pending by a network blip gets its retry before the screen
    // reads `applied`, so what it shows is already up to date.
    await _coordinator.applyPendingSilently();
    try {
      final me = await _repo.getMe();
      build((s) => s.copyWith(me: me, isLoading: false, hasError: false));
    } catch (e) {
      log.w('referral load failed: $e');
      // Keep whatever was on screen; only an empty screen becomes an error.
      build((s) => s.copyWith(isLoading: false, hasError: s.me == null));
    }
  }

  /// Pull-to-refresh.
  Future<void> refresh() => load();
}
