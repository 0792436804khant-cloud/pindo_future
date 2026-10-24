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

class CheckoutIntentEntity {
  final int courseId;
  final String courseTitle;
  final String category;
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final String teacherName;
  final bool isFree;
  final bool alreadyEnrolled;

  const CheckoutIntentEntity({
    required this.courseId,
    required this.courseTitle,
    required this.category,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.currency,
    required this.teacherName,
    required this.isFree,
    required this.alreadyEnrolled,
  });

  factory CheckoutIntentEntity.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? {};
    final pricing = json['pricing'] as Map<String, dynamic>? ?? {};
    final teacher = course['teacher'] as Map<String, dynamic>? ?? {};

    return CheckoutIntentEntity(
      courseId: _parseInt(course['id']),
      courseTitle: course['title'] as String? ?? '',
      category: course['category'] as String? ?? 'General',
      subtotal: _parseDouble(pricing['subtotal']),
      tax: _parseDouble(pricing['tax']),
      total: _parseDouble(pricing['total']),
      currency: pricing['currency'] as String? ?? 'DZD',
      teacherName: teacher['name'] as String? ?? 'Instructor',
      isFree: course['is_free'] as bool? ?? false,
      alreadyEnrolled: json['already_enrolled'] as bool? ?? false,
    );
  }
}
