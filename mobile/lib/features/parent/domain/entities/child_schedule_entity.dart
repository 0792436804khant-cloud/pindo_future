class ChildScheduleEntity {
  final String sessionId;
  final String title;
  final String status;
  final bool isLive;
  final String? scheduledAt;
  final String courseTitle;
  final String teacherName;

  const ChildScheduleEntity({
    required this.sessionId,
    required this.title,
    required this.status,
    required this.isLive,
    this.scheduledAt,
    required this.courseTitle,
    required this.teacherName,
  });

  factory ChildScheduleEntity.fromJson(Map<String, dynamic> json) {
    return ChildScheduleEntity(
      sessionId: json['session_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Masterclass',
      status: json['status'] as String? ?? 'scheduled',
      isLive: json['is_live'] as bool? ?? false,
      scheduledAt: json['scheduled_at'] as String?,
      courseTitle: json['course_title'] as String? ?? 'General Course',
      teacherName: json['teacher_name'] as String? ?? 'Instructor',
    );
  }
}
