import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_config.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_transaction.dart';

part 'wallet_state.freezed.dart';

@freezed
class WalletBuildable with _$WalletBuildable {
  const factory WalletBuildable({
    /// First paint only. Paging in more rows must not blank the screen, which
    /// is why appending has its own flag.
    @Default(true) bool isLoading,
    @Default(false) bool isLoadingMore,

    /// Null until the balance lands. The hero renders zeros rather than a
    /// spinner-shaped hole, so the card doesn't jump when it arrives.
    WalletBalance? wallet,
    @Default([]) List<WalletTransactionModel> entries,
    @Default(1) int page,
    @Default(1) int totalPages,

    /// Drives the empty state's "earn 2% back" line. Absent or disabled just
    /// drops that sentence — it never blocks the screen.
    CashbackConfig? config,
  }) = _WalletBuildable;

  const WalletBuildable._();

  bool get hasMore => page < totalPages;

  /// Nothing has ever moved in this wallet. Distinct from "still loading",
  /// which is why the empty state waits for [isLoading] to clear.
  bool get isEmpty => !isLoading && entries.isEmpty;
}

@freezed
class WalletListenable with _$WalletListenable {
  const factory WalletListenable({
    required WalletEffect effect,
  }) = _WalletListenable;
}

enum WalletEffect { none }
