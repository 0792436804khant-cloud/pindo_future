import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/classroom/data/models/whiteboard_snapshot_model.dart';
import 'package:pindo_future_mobile/features/classroom/domain/entities/room_connection_details.dart';
import 'package:pindo_future_mobile/features/classroom/domain/entities/whiteboard_snapshot_entity.dart';
import 'package:pindo_future_mobile/features/classroom/domain/entities/whiteboard_stroke_entity.dart';
import 'package:pindo_future_mobile/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:pindo_future_mobile/features/classroom/domain/repositories/whiteboard_repository.dart';
import 'package:pindo_future_mobile/features/classroom/domain/usecases/get_room_token_usecase.dart';
import 'package:pindo_future_mobile/features/classroom/domain/usecases/get_whiteboard_snapshots_usecase.dart';
import 'package:pindo_future_mobile/features/classroom/domain/usecases/save_whiteboard_snapshot_usecase.dart';
import 'package:pindo_future_mobile/features/classroom/presentation/controllers/classroom_controller.dart';
import 'package:pindo_future_mobile/features/classroom/presentation/widgets/interactive_whiteboard_canvas.dart';
import 'package:pindo_future_mobile/features/classroom/services/livekit_room_service.dart';

class FakeWhiteboardRepository implements WhiteboardRepository {
  final List<WhiteboardSnapshotEntity> storedSnapshots = [];

  @override
  Future<WhiteboardSnapshotEntity> saveSnapshot({
    required String sessionId,
    required String title,
    required List<WhiteboardStrokeEntity> strokes,
    String? token,
  }) async {
    final newSnap = WhiteboardSnapshotEntity(
      id: storedSnapshots.length + 1,
      sessionId: sessionId,
      snapshotTitle: title,
      version: storedSnapshots.length + 1,
      strokeCount: strokes.length,
      authorName: 'Instructor Demo',
      vectorData: List.from(strokes),
      createdAt: DateTime.now(),
    );
    storedSnapshots.add(newSnap);
    return newSnap;
  }

  @override
  Future<WhiteboardSnapshotEntity?> getLatestSnapshot({
    required String sessionId,
    String? token,
  }) async {
    return storedSnapshots.isNotEmpty ? storedSnapshots.last : null;
  }

  @override
  Future<List<WhiteboardSnapshotEntity>> getSnapshotHistory({
    required String sessionId,
    String? token,
  }) async {
    return List.from(storedSnapshots.reversed);
  }
}

class FakeGetRoomTokenUseCase extends GetRoomTokenUseCase {
  FakeGetRoomTokenUseCase() : super(FakeClassroomRepository());
}

class FakeClassroomRepository implements ClassroomRepository {
  @override
  Future<RoomConnectionDetails> getRoomToken({
    required String sessionId,
    String? participantName,
  }) async {
    return const RoomConnectionDetails(
      serverUrl: 'wss://livekit.demo.pindo.com',
      token: 'fake_jwt_token',
      sessionId: 'ses_1',
      role: 'teacher',
      identity: 'user_1',
      canPublish: true,
      canSubscribe: true,
      expiresIn: 3600,
    );
  }
}

