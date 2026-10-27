import 'package:pindo_future_mobile/core/network/api_client.dart';
import 'package:pindo_future_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pindo_future_mobile/features/notifications/data/models/app_notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<AppNotificationModel>> getNotifications();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Future<int> broadcastSessionLive(String sessionId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient apiClient;
  final AuthLocalDataSource authLocalDataSource;

  NotificationRemoteDataSourceImpl({
    required this.apiClient,
    required this.authLocalDataSource,
  });

  @override
  Future<List<AppNotificationModel>> getNotifications() async {
    try {
      final token = await authLocalDataSource.getToken();
      final response = await apiClient.get('/notifications', token: token);

      if (response is Map<String, dynamic> && response['data'] is List) {
        final list = response['data'] as List;
        return list
            .map((item) => AppNotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return AppNotificationModel.mockFallbackList();
    } catch (_) {
      return AppNotificationModel.mockFallbackList();
    }
  }

  @override
  Future<void> markAsRead(int id) async {
    try {
      final token = await authLocalDataSource.getToken();
      await apiClient.post('/notifications/$id/read', body: {}, token: token);
    } catch (_) {}
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final token = await authLocalDataSource.getToken();
      await apiClient.post('/notifications/read-all', body: {}, token: token);
    } catch (_) {}
  }

  @override
  Future<int> broadcastSessionLive(String sessionId) async {
    try {
      final token = await authLocalDataSource.getToken();
      final response = await apiClient.post(
        '/sessions/$sessionId/notify-live',
        body: {},
        token: token,
      );
      if (response is Map<String, dynamic> && response['recipients_count'] is int) {
        return response['recipients_count'] as int;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }
}
