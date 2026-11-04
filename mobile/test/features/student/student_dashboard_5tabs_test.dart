import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/auth/domain/entities/user.dart';
import 'package:pindo_future_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pindo_future_mobile/features/auth/presentation/screens/dashboards/student_dashboard_screen.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/student_bottom_nav_bar.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/subscription_package_modal.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/algerian_payment_sheet_modal.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/views/cohort_session_history_view.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/tabs/student_my_account_tab.dart';

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
  group('Student Experience 3 Pillars Architecture Tests', () {
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
      expect(find.text('حصصي'), findsOneWidget);
      expect(find.text('الاشتراكات'), findsOneWidget);
      expect(find.text('مكتبتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Tap on Tab 1 (حصصي)
      await tester.tap(find.text('حصصي'));
      await tester.pump();
      expect(selectedTab, 1);

      // Tap on Tab 2 (الاشتراكات)
      await tester.tap(find.text('الاشتراكات'));
      await tester.pump();
      expect(selectedTab, 2);
    });

    testWidgets('StudentDashboardScreen renders 5 tabs and allows tab navigation across the 3 pillars', (tester) async {
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
      expect(find.text('حصصي'), findsOneWidget);
      expect(find.text('الاشتراكات'), findsOneWidget);
      expect(find.text('مكتبتي'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      // Verify Pillar 3 on Tab 0 (Home):
      // - Teacher Stories Tray
      expect(find.textContaining('قصص ومستجدات الأساتذة'), findsOneWidget);
      // - Quick Live Join Bar
      expect(find.textContaining('الانضمام السريع لحصة تفاعلية مباشرة'), findsOneWidget);
      // - Smart Teacher Search Bar
      expect(find.textContaining('البحث عن الأساتذة والمواد الدراسية'), findsOneWidget);
      // - Educational Cycles Promotional Banner
      expect(find.textContaining('الطور'), findsWidgets);
      // - Today's Master Schedule with Alarms
      expect(find.textContaining('جدول اليوم والرزنامة الأساسية'), findsOneWidget);

      // Switch to Pillar 2 (حصصي والدروس واللايف)
      await tester.tap(find.text('حصصي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('حصصي والدروس المباشرة'), findsWidgets);
      expect(find.textContaining('محادثة الفوج'), findsWidgets);
      expect(find.textContaining('جدول الحصص الكامل وتفاصيل الاشتراكات'), findsWidgets);

      // Switch to Pillar 1 (واجهة الاشتراكات والدفع)
      await tester.tap(find.text('الاشتراكات'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('اشتراكاتي وباقات الدفع'), findsWidgets);
      expect(find.textContaining('دفع الاشتراك / تغيير الباقة'), findsWidgets);
      expect(find.textContaining('تجديد الاشتراك ⚡'), findsWidgets);

      // Switch to Tab 3 (مكتبتي)
      await tester.tap(find.text('مكتبتي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('مكتبتي'), findsWidgets);

      // Switch to Tab 4 (حسابي)
      await tester.tap(find.text('حسابي'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('الملف الشخصي وحسابي'), findsWidgets);
      expect(find.textContaining('جواز التعلّم وإحصائيات المواظبة'), findsOneWidget);
      expect(find.textContaining('أمان الحساب وحماية المحتوى الرقمي'), findsOneWidget);
      expect(find.textContaining('تفضيلات التنبيهات والإشعارات الذكية'), findsOneWidget);
    });

    testWidgets('Pillar 1: SubscriptionPackageModal and AlgerianPaymentSheetModal open smoothly', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Column(
                children: [
                  ElevatedButton(
                    onPressed: () => SubscriptionPackageModal.show(
                      ctx,
                      cohortName: 'فوج النخبة للبكالوريا',
                      teacherName: 'الأستاذ بن عيسى',
                      subject: 'الرياضيات',
                      currentPackageName: 'باقة الحصص فقط',
                    ),
                    child: const Text('Open Package Modal'),
                  ),
                  ElevatedButton(
                    onPressed: () => AlgerianPaymentSheetModal.show(
                      ctx,
                      cohortName: 'فوج النخبة للبكالوريا',
                      teacherName: 'الأستاذ بن عيسى',
                      subject: 'الرياضيات',
                      packageName: 'باقة الحصص فقط',
                      priceDzd: 2500,
                      isQuickRenewal: true,
                    ),
                    child: const Text('Open Payment Modal'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Open Package Modal
      await tester.tap(find.text('Open Package Modal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('اختر باقة الاشتراك المناسبة'), findsOneWidget);
      expect(find.textContaining('باقة الحصص فقط'), findsWidgets);
      expect(find.textContaining('باقة الحصص والمكتبة'), findsWidgets);

      // Close modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Open Payment Modal
      await tester.tap(find.text('Open Payment Modal'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('تجديد الاشتراك الفوري'), findsOneWidget);
      expect(find.textContaining('بريدي موب (BaridiMob)'), findsWidgets);
      expect(find.textContaining('البطاقة الذهبية / CIB'), findsWidgets);
      expect(find.textContaining('حوالة CCP'), findsWidgets);
    });

    testWidgets('Pillar 2: CohortSessionHistoryView displays chronological session table from day 1', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CohortSessionHistoryView(
              cohortId: 'SES_8PP4LVG1',
              cohortName: 'فوج النخبة للبكالوريا — الرياضيات',
              teacherName: 'الأستاذ محمد أمين بن عيسى',
              subject: 'الرياضيات',
              studentName: 'أحمد أمين',
              studentEmail: 'student.amine@pindofuture.com',
              initialEnrollmentDate: '01 سبتمبر 2026',
              remainingCredits: 4,
              onJoinLiveClassroom: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('فوج النخبة للبكالوريا'), findsWidgets);
      expect(find.textContaining('تاريخ أول اشتراك:'), findsOneWidget);
      expect(find.textContaining('01 سبتمبر 2026'), findsOneWidget);
      expect(find.textContaining('جدول الحصص التاريخي الكامل'), findsOneWidget);
      expect(find.textContaining('الحصة #1'), findsWidgets);
      expect(find.textContaining('الحصة #9'), findsWidgets);
      expect(find.textContaining('محادثة الفوج 💬'), findsWidgets);
    });

    testWidgets('StudentMyAccountTab allows setting photo de profil and toggling preferences', (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fallback = StudentDashboardData.fallback('أحمد أمين', 'student.amine@pindofuture.com');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentMyAccountTab(
              dashboardData: fallback,
              onOpenAccountSettings: () {},
              onLogout: () {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('الملف الشخصي وحسابي'), findsOneWidget);
      expect(find.textContaining('جواز التعلّم وإحصائيات المواظبة'), findsOneWidget);
      expect(find.textContaining('أمان الحساب وحماية المحتوى الرقمي'), findsOneWidget);
      expect(find.textContaining('تفضيلات التنبيهات والإشعارات الذكية'), findsOneWidget);

      // Tap on the camera icon to open photo de profil options
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('صورة الملف الشخصي (Photo de profil)'), findsOneWidget);
      expect(find.textContaining('التقاط صورة جديدة بالكاميرا'), findsOneWidget);
      expect(find.textContaining('اختيار صورة من معرض الصور'), findsOneWidget);

      // Choose camera photo
      await tester.tap(find.textContaining('التقاط صورة جديدة بالكاميرا'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify toggle switch exists and can be tapped
      final switchFinder = find.byType(Switch).first;
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pump();
    });
  });
}
