import 'course_lesson_entity.dart';

class CourseModuleEntity {
  final int id;
  final int courseId;
  final String title;
  final int order;
  final List<CourseLessonEntity> lessons;

  const CourseModuleEntity({
    required this.id,
    required this.courseId,
    required this.title,
    this.order = 1,
    this.lessons = const [],
  });

  factory CourseModuleEntity.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'] as List<dynamic>? ?? [];
    final parsedLessons = rawLessons
        .map((l) => CourseLessonEntity.fromJson(l as Map<String, dynamic>))
        .toList();

    return CourseModuleEntity(
      id: json['id'] as int? ?? 0,
      courseId: json['course_id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled Module',
      order: json['order'] as int? ?? 1,
      lessons: parsedLessons,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'order': order,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }
}
