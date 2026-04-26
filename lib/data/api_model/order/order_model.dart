class CheckoutItem {
  final int ageFrom;
  final int? ageTo; // null = adult / no upper age limit
  final int count;
  final int? duration; // minutes; null = unlimited

  const CheckoutItem({
    required this.ageFrom,
    required this.ageTo,
    required this.count,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'age_from': ageFrom,
        'age_to': ageTo,
        'count': count,
        if (duration != null) 'duration': duration,
      };
}

class CheckoutResult {
  final String orderId;
  final num totalAmount;
  final String currency;
  final String status;
  final String checkoutUrl;
  final String ticketDate;
  final List<String> ticketNumbers;

  const CheckoutResult({
    required this.orderId,
    required this.totalAmount,
    required this.currency,
    required this.status,
    required this.checkoutUrl,
    required this.ticketDate,
    required this.ticketNumbers,
  });

  factory CheckoutResult.fromJson(Map<String, dynamic> json) {
    final ticketsRaw = (json['ticket_numbers'] as List?) ?? const [];
    return CheckoutResult(
      orderId: json['order_id']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?) ?? 0,
      currency: json['currency']?.toString() ?? 'UZS',
      status: json['status']?.toString() ?? 'pending',
      checkoutUrl: json['checkout_url']?.toString() ?? '',
      ticketDate: json['ticket_date']?.toString() ?? '',
      ticketNumbers: ticketsRaw.map((e) => e.toString()).toList(),
    );
  }
}
