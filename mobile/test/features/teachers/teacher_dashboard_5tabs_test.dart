import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/teacher_bottom_nav_bar.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_home_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_groups_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_schedule_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_finance_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_account_tab.dart';

void main() {
  group('Teacher Dashboard 5-Tab Architecture Tests', () {
    final mockDashboard = TeacherDashboardModel.mockFallback();

    testWidgets('TeacherBottomNavBar renders all 5 tabs and responds to selection', (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            bottomNavigationBar: StatefulBuilder(
              builder: (context, setState) {
                return TeacherBottomNavBar(
                  currentIndex: selectedTab,
                  onTabSelected: (idx) {
                    setState(() => selectedTab = idx);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('أفواجي'), findsOneWidget);
      expect(find.text('الجدول'), findsOneWidget);
      expect(find.text('المداخيل'), findsOneWidget);
      expect(find.text('حسابي'), findsOneWidget);

      await tester.tap(find.text('أفواجي'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(selectedTab, 1);
    });

    testWidgets('TeacherHomeTab renders quick KPI stats and upcoming session', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: TeacherHomeTab(
              dashboard: mockDashboard,
              onStartLiveSession: () {},
              onNavigateToTab: (_) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('مرحباً'), findsOneWidget);
      expect(find.text('📊 الإحصائيات العامة للمنصة'), findsOneWidget);
      expect(find.text('إجمالي الطلاب'), findsOneWidget);
      expect(find.text('الأفواج النشطة'), findsOneWidget);
      expect(find.text('ابدأ البث المباشر الآن'), findsOneWidget);
    });

    testWidgets('TeacherGroupsTab renders cohort cards and Excel attendance button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: TeacherGroupsTab(
              cohorts: mockDashboard.cohorts,
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('👥 إدارة الأفواج الدراسية'), findsOneWidget);
      expect(find.text('فوج جديد'), findsOneWidget);
      expect(find.text('جدول الحضور Excel'), findsWidgets);
    });

    testWidgets('TeacherFinanceTab renders net earnings and subscription packages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: TeacherFinanceTab(
              dashboard: mockDashboard,
              onOpenDetailedEarnings: () {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('💰 إدارة المداخيل والاشتراكات'), findsOneWidget);
      expect(find.text('صافي المستحقات المتاحة'), findsOneWidget);
      expect(find.text('باقة دروس فقط'), findsOneWidget);
      expect(find.text('دروس + مكتبة'), findsOneWidget);
    });

    testWidgets('TeacherAccountTab renders profile info and deep link sharing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: TeacherAccountTab(
              dashboard: mockDashboard,
              onEditProfile: () {},
              onOpenAccountSettings: () {},
              onSignOut: () {},
              onPreviewShowcase: () {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('👤 حساب الأستاذ والمنصات'), findsOneWidget);
      expect(find.text('الرابط الذكي لموقعك وعروضك الخارجية'), findsOneWidget);
      expect(find.text('تعديل الملف والشهادات'), findsOneWidget);
      expect(find.text('تسجيل الخروج'), findsOneWidget);

      // Verify Stories System
      expect(find.text('السطوريات والتحديثات الحية (Stories)'), findsOneWidget);
      expect(find.text('ستوري جديدة'), findsOneWidget);
      expect(find.text('نشر ستوري'), findsOneWidget);

      // Verify Workplaces Section
      expect(find.text('🏢 أماكن العمل والمراكز التعليمية'), findsOneWidget);
      expect(find.text('ثانوية حسيبة بن بوعلي — القبة'), findsOneWidget);
      expect(find.text('أكاديمية النجاح لدروس الدعم والتفوق'), findsOneWidget);

      // Verify Cohorts Schedule & Timings Section
      expect(find.text('📅 مواقيت وأجندة الأفواج الدراسية'), findsOneWidget);
      expect(find.text('فوج النخبة للبكالوريا (شعبة علوم تجريبية ورياضي)'), findsOneWidget);
      expect(find.textContaining('3500 دج'), findsOneWidget);

      // Verify Students' BAC Marks Hall of Fame Section
      expect(find.text('🏆 لوحة الشرف ونقاط المتفوقين في البكالوريا'), findsOneWidget);
      expect(find.text('سارة مهدي'), findsOneWidget);
      expect(find.text('19.5'), findsOneWidget);
      expect(find.text('كريم بلقاسم'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);

      // Verify Social Channels
      expect(find.text('فيسبوك'), findsOneWidget);
      expect(find.text('تيليغرام'), findsOneWidget);
      expect(find.text('يوتيوب'), findsOneWidget);
    });

    testWidgets('Tapping a story opens the interactive TeacherStoryViewerModal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: TeacherAccountTab(
              dashboard: mockDashboard,
              onEditProfile: () {},
              onOpenAccountSettings: () {},
              onSignOut: () {},
              onPreviewShowcase: () {},
            ),
          ),
        ),
      );

      // Scroll to story if needed and tap
      await tester.ensureVisible(find.byIcon(Icons.sensors_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byIcon(Icons.sensors_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify story modal elements
      expect(find.text('🔴 بث مباشر اليوم'), findsAtLeastNWidgets(1));
      expect(find.textContaining('الحصة التفاعلية المباشرة'), findsOneWidget);
      expect(find.text('الانتقال لقاعة البث المباشر'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
      expect(find.text('🔥'), findsOneWidget);

      // Send a reaction
      await tester.tap(find.text('🔥'));
      await tester.pump(const Duration(milliseconds: 100));

      // Close modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('Opening AddTeacherStoryModal presents Instagram-style camera/video/text studio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: TeacherAccountTab(
              dashboard: mockDashboard,
              onEditProfile: () {},
              onOpenAccountSettings: () {},
              onSignOut: () {},
              onPreviewShowcase: () {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      // Tap on "نشر ستوري" button
      expect(find.text('نشر ستوري'), findsOneWidget);
      await tester.tap(find.text('نشر ستوري'));
      await tester.pumpAndSettle();

      // Verify Instagram-style modes
      expect(find.text('✍️ كتابة'), findsOneWidget);
      expect(find.text('📸 صورة'), findsOneWidget);
      expect(find.text('🎥 فيديو'), findsOneWidget);
      expect(find.text('🖼️ المعرض'), findsOneWidget);

      // Verify Instagram-style share buttons
      expect(find.text('قصتك'), findsOneWidget);
      expect(find.text('مشاركة في الستوري'), findsOneWidget);

      // Switch to Video mode
      await tester.tap(find.text('🎥 فيديو'));
      await tester.pump();
      expect(find.byIcon(Icons.videocam_rounded), findsOneWidget);

      // Switch to Camera mode
      await tester.tap(find.text('📸 صورة'));
      await tester.pump();
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);

      // Tap "قصتك" to publish
      await tester.tap(find.text('قصتك'));
      await tester.pumpAndSettle();

      // Verify returned to account tab and snackbar feedback shown
      expect(find.textContaining('تمت مشاركة الستوري في قصتك بنجاح'), findsOneWidget);
    });
  });
}
