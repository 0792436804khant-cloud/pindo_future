import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/monetization/domain/entities/checkout_intent_entity.dart';
import 'package:pindo_future_mobile/features/monetization/domain/entities/order_entity.dart';
import 'package:pindo_future_mobile/features/monetization/domain/entities/teacher_earnings_entity.dart';

void main() {
  group('Phase 7: Monetization & Checkout Entities Tests', () {
    test('OrderEntity parses JSON correctly and defaults to DZD', () {
      final json = {
        'id': 1,
        'order_number': 'ORD_20261012_A8F9K2',
        'receipt_number': 'RCP_7894561230',
        'amount': 4500.00,
        'currency': 'DZD',
        'status': 'completed',
        'card_brand': 'Visa',
        'card_last4': '4242',
        'paid_at': '2026-10-12T10:00:00Z',
        'course': {
          'id': 1,
          'title': 'Cryptography Masterclass',
          'teacher_name': 'Alan Turing',
        },
      };

      final order = OrderEntity.fromJson(json);

      expect(order.id, 1);
      expect(order.orderNumber, 'ORD_20261012_A8F9K2');
      expect(order.receiptNumber, 'RCP_7894561230');
      expect(order.amount, 4500.00);
      expect(order.currency, 'DZD');
      expect(order.cardBrand, 'Visa');
      expect(order.cardLast4, '4242');
      expect(order.paymentMethod, 'card');
      expect(order.courseTitle, 'Cryptography Masterclass');
      expect(order.teacherName, 'Alan Turing');
    });

    test('OrderEntity parses voucher payment method correctly', () {
      final json = {
        'id': 2,
        'order_number': 'ORD_20261012_VOUCH1',
        'receipt_number': 'RCP_VOUCH1234',
        'amount': 3000.00,
        'currency': 'DZD',
        'status': 'completed',
        'payment_method': 'activation_voucher',
        'card_brand': 'Voucher',
        'card_last4': 'PINDO2026',
        'paid_at': '2026-10-12T11:00:00Z',
        'course': {
          'id': 2,
          'title': 'High School Physics BAC',
          'teacher_name': 'Prof Ahmed',
        },
      };

      final order = OrderEntity.fromJson(json);

      expect(order.id, 2);
      expect(order.paymentMethod, 'activation_voucher');
      expect(order.amount, 3000.00);
      expect(order.currency, 'DZD');
      expect(order.courseTitle, 'High School Physics BAC');
    });

    test('CheckoutIntentEntity parses JSON correctly with DZD', () {
      final json = {
        'course': {
          'id': 101,
          'title': 'Full-Stack Distributed Streaming',
          'category': 'Computer Science',
          'is_free': false,
          'teacher': {'name': 'Alan Turing'},
        },
        'pricing': {
          'currency': 'DZD',
          'subtotal': 4500.00,
          'tax': 0.0,
          'total': 4500.00,
        },
        'already_enrolled': false,
      };

      final intent = CheckoutIntentEntity.fromJson(json);

      expect(intent.courseId, 101);
      expect(intent.courseTitle, 'Full-Stack Distributed Streaming');
      expect(intent.subtotal, 4500.00);
      expect(intent.total, 4500.00);
      expect(intent.currency, 'DZD');
      expect(intent.teacherName, 'Alan Turing');
      expect(intent.isFree, false);
      expect(intent.alreadyEnrolled, false);
    });

    test('TeacherEarningsSummaryEntity parses JSON correctly', () {
      final json = {
        'gross_sales': 9000.00,
        'platform_fees': 1800.00,
        'total_net_earned': 7200.00,
        'available_balance': 3600.00,
        'pending_payout': 3600.00,
        'paid_out': 0.0,
        'total_sales_count': 2,
        'revenue_split': '80% Instructor / 20% Platform',
      };

      final summary = TeacherEarningsSummaryEntity.fromJson(json);

      expect(summary.grossSales, 9000.00);
      expect(summary.platformFees, 1800.00);
      expect(summary.totalNetEarned, 7200.00);
      expect(summary.availableBalance, 3600.00);
      expect(summary.pendingPayout, 3600.00);
      expect(summary.totalSalesCount, 2);
    });

    test('TeacherTransactionEntity parses JSON correctly', () {
      final json = {
        'id': 1,
        'order_number': 'ORD_123',
        'course_id': 1,
        'course_title': 'Cryptography',
        'student_name': 'Ada Lovelace',
        'gross_amount': 4500.00,
        'platform_fee': 900.00,
        'net_amount': 3600.00,
        'status': 'available',
        'created_at': '2026-10-12T12:00:00Z',
      };

      final tx = TeacherTransactionEntity.fromJson(json);

      expect(tx.id, 1);
      expect(tx.orderNumber, 'ORD_123');
      expect(tx.studentName, 'Ada Lovelace');
      expect(tx.grossAmount, 4500.00);
      expect(tx.platformFee, 900.00);
      expect(tx.netAmount, 3600.00);
      expect(tx.status, 'available');
    });

    test('PayoutDisbursementEntity parses JSON correctly and defaults to DZD', () {
      final json = {
        'id': 5,
        'payout_reference': 'PO_20261013_4QNAXA',
        'amount': 2500.00,
        'currency': 'DZD',
        'status': 'requested',
        'payout_method': 'bank_transfer',
        'destination_account': 'DZ00 0002 9881 1224 5',
        'created_at': '2026-10-13T12:00:00Z',
      };

      final payout = PayoutDisbursementEntity.fromJson(json);

      expect(payout.id, 5);
      expect(payout.payoutReference, 'PO_20261013_4QNAXA');
      expect(payout.amount, 2500.00);
      expect(payout.currency, 'DZD');
      expect(payout.status, 'requested');
      expect(payout.payoutMethod, 'bank_transfer');
    });
  });
}
