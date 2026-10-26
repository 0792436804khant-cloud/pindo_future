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
    });
  });
}
