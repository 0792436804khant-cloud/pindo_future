import 'package:flutter/foundation.dart';

@immutable
class AppNotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final String timeAgo;

  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    required this.timeAgo,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'general',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : {},
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'].toString()) : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      timeAgo: json['time_ago'] as String? ?? 'الآن',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'time_ago': timeAgo,
    };
  }

  bool get isLiveClassAlert =>
      type == 'live_session_started' || type == 'live_session_starting';

  String? get sessionId => data['session_id'] as String?;

  static List<AppNotificationModel> mockFallbackList() {
    final now = DateTime.now();
    return [
      AppNotificationModel(
        id: 101,
        type: 'live_session_started',
        title: '🔴 الحصة المباشرة بدأت الآن!',
        body: 'الأستاذ أحمد بلحاج بدأ البث المباشر لحصة: مراجعة الدوال الأسية وحل التمارين النموذجية.',
        data: {
          'session_id': 'SES-MATH-BAC-2027',
          'teacher_name': 'الأستاذ أحمد بلحاج',
          'is_live': true,
          'priority': 'high',
        },
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 3)),
        timeAgo: 'منذ 3 دقائق',
      ),
      AppNotificationModel(
        id: 102,
        type: 'payment_confirmed',
        title: 'تم تأكيد اشتراكك بنجاح',
        body: 'تم استلام وتأكيد حوالة بريدي موب وتفعيل اشتراكك في فوج العلوم التجريبية.',
        data: {
          'cohort_id': 12,
          'amount': 4500,
        },
        isRead: true,
        readAt: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(hours: 2)),
        timeAgo: 'منذ ساعتين',
      ),
      AppNotificationModel(
        id: 103,
        type: 'recording_ready',
        title: 'تسجيل جديد متاح في مكتبتك',
        body: 'أصبح تسجيل درس «المتتاليات العددية بالتفصيل» متاحاً للمشاهدة الآمنة الآن.',
        data: {
          'recording_id': 45,
          'duration_minutes': 85,
        },
        isRead: true,
        readAt: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
        timeAgo: 'أمس',
      ),
    ];
  }
}
