/// A card the user has bound through WLCM's Subscribe/Merchant API, as returned
/// by our backend (`/api/paylov/cards`). Only the reusable `cardId` token and
/// masked display metadata are ever stored — never the full PAN.
class SavedCard {
  final String id; // our UserCard document id
  final String cardId; // WLCM token used to charge the card
  final String? maskedNumber; // "860003******9999"
  final String? vendor; // Uzcard | Humo | ...
  final String? processing;
  final String? expireDate; // YYMM
  final String? owner;
  final String? cardName;

  const SavedCard({
    required this.id,
    required this.cardId,
    this.maskedNumber,
    this.vendor,
    this.processing,
    this.expireDate,
    this.owner,
    this.cardName,
  });

  /// Last four digits pulled from the masked PAN, for compact labels.
  String get last4 {
    final digits = (maskedNumber ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
  }

  /// "Uzcard •••• 9999" — what the card row shows.
  String get label {
    final brand = (vendor?.isNotEmpty ?? false) ? vendor! : 'Card';
    return '$brand •••• $last4';
  }

  /// Expiry formatted MM/YY from the stored YYMM, or '' when unknown.
  String get expiryDisplay {
    final e = (expireDate ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (e.length != 4) return '';
    final yy = e.substring(0, 2);
    final mm = e.substring(2, 4);
    return '$mm/$yy';
  }

  factory SavedCard.fromJson(Map<String, dynamic> json) {
    String? s(Object? v) {
      final t = v?.toString();
      return (t != null && t.isNotEmpty) ? t : null;
    }

    return SavedCard(
      id: json['id']?.toString() ?? '',
      cardId: json['card_id']?.toString() ?? '',
      maskedNumber: s(json['masked_number']),
      vendor: s(json['vendor']),
      processing: s(json['processing']),
      expireDate: s(json['expire_date']),
      owner: s(json['owner']),
      cardName: s(json['card_name']),
    );
  }
}

/// Result of beginning a card-add (`POST /api/paylov/cards`): WLCM has SMSed an
/// OTP; confirm it with the returned [cid].
class CardAddSession {
  final String cid;
  final String? otpSentPhone;

  const CardAddSession({required this.cid, this.otpSentPhone});

  factory CardAddSession.fromJson(Map<String, dynamic> json) => CardAddSession(
        cid: json['cid']?.toString() ?? '',
        otpSentPhone: json['otp_sent_phone']?.toString(),
      );
}
