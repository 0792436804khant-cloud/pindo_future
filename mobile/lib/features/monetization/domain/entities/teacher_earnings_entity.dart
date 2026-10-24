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

class TeacherEarningsSummaryEntity {
  final double grossSales;
  final double platformFees;
  final double totalNetEarned;
  final double availableBalance;
  final double pendingPayout;
  final double paidOut;
  final int totalSalesCount;
  final String revenueSplit;

  const TeacherEarningsSummaryEntity({
    required this.grossSales,
    required this.platformFees,
    required this.totalNetEarned,
    required this.availableBalance,
    required this.pendingPayout,
    required this.paidOut,
    required this.totalSalesCount,
    required this.revenueSplit,
  });

  factory TeacherEarningsSummaryEntity.fromJson(Map<String, dynamic> json) {
    return TeacherEarningsSummaryEntity(
      grossSales: _parseDouble(json['gross_sales']),
      platformFees: _parseDouble(json['platform_fees']),
      totalNetEarned: _parseDouble(json['total_net_earned']),
      availableBalance: _parseDouble(json['available_balance']),
      pendingPayout: _parseDouble(json['pending_payout']),
      paidOut: _parseDouble(json['paid_out']),
      totalSalesCount: _parseInt(json['total_sales_count']),
      revenueSplit: json['revenue_split'] as String? ?? '80% Instructor / 20% Platform',
    );
  }
}

class TeacherTransactionEntity {
  final int id;
  final String orderNumber;
  final int courseId;
  final String courseTitle;
  final String studentName;
  final double grossAmount;
  final double platformFee;
  final double netAmount;
  final String status;
  final String createdAt;

  const TeacherTransactionEntity({
    required this.id,
    required this.orderNumber,
    required this.courseId,
    required this.courseTitle,
    required this.studentName,
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
    required this.status,
    required this.createdAt,
  });

  factory TeacherTransactionEntity.fromJson(Map<String, dynamic> json) {
    return TeacherTransactionEntity(
      id: _parseInt(json['id']),
      orderNumber: json['order_number'] as String? ?? '',
      courseId: _parseInt(json['course_id']),
      courseTitle: json['course_title'] as String? ?? '',
      studentName: json['student_name'] as String? ?? 'Student',
      grossAmount: _parseDouble(json['gross_amount']),
      platformFee: _parseDouble(json['platform_fee']),
      netAmount: _parseDouble(json['net_amount']),
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class PayoutDisbursementEntity {
  final int id;
  final String payoutReference;
  final double amount;
  final String currency;
  final String status;
  final String payoutMethod;
  final String? destinationAccount;
  final String? processedAt;
  final String createdAt;

  const PayoutDisbursementEntity({
    required this.id,
    required this.payoutReference,
    required this.amount,
    required this.currency,
    required this.status,
    required this.payoutMethod,
    this.destinationAccount,
    this.processedAt,
    required this.createdAt,
  });

  factory PayoutDisbursementEntity.fromJson(Map<String, dynamic> json) {
    return PayoutDisbursementEntity(
      id: _parseInt(json['id']),
      payoutReference: json['payout_reference'] as String? ?? '',
      amount: _parseDouble(json['amount']),
      currency: json['currency'] as String? ?? 'DZD',
      status: json['status'] as String? ?? 'requested',
      payoutMethod: json['payout_method'] as String? ?? 'bank_transfer',
      destinationAccount: json['destination_account'] as String?,
      processedAt: json['processed_at'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}
