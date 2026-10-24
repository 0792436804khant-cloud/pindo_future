import '../entities/checkout_intent_entity.dart';
import '../entities/order_entity.dart';
import '../entities/teacher_earnings_entity.dart';

abstract class MonetizationRepository {
  Future<CheckoutIntentEntity> getCheckoutIntent(String token, int courseId);

  Future<OrderEntity> processCharge(
    String token,
    int courseId, {
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvc,
    required String cardholderName,
  });

  Future<List<OrderEntity>> getStudentOrders(String token);

  Future<Map<String, dynamic>> getTeacherEarnings(String token);

  Future<PayoutDisbursementEntity> requestPayout(
    String token, {
    required double amount,
    required String destinationAccount,
    String? payoutMethod,
  });

  Future<OrderEntity> redeemVoucher(
    String token,
    int courseId, {
    required String voucherCode,
  });
}
