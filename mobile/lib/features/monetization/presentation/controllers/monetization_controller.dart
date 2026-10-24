import 'package:flutter/foundation.dart';
import '../../domain/entities/checkout_intent_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/teacher_earnings_entity.dart';
import '../../domain/repositories/monetization_repository.dart';

class MonetizationController extends ChangeNotifier {
  final MonetizationRepository repository;
  final String authToken;

  MonetizationController({
    required this.repository,
    required this.authToken,
  });

  // Checkout State
  CheckoutIntentEntity? _currentIntent;
  OrderEntity? _lastCompletedOrder;
  bool _isProcessingPayment = false;
  String? _checkoutError;

  // Student Invoices State
  List<OrderEntity> _studentOrders = [];
  bool _isLoadingOrders = false;

  // Teacher Earnings State
  TeacherEarningsSummaryEntity? _earningsSummary;
  List<TeacherTransactionEntity> _transactions = [];
  List<PayoutDisbursementEntity> _payouts = [];
  bool _isLoadingEarnings = false;
  bool _isRequestingPayout = false;
  String? _earningsError;
  String? _payoutSuccessMessage;

  // Getters
  CheckoutIntentEntity? get currentIntent => _currentIntent;
  OrderEntity? get lastCompletedOrder => _lastCompletedOrder;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get checkoutError => _checkoutError;

  List<OrderEntity> get studentOrders => _studentOrders;
  bool get isLoadingOrders => _isLoadingOrders;

  TeacherEarningsSummaryEntity? get earningsSummary => _earningsSummary;
  List<TeacherTransactionEntity> get transactions => _transactions;
  List<PayoutDisbursementEntity> get payouts => _payouts;
  bool get isLoadingEarnings => _isLoadingEarnings;
  bool get isRequestingPayout => _isRequestingPayout;
  String? get earningsError => _earningsError;
  String? get payoutSuccessMessage => _payoutSuccessMessage;

  void clearErrors() {
    _checkoutError = null;
    _earningsError = null;
    _payoutSuccessMessage = null;
    notifyListeners();
  }

  /// Load checkout price intent for a course
  Future<void> loadCheckoutIntent(int courseId) async {
    _isProcessingPayment = true;
    _checkoutError = null;
    _lastCompletedOrder = null;
    notifyListeners();

    try {
      _currentIntent = await repository.getCheckoutIntent(authToken, courseId);
    } catch (e) {
      _checkoutError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  /// Process credit card payment & instant enrollment
  Future<bool> processCourseCheckout({
    required int courseId,
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvc,
    required String cardholderName,
  }) async {
    _isProcessingPayment = true;
    _checkoutError = null;
    notifyListeners();

    try {
      final order = await repository.processCharge(
        authToken,
        courseId,
        cardNumber: cardNumber.replaceAll(' ', ''),
        expMonth: expMonth,
        expYear: expYear,
        cvc: cvc,
        cardholderName: cardholderName,
      );
      _lastCompletedOrder = order;
      return true;
    } catch (e) {
      _checkoutError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  /// Redeem an Academic Voucher Code (School Card) for instant enrollment & session credits
  Future<bool> redeemCourseVoucher({
    required int courseId,
    required String voucherCode,
  }) async {
    _isProcessingPayment = true;
    _checkoutError = null;
    notifyListeners();

    try {
      final order = await repository.redeemVoucher(
        authToken,
        courseId,
        voucherCode: voucherCode.trim(),
      );
      _lastCompletedOrder = order;
      return true;
    } catch (e) {
      _checkoutError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  /// Load student order receipts & invoices
  Future<void> loadStudentOrders() async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      _studentOrders = await repository.getStudentOrders(authToken);
    } catch (e) {
      _checkoutError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Load instructor earnings dashboard
  Future<void> loadTeacherEarnings() async {
    _isLoadingEarnings = true;
    _earningsError = null;
    notifyListeners();

    try {
      final data = await repository.getTeacherEarnings(authToken);
      _earningsSummary = data['summary'] as TeacherEarningsSummaryEntity?;
      _transactions = (data['transactions'] as List<TeacherTransactionEntity>?) ?? [];
      _payouts = (data['payouts'] as List<PayoutDisbursementEntity>?) ?? [];
    } catch (e) {
      _earningsError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingEarnings = false;
      notifyListeners();
    }
  }

  /// Request instructor payout
  Future<bool> submitPayoutRequest({
    required double amount,
    required String destinationAccount,
    String? payoutMethod,
  }) async {
    _isRequestingPayout = true;
    _earningsError = null;
    _payoutSuccessMessage = null;
    notifyListeners();

    try {
      final payout = await repository.requestPayout(
        authToken,
        amount: amount,
        destinationAccount: destinationAccount,
        payoutMethod: payoutMethod,
      );
      _payoutSuccessMessage = 'Payout of \$${payout.amount} requested successfully (${payout.payoutReference})!';
      await loadTeacherEarnings();
      return true;
    } catch (e) {
      _earningsError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isRequestingPayout = false;
      notifyListeners();
    }
  }
}
