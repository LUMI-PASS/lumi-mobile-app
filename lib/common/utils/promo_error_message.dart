import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/data/api_model/order/promo_error_code.dart';

/// Turns a backend promocode refusal into a localized, user-facing message.
///
/// Shared by every place a code can be typed — the booking screen and the
/// payment chooser of a Lumi Coin pack — so the same refusal reads the same
/// wherever it lands.
class PromoErrorMessage {
  PromoErrorMessage._();

  /// The message for an error body (`DioException.response?.data`) from
  /// `promocodes/validate`.
  ///
  /// Known structured errors (tagged with an `error_code`) are localized here;
  /// anything else falls back to the server message, then a generic invalid
  /// string.
  static String fromData(dynamic data) {
    if (data is! Map) return 'promo_invalid'.tr();
    final rawCode = data['error_code'];
    final serverMessage = _serverMessage(data['message']);

    final code = PromoErrorCode.fromKey(rawCode is String ? rawCode : null);
    switch (code) {
      case PromoErrorCode.maxOrder:
        final raw = data['max_order_amount'];
        final amount = raw is num ? raw : num.tryParse('$raw') ?? 0;
        return code.messageKey.tr(args: [amount.toRawUzsPrice()]);
      // The class's margin is too thin to fund any promocode discount.
      case PromoErrorCode.notApplicable:
      case PromoErrorCode.courseOnly:
      // Nothing left to redeem for this buyer.
      case PromoErrorCode.alreadyUsed:
      // The code belongs to the other kind of order, or would make a coin
      // pack free.
      case PromoErrorCode.notForCoinPacks:
      case PromoErrorCode.notForActivities:
      case PromoErrorCode.fullDiscountNotAllowed:
      // Referral vouchers ride the same field and the same 400.
      case PromoErrorCode.voucherNotFound:
      case PromoErrorCode.voucherUsed:
      case PromoErrorCode.voucherUnavailable:
      case PromoErrorCode.voucherExpired:
        return code.messageKey.tr();
      // Uses remain, but fewer than the tickets in this order. Usage is counted
      // by tickets, so name the cap — the buyer can still book a smaller order.
      case PromoErrorCode.ticketLimit:
        final raw = data['ticket_limit'];
        final limit = raw is num ? raw.toInt() : int.tryParse('$raw') ?? 1;
        return limit <= 1
            ? 'promo_one_ticket_only'.tr()
            : code.messageKey.tr(args: ['$limit']);
      case PromoErrorCode.voucherMinOrder:
        final raw = data['min_order_amount'];
        final amount = raw is num ? raw : num.tryParse('$raw') ?? 0;
        return code.messageKey.tr(args: [amount.toRawUzsPrice()]);
      case PromoErrorCode.unknown:
        return _untaggedUsageMessage(serverMessage) ??
            serverMessage ??
            'promo_invalid'.tr();
    }
  }

  /// The message for a PURCHASE that was refused because of the promocode sent
  /// with it, or null when the failure was about something else (the gateway,
  /// the card, the pack) and the caller's own handling applies.
  ///
  /// A tagged refusal is recognised by its `error_code`. The older refusals
  /// (not found, expired, not active, minimum order) carry no code, only
  /// English prose that always names the promocode — which is the one thing
  /// about that prose worth matching on.
  static String? refusalFromData(dynamic data) {
    if (data is! Map) return null;
    final rawCode = data['error_code'];
    final code = PromoErrorCode.fromKey(rawCode is String ? rawCode : null);
    if (code != PromoErrorCode.unknown) return fromData(data);
    // Some other feature's code (a coin rule, a gateway error) — not ours.
    if (rawCode is String && rawCode.isNotEmpty) return null;
    final m = _serverMessage(data['message'])?.toLowerCase() ?? '';
    if (m.contains('promocode') || m.contains('voucher')) return fromData(data);
    return null;
  }

  /// The backend's own `message`, which is either a string or a list of
  /// validation strings.
  static String? _serverMessage(dynamic message) {
    if (message == null) return null;
    return message is List ? message.join(', ') : message.toString();
  }

  /// Servers that predate the tagged usage errors send the limit rejections as
  /// plain English prose with no `error_code`. Match their wording so an older
  /// backend still shows a localized message instead of leaking English.
  static String? _untaggedUsageMessage(String? message) {
    if (message == null) return null;
    final m = message.toLowerCase();
    if (m.contains('usage limit reached') ||
        m.contains('already used this promocode')) {
      return 'promo_already_used'.tr();
    }
    return null;
  }
}
