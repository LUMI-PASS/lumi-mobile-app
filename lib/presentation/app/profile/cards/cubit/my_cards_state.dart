import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';

part 'my_cards_state.freezed.dart';

@freezed
class MyCardsBuildable with _$MyCardsBuildable {
  const factory MyCardsBuildable({
    @Default(true) bool isLoading,

    /// Set when the list itself couldn't be read. Distinct from a failed
    /// delete, which leaves the list intact and only shows a toast.
    String? error,
    @Default([]) List<SavedCard> cards,

    /// The row currently being deleted — fades it and swaps its trash icon for
    /// a spinner, so a slow gateway doesn't look like a dead tap.
    String? removingId,

    /// False when the server says card management is unavailable (503 — the
    /// gateway or the encryption key isn't configured). The screen then
    /// explains that instead of offering an Add button that can't work.
    @Default(true) bool isAvailable,
  }) = _MyCardsBuildable;

  const MyCardsBuildable._();

  /// The user has no cards. Distinct from "still loading", which is why this
  /// waits for [isLoading] to clear.
  bool get isEmpty => !isLoading && error == null && cards.isEmpty;
}

@freezed
class MyCardsListenable with _$MyCardsListenable {
  const factory MyCardsListenable({
    required MyCardsEffect effect,

    /// Message for [MyCardsEffect.deleteFailed].
    String? message,
  }) = _MyCardsListenable;
}

enum MyCardsEffect { none, deleteFailed }
