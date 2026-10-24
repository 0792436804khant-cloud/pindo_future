import 'course_entity.dart';

class StudentAchievementEntity {
  final String id;
  final String title;
  final String studentName;
  final String gradeOrScore;
  final String year;
  final String photoUrl;
  final String description;

  const StudentAchievementEntity({
    required this.id,
    required this.title,
    this.studentName = '',
    this.gradeOrScore = '',
    this.year = '',
    this.photoUrl = '',
    this.description = '',
  });

  factory StudentAchievementEntity.fromJson(Map<String, dynamic> json) {
    return StudentAchievementEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Academic Honor',
      studentName: json['student_name']?.toString() ?? '',
      gradeOrScore: json['grade_or_score']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'student_name': studentName,
      'grade_or_score': gradeOrScore,
      'year': year,
      'photo_url': photoUrl,
      'description': description,
    };
  }
}

class TeacherShowcaseEntity {
  final int id;
  final String name;
  final String email;
  final String teacherId; // TCH_123
  final String deepLinkUrl;
  final String headline;
  final String bio;
  final String? websiteUrl;
  final String? avatarUrl;
  final int? yearsOfExperience;
  final List<String> teachingLevels;
  final List<String> teachingYears;
  final List<String> teachingSubjects;
  final List<StudentAchievementEntity> studentAchievements;
  final int totalCourses;
  final int totalSessions;
  final int totalStudents;
  final String? activeSessionId;
  final String? activeSessionTitle;
  final bool hasActiveLiveSession;
  final List<CourseEntity> courses;

  const TeacherShowcaseEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.teacherId,
    required this.deepLinkUrl,
    required this.headline,
    required this.bio,
    this.websiteUrl,
    this.avatarUrl,
    this.yearsOfExperience,
    this.teachingLevels = const [],
    this.teachingYears = const [],
    this.teachingSubjects = const [],
    this.studentAchievements = const [],
    this.totalCourses = 0,
    this.totalSessions = 0,
    this.totalStudents = 0,
    this.activeSessionId,
    this.activeSessionTitle,
    this.hasActiveLiveSession = false,
    this.courses = const [],
  });

  factory TeacherShowcaseEntity.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>? ?? {};
    final platform = json['platform'] as Map<String, dynamic>? ?? {};
    final metrics = json['metrics'] as Map<String, dynamic>? ?? {};
    final activeSession = json['active_session'] as Map<String, dynamic>?;

    final rawCourses = json['courses'] as List<dynamic>? ?? [];
    final parsedCourses = rawCourses
        .whereType<Map<String, dynamic>>()
        .map((c) => CourseEntity.fromJson(c))
        .toList();

    // Achievements from platform or teacher
    final rawAchievements = (platform['student_achievements'] ?? teacher['student_achievements']) as List<dynamic>? ?? [];
    final parsedAchievements = rawAchievements
        .whereType<Map<String, dynamic>>()
        .map((a) => StudentAchievementEntity.fromJson(a))
        .toList();

    // Classifications
    final rawLevels = (teacher['teaching_levels'] ?? platform['teaching_levels']) as List<dynamic>? ?? [];
    final rawYears = (teacher['teaching_years'] ?? platform['teaching_years']) as List<dynamic>? ?? [];
    final rawSubjects = (teacher['teaching_subjects'] ?? platform['teaching_subjects']) as List<dynamic>? ?? [];

    final avatar = (platform['avatar_url'] ?? teacher['avatar_url'])?.toString();
    final expRaw = platform['years_of_experience'] ?? teacher['years_of_experience'];
    final exp = expRaw is num ? expRaw.toInt() : int.tryParse(expRaw?.toString() ?? '');

    return TeacherShowcaseEntity(
      id: teacher['id'] as int? ?? 0,
      name: teacher['name'] as String? ?? 'Instructor',
      email: teacher['email'] as String? ?? '',
      teacherId: teacher['teacher_id'] as String? ?? '',
      deepLinkUrl: teacher['deep_link_url'] as String? ?? '',
      headline: platform['headline'] as String? ?? 'Verified Instructor',
      bio: platform['bio'] as String? ?? '',
      websiteUrl: platform['website_url'] as String?,
      avatarUrl: (avatar != null && avatar.trim().isNotEmpty) ? avatar : null,
      yearsOfExperience: exp,
      teachingLevels: rawLevels.map((e) => e.toString()).toList(),
      teachingYears: rawYears.map((e) => e.toString()).toList(),
      teachingSubjects: rawSubjects.map((e) => e.toString()).toList(),
      studentAchievements: parsedAchievements,
      totalCourses: metrics['total_courses'] as int? ?? parsedCourses.length,
      totalSessions: metrics['total_sessions_hosted'] as int? ?? 0,
      totalStudents: metrics['total_enrolled_students'] as int? ?? 0,
      activeSessionId: activeSession?['session_id'] as String?,
      activeSessionTitle: activeSession?['title'] as String?,
      hasActiveLiveSession: activeSession != null && activeSession['is_live'] == true,
      courses: parsedCourses,
    );
  }
}
