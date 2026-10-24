import '../../domain/entities/checkout_intent_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/teacher_earnings_entity.dart';
import '../../domain/repositories/monetization_repository.dart';
import '../datasources/monetization_remote_datasource.dart';

class MonetizationRepositoryImpl implements MonetizationRepository {
  final MonetizationRemoteDataSource remoteDataSource;

  MonetizationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CheckoutIntentEntity> getCheckoutIntent(String token, int courseId) async {
    final raw = await remoteDataSource.fetchCheckoutIntent(token, courseId);
    return CheckoutIntentEntity.fromJson(raw);
  }

  @override
  Future<OrderEntity> processCharge(
    String token,
    int courseId, {
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvc,
    required String cardholderName,
  }) async {
    final body = {
      'card_number': cardNumber,
      'exp_month': expMonth,
      'exp_year': expYear,
      'cvc': cvc,
      'cardholder_name': cardholderName,
    };

    final raw = await remoteDataSource.submitCharge(token, courseId, body);
    return OrderEntity.fromJson(raw);
  }

  @override
  Future<List<OrderEntity>> getStudentOrders(String token) async {
    final raw = await remoteDataSource.fetchStudentOrders(token);
    return raw
        .map((item) => OrderEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getTeacherEarnings(String token) async {
    final raw = await remoteDataSource.fetchTeacherEarnings(token);
    final summaryRaw = raw['summary'] as Map<String, dynamic>? ?? {};
    final transactionsRaw = (raw['transactions'] as List<dynamic>?) ?? [];
    final payoutsRaw = (raw['payouts'] as List<dynamic>?) ?? [];

    final summary = TeacherEarningsSummaryEntity.fromJson(summaryRaw);
    final transactions = transactionsRaw
        .map((t) => TeacherTransactionEntity.fromJson(t as Map<String, dynamic>))
        .toList();
    final payouts = payoutsRaw
        .map((p) => PayoutDisbursementEntity.fromJson(p as Map<String, dynamic>))
        .toList();

    return {
      'summary': summary,
      'transactions': transactions,
      'payouts': payouts,
    };
  }

  @override
  Future<PayoutDisbursementEntity> requestPayout(
    String token, {
    required double amount,
    required String destinationAccount,
    String? payoutMethod,
  }) async {
    final body = {
      'amount': amount,
      'destination_account': destinationAccount,
      if (payoutMethod != null) 'payout_method': payoutMethod,
    };

    final raw = await remoteDataSource.submitPayoutRequest(token, body);
    return PayoutDisbursementEntity.fromJson(raw);
  }

  @override
  Future<OrderEntity> redeemVoucher(
    String token,
    int courseId, {
    required String voucherCode,
  }) async {
    final receipt = await remoteDataSource.redeemVoucher(token, courseId, voucherCode);
    return OrderEntity.fromJson(receipt);
  }
}
