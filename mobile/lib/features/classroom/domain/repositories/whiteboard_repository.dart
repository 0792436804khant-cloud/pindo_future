import '../entities/whiteboard_snapshot_entity.dart';
import '../entities/whiteboard_stroke_entity.dart';

abstract class WhiteboardRepository {
  Future<WhiteboardSnapshotEntity> saveSnapshot({
    required String sessionId,
    required String title,
    required List<WhiteboardStrokeEntity> strokes,
    String? token,
  });

  Future<WhiteboardSnapshotEntity?> getLatestSnapshot({
    required String sessionId,
    String? token,
  });

  Future<List<WhiteboardSnapshotEntity>> getSnapshotHistory({
    required String sessionId,
    String? token,
  });
}
