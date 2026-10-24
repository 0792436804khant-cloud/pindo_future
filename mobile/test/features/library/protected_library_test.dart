import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/classroom/presentation/widgets/floating_student_watermark.dart';
import 'package:pindo_future_mobile/features/library/data/models/cohort_material_model.dart';
import 'package:pindo_future_mobile/features/library/data/models/session_recording_model.dart';
import 'package:pindo_future_mobile/features/library/domain/entities/cohort_material_entity.dart';
import 'package:pindo_future_mobile/features/library/domain/entities/session_recording_entity.dart';
import 'package:pindo_future_mobile/features/library/domain/repositories/library_repository.dart';
import 'package:pindo_future_mobile/features/library/presentation/controllers/library_controller.dart';
import 'package:pindo_future_mobile/features/library/presentation/screens/cohort_library_screen.dart';

class FakeLibraryRepository implements LibraryRepository {
  final CohortLibraryData libraryData;

  FakeLibraryRepository({required this.libraryData});

  @override
  Future<CohortLibraryData> getCohortLibrary(String token, int cohortId) async {
    return libraryData;
  }

  @override
  Future<StreamAccessData> getRecordingStream(String token, int recordingId) async {
    return const StreamAccessData(
      streamUrl: 'https://stream.pindofuture.com/test.m3u8',
      expiresAt: '2026-10-24T00:00:00Z',
      watermarkText: 'Amine Benali • PINDO-STU-12345',
    );
  }

  @override
  Future<String> getMaterialDownloadUrl(String token, int materialId) async {
    return 'https://cdn.pindofuture.com/download/test.pdf';
  }
}

void main() {
  group('FloatingStudentWatermark Widget Tests', () {
    testWidgets('Renders watermark text with student identity', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingStudentWatermark(
              watermarkText: 'Mohamed Salah • PINDO-STU-9921',
            ),
          ),
        ),
      );

      expect(find.text('Mohamed Salah • PINDO-STU-9921'), findsWidgets);
    });

    testWidgets('Renders SizedBox.shrink when watermark text is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatingStudentWatermark(
              watermarkText: '',
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('Library Entities & Models Tests', () {
    test('SessionRecordingEntity formats duration correctly', () {
      const rec1 = SessionRecordingEntity(
        id: 1,
        recordingCode: 'REC_1',
        title: 'Lecture 1',
        durationSeconds: 1500, // 25 min 00 sec
        viewsCount: 10,
        createdAt: '2026-10-23T00:00:00Z',
        isAccessible: true,
      );
      expect(rec1.formattedDuration, '25:00');

      const rec2 = SessionRecordingEntity(
        id: 2,
        recordingCode: 'REC_2',
        title: 'Lecture 2',
        durationSeconds: 5400, // 1h 30m
        viewsCount: 5,
        createdAt: '2026-10-23T00:00:00Z',
        isAccessible: true,
      );
      expect(rec2.formattedDuration, '1h 30m');
    });

    test('CohortMaterialEntity formats file size correctly', () {
      const mat1 = CohortMaterialEntity(
        id: 1,
        materialCode: 'MAT_1',
        title: 'Summary PDF',
        fileType: 'pdf',
        fileSizeBytes: 2048000, // ~2.0 MB
        downloadsCount: 12,
        createdAt: '2026-10-23T00:00:00Z',
        isAccessible: true,
      );
      expect(mat1.formattedFileSize, '2.0 MB');
    });

    test('SessionRecordingModel parses JSON correctly', () {
      final json = {
        'id': 10,
        'recording_code': 'REC_XYZ',
        'title': 'BAC Chemistry Organic Reactions',
        'duration_seconds': 3600,
        'views_count': 42,
        'created_at': '2026-10-23T10:00:00Z',
        'is_accessible': true,
      };

      final model = SessionRecordingModel.fromJson(json);
      expect(model.id, 10);
      expect(model.recordingCode, 'REC_XYZ');
      expect(model.title, 'BAC Chemistry Organic Reactions');
      expect(model.isAccessible, true);
    });

    test('CohortMaterialModel parses JSON correctly', () {
      final json = {
        'id': 20,
        'material_code': 'MAT_ABC',
        'title': 'Philosophy Methodological Synthesis',
        'file_type': 'pdf',
        'file_size_bytes': 102400,
        'downloads_count': 99,
        'created_at': '2026-10-23T12:00:00Z',
        'is_accessible': false,
      };

      final model = CohortMaterialModel.fromJson(json);
      expect(model.id, 20);
      expect(model.materialCode, 'MAT_ABC');
      expect(model.isAccessible, false);
    });
  });

  group('CohortLibraryScreen Widget Tests', () {
    testWidgets('Renders library tabs and displays locked status when not subscribed', (tester) async {
      final fakeData = CohortLibraryData(
        cohortInfo: {'name': 'BAC Math Cohort'},
        isSubscribed: false,
        requiresSubscription: true,
        recordings: [
          const SessionRecordingEntity(
            id: 1,
            recordingCode: 'REC_1',
            title: 'Complex Numbers Masterclass',
            durationSeconds: 3600,
            viewsCount: 20,
            createdAt: '2026-10-23T00:00:00Z',
            isAccessible: false,
          ),
        ],
        materials: [],
      );

      final repo = FakeLibraryRepository(libraryData: fakeData);
      final controller = LibraryController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: CohortLibraryScreen(
            cohortId: 1,
            cohortName: 'BAC Math Cohort',
            controller: controller,
            token: 'test_token',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('تسجيلات الحصص'), findsOneWidget);
      expect(find.text('الملخصات والتمارين'), findsOneWidget);
      expect(find.text('Complex Numbers Masterclass'), findsOneWidget);
      expect(find.text('مقفل'), findsOneWidget);
    });

    testWidgets('Displays accessible button when student is subscribed', (tester) async {
      final fakeData = CohortLibraryData(
        cohortInfo: {'name': 'BAC Math Cohort'},
        isSubscribed: true,
        requiresSubscription: false,
        recordings: [
          const SessionRecordingEntity(
            id: 2,
            recordingCode: 'REC_2',
            title: 'Derivatives and Limits Live Replay',
            durationSeconds: 4200,
            viewsCount: 55,
            createdAt: '2026-10-23T00:00:00Z',
            isAccessible: true,
          ),
        ],
        materials: [],
      );

      final repo = FakeLibraryRepository(libraryData: fakeData);
      final controller = LibraryController(repository: repo);

      await tester.pumpWidget(
        MaterialApp(
          home: CohortLibraryScreen(
            cohortId: 2,
            cohortName: 'BAC Math Cohort',
            controller: controller,
            token: 'test_token',
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Derivatives and Limits Live Replay'), findsOneWidget);
      expect(find.text('مشاهدة'), findsOneWidget);
    });
  });
}
