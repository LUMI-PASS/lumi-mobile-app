import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_config.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart';

import 'wallet_state.dart';

/// The wallet screen: balance plus a paginated ledger.
///
/// Every read here is best-effort. A wallet is a secondary screen reached from
/// the profile, and a failed fetch should leave the user looking at zeros and
/// an empty list rather than an error page — the money is safe on the server
/// either way, and there is nothing they can do about a network blip.
@injectable
class WalletCubit extends BaseCubit<WalletBuildable, WalletListenable> {
  WalletCubit(this._repo) : super(const WalletBuildable());

  final WalletRepository _repo;

  static const _pageSize = 20;

  /// Balance, first page of history and the public rates, in parallel.
  ///
  /// Sequentially this would be three round trips before the screen paints;
  /// they don't depend on each other, so they go together.
  Future<void> load() async {
    build((s) => s.copyWith(isLoading: true));
    try {
      final results = await Future.wait([
        _repo.getWallet().catchError((_) => WalletBalance.empty),
        _repo.getTransactions(page: 1, limit: _pageSize)
            .catchError((_) => WalletTransactionsPage.empty),
        _repo.getCashbackConfig().catchError((_) => const CashbackConfig()),
      ]);
      final balance = results[0] as WalletBalance;
      final history = results[1] as WalletTransactionsPage;
      final config = results[2] as CashbackConfig;

      build((s) => s.copyWith(
            wallet: balance,
            entries: history.items,
            page: history.page,
            totalPages: history.totalPages,
            config: config,
            isLoading: false,
          ));
    } catch (_) {
      // Already swallowed per-call above; this only catches a Future.wait
      // surprise. Land on an empty screen, not a broken one.
      build((s) => s.copyWith(isLoading: false));
    }
  }

  /// Pull-to-refresh. Deliberately re-runs [load] rather than merging, so a
  /// balance corrected server-side (an admin adjustment, a matured earn) shows
  /// up instead of being papered over by stale rows.
  Future<void> refresh() => load();

  /// Append the next page. Guarded against double-firing, which a scroll
  /// listener will otherwise do on every frame near the bottom.
  Future<void> loadMore() async {
    final state = buildable;
    if (state.isLoadingMore || !state.hasMore) return;

    build((s) => s.copyWith(isLoadingMore: true));
    try {
      final next = await _repo.getTransactions(
        page: state.page + 1,
        limit: _pageSize,
      );
      build((s) => s.copyWith(
            entries: [...s.entries, ...next.items],
            page: next.page,
            totalPages: next.totalPages,
            isLoadingMore: false,
          ));
    } catch (_) {
      // Keep what we have; the user can pull to retry.
      build((s) => s.copyWith(isLoadingMore: false));
    }
  }
}
