import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

/// Turns a payment gateway's raw code into something a buyer can act on.
///
/// WLCM answers with bare machine codes — `card_not_found`,
/// `insufficient_funds` — sometimes wrapped in our own prose ("Checkout failed:
/// Paylov checkout payment failed: card_not_found"). Showing those to a parent
/// at the till is useless: `card_not_found` doesn't mean the card is missing,
/// it means the number or expiry is wrong, and only a localized sentence says
/// what to do about it.
///
/// Matching is by word pairs, deliberately: the same code arrives at different
/// nesting depths from `/orders/checkout` and `/paylov/card/confirm`, in either
/// word order, and new wrappers must not silently stop it matching.
class PaymentError {
  PaymentError._();

  /// Gateway condition -> translation key, matched as word PAIRS rather than
  /// exact codes.
  ///
  /// WLCM sends both `otp_expired` and `expired_otp` for the same thing, and a
  /// list of literals silently missed the second — the buyer was told "wrong
  /// code" when their code had simply timed out, sending them round a loop that
  /// could not succeed. Pairs survive word order and new wrappers.
  static const List<(List<String>, String)> _rules = [
    (['insufficient', 'fund'], 'pay_err_insufficient_funds'),
    (['not_enough'], 'pay_err_insufficient_funds'),
    (['card', 'not_found'], 'pay_err_card_not_found'),
    (['card', 'invalid'], 'pay_err_card_not_found'),
    (['invalid', 'card'], 'pay_err_card_not_found'),
    (['card', 'number'], 'pay_err_card_not_found'),
    (['card', 'expired'], 'pay_err_card_expired'),
    (['expired', 'card'], 'pay_err_card_expired'),
    (['card', 'blocked'], 'pay_err_card_blocked'),
    (['blocked', 'card'], 'pay_err_card_blocked'),
    (['otp', 'expired'], 'pay_err_otp_expired'),
    (['expired', 'otp'], 'pay_err_otp_expired'),
    (['otp', 'invalid'], 'pay_err_otp_invalid'),
    (['invalid', 'otp'], 'pay_err_otp_invalid'),
    (['wrong', 'otp'], 'pay_err_otp_invalid'),
    (['limit', 'exceeded'], 'pay_err_limit_exceeded'),
    (['exceeded', 'limit'], 'pay_err_limit_exceeded'),
  ];

  /// The localized message for a gateway code found anywhere in [raw], or null
  /// when nothing matches — the caller then keeps whatever it would have shown.
  static String? fromText(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final low = raw.toLowerCase();
    // Expiry is checked before invalidity: "expired_otp" contains neither
    // "invalid" nor "wrong", but ordering the rules keeps the intent explicit
    // if a future code carries both words.
    for (final (words, key) in _rules) {
      if (words.every(low.contains)) return key.tr();
    }
    return null;
  }

  /// Same, reading the message out of a [DioException]'s body first — that is
  /// where the gateway's own words are — and falling back to the exception text.
  static String? fromDio(Object error) {
    if (error is! DioException) return fromText(error.toString());
    final data = error.response?.data;
    final fromBody = data is Map ? data['message']?.toString() : null;
    return fromText(fromBody) ?? fromText(error.message);
  }
}
