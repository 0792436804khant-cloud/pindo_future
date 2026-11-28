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
    super.liveSessionsPrice,
    super.libraryPrice,
    super.bundlePrice,
    super.includeLibrary,
    super.includedSessionsCount,
    super.extraSessionsCount,
    super.extraSessionsIsPaid,
    super.extraSessionPriceDzd,
    super.teacherBio,
    super.teacherHeadline,
    super.teacherYearsExperience,
    super.teacherAvatarUrl,
    super.teacherSubjects,
    super.teacherYears,
    super.schedule,
    super.isActive,
    super.description,
    super.sessions,
  });

  factory StudyCohortModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>?;
    final platform = teacher?['teacher_platform'] as Map<String, dynamic>?;
    final settings = platform?['settings'] as Map<String, dynamic>?;

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

    final liveRaw = json['live_sessions_price'];
    final livePrice = liveRaw is num
        ? liveRaw.toDouble()
        : double.tryParse(liveRaw?.toString() ?? '') ?? price;

    final libRaw = json['library_price'];
    final libraryPrice = libRaw is num
        ? libRaw.toDouble()
        : double.tryParse(libRaw?.toString() ?? '0') ?? 0.0;

    final bundleRaw = json['bundle_price'];
    final bundlePrice = bundleRaw is num
        ? bundleRaw.toDouble()
        : double.tryParse(bundleRaw?.toString() ?? '') ??
            (livePrice + libraryPrice > 0 ? livePrice + libraryPrice : price);

    final includeLibRaw = json['include_library'] ?? json['has_library'];
    final includeLibrary = includeLibRaw == null ||
        includeLibRaw == true ||
        includeLibRaw == 1 ||
        includeLibRaw == '1';

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

    final includedRaw = json['included_sessions_count'];
    final includedSessions = includedRaw is num
        ? includedRaw.toInt()
        : int.tryParse(includedRaw?.toString() ?? '8') ?? 8;

    final extraCountRaw = json['extra_sessions_count'];
    final extraSessions = extraCountRaw is num
        ? extraCountRaw.toInt()
        : int.tryParse(extraCountRaw?.toString() ?? '0') ?? 0;

    final extraPaidRaw = json['extra_sessions_is_paid'];
    final extraPaid = extraPaidRaw == true || extraPaidRaw == 1 || extraPaidRaw == '1';

    final extraPriceRaw = json['extra_session_price_dzd'];
    final extraPrice = extraPriceRaw is num
        ? extraPriceRaw.toDouble()
        : double.tryParse(extraPriceRaw?.toString() ?? '0') ?? 0.0;

    final teacherYearsExpRaw = settings?['years_of_experience'];
    final teacherYearsExp = teacherYearsExpRaw is num
        ? teacherYearsExpRaw.toInt()
        : int.tryParse(teacherYearsExpRaw?.toString() ?? '');

    final teacherSubjectsRaw = teacher?['teaching_subjects'];
    final teacherSubjects = teacherSubjectsRaw is List
        ? teacherSubjectsRaw.map((e) => e.toString()).toList()
        : const <String>[];

    final teacherYearsRaw = teacher?['teaching_years'];
    final teacherYears = teacherYearsRaw is List
        ? teacherYearsRaw.map((e) => e.toString()).toList()
        : const <String>[];

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
      liveSessionsPrice: livePrice,
      libraryPrice: libraryPrice,
      bundlePrice: bundlePrice,
      includeLibrary: includeLibrary,
      includedSessionsCount: includedSessions,
      extraSessionsCount: extraSessions,
      extraSessionsIsPaid: extraPaid,
      extraSessionPriceDzd: extraPrice,
      teacherBio: platform?['bio']?.toString(),
      teacherHeadline: platform?['headline']?.toString(),
      teacherYearsExperience: teacherYearsExp,
      teacherAvatarUrl: settings?['avatar_url']?.toString(),
      teacherSubjects: teacherSubjects,
      teacherYears: teacherYears,
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
      'live_sessions_price': liveSessionsPrice,
      'library_price': libraryPrice,
      'bundle_price': bundlePrice,
      'include_library': includeLibrary,
      'schedule': schedule,
      'is_active': isActive,
      'description': description,
    };
  }
}
