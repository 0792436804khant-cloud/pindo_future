import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/auth/domain/entities/user.dart';
import 'package:pindo_future_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pindo_future_mobile/features/auth/presentation/screens/dashboards/student_dashboard_screen.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/student_bottom_nav_bar.dart';

// Mock minimal AuthController for widget tests
class _MockAuthController extends ChangeNotifier implements AuthController {
  @override
  User? get currentUser => const User(
        id: 1,
        name: 'Ada Lovelace',
        email: 'ada@pindofuture.com',
        role: UserRole.student,
      );

  @override
  bool get isAuthenticated => true;

  @override
  bool get isAuthenticating => false;

  @override
  String? get errorMessage => null;

  @override
  AuthStatus get status => AuthStatus.authenticated;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Phase 9: Student Module 5-Tab Architecture Tests', () {
    test('StudentDashboardData DTO correctly falls back and parses mock payload', () {
      final fallback = StudentDashboardData.fallback('Ada Lovelace', 'ada@pindofuture.com');

      expect(fallback.student.name, 'Ada Lovelace');
      expect(fallback.student.email, 'ada@pindofuture.com');
      expect(fallback.nextSession, isNotNull);
      expect(fallback.nextSession!.sessionId, 'SES_8PP4LVG1');
      expect(fallback.subscriptions.remainingCredits, 4);
      expect(fallback.subscriptions.libraryAccess, isTrue);
      expect(fallback.todaySchedule.length, 2);
      expect(fallback.recentRecordings.isNotEmpty, isTrue);
      expect(fallback.attendance.attendanceRate, 96);
      expect(fallback.notifications.length, 3);
    });

    testWidgets('StudentBottomNavBar renders 5 primary tabs with Arabic labels', (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            bottomNavigationBar: StudentBottomNavBar(
              currentIndex: selectedTab,
              onTap: (idx) => selectedTab = idx,
              unreadNotificationsCount: 2,
            ),
          ),
        ),
      );

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('اكتشف'), findsOneWidget);
      expect(find.text('حصصي'), findsOneWidget);
      expect(find.text('مكتبتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Tap on Tab 1 (اكتشف)
      await tester.tap(find.text('اكتشف'));
      await tester.pump();
      expect(selectedTab, 1);

      // Tap on Tab 2 (حصصي)
      await tester.tap(find.text('حصصي'));
      await tester.pump();
      expect(selectedTab, 2);
    });

    testWidgets('StudentDashboardScreen renders 5 tabs and allows tab navigation', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockAuthController = _MockAuthController();
      const mockUser = User(
        id: 1,
        name: 'Ada Lovelace',
        email: 'ada@pindofuture.com',
        role: UserRole.student,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: StudentDashboardScreen(
            user: mockUser,
            authController: mockAuthController,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Header & Bottom Nav
      expect(find.byType(StudentBottomNavBar), findsOneWidget);
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('اكتشف'), findsOneWidget);
      expect(find.text('حصصي'), findsOneWidget);
      expect(find.text('مكتبتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Verify Tab 0 (Home): Welcome greeting & Next session hero card
      expect(find.textContaining('مرحباً، Ada'), findsOneWidget);
      expect(find.textContaining('الحصة'), findsWidgets);
      expect(find.text('اشتراكاتي ورصيدي'), findsOneWidget);

      // Switch to Tab 2 (حصصي)
      await tester.tap(find.text('حصصي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('حصصي والبرنامج الدراسي'), findsWidgets);

      // Switch to Tab 3 (مكتبتي)
      await tester.tap(find.text('مكتبتي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('مكتبتي'), findsWidgets);

      // Switch to Tab 4 (حسابي)
      await tester.tap(find.text('حسابي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('حسابي'), findsWidgets);
    });
  });
}
