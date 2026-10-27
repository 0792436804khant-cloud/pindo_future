import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/notifications/data/models/app_notification_model.dart';
import 'package:pindo_future_mobile/features/notifications/presentation/widgets/floating_live_alert_banner.dart';

void main() {
  group('Real-Time Notification & Live Alerts System Tests', () {
    final mockLiveNotification = AppNotificationModel(
      id: 99,
      type: 'live_session_started',
      title: '🔴 الحصة المباشرة بدأت الآن!',
      body: 'الأستاذ أحمد بلحاج بدأ البث المباشر لمادة الرياضيات.',
      data: {
        'session_id': 'SES-TEST-LIVE-123',
        'is_live': true,
      },
      isRead: false,
      createdAt: DateTime.now(),
      timeAgo: 'منذ دقيقة',
    );

    test('AppNotificationModel parses JSON and identifies live alerts', () {
      final json = {
        'id': 1,
        'type': 'live_session_started',
        'title': 'Test Live Title',
        'body': 'Test Live Body',
        'data': {'session_id': 'SES-XYZ'},
        'is_read': false,
        'created_at': '2026-10-27T20:00:00Z',
        'time_ago': 'الآن',
      };

      final model = AppNotificationModel.fromJson(json);

      expect(model.id, 1);
      expect(model.type, 'live_session_started');
      expect(model.isLiveClassAlert, isTrue);
      expect(model.sessionId, 'SES-XYZ');
      expect(model.isRead, isFalse);

      final backToJson = model.toJson();
      expect(backToJson['id'], 1);
      expect(backToJson['type'], 'live_session_started');
    });

    test('AppNotificationModel provides robust mock fallback list', () {
      final list = AppNotificationModel.mockFallbackList();
      expect(list.isNotEmpty, isTrue);
      expect(list.first.isLiveClassAlert, isTrue);
    });

    testWidgets('FloatingLiveAlertBanner renders live badge, title and buttons', (tester) async {
      bool joined = false;
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: FloatingLiveAlertBanner(
              notification: mockLiveNotification,
              onJoinLive: () => joined = true,
              onDismiss: () => dismissed = true,
            ),
          ),
        ),
      );

      // Verify content rendering
      expect(find.text('مباشر LIVE'), findsOneWidget);
      expect(find.text('🔴 الحصة المباشرة بدأت الآن!'), findsOneWidget);
      expect(find.text('الأستاذ أحمد بلحاج بدأ البث المباشر لمادة الرياضيات.'), findsOneWidget);
      expect(find.text('انضم الآن'), findsOneWidget);

      // Verify join live class callback
      await tester.tap(find.text('انضم الآن'));
      await tester.pump();
      expect(joined, isTrue);

      // Verify dismiss callback
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      expect(dismissed, isTrue);
    });
  });
}
