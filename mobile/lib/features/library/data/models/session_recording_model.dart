import '../../domain/entities/session_recording_entity.dart';

class SessionRecordingModel extends SessionRecordingEntity {
  const SessionRecordingModel({
    required super.id,
    required super.recordingCode,
    required super.title,
    super.description,
    required super.durationSeconds,
    required super.viewsCount,
    required super.createdAt,
    required super.isAccessible,
  });

  factory SessionRecordingModel.fromJson(Map<String, dynamic> json) {
    return SessionRecordingModel(
      id: json['id'] as int? ?? 0,
      recordingCode: json['recording_code'] as String? ?? '',
      title: json['title'] as String? ?? 'Lecture Recording',
      description: json['description'] as String?,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      isAccessible: json['is_accessible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recording_code': recordingCode,
      'title': title,
      'description': description,
      'duration_seconds': durationSeconds,
      'views_count': viewsCount,
      'created_at': createdAt,
      'is_accessible': isAccessible,
    };
  }
}
