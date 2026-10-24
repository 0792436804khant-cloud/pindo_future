import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/exams/data/models/exam_exercise_model.dart';
import 'package:pindo_future_mobile/features/exams/data/models/exam_paper_model.dart';
import 'package:pindo_future_mobile/features/exams/data/models/exam_simulation_model.dart';
import 'package:pindo_future_mobile/features/exams/domain/entities/exam_exercise_entity.dart';
import 'package:pindo_future_mobile/features/exams/domain/entities/exam_paper_entity.dart';
import 'package:pindo_future_mobile/features/exams/domain/entities/exam_simulation_entity.dart';
import 'package:pindo_future_mobile/features/exams/domain/repositories/exam_bank_repository.dart';
import 'package:pindo_future_mobile/features/exams/presentation/controllers/exam_bank_controller.dart';
import 'package:pindo_future_mobile/features/exams/presentation/screens/exam_bank_explorer_screen.dart';
import 'package:pindo_future_mobile/features/exams/presentation/screens/exam_simulation_screen.dart';
import 'package:pindo_future_mobile/features/exams/presentation/widgets/exam_paper_card.dart';

class FakeExamBankRepository implements ExamBankRepository {
  List<ExamPaperEntity> papers = [];
  List<ExamExerciseEntity> exercises = [];
  ExamSimulationEntity? simulationToReturn;

  @override
  Future<List<ExamPaperEntity>> getExamPapers({
    String? cycle,
    String? stream,
    String? subject,
    int? year,
    String? search,
  }) async {
    return papers.where((p) {
      if (cycle != null && p.cycle.toLowerCase() != cycle.toLowerCase()) return false;
      if (stream != null && p.stream != stream) return false;
      if (year != null && p.year != year) return false;
      return true;
    }).toList();
  }

  @override
  Future<({ExamPaperEntity paper, List<ExamExerciseEntity> exercises})> getExamPaperDetails(int id) async {
    final paper = papers.firstWhere((p) => p.id == id, orElse: () => papers.first);
    return (paper: paper, exercises: exercises);
  }

  @override
  Future<ExamSimulationEntity> startSimulation(String token, int examId) async {
    return simulationToReturn ??
        ExamSimulationEntity(
          id: 101,
          simulationCode: 'SIM_TEST_101',
          examPaperId: examId,
          startedAt: DateTime.now(),
          timeSpentSeconds: 0,
          status: 'in_progress',
        );
  }

  @override
  Future<ExamSimulationEntity> updateSimulationProgress(
    String token,
    int simulationId, {
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  }) async {
    return ExamSimulationEntity(
      id: simulationId,
      simulationCode: 'SIM_TEST_101',
      examPaperId: 1,
      startedAt: DateTime.now(),
      timeSpentSeconds: timeSpentSeconds ?? 0,
      completedExercises: completedExercises ?? [],
      studentNotes: studentNotes,
      status: 'in_progress',
    );
  }

  @override
  Future<ExamSimulationEntity> finishSimulation(
    String token,
    int simulationId, {
    double? selfAssessmentScore,
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  }) async {
    return ExamSimulationEntity(
      id: simulationId,
      simulationCode: 'SIM_TEST_101',
      examPaperId: 1,
      startedAt: DateTime.now(),
      endedAt: DateTime.now(),
      timeSpentSeconds: timeSpentSeconds ?? 3600,
      completedExercises: completedExercises ?? [],
      selfAssessmentScore: selfAssessmentScore,
      studentNotes: studentNotes,
      status: 'completed',
    );
  }

  @override
  Future<List<ExamSimulationEntity>> getStudentSimulations(String token) async {
    return [
      ExamSimulationEntity(
        id: 101,
        simulationCode: 'SIM_TEST_101',
        examPaperId: 1,
        startedAt: DateTime.now().subtract(const Duration(days: 1)),
        endedAt: DateTime.now().subtract(const Duration(days: 1, hours: -3)),
        timeSpentSeconds: 10800,
        selfAssessmentScore: 17.5,
        status: 'completed',
        examPaper: papers.isNotEmpty ? papers.first : null,
      ),
    ];
  }
}