void main() {
  group('Whiteboard Domain & Data Tests', () {
    test('WhiteboardStrokeEntity serializes and parses coordinateSystem and laserPointer', () {
      final stroke = WhiteboardStrokeEntity(
        id: 'stk_axes_1',
        tool: WhiteboardTool.coordinateSystem,
        colorValue: 0xFF2563EB,
        strokeWidth: 3.0,
        points: const [
          WhiteboardPoint(x: 0.2, y: 0.2),
          WhiteboardPoint(x: 0.8, y: 0.8),
        ],
        authorIdentity: 'TEA_01',
        authorName: 'Prof. Karim',
        timestamp: DateTime(2026, 10, 24, 12, 0, 0),
      );

      final json = stroke.toJson();
      expect(json['tool'], 'coordinateSystem');
      expect(json['color_value'], 0xFF2563EB);
      expect(json['points'], hasLength(2));

      final parsed = WhiteboardStrokeEntity.fromJson(json);
      expect(parsed.tool, WhiteboardTool.coordinateSystem);
      expect(parsed.id, 'stk_axes_1');
      expect(parsed.authorName, 'Prof. Karim');

      // Test laserPointer tool
      final laserJson = {
        'id': 'stk_laser_1',
        'tool': 'laserPointer',
        'color_value': 0xFFEF4444,
        'stroke_width': 5.0,
        'points': [{'x': 0.5, 'y': 0.5}],
        'author_identity': 'TEA_01',
        'author_name': 'Prof. Karim',
        'timestamp': '2026-10-24T12:00:00.000Z',
      };
      final laserStroke = WhiteboardStrokeEntity.fromJson(laserJson);
      expect(laserStroke.tool, WhiteboardTool.laserPointer);
    });

    test('WhiteboardSnapshotModel parses backend JSON payload correctly', () {
      final jsonPayload = {
        'id': 42,
        'session_id': 'SES_BAC_MATH_01',
        'snapshot_title': 'Derivatives & Polynomials Slide 1',
        'version': 3,
        'stroke_count': 12,
        'thumbnail_url': 'https://storage.pindofuture.com/thumb42.jpg',
        'author': {
          'id': 5,
          'name': 'Maitre Ahmed',
          'role': 'teacher',
        },
        'vector_data': [
          {
            'id': 'stk_1',
            'tool': 'pen',
            'color_value': 0xFF0D9488,
            'stroke_width': 4.0,
            'points': [{'x': 0.1, 'y': 0.1}],
            'author_identity': 'TEA_05',
            'author_name': 'Maitre Ahmed',
            'timestamp': '2026-10-24T12:00:00.000Z',
          }
        ],
        'created_at': '2026-10-24T12:15:00.000Z',
      };

      final model = WhiteboardSnapshotModel.fromJson(jsonPayload);
      expect(model.id, 42);
      expect(model.snapshotTitle, 'Derivatives & Polynomials Slide 1');
      expect(model.version, 3);
      expect(model.strokeCount, 12);
      expect(model.authorName, 'Maitre Ahmed');
      expect(model.vectorData, hasLength(1));
      expect(model.vectorData.first.tool, WhiteboardTool.pen);
    });
  });

  group('InteractiveWhiteboardCanvas Widget Tests', () {
    late FakeWhiteboardRepository fakeRepo;
    late ClassroomController controller;

    setUp(() {
      fakeRepo = FakeWhiteboardRepository();
      controller = ClassroomController(
        getRoomTokenUseCase: FakeGetRoomTokenUseCase(),
        roomService: LiveKitRoomService(),
        saveWhiteboardSnapshotUseCase: SaveWhiteboardSnapshotUseCase(fakeRepo),
        getWhiteboardSnapshotsUseCase: GetWhiteboardSnapshotsUseCase(fakeRepo),
      );
    });

    testWidgets('Renders drawing surface and teacher floating toolbar with specialized tools', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveWhiteboardCanvas(
                controller: controller,
                isTeacher: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify custom painter is present
      expect(find.byType(CustomPaint), findsWidgets);

      // Verify tool buttons exist
      expect(find.byIcon(Icons.edit), findsOneWidget); // Pen
      expect(find.byIcon(Icons.brush), findsOneWidget); // Highlighter
      expect(find.byIcon(Icons.crop_square), findsOneWidget); // Rectangle
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget); // Circle
      expect(find.byIcon(Icons.horizontal_rule), findsOneWidget); // Line
      expect(find.byIcon(Icons.arrow_outward), findsOneWidget); // Arrow
      expect(find.byIcon(Icons.timeline), findsOneWidget); // Coordinate Axes
      expect(find.byIcon(Icons.flare), findsOneWidget); // Laser Pointer
      expect(find.byIcon(Icons.auto_fix_normal), findsOneWidget); // Eraser

      // Verify Slide History button and Save Notes button are present
      expect(find.byIcon(Icons.collections_bookmark_outlined), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_add), findsOneWidget);
    });

    testWidgets('Tapping Slide History button opens bottom sheet modal', (tester) async {
      // Pre-populate a snapshot
      fakeRepo.storedSnapshots.add(
        WhiteboardSnapshotEntity(
          id: 1,
          sessionId: 'SES_DEMO',
          snapshotTitle: 'BAC Math Functions Intro',
          version: 1,
          strokeCount: 8,
          authorName: 'Prof. Amine',
          vectorData: const [],
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveWhiteboardCanvas(
                controller: controller,
                isTeacher: true,
                sessionId: 'SES_DEMO',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap history button
      await tester.tap(find.byIcon(Icons.collections_bookmark_outlined));
      await tester.pumpAndSettle();

      // Verify modal opened with slide info
      expect(find.text('Whiteboard Slide History'), findsOneWidget);
      expect(find.text('BAC Math Functions Intro'), findsOneWidget);
      expect(find.text('v1'), findsOneWidget);
    });

    testWidgets('Student view shows live broadcast indicator without teacher tool buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: InteractiveWhiteboardCanvas(
                controller: controller,
                isTeacher: false, // Student mode
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify student live indicator is shown
      expect(find.text('Live Broadcast • Instructor Drawing'), findsOneWidget);

      // Verify teacher-only tools are hidden
      expect(find.byIcon(Icons.crop_square), findsNothing);
      expect(find.byIcon(Icons.bookmark_add), findsNothing);
      expect(find.byIcon(Icons.collections_bookmark_outlined), findsOneWidget); // Students can view slides
    });

    testWidgets('WhiteboardPainter paints coordinateSystem and laserPointer without throwing', (tester) async {
      final strokes = [
        WhiteboardStrokeEntity(
          id: 'stk_axes',
          tool: WhiteboardTool.coordinateSystem,
          colorValue: 0xFF2563EB,
          strokeWidth: 2.0,
          points: const [
            WhiteboardPoint(x: 0.1, y: 0.1),
            WhiteboardPoint(x: 0.9, y: 0.9),
          ],
          authorIdentity: 'TEA_01',
          authorName: 'Teacher',
          timestamp: DateTime.now(),
        ),
        WhiteboardStrokeEntity(
          id: 'stk_laser',
          tool: WhiteboardTool.laserPointer,
          colorValue: 0xFFEF4444,
          strokeWidth: 4.0,
          points: const [
            WhiteboardPoint(x: 0.5, y: 0.5),
          ],
          authorIdentity: 'TEA_01',
          authorName: 'Teacher',
          timestamp: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(400, 400),
              painter: WhiteboardPainter(
                strokes: strokes,
                activePoints: const [],
                activeTool: WhiteboardTool.pen,
                activeColor: Colors.blue,
                activeStrokeWidth: 3.0,
                isDark: true,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
