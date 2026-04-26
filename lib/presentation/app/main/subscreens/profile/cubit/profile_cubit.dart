import 'package:dio/dio.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:injectable/injectable.dart';

import 'profile_state.dart';

@injectable
class ProfileCubit extends BaseCubit<ProfileBuildable, ProfileListenable> {
  ProfileCubit(this._storage, this._repo) : super(const ProfileBuildable());
  final Storage _storage;
  final HomeRepository _repo;

  Future<void> load() => _load(silent: false);

  /// Silent refresh (used on tab focus) — no spinner.
  Future<void> refreshSilently() => _load(silent: true);

  Future<void> _load({required bool silent}) async {
    if (!silent) build((b) => b.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        _repo.getProfileData(),
        _repo.getParentProfile(),
      ]);
      final user = results[0] as HomForUser;
      final parent = results[1] as ParentProfileResult;

      final trialSummary = parent.trialSummary;
      final trialByChildId = <String, TrialSummaryChild>{};
      if (trialSummary != null) {
        for (final entry in trialSummary.children) {
          if (entry.childId != null) {
            trialByChildId[entry.childId!] = entry;
          }
        }
      }

      final children = parent.children.map((child) {
        final trial = trialByChildId[child.id];
        if (trial != null) {
          return child.copyWith(
            remainingTrials: trial.remainingTrials,
            coinsIntoUnlockCycle: trial.coinsIntoUnlockCycle,
            coinsToNextUnlock: trial.coinsToNextUnlock,
            nextUnlockAtTotalPaidCoins: trial.nextUnlockAtTotalPaidCoins,
            unlockThresholdCoin: trialSummary?.unlockThresholdCoin,
          );
        }
        return child;
      }).toList();

      build((b) => b.copyWith(
            user: user,
            children: children,
            trialSummary: trialSummary,
          ));
    } on DioException catch (error) {
      if (silent) return;
      if (error.response?.statusCode == 500 ||
          error.response?.statusCode == 502) {
        display.error(Strings.serverErrorTryLater);
      } else if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        display.error(Strings.connectionError);
      }
    } catch (_) {
    } finally {
      if (!silent) build((b) => b.copyWith(isLoading: false));
    }
  }

  Future<void> logout() => callable(
        future: _storage.logout(),
        buildOnStart: () => buildable.copyWith(isLoading: true),
        invokeOnData: (data) => const ProfileListenable(
          effect: ProfileEffect.login,
        ),
        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(isLoading: false),
      );
}
