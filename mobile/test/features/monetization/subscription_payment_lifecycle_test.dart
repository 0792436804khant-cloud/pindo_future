import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/core/config/platform_payment_config.dart';
import 'package:pindo_future_mobile/features/monetization/domain/entities/subscription_payment_receipt.dart';
import 'package:pindo_future_mobile/features/monetization/services/subscription_payment_service.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/algerian_payment_sheet_modal.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/tabs/student_subscriptions_tab.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/modals/verify_payment_receipt_modal.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_finance_tab.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Subscription Payment Lifecycle Tests', () {
    late SubscriptionPaymentService service;

    setUp(() {
      service = SubscriptionPaymentService.instance;
      service.resetForTesting();
    });

    test('SubscriptionPaymentService initializes with pending and approved receipts', () {
      expect(service.allReceipts.length, greaterThanOrEqualTo(2));
      expect(service.pendingReceipts.length, equals(1));
      expect(service.approvedReceipts.length, equals(1));
    });

    test('Student submitting a receipt creates a pending transaction with unique reference', () {
      final initialPendingCount = service.pendingReceipts.length;

      final receipt = service.submitReceipt(
        cohortName: 'فوج النخبة للرياضيات',
        teacherName: 'الأستاذ بن عيسى',
        subject: 'الرياضيات',
        packageName: 'باقة الحصص فقط',
        priceDzd: 2500,
        paymentMethod: 'BaridiMob',
        receiptName: 'recu_baridimob_test.jpg',
        studentName: 'بلقاسم نذير',
        studentEmail: 'nadir@pindofuture.com',
        studentId: 'STU_0099_2026',
      );

      expect(receipt.id, startsWith('REC_'));
      expect(receipt.referenceNumber, startsWith('TRX-ALG-'));
      expect(receipt.status, equals(ReceiptStatus.pending));
      expect(receipt.priceDzd, equals(2500));
      expect(service.pendingReceipts.length, equals(initialPendingCount + 1));
    });

    test('Teacher approving a receipt marks it approved and updates timestamps', () {
      final pending = service.pendingReceipts.first;
      expect(pending.isPending, isTrue);

      final success = service.approveReceipt(pending.id);
      expect(success, isTrue);

      final updated = service.allReceipts.firstWhere((r) => r.id == pending.id);
      expect(updated.isApproved, isTrue);
      expect(updated.reviewedAt, isNotNull);
      expect(service.pendingReceipts.any((r) => r.id == pending.id), isFalse);
    });

    test('Teacher rejecting a receipt records the explanatory rejection reason', () {
      final receipt = service.submitReceipt(
        cohortName: 'فوج العلوم الفيزيائية',
        teacherName: 'الأستاذة بلقاسم',
        subject: 'الفيزياء',
        packageName: 'باقة الحصص والمكتبة',
        priceDzd: 3800,
        paymentMethod: 'CCP',
        studentName: 'فاروق مروان',
      );

      final success = service.rejectReceipt(receipt.id, 'صورة الوصل غير واضحة ومبتورة.');
      expect(success, isTrue);

      final updated = service.allReceipts.firstWhere((r) => r.id == receipt.id);
      expect(updated.isRejected, isTrue);
      expect(updated.rejectionReason, equals('صورة الوصل غير واضحة ومبتورة.'));
    });

    testWidgets('VerifyPaymentReceiptModal displays receipt details and approves successfully', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final receipt = service.pendingReceipts.first;
      bool statusChanged = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  VerifyPaymentReceiptModal.show(
                    ctx,
                    receipt: receipt,
                    onStatusChanged: () {
                      statusChanged = true;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      // Open Modal
      await tester.tap(find.text('Open Modal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('فحص وتأكيد وصل الدفع'), findsOneWidget);
      expect(find.textContaining(receipt.studentName), findsWidgets);
      expect(find.textContaining('${receipt.priceDzd} دج'), findsWidgets);
      expect(find.textContaining(receipt.referenceNumber), findsWidgets);
      expect(find.textContaining('تأكيد الدفع وتفعيل الاشتراك فوراً'), findsOneWidget);

      // Tap Approve Button
      await tester.tap(find.textContaining('تأكيد الدفع وتفعيل الاشتراك فوراً'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(statusChanged, isTrue);
      expect(service.allReceipts.firstWhere((r) => r.id == receipt.id).isApproved, isTrue);
    });

    testWidgets('TeacherFinanceTab renders pending receipts alert banner', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fallback = TeacherDashboardModel.mockFallback();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeacherFinanceTab(
              dashboard: fallback,
              onOpenDetailedEarnings: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Alert banner should exist because service starts with 1 pending receipt
      expect(find.textContaining('وصلات جديدة بانتظار التأكيد'), findsOneWidget);
      expect(find.textContaining('فحص وتفعيل'), findsOneWidget);
    });

    testWidgets('StudentSubscriptionsTab dynamically renders pending receipt banner and history items', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final studentDashboard = StudentDashboardData.fallback('أحمد أمين', 'amine@pindofuture.com');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentSubscriptionsTab(
              dashboardData: studentDashboard,
              onOpenCohortsExplorer: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Pending receipt alert banner is displayed
      expect(find.textContaining('طلب اشتراك قيد المراجعة'), findsOneWidget);
      expect(find.textContaining('TRX-ALG-2026-9042'), findsWidgets);

      // Verify payment history shows existing receipts
      expect(find.textContaining('TRX-ALG-2026-8711'), findsWidgets);
    });

    test('PlatformPaymentConfig computes exact 15% live and 10% library commission', () {
      // 1. Live Only: 2,500 DZD -> 15% platform cut (375 DZD), teacher gets 2,125 DZD
      final liveOnly = PlatformPaymentConfig.calculateCommission(
        totalPriceDzd: 2500,
        packageName: 'باقة الحصص فقط',
      );
      expect(liveOnly.grossPriceDzd, equals(2500));
      expect(liveOnly.platformCommissionDzd, equals(375));
      expect(liveOnly.teacherPayoutDzd, equals(2125));
      expect(liveOnly.isLibraryIncluded, isFalse);

      // 2. Live + Library: 3,800 DZD (2500 live + 1300 library)
      // 15% on 2500 = 375 DZD, 10% on 1300 = 130 DZD -> Total platform: 505 DZD, teacher gets 3,295 DZD
      final liveAndLibrary = PlatformPaymentConfig.calculateCommission(
        totalPriceDzd: 3800,
        packageName: 'باقة الحصص والمكتبة الرقمية',
      );
      expect(liveAndLibrary.grossPriceDzd, equals(3800));
      expect(liveAndLibrary.platformCommissionDzd, equals(505));
      expect(liveAndLibrary.teacherPayoutDzd, equals(3295));
      expect(liveAndLibrary.isLibraryIncluded, isTrue);
    });

    testWidgets('VerifyPaymentReceiptModal shows net teacher earnings and conceals platform commission', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final receipt = service.pendingReceipts.first;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => VerifyPaymentReceiptModal.show(ctx, receipt: receipt),
                child: const Text('Open Verify Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Verify Modal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Shows package price and teacher's net earnings
      expect(find.textContaining('سعر الباقة'), findsOneWidget);
      expect(find.textContaining('${receipt.priceDzd} دج'), findsWidgets);
      expect(find.textContaining('مستحقاتك المحتسبة'), findsOneWidget);
      expect(find.textContaining('+${receipt.teacherPayoutDzd} دج'), findsWidgets);

      // CRITICAL: Must NEVER show platform commission or deduction to teacher
      expect(find.textContaining('عمولة المنصة'), findsNothing);
      expect(find.textContaining('اقتطاع'), findsNothing);
    });

    testWidgets('AlgerianPaymentSheetModal displays official RIP and platform account holder name', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => AlgerianPaymentSheetModal.show(
                  ctx,
                  cohortName: 'فوج النخبة للبكالوريا',
                  teacherName: 'الأستاذ بن عيسى',
                  subject: 'الرياضيات',
                  packageName: 'باقة الحصص فقط',
                  priceDzd: 2500,
                ),
                child: const Text('Open Payment Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Payment Sheet'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check RIP and Holder name are displayed
      expect(find.textContaining(PlatformPaymentConfig.formattedRip), findsOneWidget);
      expect(find.textContaining(PlatformPaymentConfig.accountHolderName), findsWidgets);
    });
  });
}
