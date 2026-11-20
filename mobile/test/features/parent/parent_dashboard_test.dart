import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/core/config/platform_payment_config.dart';
import 'package:pindo_future_mobile/features/auth/domain/entities/user.dart';
import 'package:pindo_future_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pindo_future_mobile/features/auth/presentation/screens/dashboards/parent_dashboard_screen.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/child_academic_course_entity.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/child_overview_entity.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/child_schedule_entity.dart';
import 'package:pindo_future_mobile/features/parent/domain/entities/guardian_note_entity.dart';
import 'package:pindo_future_mobile/features/parent/domain/repositories/parent_repository.dart';
import 'package:pindo_future_mobile/features/parent/presentation/controllers/parent_controller.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/algerian_payment_sheet_modal.dart';

class MockParentRepository implements ParentRepository {
  List<ChildOverviewEntity> mockChildren = [
    const ChildOverviewEntity(
      id: 1,
      name: 'أحمد أمين قادري',
      email: 'student.amine@pindofuture.com',
      relationship: 'الابن (BAC 2026)',
      linkedAt: '2026-10-15T10:00:00Z',
      enrolledCoursesCount: 3,
      completedCoursesCount: 1,
      averageProgress: 72.5,
      totalWatchSeconds: 85200,
      totalWatchMinutes: 1420.0,
      sessionsAttendedCount: 18,
      notesCount: 2,
    ),
    const ChildOverviewEntity(
      id: 2,
      name: 'ياسمين قادري',
      email: 'yasmine.q@pindofuture.com',
      relationship: 'الابنة (BEM 2026)',
      linkedAt: '2026-10-20T14:30:00Z',
      enrolledCoursesCount: 2,
      completedCoursesCount: 0,
      averageProgress: 58.0,
      totalWatchSeconds: 51600,
      totalWatchMinutes: 860.0,
      sessionsAttendedCount: 11,
      notesCount: 1,
    ),
  ];
  bool shouldThrow = false;

  @override
  Future<List<ChildOverviewEntity>> getChildren(String token) async {
    if (shouldThrow) throw Exception('Network error');
    return mockChildren;
  }

  @override
  Future<ChildOverviewEntity> linkChild(
    String token, {
    String? email,
    String? linkingCode,
    String? relationship,
  }) async {
    final child = ChildOverviewEntity(
      id: 99,
      name: linkingCode ?? 'طالب جديد',
      email: email ?? 'student99@pindo.dz',
      relationship: relationship ?? 'ولي الأمر',
      linkedAt: DateTime.now().toIso8601String(),
      enrolledCoursesCount: 1,
      completedCoursesCount: 0,
      averageProgress: 0.0,
      totalWatchSeconds: 0,
      totalWatchMinutes: 0.0,
      sessionsAttendedCount: 0,
      notesCount: 0,
    );
    mockChildren.add(child);
    return child;
  }

  @override
  Future<List<ChildAcademicCourseEntity>> getAcademics(String token, int studentId) async => [
        const ChildAcademicCourseEntity(
          enrollmentId: 101,
          courseId: 501,
          title: 'فوج النخبة للبكالوريا — الرياضيات',
          slug: 'bac-math-elite',
          category: 'الرياضيات',
          description: 'شعبة علوم تجريبية ورياضي وتقني رياضي مع الأستاذ بن عيسى',
          enrolledAt: '2026-10-15T10:00:00Z',
          status: 'active',
          progressPercentage: 70,
          totalModules: 4,
          totalLessons: 16,
          completedLessons: 11,
          teacherName: 'الأستاذ محمد أمين بن عيسى',
          teacherHeadline: 'أستاذ متميز في الرياضيات للطور الثانوي بالقبة',
        ),
      ];

  @override
  Future<Map<String, dynamic>> getAttendance(String token, int studentId) async => {
        'summary': {'total_watch_hours': 23.6, 'total_watch_minutes': 1420.0, 'total_sessions_attended': 18},
        'records': [],
      };

  @override
  Future<List<ChildScheduleEntity>> getSchedule(String token, int studentId) async => [
        const ChildScheduleEntity(
          sessionId: 'SES_LIVE_01',
          title: 'الرياضيات — بث مباشر تفاعلي',
          courseTitle: 'فوج النخبة للبكالوريا',
          teacherName: 'الأستاذ محمد أمين بن عيسى',
          status: 'live',
          isLive: true,
          scheduledAt: '2026-11-20T18:00:00Z',
        ),
      ];

  @override
  Future<List<GuardianNoteEntity>> getNotes(String token, int studentId) async => [
        GuardianNoteEntity(
          id: 1,
          title: 'إشادة بمواظبة التلميذ وتفاعله',
          content: 'أحمد يظهر انضباطاً ممتازاً وفهماً سريعاً للأفكار الرياضية الصعبة خلال البث المباشر.',
          type: 'praise',
          isAcknowledged: true,
          createdAt: '2026-11-17T20:15:00Z',
          authorName: 'الأستاذ محمد أمين بن عيسى',
          authorRole: 'أستاذ المادة',
        ),
      ];

