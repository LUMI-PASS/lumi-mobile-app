class CheckoutItem {
  final int ageFrom;
  final int? ageTo; // null = adult / no upper age limit
  final int count;
  final int? duration; // minutes; null = unlimited
  // Required-booking categories: client-picked time window for the ticket(s).
  // Both null for the standard recurring-schedule flow.
  final String? startTime; // HH:mm
  final String? endTime; // HH:mm

  const CheckoutItem({
    required this.ageFrom,
    required this.ageTo,
    required this.count,
    this.duration,
    this.startTime,
    this.endTime,
  });

  Map<String, dynamic> toJson() => {
        'age_from': ageFrom,
        'age_to': ageTo,
        'count': count,
        if (duration != null) 'duration': duration,
        if (startTime != null) 'start_time': startTime,
        if (endTime != null) 'end_time': endTime,
      };
}

class CheckoutResult {
  final String orderId;
  final num totalAmount;
  // Order subtotal before any discount, and the discount actually applied
  // (from a coupon plan or a promocode). Both 0 when nothing was discounted.
  final num subtotalAmount;
  final num discountAmount;
  // The promocode that was applied to this order, if any.
  final String? promocodeCode;
  final String currency;
  final String status;
  final String checkoutUrl;
  final String ticketDate;
  final List<String> ticketNumbers;

  // ── Wallet ─────────────────────────────────────────────────────────────────
  /// Wallet balance the server actually applied, in soum.
  ///
  /// The client asks for a contribution with `use_wallet`; the server decides
  /// the amount, clamping against the available balance, the per-order
  /// redemption cap and the total. **Render this, never the local estimate** —
  /// they disagree whenever the balance moved between the preview and the sale.
  final num walletAmount;

  /// What the gateway is actually charged: [totalAmount] − [walletAmount].
  ///
  /// [totalAmount] is still what the order cost, and is what the summary's
  /// grand total shows. The wallet is a payment method, not a discount.
  final num payableAmount;

  /// What this order earns back, priced server-side off [payableAmount] —
  /// the wallet-funded part earns nothing.
  final num cashbackEstimate;

  // ── Paylov (WLCM) ──────────────────────────────────────────────────────────
  // Populated only when the checkout was routed through Paylov. For redirect
  // providers (payme/click/uzum/paylov) [checkoutUrl] is set and these stay
  // null. For the card provider [checkoutUrl] is empty and the card fields are
  // returned instead: the client collects the OTP and calls paylovConfirmCard.
  final String? paymentProvider;
  final String? transactionId;
  final String? cid;
  final String? otpSentPhone;

  /// Paylov's own answer, forwarded by our backend untouched.
  /// [paylovState]: 1 pending · 2 success · -2 cancelled.
  /// [paylovMessage] is the gateway's text (e.g. "Already paid").
  /// [paylovOrderId] is WLCM's order id — quote it to their support, not
  /// [orderId], which is ours.
  final int? paylovState;
  final String? paylovMessage;
  final String? paylovOrderId;

  const CheckoutResult({
    required this.orderId,
    required this.totalAmount,
    this.subtotalAmount = 0,
    this.discountAmount = 0,
    this.promocodeCode,
    required this.currency,
    required this.status,
    required this.checkoutUrl,
    required this.ticketDate,
    required this.ticketNumbers,
    this.walletAmount = 0,
    this.payableAmount = 0,
    this.cashbackEstimate = 0,
    this.paymentProvider,
    this.transactionId,
    this.cid,
    this.otpSentPhone,
    this.paylovState,
    this.paylovMessage,
    this.paylovOrderId,
  });

  /// True when this is a Paylov card checkout awaiting an OTP confirmation
  /// (no redirect URL, but a transaction to confirm).
  bool get isCardOtpPending =>
      checkoutUrl.isEmpty && (transactionId?.isNotEmpty ?? false);

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    final ticketsRaw = (json['ticket_numbers'] as List?) ?? const [];
    final code = json['promocode_code']?.toString();
    String? nonEmpty(Object? v) {
      final s = v?.toString();
      return (s != null && s.isNotEmpty) ? s : null;
    }

    return CheckoutResult(
      orderId: json['order_id']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?) ?? 0,
      subtotalAmount: (json['subtotal_amount'] as num?) ?? 0,
      discountAmount: (json['discount_amount'] as num?) ?? 0,
      promocodeCode: (code != null && code.isNotEmpty) ? code : null,
      currency: json['currency']?.toString() ?? 'UZS',
      status: json['status']?.toString() ?? 'pending',
      checkoutUrl: json['checkout_url']?.toString() ?? '',
      ticketDate: json['ticket_date']?.toString() ?? '',
      ticketNumbers: ticketsRaw.map((e) => e.toString()).toList(),
      walletAmount: (json['wallet_amount'] as num?) ?? 0,
      // Absent on a server that predates the wallet — fall back to the total,
      // which is what such a server charges, so an older backend keeps working
      // rather than reading as "nothing to pay".
      payableAmount:
          (json['payable_amount'] as num?) ?? (json['total_amount'] as num?) ?? 0,
      cashbackEstimate: (json['cashback_estimate'] as num?) ?? 0,
      paymentProvider: nonEmpty(json['payment_provider']),
      transactionId: nonEmpty(json['transaction_id']),
      cid: nonEmpty(json['cid']),
      otpSentPhone: nonEmpty(json['otp_sent_phone']),
      paylovState: json['state'] is num
          ? (json['state'] as num).toInt()
          : int.tryParse('${json['state'] ?? ''}'),
      paylovMessage: nonEmpty(json['message']),
      paylovOrderId: nonEmpty(json['paylov_order_id']),
    );
  }
}

/// Result of confirming a Paylov card OTP (`POST /api/paylov/card/confirm`).
class PaylovCardConfirmResult {
  final bool success;
  final String orderId;
  final String status;
  final String? message;

  const PaylovCardConfirmResult({
    required this.success,
    required this.orderId,
    required this.status,
    this.message,
  });

  factory PaylovCardConfirmResult.fromJson(Map<String, dynamic> json) {
    return PaylovCardConfirmResult(
      success: json['success'] == true,
      orderId: json['order_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      message: json['message']?.toString(),
    );
  }
}

/// Preview of a promocode applied to a subtotal, returned by
/// `POST /api/promocodes/validate`. Used by the checkout screen to show the
/// new total before the user pays — the discount is re-validated server-side
/// at checkout time.
class PromocodePreview {
  final String code;
  final String discountType; // 'percent' | 'fixed'
  final num discountValue;
  final num discountAmount;
  final num totalAmount;

  const PromocodePreview({
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.discountAmount,
    required this.totalAmount,
  });

  factory PromocodePreview.fromJson(Map<String, dynamic> json) {
    return PromocodePreview(
      code: json['code']?.toString() ?? '',
      discountType: json['discount_type']?.toString() ?? 'percent',
      discountValue: (json['discount_value'] as num?) ?? 0,
      discountAmount: (json['discount_amount'] as num?) ?? 0,
      totalAmount: (json['total_amount'] as num?) ?? 0,
    );
  }
}
