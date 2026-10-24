import '../../domain/entities/study_cohort_entity.dart';

class StudyCohortModel extends StudyCohortEntity {
  const StudyCohortModel({
    required super.id,
    required super.cohortCode,
    required super.teacherId,
    super.teacherName,
    super.isTeacherVerified,
    super.teacherWilaya,
    required super.name,
    required super.subject,
    required super.academicLevel,
    super.stream,
    super.maxStudents,
    super.enrolledCount,
    super.monthlyPrice,
    super.schedule,
    super.isActive,
    super.description,
    super.sessions,
  });

  factory StudyCohortModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>?;

    final teacherVerifiedRaw = teacher?['is_verified'];
    final isVerified = teacherVerifiedRaw == true ||
        teacherVerifiedRaw == 1 ||
        teacherVerifiedRaw == '1';

    final scheduleRaw = json['schedule'];
    List<Map<String, dynamic>> scheduleList = [];
    if (scheduleRaw is List) {
      for (final item in scheduleRaw) {
        if (item is Map) {
          scheduleList.add(Map<String, dynamic>.from(item));
        }
      }
    }

    final priceRaw = json['monthly_price'];
    final price = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '0') ?? 0.0;

    final maxRaw = json['max_students'];
    final max = maxRaw is num
        ? maxRaw.toInt()
        : int.tryParse(maxRaw?.toString() ?? '100') ?? 100;

    final enrolledRaw = json['enrolled_count'] ?? json['active_students_count'];
    final enrolled = enrolledRaw is num
        ? enrolledRaw.toInt()
        : int.tryParse(enrolledRaw?.toString() ?? '0') ?? 0;

    final activeRaw = json['is_active'];
    final isActive = activeRaw == null ||
        activeRaw == true ||
        activeRaw == 1 ||
        activeRaw == '1';

    return StudyCohortModel(
      id: json['id'] as int? ?? 0,
      cohortCode: json['cohort_code'] as String? ?? '',
      teacherId: json['teacher_id'] as int? ?? teacher?['id'] as int? ?? 0,
      teacherName: teacher?['name'] as String?,
      isTeacherVerified: isVerified,
      teacherWilaya: teacher?['wilaya'] as int?,
      name: json['name'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      academicLevel: json['academic_level'] as String? ?? '',
      stream: json['stream'] as String?,
      maxStudents: max,
      enrolledCount: enrolled,
      monthlyPrice: price,
      schedule: scheduleList,
      isActive: isActive,
      description: json['description'] as String?,
      sessions: json['sessions'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cohort_code': cohortCode,
      'teacher_id': teacherId,
      'name': name,
      'subject': subject,
      'academic_level': academicLevel,
      'stream': stream,
      'max_students': maxStudents,
      'enrolled_count': enrolledCount,
      'monthly_price': monthlyPrice,
      'schedule': schedule,
      'is_active': isActive,
      'description': description,
    };
  }
}
