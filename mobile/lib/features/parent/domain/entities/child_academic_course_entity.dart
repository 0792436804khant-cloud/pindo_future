class ChildAcademicCourseEntity {
  final int enrollmentId;
  final String status;
  final String enrolledAt;
  final int progressPercentage;
  final int courseId;
  final String title;
  final String slug;
  final String category;
  final String description;
  final int totalModules;
  final int totalLessons;
  final int completedLessons;
  final String teacherName;
  final String? teacherHeadline;

  const ChildAcademicCourseEntity({
    required this.enrollmentId,
    required this.status,
    required this.enrolledAt,
    required this.progressPercentage,
    required this.courseId,
    required this.title,
    required this.slug,
    required this.category,
    required this.description,
    required this.totalModules,
    required this.totalLessons,
    required this.completedLessons,
    required this.teacherName,
    this.teacherHeadline,
  });

  factory ChildAcademicCourseEntity.fromJson(Map<String, dynamic> json) {
    final course = json['course'] as Map<String, dynamic>? ?? {};
    final teacher = course['teacher'] as Map<String, dynamic>? ?? {};

    return ChildAcademicCourseEntity(
      enrollmentId: json['enrollment_id'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      enrolledAt: json['enrolled_at'] as String? ?? '',
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      courseId: course['id'] as int? ?? 0,
      title: course['title'] as String? ?? 'Untitled Course',
      slug: course['slug'] as String? ?? '',
      category: course['category'] as String? ?? 'General',
      description: course['description'] as String? ?? '',
      totalModules: course['total_modules'] as int? ?? 0,
      totalLessons: course['total_lessons'] as int? ?? 0,
      completedLessons: course['completed_lessons'] as int? ?? 0,
      teacherName: teacher['name'] as String? ?? 'Instructor',
      teacherHeadline: teacher['headline'] as String?,
    );
  }
}
