class EnrollmentEntity {
  final int enrollmentId;
  final int courseId;
  final String courseTitle;
  final String courseSlug;
  final String? courseThumbnail;
  final String? teacherName;
  final String? teacherHeadline;
  final String status; // 'active', 'completed', 'cancelled'
  final int progressPercentage;
  final DateTime enrolledAt;
  final int totalModules;
  final int totalLessons;
  final int liveLessonsCount;
  final String? nextLiveSessionId;
  final String? nextLiveSessionTitle;
  final bool isLiveNow;

  const EnrollmentEntity({
    required this.enrollmentId,
    required this.courseId,
    required this.courseTitle,
    required this.courseSlug,
    this.courseThumbnail,
    this.teacherName,
    this.teacherHeadline,
    this.status = 'active',
    this.progressPercentage = 0,
    required this.enrolledAt,
    this.totalModules = 0,
    this.totalLessons = 0,
    this.liveLessonsCount = 0,
    this.nextLiveSessionId,
    this.nextLiveSessionTitle,
    this.isLiveNow = false,
  });

  bool get isCompleted => status == 'completed' || progressPercentage == 100;

  factory EnrollmentEntity.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? {};
    final teacher = course['teacher'] as Map<String, dynamic>?;
    final nextSession = course['next_live_session'] as Map<String, dynamic>?;

    return EnrollmentEntity(
      enrollmentId: json['enrollment_id'] as int? ?? (json['id'] as int? ?? 0),
      courseId: course['id'] as int? ?? (json['course_id'] as int? ?? 0),
      courseTitle: course['title'] as String? ?? (json['course_title'] as String? ?? 'Untitled Course'),
      courseSlug: course['slug'] as String? ?? (json['course_slug'] as String? ?? ''),
      courseThumbnail: course['thumbnail_url'] as String?,
      teacherName: teacher?['name'] as String?,
      teacherHeadline: teacher?['headline'] as String?,
      status: json['status'] as String? ?? 'active',
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      enrolledAt: json['enrolled_at'] != null
          ? DateTime.tryParse(json['enrolled_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      totalModules: course['total_modules'] as int? ?? 0,
      totalLessons: course['total_lessons'] as int? ?? 0,
      liveLessonsCount: course['live_lessons_count'] as int? ?? 0,
      nextLiveSessionId: nextSession?['session_id'] as String?,
      nextLiveSessionTitle: nextSession?['title'] as String?,
      isLiveNow: nextSession?['is_live'] as bool? ?? false,
    );
  }
}
