import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pindo_future_mobile/core/config/platform_payment_config.dart';
import '../domain/entities/subscription_payment_receipt.dart';

/// Central reactive service managing subscription payment requests,
/// receipt uploads (BaridiMob, Edahabia, CCP), and teacher verification workflows.
class SubscriptionPaymentService {
  static final SubscriptionPaymentService instance = SubscriptionPaymentService._internal();

  factory SubscriptionPaymentService() => instance;

  final ValueNotifier<List<SubscriptionPaymentReceipt>> _receiptsNotifier =
      ValueNotifier<List<SubscriptionPaymentReceipt>>([]);

  ValueListenable<List<SubscriptionPaymentReceipt>> get receiptsListenable =>
      _receiptsNotifier;

  List<SubscriptionPaymentReceipt> get allReceipts =>
      List.unmodifiable(_receiptsNotifier.value);

  List<SubscriptionPaymentReceipt> get pendingReceipts =>
      _receiptsNotifier.value.where((r) => r.isPending).toList();

  List<SubscriptionPaymentReceipt> get approvedReceipts =>
      _receiptsNotifier.value.where((r) => r.isApproved).toList();

  /// Total Gross Revenue received from all approved subscriptions (in DZD)
  int get totalGrossRevenue =>
      approvedReceipts.fold(0, (sum, r) => sum + r.priceDzd);

  /// Total Net Earnings payable to teachers from approved subscriptions (in DZD)
  int get totalTeacherNetEarnings =>
      approvedReceipts.fold(0, (sum, r) => sum + r.teacherPayoutDzd);

  /// Total Platform Commission collected (15% live + 10% library) (in DZD)
  int get totalPlatformCommission =>
      approvedReceipts.fold(0, (sum, r) => sum + r.platformCommissionDzd);

  SubscriptionPaymentService._internal();

