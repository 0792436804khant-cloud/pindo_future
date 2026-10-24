import '../../../../core/network/api_client.dart';

abstract class MonetizationRemoteDataSource {
  Future<Map<String, dynamic>> fetchCheckoutIntent(String token, int courseId);

  Future<Map<String, dynamic>> submitCharge(
    String token,
    int courseId,
    Map<String, dynamic> body,
  );

  Future<List<dynamic>> fetchStudentOrders(String token);

  Future<Map<String, dynamic>> fetchTeacherEarnings(String token);

  Future<Map<String, dynamic>> submitPayoutRequest(
    String token,
    Map<String, dynamic> body,
  );

  Future<Map<String, dynamic>> redeemVoucher(
    String token,
    int courseId,
    String voucherCode,
  );
}

class MonetizationRemoteDataSourceImpl implements MonetizationRemoteDataSource {
  final ApiClient apiClient;

  MonetizationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> fetchCheckoutIntent(String token, int courseId) async {
    final response = await apiClient.get('/checkout/intent/$courseId', token: token);
    return (response['checkout'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<Map<String, dynamic>> submitCharge(
    String token,
    int courseId,
    Map<String, dynamic> body,
  ) async {
    final response = await apiClient.post(
      '/checkout/charge/$courseId',
      body: body,
      token: token,
    );
    return (response['receipt'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<List<dynamic>> fetchStudentOrders(String token) async {
    final response = await apiClient.get('/student/orders', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> fetchTeacherEarnings(String token) async {
    final response = await apiClient.get('/teacher/earnings', token: token);
    return response as Map<String, dynamic>? ?? {};
  }

  @override
  Future<Map<String, dynamic>> submitPayoutRequest(
    String token,
    Map<String, dynamic> body,
  ) async {
    final response = await apiClient.post(
      '/teacher/payouts/request',
      body: body,
      token: token,
    );
    return (response['payout'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<Map<String, dynamic>> redeemVoucher(
    String token,
    int courseId,
    String voucherCode,
  ) async {
    final response = await apiClient.post(
      '/checkout/voucher/$courseId',
      body: {'voucher_code': voucherCode},
      token: token,
    );
    return (response['receipt'] as Map<String, dynamic>?) ?? {};
  }
}
