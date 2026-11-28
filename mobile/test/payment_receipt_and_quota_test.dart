import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pindo_future_mobile/features/cohorts/data/models/study_cohort_model.dart';
import 'package:pindo_future_mobile/features/monetization/services/subscription_payment_service.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/algerian_payment_sheet_modal.dart';

void main() {
  group('Real Receipt Upload & Validation', () {
    test('uploadCohortReceipt throws explicit error when receiptBytes are empty or null', () async {
      await expectLater(
        SubscriptionPaymentService.instance.uploadCohortReceipt(
          cohortId: 12,
          receiptBytes: null,
          receiptFilename: 'empty.jpg',
          paymentMethod: 'BaridiMob',
          cohortName: 'فوج الفيزياء',
          teacherName: 'الأستاذ مهدي',
          subject: 'الفيزياء',
          packageName: 'الباقة المتكاملة',
          priceDzd: 3500,
          token: 'fake-token',
        ),
        throwsException,
      );

      await expectLater(
        SubscriptionPaymentService.instance.uploadCohortReceipt(
          cohortId: 12,
          receiptBytes: Uint8List(0),
          receiptFilename: 'empty.jpg',
          paymentMethod: 'BaridiMob',
          cohortName: 'فوج الفيزياء',
          teacherName: 'الأستاذ مهدي',
          subject: 'الفيزياء',
          packageName: 'الباقة المتكاملة',
          priceDzd: 3500,
          token: 'fake-token',
        ),
        throwsException,
      );
    });

    test('uploadCohortReceipt sends multipart request and fails cleanly on HTTP error', () async {
      final samplePng = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

      final successClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, endsWith('/student/cohorts/55/subscribe-receipt'));
        expect(request.headers['Authorization'], 'Bearer student-sanctum-token');

        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': {
              'order_id': 901,
              'order_number': 'ORD_20261128_TEST01',
              'receipt_number': 'RCP_TEST01',
              'status': 'pending',
              'amount': 3500,
            },
          }),
          201,
        );
      });

      final res = await SubscriptionPaymentService.instance.uploadCohortReceipt(
        cohortId: 55,
        receiptBytes: samplePng,
        receiptFilename: 'real_receipt.png',
        paymentMethod: 'BaridiMob',
        cohortName: 'فوج 1',
        teacherName: 'أستاذ مهدي',
        subject: 'الفيزياء',
        packageName: 'الباقة المتكاملة',
        priceDzd: 3500,
        token: 'student-sanctum-token',
        studentName: 'ياسين',
        client: successClient,
      );

      expect(res['order_number'], 'ORD_20261128_TEST01');
      expect(res['status'], 'pending');

      final failClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(jsonEncode({'status': 'error', 'message': 'ملف الوصل غير صالح'})),
          422,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      await expectLater(
        SubscriptionPaymentService.instance.uploadCohortReceipt(
          cohortId: 55,
          receiptBytes: samplePng,
          receiptFilename: 'bad.png',
          paymentMethod: 'BaridiMob',
          cohortName: 'فوج 1',
          teacherName: 'أستاذ مهدي',
          subject: 'الفيزياء',
          packageName: 'الباقة المتكاملة',
          priceDzd: 3500,
          token: 'student-sanctum-token',
          client: failClient,
        ),
        throwsException,
      );
    });
  });

  group('StudyCohortModel Session Quotas & Extra Sessions', () {
    test('parses included_sessions_count and extra session pricing accurately', () {
      final model = StudyCohortModel.fromJson({
        'id': 7,
        'cohort_code': 'COHORT_ABC',
        'teacher_id': 3,
        'name': 'فوج البكالوريا',
        'subject': 'الرياضيات',
        'academic_level': '3AS',
        'included_sessions_count': 12,
        'extra_sessions_count': 3,
        'extra_sessions_is_paid': true,
        'extra_session_price_dzd': 750,
      });

      expect(model.includedSessionsCount, 12);
      expect(model.extraSessionsCount, 3);
      expect(model.extraSessionsIsPaid, true);
      expect(model.extraSessionPriceDzd, 750.0);
    });
  });

  group('AlgerianPaymentSheetModal UI & Anti-Fake Guard', () {
    testWidgets('blocks submission without attached receipt and shows honest CIB/SATIM notice', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AlgerianPaymentSheetModal.show(
                  context,
                  cohortId: 10,
                  cohortName: 'فوج 1',
                  teacherName: 'mehdi zennir',
                  subject: 'الفيزياء',
                  packageName: 'الباقة المتكاملة',
                  priceDzd: 3500,
                  includedSessionsCount: 8,
                ),
                child: const Text('فتح الدفع'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('فتح الدفع'));
      await tester.pumpAndSettle();

      // Confirm session quota range is displayed
      expect(find.textContaining('من الحصة 1 إلى الحصة 8'), findsOneWidget);

      // Tapping submit without any receipt must NOT succeed or open success dialog
      final submitBtnFinder = find.text('أرفق صورة الوصل الحقيقي أولاً');
      await tester.ensureVisible(submitBtnFinder);
      await tester.tap(submitBtnFinder);
      await tester.pumpAndSettle();
      expect(find.text('تم رفع الوصل وإرسال الطلب بنجاح'), findsNothing);
      expect(find.textContaining('يرجى تصوير أو اختيار ملف وصل الدفع الحقيقي'), findsOneWidget);

      // Switching to CIB / Edahabia must show honest SATIM/Chargily requirement notice (no fake card charge)
      final cibFinder = find.textContaining('CIB');
      await tester.ensureVisible(cibFinder);
      await tester.tap(cibFinder);
      await tester.pumpAndSettle();
      expect(find.textContaining('SATIM'), findsOneWidget);
      expect(find.text('رقم البطاقة الذهبية (16 رقماً)'), findsNothing);
    });
  });
}
