import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/avatar_notifier.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:injectable/injectable.dart';

import 'profile_state.dart';

@injectable
class ProfileCubit extends BaseCubit<ProfileBuildable, ProfileListenable> {
  ProfileCubit(this._storage, this._repo, this._walletRepo)
      : super(const ProfileBuildable());
  final Storage _storage;
  final HomeRepository _repo;
  final WalletRepository _walletRepo;

  bool _showDeletedBanner = false;
  bool get showDeletedBanner => _showDeletedBanner;

  void dismissDeletedBanner() {
    _showDeletedBanner = false;
    build((b) => b.copyWith());
  }

  Future<void> load() => _load(silent: false);

  /// Silent refresh (used on tab focus) — no spinner.
  Future<void> refreshSilently() => _load(silent: true);

  /// The wallet is fetched alongside the profile but never allowed to break it:
  /// in release a failure leaves [ProfileBuildable.wallet] null, which hides the
  /// section rather than showing a zero balance that reads as "your money is
  /// gone".
  ///
  /// In debug that silence is unhelpful — a backend that hasn't shipped the
  /// wallet endpoints yet looks exactly like a layout bug. So debug builds fall
  /// back to an empty wallet and set [ProfileBuildable.walletError], which
  /// renders the section with the reason attached.
  Future<void> _loadWallet() async {
    try {
      final wallet = await _walletRepo.getWallet();
      build((b) => b.copyWith(wallet: wallet, walletError: null));
    } catch (e) {
      log.w('wallet load failed: $e');
      if (!kDebugMode) return;
      build((b) => b.copyWith(
            wallet: b.wallet ?? const WalletBalance(),
            walletError: e is DioException
                ? 'HTTP ${e.response?.statusCode ?? '—'} ${e.requestOptions.path}'
                : e.toString(),
          ));
    }
  }

  Future<void> _load({required bool silent}) async {
    if (!silent) build((b) => b.copyWith(isLoading: true));
    unawaited(_loadWallet());
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

  /// Clearing the box isn't enough on its own: these notifiers are in memory and
  /// outlive the sign-out, so without this the next user to sign in on this run
  /// is greeted by the previous user's name and avatar until the API answers.
  Future<void> _clearSession() async {
    await _storage.logout();
    displayNameNotifier.value = null;
    parentAvatarNotifier.value = null;
    // AppCubit outlives the session, so the plan has to be dropped from its
    // state too — clearing the box alone would leave the next account signed
    // in on this run showing the previous buyer's discounted prices.
    getIt<AppCubit>().clearSubscription();
  }

  Future<void> logout() => callable(
        future: _clearSession(),
        buildOnStart: () => buildable.copyWith(isLoading: true),
        invokeOnData: (data) => const ProfileListenable(
          effect: ProfileEffect.login,
        ),
        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(isLoading: false),
      );

  Future<void> deleteAccount() => callable(
        future: _clearSession().then((_) => _showDeletedBanner = true),
        buildOnStart: () => buildable.copyWith(isLoading: true),
        invokeOnData: (_) => const ProfileListenable(
          effect: ProfileEffect.deleted,
        ),
        onErrorData: (error) => display.error(error),
        buildOnDone: () => buildable.copyWith(isLoading: false),
      );
}
