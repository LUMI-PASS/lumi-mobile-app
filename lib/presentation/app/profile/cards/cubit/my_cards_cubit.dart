import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

import 'my_cards_state.dart';

/// The user's saved cards: list, add, forget.
///
/// Adding a card is not done here — it runs inside the add/OTP sheets, which
/// own the two-step gateway conversation and the money it moves. The cubit only
/// reloads afterwards, so the list always reflects the server rather than an
/// optimistic guess about what got saved.
@injectable
class MyCardsCubit extends BaseCubit<MyCardsBuildable, MyCardsListenable> {
  MyCardsCubit(this._api) : super(const MyCardsBuildable());

  final OrdersApi _api;

  Future<void> load() async {
    build((s) => s.copyWith(isLoading: true, error: null));
    try {
      final cards = await _api.getSavedCards();
      build((s) => s.copyWith(
            cards: cards,
            isLoading: false,
            isAvailable: true,
            error: null,
          ));
    } on DioException catch (e) {
      // 503 is a configuration answer, not a failure the user can retry away:
      // the server has no gateway credentials or no encryption key. Say that
      // once, and hide the Add button rather than letting them try.
      if (e.response?.statusCode == 503) {
        build((s) => s.copyWith(
              isLoading: false,
              isAvailable: false,
              cards: const [],
              error: 'card_save_unavailable'.tr(),
            ));
        return;
      }
      build((s) => s.copyWith(
            isLoading: false,
            error: PaymentError.fromDio(e) ?? 'card_load_error'.tr(),
          ));
    } catch (_) {
      build((s) => s.copyWith(isLoading: false, error: 'card_load_error'.tr()));
    }
  }

  Future<void> refresh() => load();

  /// Reload after a card was added. Kept separate from [refresh] so the intent
  /// reads at the call site.
  Future<void> onCardAdded() => load();

  /// Forget a card.
  ///
  /// The row is marked removing rather than dropped up front: if the delete
  /// fails, a card that still exists must not have vanished from the list.
  Future<void> remove(SavedCard card) async {
    if (buildable.removingId != null) return;
    build((s) => s.copyWith(removingId: card.id));
    try {
      await _api.deleteSavedCard(card.id);
      build((s) => s.copyWith(
            cards: s.cards.where((c) => c.id != card.id).toList(),
            removingId: null,
          ));
    } catch (e) {
      build((s) => s.copyWith(removingId: null));
      invoke(MyCardsListenable(
        effect: MyCardsEffect.deleteFailed,
        message: e is DioException
            ? (PaymentError.fromDio(e) ?? 'card_delete_error'.tr())
            : 'card_delete_error'.tr(),
      ));
    }
  }
}
