import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/chat/domain/entities/cohort_chat_message.dart';
import 'package:pindo_future_mobile/features/chat/services/cohort_chat_service.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chats_hub_modal.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chat_room_modal.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_groups_tab.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/tabs/student_my_classes_tab.dart';

void main() {
  group('Cohort Chat Service Unit Tests', () {
    late CohortChatService service;

    setUp(() {
      service = CohortChatService();
    });

    test('Loads pre-seeded messages for Algerian BAC cohorts', () {
      final messages = service.getMessages('COHORT_BAC27_MATH');
      expect(messages.isNotEmpty, isTrue);
      expect(messages.any((m) => m.senderRole == 'teacher'), isTrue);
      expect(messages.any((m) => m.senderRole == 'student'), isTrue);
      expect(service.getTotalUnreadCount(), greaterThanOrEqualTo(0));
    });

    test('Sending text message appends to cohort chat stream', () {
      final initialCount = service.getMessages('COHORT_BAC27_MATH').length;
      final newMsg = CohortChatMessage(
        id: 'test_msg_1',
        cohortId: 'COHORT_BAC27_MATH',
        cohortName: 'فوج النخبة للبكالوريا',
        senderId: 'TCH_01',
        senderName: 'الأستاذ محمد أمين',
        senderRole: 'teacher',
        text: 'رسالة تجريبية لاختبار الدردشة',
        timestamp: DateTime.now(),
      );

      service.sendMessage(newMsg);
      final updated = service.getMessages('COHORT_BAC27_MATH');
      expect(updated.length, initialCount + 1);
      expect(updated.last.text, 'رسالة تجريبية لاختبار الدردشة');
    });

    test('Toggle pin on cohort message updates status', () {
      final messages = service.getMessages('COHORT_BAC27_MATH');
      final target = messages.first;
      final wasPinned = target.isPinned;

      service.togglePin('COHORT_BAC27_MATH', target.id);
      final refreshed = service.getMessages('COHORT_BAC27_MATH').firstWhere((m) => m.id == target.id);
      expect(refreshed.isPinned, !wasPinned);
    });

    test('Toggling emoji reaction adds or removes emoji', () {
      final messages = service.getMessages('COHORT_BAC27_MATH');
      final target = messages.first;
      final hadFire = target.reactions.contains('🔥');

      service.addReaction('COHORT_BAC27_MATH', target.id, '🔥');
      final after = service.getMessages('COHORT_BAC27_MATH').firstWhere((m) => m.id == target.id);
      expect(after.reactions.contains('🔥'), !hadFire);
    });

    test('Cohort summaries list all enrolled cohorts with badges', () {
      final summaries = service.getAllCohortSummaries();
      expect(summaries.length, greaterThanOrEqualTo(3));
      expect(summaries.any((s) => s.cohortId == 'COHORT_BAC27_MATH'), isTrue);
      expect(summaries.any((s) => s.isLiveNow), isTrue);
    });
  });

  group('Cohort Chat UI Widget Tests', () {
    testWidgets('CohortChatsHubModal renders cohort search and chat list items', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CohortChatsHubModal(
              currentUserName: 'الأستاذ محمد أمين بن عيسى',
              currentUserRole: 'teacher',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('محادثات الأفواج والدردشة 💬'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('فوج النخبة للبكالوريا'), findsOneWidget);
      expect(find.textContaining('فوج التفوق في العلوم الفيزيائية'), findsOneWidget);
    });

    testWidgets('CohortChatRoomModal displays messages and allows sending new message', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CohortChatRoomModal(
              cohortId: 'COHORT_BAC27_MATH',
              cohortName: 'فوج النخبة للبكالوريا — الرياضيات',
              academicLevel: 'ثالثة ثانوي',
              currentUserName: 'الأستاذ محمد أمين بن عيسى',
              currentUserRole: 'teacher',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('فوج النخبة للبكالوريا — الرياضيات'), findsOneWidget);
      expect(find.textContaining('ثالثة ثانوي'), findsOneWidget);

      // Verify action buttons present (camera, attachment menu, send)
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      expect(find.byIcon(Icons.attach_file_rounded), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);

      // Type and send text
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'توجيه جديد للطلبة: مراجعة الدالة اللوغاريتمية');
      await tester.pumpAndSettle();

      final sendButton = find.byIcon(Icons.send_rounded);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(find.text('توجيه جديد للطلبة: مراجعة الدالة اللوغاريتمية'), findsOneWidget);
    });

    testWidgets('TeacherGroupsTab renders primary official cohort chat button and header hub button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      final List<TeacherCohortItem> testCohorts = [
        const TeacherCohortItem(
          id: 1,
          cohortCode: 'COHORT_BAC27_MATH',
          name: 'فوج النخبة للبكالوريا',
          subject: 'الرياضيات',
          academicLevel: 'ثالثة ثانوي',
          stream: 'علوم تجريبية',
          enrolledCount: 42,
          maxStudents: 50,
          monthlyPrice: 3500.0,
          isActive: true,
          hasLibrary: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeacherGroupsTab(cohorts: testCohorts),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Official button on cohort card
      expect(find.text('محادثة الفوج والدردشة 💬'), findsOneWidget);
      // Header quick access button
      expect(find.text('المحادثات 💬'), findsOneWidget);

      // Tap official chat button opens room modal
      await tester.tap(find.text('محادثة الفوج والدردشة 💬'));
      await tester.pumpAndSettle();

      expect(find.byType(CohortChatRoomModal), findsOneWidget);
    });

    testWidgets('StudentMyClassesTab renders cohort chat button and opens modal', (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 900));

      final dummyData = StudentDashboardData.fallback('أحمد أمين قادري', 'ahmed@pindo.dz');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StudentMyClassesTab(
              dashboardData: dummyData,
              onJoinLiveClassroom: (_) {},
              onOpenCohortsExplorer: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Look for the student cohort chat buttons
      final chatButtons = find.text('محادثة الفوج 💬');
      expect(chatButtons, findsWidgets);

      await tester.tap(chatButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(CohortChatRoomModal), findsOneWidget);
    });
  });
}
