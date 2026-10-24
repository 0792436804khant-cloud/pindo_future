class ChildOverviewEntity {
  final int id;
  final String name;
  final String email;
  final String relationship;
  final String linkedAt;
  final int enrolledCoursesCount;
  final int completedCoursesCount;
  final double averageProgress;
  final int totalWatchSeconds;
  final double totalWatchMinutes;
  final int sessionsAttendedCount;
  final int notesCount;

  const ChildOverviewEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.relationship,
    required this.linkedAt,
    required this.enrolledCoursesCount,
    required this.completedCoursesCount,
    required this.averageProgress,
    required this.totalWatchSeconds,
    required this.totalWatchMinutes,
    required this.sessionsAttendedCount,
    required this.notesCount,
  });

  factory ChildOverviewEntity.fromJson(Map<String, dynamic> json) {
    final academics = json['academics'] as Map<String, dynamic>? ?? {};
    final attendance = json['attendance'] as Map<String, dynamic>? ?? {};

    return ChildOverviewEntity(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Student',
      email: json['email'] as String? ?? '',
      relationship: json['relationship'] as String? ?? 'Child',
      linkedAt: json['linked_at'] as String? ?? '',
      enrolledCoursesCount: academics['enrolled_courses_count'] as int? ?? 0,
      completedCoursesCount: academics['completed_courses_count'] as int? ?? 0,
      averageProgress: (academics['average_progress'] as num?)?.toDouble() ?? 0.0,
      totalWatchSeconds: attendance['total_watch_seconds'] as int? ?? 0,
      totalWatchMinutes: (attendance['total_watch_minutes'] as num?)?.toDouble() ?? 0.0,
      sessionsAttendedCount: attendance['sessions_attended_count'] as int? ?? 0,
      notesCount: json['notes_count'] as int? ?? 0,
    );
  }
}
