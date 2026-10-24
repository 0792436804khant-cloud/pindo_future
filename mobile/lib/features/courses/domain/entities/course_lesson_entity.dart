class CourseLessonEntity {
  final int id;
  final int moduleId;
  final String title;
  final String type; // 'live_session', 'video', 'document'
  final int? classroomSessionId;
  final String? sessionId; // e.g. SES_DEMO_LIVE
  final int durationMinutes;
  final int order;
  final String? contentUrl;
  final bool isLiveNow;

  const CourseLessonEntity({
    required this.id,
    required this.moduleId,
    required this.title,
    this.type = 'live_session',
    this.classroomSessionId,
    this.sessionId,
    this.durationMinutes = 45,
    this.order = 1,
    this.contentUrl,
    this.isLiveNow = false,
  });

  bool get isLiveSession => type == 'live_session';
  bool get isVideo => type == 'video';
  bool get isDocument => type == 'document';

  factory CourseLessonEntity.fromJson(Map<String, dynamic> json) {
    final classroomSession = json['classroom_session'] as Map<String, dynamic>?;

    return CourseLessonEntity(
      id: json['id'] as int? ?? 0,
      moduleId: json['course_module_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled Lesson',
      type: json['type'] as String? ?? 'live_session',
      classroomSessionId: json['classroom_session_id'] as int?,
      sessionId: classroomSession?['session_id'] as String?,
      durationMinutes: json['duration_minutes'] as int? ?? 45,
      order: json['order'] as int? ?? 1,
      contentUrl: json['content_url'] as String?,
      isLiveNow: classroomSession?['status'] == 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_module_id': moduleId,
      'title': title,
      'type': type,
      'classroom_session_id': classroomSessionId,
      'duration_minutes': durationMinutes,
      'order': order,
      'content_url': contentUrl,
    };
  }
}