  void _initializeSeedData() {
    final now = DateTime.now();

    // 1x1 valid sample PNG bytes for receipt preview fallback
    final sampleReceiptBytes = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]);

    // Seed Receipts:
    // REC_001: 3,800 DZD (Live + Library) -> Teacher Net: 3,295 DZD, Platform: 505 DZD
    // REC_002: 2,500 DZD (Live Only) -> Teacher Net: 2,125 DZD, Platform: 375 DZD
    _receiptsNotifier.value = [
      SubscriptionPaymentReceipt(
        id: 'REC_001',
        referenceNumber: 'TRX-ALG-2026-9042',
        studentName: 'أحمد أمين قادري',
        studentEmail: 'student.amine@pindofuture.com',
        studentId: 'STU_0001_2026',
        cohortName: 'فوج النخبة للبكالوريا (شعبة علوم تجريبية ورياضي)',
        teacherName: 'الأستاذ محمد أمين بن عيسى',
        subject: 'الرياضيات',
        packageName: 'باقة الحصص والمكتبة الرقمية',
        priceDzd: 3800,
        teacherPayoutDzd: 3295,
        platformCommissionDzd: 505,
        paymentMethod: 'BaridiMob',
        receiptName: 'recu_baridimob_9042.jpg',
        receiptBytes: sampleReceiptBytes,
        status: ReceiptStatus.pending,
        submittedAt: now.subtract(const Duration(minutes: 25)),
      ),
      SubscriptionPaymentReceipt(
        id: 'REC_002',
        referenceNumber: 'TRX-ALG-2026-8711',
        studentName: 'ياسمين بوعلام',
        studentEmail: 'yasmine.b@pindofuture.com',
        studentId: 'STU_0045_2026',
        cohortName: 'فوج النخبة للبكالوريا',
        teacherName: 'الأستاذ محمد أمين بن عيسى',
        subject: 'الرياضيات',
        packageName: 'باقة الحصص فقط',
        priceDzd: 2500,
        teacherPayoutDzd: 2125,
        platformCommissionDzd: 375,
        paymentMethod: 'Edahabia',
        receiptName: 'cib_satim_8711.pdf',
        receiptBytes: sampleReceiptBytes,
        status: ReceiptStatus.approved,
        submittedAt: now.subtract(const Duration(hours: 3)),
        reviewedAt: now.subtract(const Duration(hours: 2, minutes: 45)),
      ),
    ];
  }

  /// Student submits a new payment receipt for teacher review
  SubscriptionPaymentReceipt submitReceipt({
    required String cohortName,
    required String teacherName,
    required String subject,
    required String packageName,
    required int priceDzd,
    required String paymentMethod,
    String? receiptName,
    Uint8List? receiptBytes,
    String studentName = 'أحمد أمين قادري',
    String studentEmail = 'student.amine@pindofuture.com',
    String studentId = 'STU_0001_2026',
  }) {
    final now = DateTime.now();
    final ref = 'TRX-ALG-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}';

    final breakdown = PlatformPaymentConfig.calculateCommission(
      totalPriceDzd: priceDzd,
      packageName: packageName,
    );

    final receipt = SubscriptionPaymentReceipt(
      id: 'REC_${now.millisecondsSinceEpoch}',
      referenceNumber: ref,
      studentName: studentName,
      studentEmail: studentEmail,
      studentId: studentId,
      cohortName: cohortName,
      teacherName: teacherName,
      subject: subject,
      packageName: packageName,
      priceDzd: priceDzd,
      teacherPayoutDzd: breakdown.teacherPayoutDzd,
      platformCommissionDzd: breakdown.platformCommissionDzd,
      paymentMethod: paymentMethod,
      receiptName: receiptName ?? 'receipt_${now.millisecondsSinceEpoch}.jpg',
      receiptBytes: receiptBytes,
      status: ReceiptStatus.pending,
      submittedAt: now,
    );

    _receiptsNotifier.value = [receipt, ..._receiptsNotifier.value];
    debugPrint('[SubscriptionPaymentService] 💳 Receipt submitted: $ref for $studentName ($priceDzd DZD -> Teacher Net: ${breakdown.teacherPayoutDzd} DZD, Platform: ${breakdown.platformCommissionDzd} DZD)');
    return receipt;
  }

  /// Teacher approves the receipt and activates the student's subscription
  bool approveReceipt(String id) {
    final index = _receiptsNotifier.value.indexWhere((r) => r.id == id);
    if (index == -1) return false;

    final existing = _receiptsNotifier.value[index];
    final updated = existing.copyWith(
      status: ReceiptStatus.approved,
      reviewedAt: DateTime.now(),
    );

    final list = List<SubscriptionPaymentReceipt>.from(_receiptsNotifier.value);
    list[index] = updated;
    _receiptsNotifier.value = list;

    debugPrint('[SubscriptionPaymentService] ✅ Receipt APPROVED: ${updated.referenceNumber} for ${updated.studentName}');
    return true;
  }

  /// Teacher rejects the receipt with an explanatory reason
  bool rejectReceipt(String id, String reason) {
    final index = _receiptsNotifier.value.indexWhere((r) => r.id == id);
    if (index == -1) return false;

    final existing = _receiptsNotifier.value[index];
    final updated = existing.copyWith(
      status: ReceiptStatus.rejected,
      rejectionReason: reason.isNotEmpty ? reason : 'الوصل غير واضح أو المبلغ غير مطابق.',
      reviewedAt: DateTime.now(),
    );

    final list = List<SubscriptionPaymentReceipt>.from(_receiptsNotifier.value);
    list[index] = updated;
    _receiptsNotifier.value = list;

    debugPrint('[SubscriptionPaymentService] ❌ Receipt REJECTED: ${updated.referenceNumber}. Reason: $reason');
    return true;
  }

  @visibleForTesting
  void resetForTesting() {
    _initializeSeedData();
  }
}
