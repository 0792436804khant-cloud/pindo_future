import 'course_module_entity.dart';

class CourseEntity {
  final int id;
  final int teacherId;
  final String title;
  final String slug;
  final String description;
  final String category;
  final double price;
  final bool isFree;
  final String? thumbnailUrl;
  final String status; // 'draft', 'published', 'archived'
  final int modulesCount;
  final int lessonsCount;
  final int enrolledStudentsCount;
  final List<CourseModuleEntity> modules;
  final String? teacherName;
  final String? teacherHeadline;

  const CourseEntity({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.slug,
    this.description = '',
    this.category = 'General',
    this.price = 0.0,
    this.isFree = true,
    this.thumbnailUrl,
    this.status = 'draft',
    this.modulesCount = 0,
    this.lessonsCount = 0,
    this.enrolledStudentsCount = 0,
    this.modules = const [],
    this.teacherName,
    this.teacherHeadline,
  });

  bool get isPublished => status == 'published';

  factory CourseEntity.fromJson(Map<String, dynamic> json) {
    final rawModules = json['modules'] as List<dynamic>? ?? [];
    final parsedModules = rawModules
        .map((m) => CourseModuleEntity.fromJson(m as Map<String, dynamic>))
        .toList();

    final teacher = json['teacher'] as Map<String, dynamic>?;
    final platform = teacher?['teacher_platform'] as Map<String, dynamic>?;
    
    double priceVal = 0.0;
    if (json['price'] != null) {
      if (json['price'] is num) {
        priceVal = (json['price'] as num).toDouble();
      } else if (json['price'] is String) {
        priceVal = double.tryParse(json['price'] as String) ?? 0.0;
      }
    }

    return CourseEntity(
      id: json['id'] as int? ?? 0,
      teacherId: json['teacher_id'] as int? ?? (teacher?['id'] as int? ?? 0),
      title: json['title'] as String? ?? 'Untitled Course',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      price: priceVal,
      isFree: json['is_free'] as bool? ?? (priceVal == 0.0),
      thumbnailUrl: json['thumbnail_url'] as String?,
      status: json['status'] as String? ?? 'draft',
      modulesCount: json['modules_count'] as int? ?? parsedModules.length,
      lessonsCount: json['lessons_count'] as int? ??
          parsedModules.fold<int>(0, (sum, m) => sum + m.lessons.length),
      enrolledStudentsCount: json['enrolled_students_count'] as int? ??
          (json['students_count'] as int? ?? 0),
      modules: parsedModules,
      teacherName: teacher?['name'] as String?,
      teacherHeadline: platform?['headline'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_id': teacherId,
      'title': title,
      'slug': slug,
      'description': description,
      'category': category,
      'price': price,
      'thumbnail_url': thumbnailUrl,
      'status': status,
    };
  }
}
