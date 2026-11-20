import 'dart:typed_data';

enum ReceiptStatus {
  pending,
  approved,
  rejected,
}

extension ReceiptStatusX on ReceiptStatus {
  String get arabicLabel {
    switch (this) {
      case ReceiptStatus.pending:
        return 'قيد المراجعة ⏱️';
      case ReceiptStatus.approved:
        return 'مؤكد ومفعل 🟢';
      case ReceiptStatus.rejected:
        return 'مرفوض ❌';
    }
  }
}

class SubscriptionPaymentReceipt {
  final String id;
  final String referenceNumber;
  final String studentName;
  final String studentEmail;
  final String studentId;
  final String cohortName;
  final String teacherName;
  final String subject;
  final String packageName;
  final int priceDzd;
  final String paymentMethod; // 'BaridiMob', 'Edahabia', 'CCP'
  final String? receiptName;
  final Uint8List? receiptBytes;
  final ReceiptStatus status;
  final String? rejectionReason;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const SubscriptionPaymentReceipt({
    required this.id,
    required this.referenceNumber,
    required this.studentName,
    required this.studentEmail,
    required this.studentId,
    required this.cohortName,
    required this.teacherName,
    required this.subject,
    required this.packageName,
    required this.priceDzd,
    required this.paymentMethod,
    this.receiptName,
    this.receiptBytes,
    this.status = ReceiptStatus.pending,
    this.rejectionReason,
    required this.submittedAt,
    this.reviewedAt,
  });

  bool get isPending => status == ReceiptStatus.pending;
  bool get isApproved => status == ReceiptStatus.approved;
  bool get isRejected => status == ReceiptStatus.rejected;

  SubscriptionPaymentReceipt copyWith({
    ReceiptStatus? status,
    String? rejectionReason,
    DateTime? reviewedAt,
  }) {
    return SubscriptionPaymentReceipt(
      id: id,
      referenceNumber: referenceNumber,
      studentName: studentName,
      studentEmail: studentEmail,
      studentId: studentId,
      cohortName: cohortName,
      teacherName: teacherName,
      subject: subject,
      packageName: packageName,
      priceDzd: priceDzd,
      paymentMethod: paymentMethod,
      receiptName: receiptName,
      receiptBytes: receiptBytes,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
