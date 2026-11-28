import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/modals/create_session_modal.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_schedule_tab.dart';

void main() {
  testWidgets('TeacherScheduleTab renders multi-day calendar with all weekdays and filters sessions', (tester) async {
    final now = DateTime.now();
    final todaySession = TeacherScheduleItem(
      id: 1,
      sessionId: 'SES_TODAY',
      cohortId: 10,
      title: 'حصة المراجعة اليوم',
      cohortName: 'فوج 1',
      subject: 'الرياضيات',
      scheduledAt: now,
      timeFormatted: '18:00',
      durationMinutes: 120,
      status: 'scheduled',
    );
    final futureSession = TeacherScheduleItem(
      id: 2,
      sessionId: 'SES_FUTURE',
      cohortId: 10,
      title: 'حصة الدوال بعد 3 أيام',
      cohortName: 'فوج 1',
      subject: 'الرياضيات',
      scheduledAt: now.add(const Duration(days: 3)),
      timeFormatted: '20:00',
      durationMinutes: 90,
      status: 'scheduled',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: const Color(0xFF0A0F1E),
            body: TeacherScheduleTab(
              schedule: [todaySession, futureSession],
              cohorts: const [
                TeacherCohortItem(
                  id: 10,
                  cohortCode: 'COH_10',
                  name: 'فوج 1',
                  subject: 'الرياضيات',
                  academicLevel: 'ثالثة ثانوي',
                  stream: 'علوم تجريبية',
                  enrolledCount: 1,
                  maxStudents: 50,
                  monthlyPrice: 3500,
                  isActive: true,
                  hasLibrary: true,
                ),
              ],
              onStartLiveSession: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('كل الحصص (2)'), findsOneWidget);
    expect(find.text('حصة المراجعة اليوم'), findsOneWidget);
    expect(find.text('حصة الدوال بعد 3 أيام'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('غداً'), findsOneWidget);
    expect(find.text('اختيار يوم'), findsOneWidget);

    // Filter to Today only by tapping "اليوم"
    await tester.tap(find.text('اليوم'));
    await tester.pumpAndSettle();

    expect(find.text('حصة المراجعة اليوم'), findsOneWidget);
    expect(find.text('حصة الدوال بعد 3 أيام'), findsNothing);

    // Return to all scheduled sessions
    await tester.tap(find.text('كل الحصص (2)'));
    await tester.pumpAndSettle();

    expect(find.text('حصة الدوال بعد 3 أيام'), findsOneWidget);
  });

  testWidgets('CreateSessionModal submits via onSave and stays open with error when onSave fails', (tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    Map<String, dynamic>? submittedPayload;
    bool shouldFail = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: CreateSessionModal(
              cohorts: const [
                TeacherCohortItem(
                  id: 7,
                  cohortCode: 'COH_7',
                  name: 'فوج النخبة',
                  subject: 'الفيزياء',
                  academicLevel: 'ثالثة ثانوي',
                  stream: 'علوم تجريبية',
                  enrolledCount: 2,
                  maxStudents: 40,
                  monthlyPrice: 3500,
                  isActive: true,
                  hasLibrary: true,
                ),
              ],
              onSave: (payload) async {
                if (shouldFail) {
                  throw Exception('فشل الاتصال');
                }
                submittedPayload = payload;
              },
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'مراجعة شاملة للوحدة الأولى');
    await tester.ensureVisible(find.text('جدولة الحصة وإرسال التنبيه'));
    await tester.tap(find.text('جدولة الحصة وإرسال التنبيه'));
    await tester.pumpAndSettle();

    expect(submittedPayload, isNull);
    expect(find.textContaining('فشل الاتصال'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.text('جدولة الحصة وإرسال التنبيه'))).clearSnackBars();
    await tester.pumpAndSettle();

    shouldFail = false;
    await tester.ensureVisible(find.text('جدولة الحصة وإرسال التنبيه'));
    await tester.tap(find.text('جدولة الحصة وإرسال التنبيه'));
    await tester.pumpAndSettle();

    expect(submittedPayload, isNotNull);
    expect(submittedPayload!['cohort_id'], 7);
    expect(submittedPayload!['title'], 'مراجعة شاملة للوحدة الأولى');
  });
}
