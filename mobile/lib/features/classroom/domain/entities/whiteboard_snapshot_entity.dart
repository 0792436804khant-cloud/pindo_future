import 'whiteboard_stroke_entity.dart';

class WhiteboardSnapshotEntity {
  final int id;
  final String sessionId;
  final String snapshotTitle;
  final int version;
  final int strokeCount;
  final String authorName;
  final String? thumbnailUrl;
  final List<WhiteboardStrokeEntity> vectorData;
  final DateTime createdAt;

  const WhiteboardSnapshotEntity({
    required this.id,
    required this.sessionId,
    required this.snapshotTitle,
    required this.version,
    required this.strokeCount,
    required this.authorName,
    this.thumbnailUrl,
    required this.vectorData,
    required this.createdAt,
  });
}