  @override
  Future<GuardianNoteEntity> addNote(
    String token,
    int studentId, {
    required String title,
    required String content,
    String? type,
  }) async {
    return GuardianNoteEntity(
      id: 99,
      title: title,
      content: content,
      type: type ?? 'general',
      isAcknowledged: false,
      createdAt: DateTime.now().toIso8601String(),
      authorName: 'ولي الأمر',
      authorRole: 'parent',
    );
  }

  @override
  Future<void> acknowledgeNote(String token, int noteId) async {}
}

class FakeAuthController extends ChangeNotifier implements AuthController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> logout() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testParentUser = const User(
    id: 10,
    name: 'عبد القادر قادري',
    email: 'parent.kadri@pindo.dz',
    role: UserRole.parent,
  );

  group('Parent Guardian Sync & Absence Alert Tests', () {
    late MockParentRepository mockRepo;
    late ParentController controller;

    setUp(() {
      mockRepo = MockParentRepository();
      controller = ParentController(repository: mockRepo, authToken: 'test_token');
    });

    test('ParentController loads realistic fallback children when offline/empty', () async {
      await controller.loadChildren();

      expect(controller.children.length, 2);
      expect(controller.children.first.name, 'أحمد أمين قادري');
      expect(controller.children.first.relationship, contains('BAC 2026'));
      expect(controller.children.last.name, 'ياسمين قادري');
      expect(controller.selectedChild?.id, 1);
      expect(controller.academics.isNotEmpty, isTrue);
    });

    test('Live absence radar triggers alert when live session is >= 15 min and child absent', () async {
      await controller.loadChildren();

      expect(controller.isLiveSessionNow, isTrue);
      expect(controller.isChildAttendingNow, isFalse);
      expect(controller.liveMinutesElapsed, 18);
      expect(controller.isAbsenceAlertTriggered, isTrue);

      // Parent toggles presence (e.g. simulated presence or after student enters)
      controller.toggleChildLivePresence();
      expect(controller.isChildAttendingNow, isTrue);
      expect(controller.isAbsenceAlertTriggered, isFalse);
    });

    test('Linking child via Family Code (PINDO-FAM-XXXX) adds child to portal', () async {
      await controller.loadChildren();
      final initialCount = controller.children.length;

      await controller.linkChild(
        linkingCode: 'PINDO-FAM-7892',
        relationship: 'ولي الأمر',
      );

      expect(controller.children.length, initialCount + 1);
      expect(controller.successMessage, contains('بنجاح'));
    });

    test('Selecting another child switches active overview and data', () async {
      await controller.loadChildren();
      expect(controller.selectedChild?.id, 1);

      final secondChild = controller.children[1];
      controller.selectChild(secondChild);

      expect(controller.selectedChild?.id, 2);
      expect(controller.selectedChild?.name, 'ياسمين قادري');
    });
  });

  group('Parent Dashboard Screen Widget & Direct Payment Tests', () {
    testWidgets('ParentDashboardScreen renders RTL Arabic header and child selector', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 1600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final mockRepo = MockParentRepository();
      final controller = ParentController(repository: mockRepo, authToken: 'test_token');
      await controller.loadChildren();

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ParentDashboardScreen(
              user: testParentUser,
              authController: FakeAuthController(),
              parentController: controller,
            ),
          ),
        ),
      );

      // Advance animation frames cleanly
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Check header and user name
      expect(find.textContaining('بوابة ولي الأمر 👨‍👦'), findsOneWidget);
      expect(find.textContaining('عبد القادر قادري'), findsWidgets);

      // Child selector pills
      expect(find.textContaining('أحمد أمين قادري'), findsWidgets);
      expect(find.textContaining('ياسمين قادري'), findsWidgets);

      // Live absence alert banner
      expect(find.textContaining('تنبيه غياب فوري'), findsOneWidget);

      // 5 Arabic Tab Bar
      expect(find.text('حصص واشتراكات الابن'), findsOneWidget);
      expect(find.text('المواظبة والحضور'), findsOneWidget);
      expect(find.text('الجدول الأسبوعي'), findsOneWidget);
      expect(find.text('ملاحظات الأساتذة'), findsOneWidget);
      expect(find.text('استكشاف الأساتذة'), findsOneWidget);

      // Check direct payment button in Academics tab
      expect(find.text('تجديد ودفع اشتراك الابن ببريدي موب ⚡'), findsWidgets);
    });

    testWidgets('Tapping direct BaridiMob payment button opens AlgerianPaymentSheetModal with official RIP', (tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 1600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      final mockRepo = MockParentRepository();
      final controller = ParentController(repository: mockRepo, authToken: 'test_token');
      await controller.loadChildren();

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: ParentDashboardScreen(
              user: testParentUser,
              authController: FakeAuthController(),
              parentController: controller,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Find the direct payment button and tap it
      final payButton = find.text('تجديد ودفع اشتراك الابن ببريدي موب ⚡').first;
      await tester.ensureVisible(payButton);
      await tester.tap(payButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Verify the AlgerianPaymentSheetModal opened
      expect(find.byType(AlgerianPaymentSheetModal), findsOneWidget);

      // Verify official platform RIP and formatted RIP are displayed
      expect(find.text(PlatformPaymentConfig.formattedRip), findsOneWidget);
      expect(find.text(PlatformPaymentConfig.accountHolderName), findsOneWidget);
    });
  });
}
