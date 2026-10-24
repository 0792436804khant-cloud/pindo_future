import '../../domain/entities/whiteboard_snapshot_entity.dart';
import '../../domain/entities/whiteboard_stroke_entity.dart';

class WhiteboardSnapshotModel extends WhiteboardSnapshotEntity {
  const WhiteboardSnapshotModel({
    required super.id,
    required super.sessionId,
    required super.snapshotTitle,
    required super.version,
    required super.strokeCount,
    required super.authorName,
    super.thumbnailUrl,
    required super.vectorData,
    required super.createdAt,
  });

  factory WhiteboardSnapshotModel.fromJson(Map<String, dynamic> json, {String? defaultSessionId}) {
    final rawStrokes = json['vector_data'] as List<dynamic>? ?? [];
    final strokes = rawStrokes
        .whereType<Map<String, dynamic>>()
        .map((s) => WhiteboardStrokeEntity.fromJson(s))
        .toList();

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['created_at'] as String? ?? '');
    } catch (_) {
      parsedDate = DateTime.now();
    }

    String author = 'Instructor';
    if (json['author'] is Map<String, dynamic>) {
      author = json['author']['name'] as String? ?? 'Instructor';
    } else if (json['author_name'] is String) {
      author = json['author_name'] as String;
    }

    return WhiteboardSnapshotModel(
      id: json['id'] as int? ?? 0,
      sessionId: json['session_id'] as String? ?? defaultSessionId ?? '',
      snapshotTitle: json['snapshot_title'] as String? ?? 'Lecture Slide Notes',
      version: json['version'] as int? ?? 1,
      strokeCount: json['stroke_count'] as int? ?? strokes.length,
      authorName: author,
      thumbnailUrl: json['thumbnail_url'] as String?,
      vectorData: strokes,
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'snapshot_title': snapshotTitle,
        'version': version,
        'stroke_count': strokeCount,
        'author_name': authorName,
        'thumbnail_url': thumbnailUrl,
        'vector_data': vectorData.map((s) => s.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };
}