void main() {
  const samplePaper = ExamPaperModel(
    id: 1,
    examCode: 'BAC-2024-MATH-S1',
    title: 'بكالوريا 2024 - علوم تجريبية - مادة الرياضيات',
    cycle: 'bac',
    stream: 'experimental_sciences',
    subject: 'mathematics',
    subjectNameAr: 'الرياضيات',
    year: 2024,
    sessionType: 'main',
    optionNumber: 1,
    durationMinutes: 210,
    coefficient: 5,
    totalScore: 20,
    paperPdfUrl: 'https://cdn.pindofuture.com/paper.pdf',
    solutionPdfUrl: 'https://cdn.pindofuture.com/solution.pdf',
    description: 'الموضوع الأول يحتوي على 4 تمارين مستقلة',
    difficultyLevel: 'medium',
    exerciseCount: 4,
    viewsCount: 15,
    downloadsCount: 10,
  );

  const sampleExercise = ExamExerciseModel(
    id: 1,
    examPaperId: 1,
    exerciseNumber: 1,
    title: 'التمرين الأول (04.5 نقاط) - المتتاليات العددية',
    topic: 'المتتاليات العددية',
    points: 4.5,
    instructions: 'برهن بالتراجع على أن المتتالية محدودة',
    officialMarkingRubric: [
      ExamRubricStepEntity(step: 'البرهان بالتراجع', points: 1.5),
      ExamRubricStepEntity(step: 'دراسة الرتابة', points: 1.5),
    ],
  );

  group('Exam Bank Entities & Models Tests', () {
    test('ExamPaperModel parses JSON correctly', () {
      final json = samplePaper.toJson();
      final parsed = ExamPaperModel.fromJson(json);

      expect(parsed.id, 1);
      expect(parsed.examCode, 'BAC-2024-MATH-S1');
      expect(parsed.cycle, 'bac');
      expect(parsed.cycleBadge, 'BAC');
      expect(parsed.formattedDuration, '3 سا 30 د');
      expect(parsed.streamDisplayAr, 'علوم تجريبية');
      expect(parsed.hasOfficialSolution, isTrue);
    });

    test('ExamExerciseModel parses rubric JSON correctly', () {
      final json = sampleExercise.toJson();
      final parsed = ExamExerciseModel.fromJson(json);

      expect(parsed.title, 'التمرين الأول (04.5 نقاط) - المتتاليات العددية');
      expect(parsed.points, 4.5);
      expect(parsed.officialMarkingRubric.length, 2);
      expect(parsed.officialMarkingRubric[0].step, 'البرهان بالتراجع');
      expect(parsed.officialMarkingRubric[0].points, 1.5);
    });

    test('ExamSimulationModel parses JSON and formats time correctly', () {
      final sim = ExamSimulationModel.fromJson({
        'id': 10,
        'simulation_code': 'SIM_ABCD',
        'exam_paper_id': 1,
        'started_at': '2026-10-24T10:00:00Z',
        'time_spent_seconds': 3725,
        'status': 'completed',
        'self_assessment_score': 16.5,
      });

      expect(sim.id, 10);
      expect(sim.simulationCode, 'SIM_ABCD');
      expect(sim.isCompleted, isTrue);
      expect(sim.selfAssessmentScore, 16.5);
      expect(sim.formattedTimeSpent, '62:05');
    });
  });

  group('ExamBankController Logic Tests', () {
    late FakeExamBankRepository fakeRepo;
    late ExamBankController controller;

    setUp(() {
      fakeRepo = FakeExamBankRepository();
      fakeRepo.papers = [samplePaper];
      fakeRepo.exercises = [sampleExercise];
      controller = ExamBankController(repository: fakeRepo, userToken: 'test_student_token');
    });

    tearDown(() {
      controller.dispose();
    });

    test('Loads exams and handles cycle filter correctly', () async {
      await controller.loadExams();
      expect(controller.exams.length, 1);
      expect(controller.isLoading, isFalse);

      controller.setCycle('bem');
      expect(controller.selectedCycle, 'bem');
      expect(controller.selectedStream, isNull);
    });

    test('Simulation lifecycle: start, toggle exercise, and finish', () async {
      await controller.startSimulation(samplePaper);

      expect(controller.isSimulationRunning, isTrue);
      expect(controller.activeSimulation?.id, 101);
      expect(controller.remainingSeconds, 210 * 60);

      // Check exercise
      controller.toggleExerciseCompleted(1);
      expect(controller.completedExerciseNumbers.contains(1), isTrue);

      controller.toggleExerciseCompleted(1);
      expect(controller.completedExerciseNumbers.contains(1), isFalse);

      // Finish simulation
      final success = await controller.finishSimulation(selfAssessmentScore: 18.0);
      expect(success, isTrue);
      expect(controller.isSimulationRunning, isFalse);
      expect(controller.activeSimulation?.status, 'completed');
    });
  });

  group('Exam Bank Widget Tests', () {
    late FakeExamBankRepository fakeRepo;
    late ExamBankController controller;

    setUp(() {
      fakeRepo = FakeExamBankRepository();
      fakeRepo.papers = [samplePaper];
      fakeRepo.exercises = [sampleExercise];
      controller = ExamBankController(repository: fakeRepo, userToken: 'test_token');
    });

    tearDown(() {
      controller.cancelSimulation();
      controller.dispose();
    });

    testWidgets('ExamPaperCard renders badges, title, and buttons', (tester) async {
      bool tapped = false;
      bool simTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: ExamPaperCard(
              paper: samplePaper,
              onTap: () => tapped = true,
              onStartSimulation: () => simTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('BAC'), findsOneWidget);
      expect(find.text('دورة 2024'), findsOneWidget);
      expect(find.text('سلم التنقيط الوزاري'), findsOneWidget);
      expect(find.text('بكالوريا 2024 - علوم تجريبية - مادة الرياضيات'), findsOneWidget);
      expect(find.text('3 سا 30 د'), findsOneWidget);

      await tester.tap(find.text('عرض الموضوع'));
      expect(tapped, isTrue);

      await tester.tap(find.text('محاكاة مؤقتة ⏱️'));
      expect(simTapped, isTrue);
    });

    testWidgets('ExamBankExplorerScreen renders cycle filters and papers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: ExamBankExplorerScreen(controller: controller),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('بنك الامتحانات الرسمية 🇩🇿'), findsOneWidget);
      expect(find.text('شهادة البكالوريا (BAC)'), findsOneWidget);
      expect(find.text('التعليم المتوسط (BEM)'), findsOneWidget);
      expect(find.text('بكالوريا 2024 - علوم تجريبية - مادة الرياضيات'), findsOneWidget);
    });

    testWidgets('ExamSimulationScreen renders countdown timer and tabs', (tester) async {
      await controller.startSimulation(samplePaper);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: ExamSimulationScreen(
            paper: samplePaper,
            controller: controller,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('محاكاة البكالوريا الرسمية'), findsOneWidget);
      expect(find.text('الوقت المتبقي للامتحان'), findsOneWidget);
      expect(find.text('إنهاء وتقييم'), findsOneWidget);
      expect(find.text('التمارين'), findsOneWidget);
      expect(find.text('المسودة'), findsOneWidget);
      expect(find.text('سلم التنقيط'), findsOneWidget);

      controller.cancelSimulation();
      await tester.pump();
    });
  });
}
