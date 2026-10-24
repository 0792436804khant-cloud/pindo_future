import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/classroom/domain/entities/classroom_stage_mode.dart';
import 'package:pindo_future_mobile/features/classroom/domain/entities/whiteboard_stroke_entity.dart';

void main() {
  group('Phase 8: Whiteboard & Screen Sharing Entities Tests', () {
    test('WhiteboardStrokeEntity serializes and deserializes correctly', () {
      final stroke = WhiteboardStrokeEntity(
        id: 'stroke_101',
        tool: WhiteboardTool.pen,
        colorValue: 0xFF0D9488,
        strokeWidth: 4.5,
        points: const [
          WhiteboardPoint(x: 0.12, y: 0.34),
          WhiteboardPoint(x: 0.15, y: 0.38),
          WhiteboardPoint(x: 0.22, y: 0.45),
        ],
        text: null,
        authorIdentity: 'TCH_123',
        authorName: 'Alan Turing',
        timestamp: DateTime.parse('2026-10-14T10:00:00Z'),
      );

      final json = stroke.toJson();
      expect(json['id'], 'stroke_101');
      expect(json['tool'], 'pen');
      expect(json['color_value'], 0xFF0D9488);
      expect(json['stroke_width'], 4.5);
      expect((json['points'] as List).length, 3);
      expect(json['author_name'], 'Alan Turing');

      final deserialized = WhiteboardStrokeEntity.fromJson(json);
      expect(deserialized.id, 'stroke_101');
      expect(deserialized.tool, WhiteboardTool.pen);
      expect(deserialized.points.length, 3);
      expect(deserialized.points.first.x, 0.12);
      expect(deserialized.points.first.y, 0.34);
      expect(deserialized.authorIdentity, 'TCH_123');
    });

    test('ClassroomStageMode parsing and serialization', () {
      expect(ClassroomStageMode.camera.name, 'camera');
      expect(ClassroomStageMode.whiteboard.name, 'whiteboard');
      expect(ClassroomStageMode.screenShare.name, 'screen_share');

      expect(ClassroomStageModeExtension.fromString('whiteboard'), ClassroomStageMode.whiteboard);
      expect(ClassroomStageModeExtension.fromString('screen_share'), ClassroomStageMode.screenShare);
      expect(ClassroomStageModeExtension.fromString('camera'), ClassroomStageMode.camera);
      expect(ClassroomStageModeExtension.fromString(null), ClassroomStageMode.camera);
    });
  });
}
