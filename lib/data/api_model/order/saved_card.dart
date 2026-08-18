/// A card the user has verified and saved, as returned by our backend
/// (`/api/paylov/cards`).
///
/// The card rail issues no reusable token, so the server keeps the number
/// itself (encrypted) and hands the app only what it needs to draw a row. The
/// PAN never reaches the client after the moment the user typed it.
class SavedCard {
  final String id; // our UserCard document id — what /pay and DELETE take
  final String? maskedNumber; // "860012******9012"
  final String? vendor; // Uzcard | Humo | Visa | Mastercard | Card
  final String? expireDate; // YYMM — the order the gateway uses
  final String? owner; // always null on this rail — kept for the fallback
  final String? cardName;

  const SavedCard({
    required this.id,
    this.maskedNumber,
    this.vendor,
    this.expireDate,
    this.owner,
    this.cardName,
  });

  /// Last four digits pulled from the masked PAN, for compact labels.
  String get last4 {
    final digits = (maskedNumber ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
  }

  /// What the card row shows. The gateway returns no cardholder name, so the
  /// user's own label wins and the brand is the fallback — never an empty row.
  String get label {
    final name = cardName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final brand = (vendor?.isNotEmpty ?? false) ? vendor! : 'Card';
    return '$brand •••• $last4';
  }

  /// Expiry as MM/YY for display, from the stored YYMM. '' when unknown.
  String get expiryDisplay {
    final e = (expireDate ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (e.length != 4) return '';
    return '${e.substring(2, 4)}/${e.substring(0, 2)}';
  }

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    String? s(Object? v) {
      final t = v?.toString();
      return (t != null && t.isNotEmpty) ? t : null;
    }

    return SavedCard(
      id: json['id']?.toString() ?? '',
      maskedNumber: s(json['masked_number']),
      vendor: s(json['vendor']),
      expireDate: s(json['expire_date']),
      owner: s(json['owner']),
      cardName: s(json['card_name']),
    );
  }
}

/// Result of starting card verification (`POST /api/paylov/cards/verify`): the
/// card has been charged 100 soum and the bank has SMSed a code to
/// [otpSentPhone]. Confirm it with [verificationId].
class CardVerifySession {
  final String verificationId;
  final String? otpSentPhone;
  final String? maskedNumber;
  final String? vendor;

  /// True when the server handed back an attempt that was already in flight
  /// rather than opening a new one — i.e. the card was NOT charged again.
  final bool reused;

  const CardVerifySession({
    required this.verificationId,
    this.otpSentPhone,
    this.maskedNumber,
    this.vendor,
    this.reused = false,
  });

  factory CardVerifySession.fromJson(Map<String, dynamic> json) =>
      CardVerifySession(
        verificationId: json['verification_id']?.toString() ?? '',
        otpSentPhone: json['otp_sent_phone']?.toString(),
        maskedNumber: json['masked_number']?.toString(),
        vendor: json['vendor']?.toString(),
        reused: json['reused'] == true,
      );
}

/// Result of charging an order with a saved card
/// (`POST /api/paylov/cards/pay`).
///
/// This rail challenges every payment, so the order is **not** paid yet when
/// [otpRequired] is true — the client collects the code and finishes through
/// `POST /api/paylov/card/confirm`.
class SavedCardCharge {
  final String orderId;
  final bool otpRequired;
  final String? transactionId;
  final String? cid;
  final String? otpSentPhone;

  const SavedCardCharge({
    required this.orderId,
    required this.otpRequired,
    this.transactionId,
    this.cid,
    this.otpSentPhone,
  });

  factory SavedCardCharge.fromJson(Map<String, dynamic> json) =>
      SavedCardCharge(
        orderId: json['order_id']?.toString() ?? '',
        otpRequired: json['otp_required'] == true,
        transactionId: json['transaction_id']?.toString(),
        cid: json['cid']?.toString(),
        otpSentPhone: json['otp_sent_phone']?.toString(),
      );
}
