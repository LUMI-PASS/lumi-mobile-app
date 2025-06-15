class PurchaseRequest {
  final String user;
  final String course;
  final double amount;

  PurchaseRequest({
    required this.user,
    required this.course,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'course': course,
      'amount': amount,
    };
  }
}
