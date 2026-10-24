double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class OrderEntity {
  final int id;
  final String orderNumber;
  final String receiptNumber;
  final double amount;
  final String currency;
  final String status;
  final String cardBrand;
  final String cardLast4;
  final String paymentMethod;
  final String paidAt;
  final int courseId;
  final String courseTitle;
  final String teacherName;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.receiptNumber,
    required this.amount,
    required this.currency,
    required this.status,
    required this.cardBrand,
    required this.cardLast4,
    this.paymentMethod = 'card',
    required this.paidAt,
    required this.courseId,
    required this.courseTitle,
    required this.teacherName,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? {};

    return OrderEntity(
      id: _parseInt(json['id']),
      orderNumber: json['order_number'] as String? ?? '',
      receiptNumber: json['receipt_number'] as String? ?? '',
      amount: _parseDouble(json['amount']),
      currency: json['currency'] as String? ?? 'DZD',
      status: json['status'] as String? ?? 'completed',
      cardBrand: json['card_brand'] as String? ?? 'Visa',
      cardLast4: json['card_last4'] as String? ?? '****',
      paymentMethod: json['payment_method'] as String? ?? 'card',
      paidAt: json['paid_at'] as String? ?? '',
      courseId: _parseInt(course['id']),
      courseTitle: course['title'] as String? ?? 'Course',
      teacherName: course['teacher_name'] as String? ?? 'Instructor',
    );
  }
}
