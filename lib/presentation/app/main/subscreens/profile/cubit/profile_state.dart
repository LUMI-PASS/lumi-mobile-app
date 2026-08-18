import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileBuildable with _$ProfileBuildable {
  const factory ProfileBuildable({
    @Default(false) bool isLoading,
    HomForUser? user,
    @Default([]) List<ChildModel> children,
    ParentTrialSummary? trialSummary,

    /// Null until the wallet has loaded, or when the fetch failed in a release
    /// build. The section stays hidden in both cases rather than rendering a
    /// misleading zero balance — a failed request must not look like "you have
    /// no money".
    WalletBalance? wallet,

    /// Debug-only: why the wallet fetch failed. Set alongside an empty [wallet]
    /// so the section still renders during development instead of vanishing —
    /// see ProfileCubit._loadWallet. Always null in release.
    String? walletError,
  }) = _ProfileBuildable;
}

@freezed
class ProfileListenable with _$ProfileListenable {
  const factory ProfileListenable({
    required ProfileEffect effect,
  }) = _ProfileListenable;
}

enum ProfileEffect { login, deleted }
