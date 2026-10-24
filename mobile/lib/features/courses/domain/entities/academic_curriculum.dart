import 'package:flutter/material.dart';
import 'teacher_showcase_entity.dart';

/// Represents an educational cycle / level of study
class AcademicLevel {
  final String id;
  final String title;
  final String arabicTitle;
  final String badge;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
  final List<AcademicYear> years;

  const AcademicLevel({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.badge,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
    required this.years,
  });
}

/// Represents an academic year / grade within a level
class AcademicYear {
  final String id;
  final String levelId;
  final String title;
  final String arabicTitle;
  final String code;
  final List<AcademicSubject> subjects;

  const AcademicYear({
    required this.id,
    required this.levelId,
    required this.title,
    required this.arabicTitle,
    required this.code,
    required this.subjects,
  });
}

/// Represents a specific subject taught within an academic year
class AcademicSubject {
  final String id;
  final String title;
  final String arabicTitle;
  final IconData icon;
  final Color color;
  final String categoryTag;

  const AcademicSubject({
    required this.id,
    required this.title,
    required this.arabicTitle,
    required this.icon,
    required this.color,
    required this.categoryTag,
  });
}

/// Teacher directory item returned for subject queries
class TeacherDirectoryItem {
  final int id;
  final String name;
  final String email;
  final String teacherId;
  final String deepLinkUrl;
  final List<String> teachingLevels;
  final List<String> teachingYears;
  final List<String> teachingSubjects;
  final String headline;
  final String bio;
  final bool isLive;
  final String? liveSessionId;
  final int totalCourses;
  final int totalStudents;
  final String? avatarUrl;
  final int? yearsOfExperience;
  final List<StudentAchievementEntity> studentAchievements;

  const TeacherDirectoryItem({
    required this.id,
    required this.name,
    required this.email,
    required this.teacherId,
    required this.deepLinkUrl,
    required this.teachingLevels,
    required this.teachingYears,
    required this.teachingSubjects,
    required this.headline,
    required this.bio,
    required this.isLive,
    this.liveSessionId,
    required this.totalCourses,
    required this.totalStudents,
    this.avatarUrl,
    this.yearsOfExperience,
    this.studentAchievements = const [],
  });

  factory TeacherDirectoryItem.fromJson(Map<String, dynamic> json) {
    final activeSession = json['active_session'];
    final metrics = json['metrics'] as Map<String, dynamic>? ?? {};

    final rawAchievements = json['student_achievements'] as List<dynamic>? ?? [];
    final parsedAchievements = rawAchievements
        .whereType<Map<String, dynamic>>()
        .map((a) => StudentAchievementEntity.fromJson(a))
        .toList();

    final expRaw = json['years_of_experience'];
    final exp = expRaw is num ? expRaw.toInt() : int.tryParse(expRaw?.toString() ?? '');
    final avatar = json['avatar_url']?.toString();

    return TeacherDirectoryItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Instructor',
      email: json['email'] as String? ?? '',
      teacherId: json['teacher_id'] as String? ?? 'TCH_101',
      deepLinkUrl: json['deep_link_url'] as String? ?? '',
      teachingLevels: (json['teaching_levels'] as List? ?? []).map((e) => e.toString()).toList(),
      teachingYears: (json['teaching_years'] as List? ?? []).map((e) => e.toString()).toList(),
      teachingSubjects: (json['teaching_subjects'] as List? ?? []).map((e) => e.toString()).toList(),
      headline: json['headline'] as String? ?? 'Verified Instructor at Pindo Future',
      bio: json['bio'] as String? ?? '',
      isLive: activeSession != null && (activeSession['is_live'] == true),
      liveSessionId: activeSession != null ? activeSession['session_id'] as String? : null,
      totalCourses: metrics['total_courses'] as int? ?? 0,
      totalStudents: metrics['total_enrolled_students'] as int? ?? 0,
      avatarUrl: (avatar != null && avatar.trim().isNotEmpty) ? avatar : null,
      yearsOfExperience: exp,
      studentAchievements: parsedAchievements,
    );
  }
}

/// Comprehensive Educational Curriculum Catalog
class AcademicCurriculumCatalog {
  static const Color brightCyan = Color(0xFF00E5FF);
  static const Color electricPurple = Color(0xFF7C4DFF);
  static const Color deepIndigo = Color(0xFF311B92);
  static const Color neonEmerald = Color(0xFF10B981);
  static const Color warmAmber = Color(0xFFF59E0B);
  static const Color coralRose = Color(0xFFF43F5E);

  static List<AcademicLevel> getAllLevels() {
    return [
      // 1. PRIMARY SCHOOL
      AcademicLevel(
        id: 'primary',
        title: 'Primary School',
        arabicTitle: 'التعليم الابتدائي',
        badge: '5 Academic Years (1AP - 5AP)',
        icon: Icons.backpack_rounded,
        accentColor: neonEmerald,
        gradientColors: [
          const Color(0xFF064E3B).withValues(alpha: 0.85),
          const Color(0xFF059669).withValues(alpha: 0.45),
          const Color(0xFF0F172A).withValues(alpha: 0.90),
        ],
        years: [
          AcademicYear(
            id: '1ap',
            levelId: 'primary',
            title: '1st Year Primary',
            arabicTitle: 'السنة الأولى ابتدائي',
            code: '1AP',
            subjects: _getPrimarySubjects(),
          ),
          AcademicYear(
            id: '2ap',
            levelId: 'primary',
            title: '2nd Year Primary',
            arabicTitle: 'السنة الثانية ابتدائي',
            code: '2AP',
            subjects: _getPrimarySubjects(),
          ),
          AcademicYear(
            id: '3ap',
            levelId: 'primary',
            title: '3rd Year Primary',
            arabicTitle: 'السنة الثالثة ابتدائي',
            code: '3AP',
            subjects: _getPrimarySubjects(),
          ),
          AcademicYear(
            id: '4ap',
            levelId: 'primary',
            title: '4th Year Primary',
            arabicTitle: 'السنة الرابعة ابتدائي',
            code: '4AP',
            subjects: _getPrimarySubjects(),
          ),
          AcademicYear(
            id: '5ap',
            levelId: 'primary',
            title: '5th Year Primary (Graduation)',
            arabicTitle: 'السنة الخامسة ابتدائي (امتحان التخرج)',
            code: '5AP',
            subjects: _getPrimarySubjects(),
          ),
        ],
      ),

      // 2. MIDDLE SCHOOL (CEM)
      AcademicLevel(
        id: 'middle',
        title: 'Middle School (CEM)',
        arabicTitle: 'التعليم المتوسط',
        badge: '4 Academic Years (1AM - 4AM BEM)',
        icon: Icons.school_rounded,
        accentColor: brightCyan,
        gradientColors: [
          const Color(0xFF0C4A6E).withValues(alpha: 0.85),
          const Color(0xFF0284C7).withValues(alpha: 0.45),
          const Color(0xFF0F172A).withValues(alpha: 0.90),
        ],
        years: [
          AcademicYear(
            id: '1am',
            levelId: 'middle',
            title: '1st Middle School',
            arabicTitle: 'السنة الأولى متوسط',
            code: '1AM',
            subjects: _getMiddleSubjects(),
          ),
          AcademicYear(
            id: '2am',
            levelId: 'middle',
            title: '2nd Middle School',
            arabicTitle: 'السنة الثانية متوسط',
            code: '2AM',
            subjects: _getMiddleSubjects(),
          ),
          AcademicYear(
            id: '3am',
            levelId: 'middle',
            title: '3rd Middle School',
            arabicTitle: 'السنة الثالثة متوسط',
            code: '3AM',
            subjects: _getMiddleSubjects(),
          ),
          AcademicYear(
            id: '4am',
            levelId: 'middle',
            title: '4th Middle School (BEM Exam)',
            arabicTitle: 'السنة الرابعة متوسط (شهادة التعليم المتوسط BEM)',
            code: '4AM (BEM)',
            subjects: _getMiddleSubjects(),
          ),
        ],
      ),

      // 3. HIGH SCHOOL (SECONDARY)
      AcademicLevel(
        id: 'high',
        title: 'High School (Secondary)',
        arabicTitle: 'التعليم الثانوي',
        badge: '3 Academic Years (1AS - 3AS BAC)',
        icon: Icons.auto_stories_rounded,
        accentColor: electricPurple,
        gradientColors: [
          deepIndigo.withValues(alpha: 0.85),
          electricPurple.withValues(alpha: 0.50),
          const Color(0xFF0F172A).withValues(alpha: 0.90),
        ],
        years: [
          AcademicYear(
            id: '1as',
            levelId: 'high',
            title: '1st Year Secondary (Tronc Commun)',
            arabicTitle: 'السنة الأولى ثانوي (جذع مشترك)',
            code: '1AS',
            subjects: _getHighSchoolSubjects(),
          ),
          AcademicYear(
            id: '2as',
            levelId: 'high',
            title: '2nd Year Secondary (Filières)',
            arabicTitle: 'السنة الثانية ثانوي (تخصص شعب)',
            code: '2AS',
            subjects: _getHighSchoolSubjects(),
          ),
          AcademicYear(
            id: '3as_bac',
            levelId: 'high',
            title: '3rd Year Secondary (Baccalaureate - BAC)',
            arabicTitle: 'السنة الثالثة ثانوي (بكالوريا BAC)',
            code: '3AS (BAC)',
            subjects: _getHighSchoolSubjects(),
          ),
        ],
      ),

      // 4. UNIVERSITY & HIGHER ED
      AcademicLevel(
        id: 'university',
        title: 'University & Higher Ed',
        arabicTitle: 'التعليم الجامعي والعالي',
        badge: 'Undergrad & Master / Engineering',
        icon: Icons.account_balance_rounded,
        accentColor: warmAmber,
        gradientColors: [
          const Color(0xFF78350F).withValues(alpha: 0.85),
          const Color(0xFFD97706).withValues(alpha: 0.45),
          const Color(0xFF0F172A).withValues(alpha: 0.90),
        ],
        years: [
          AcademicYear(
            id: 'l1',
            levelId: 'university',
            title: '1st Year License (L1)',
            arabicTitle: 'السنة الأولى ليسانس',
            code: 'L1',
            subjects: _getUniversitySubjects(),
          ),
          AcademicYear(
            id: 'l2',
            levelId: 'university',
            title: '2nd Year License (L2)',
            arabicTitle: 'السنة الثانية ليسانس',
            code: 'L2',
            subjects: _getUniversitySubjects(),
          ),
          AcademicYear(
            id: 'l3',
            levelId: 'university',
            title: '3rd Year License (L3 Graduation)',
            arabicTitle: 'السنة الثالثة ليسانس (تخرج)',
            code: 'L3',
            subjects: _getUniversitySubjects(),
          ),
          AcademicYear(
            id: 'master',
            levelId: 'university',
            title: 'Master & Engineering Degrees',
            arabicTitle: 'ماستر ومدارس الهندسة العليا',
            code: 'Master / Engineer',
            subjects: _getUniversitySubjects(),
          ),
        ],
      ),
    ];
  }

  static List<AcademicSubject> _getPrimarySubjects() {
    return [
      const AcademicSubject(
        id: 'prim_math',
        title: 'Mathematics',
        arabicTitle: 'الرياضيات',
        icon: Icons.calculate_rounded,
        color: brightCyan,
        categoryTag: 'Mathematics',
      ),
      const AcademicSubject(
        id: 'prim_arabic',
        title: 'Arabic Language',
        arabicTitle: 'اللغة العربية',
        icon: Icons.menu_book_rounded,
        color: neonEmerald,
        categoryTag: 'Languages',
      ),
      const AcademicSubject(
        id: 'prim_french',
        title: 'French Language',
        arabicTitle: 'اللغة الفرنسية',
        icon: Icons.language_rounded,
        color: electricPurple,
        categoryTag: 'Languages',
      ),
      const AcademicSubject(
        id: 'prim_science',
        title: 'Science & Technology',
        arabicTitle: 'التربية العلمية والتكنولوجية',
        icon: Icons.science_rounded,
        color: warmAmber,
        categoryTag: 'Sciences',
      ),
      const AcademicSubject(
        id: 'prim_islamic',
        title: 'Islamic Education',
        arabicTitle: 'التربية الإسلامية',
        icon: Icons.brightness_medium_rounded,
        color: coralRose,
        categoryTag: 'Humanities',
      ),
    ];
  }

  static List<AcademicSubject> _getMiddleSubjects() {
    return [
      const AcademicSubject(
        id: 'mid_math',
        title: 'Mathematics',
        arabicTitle: 'الرياضيات',
        icon: Icons.calculate_rounded,
        color: brightCyan,
        categoryTag: 'Mathematics',
      ),
      const AcademicSubject(
        id: 'mid_physics',
        title: 'Physical Sciences & Chemistry',
        arabicTitle: 'العلوم الفيزيائية والتكنولوجيا',
        icon: Icons.bolt_rounded,
        color: electricPurple,
        categoryTag: 'Physics',
      ),
      const AcademicSubject(
        id: 'mid_biology',
        title: 'Natural & Life Sciences',
        arabicTitle: 'علوم الطبيعة والحياة',
        icon: Icons.biotech_rounded,
        color: neonEmerald,
        categoryTag: 'Biology',
      ),
      const AcademicSubject(
        id: 'mid_arabic',
        title: 'Arabic Language & Literature',
        arabicTitle: 'اللغة العربية وآدابها',
        icon: Icons.menu_book_rounded,
        color: coralRose,
        categoryTag: 'Languages',
      ),
      const AcademicSubject(
        id: 'mid_french',
        title: 'French Language',
        arabicTitle: 'اللغة الفرنسية',
        icon: Icons.language_rounded,
        color: warmAmber,
        categoryTag: 'Languages',
      ),
      const AcademicSubject(
        id: 'mid_english',
        title: 'English Language',
        arabicTitle: 'اللغة الإنجليزية',
        icon: Icons.public_rounded,
        color: brightCyan,
        categoryTag: 'Languages',
      ),
      const AcademicSubject(
        id: 'mid_history',
        title: 'History & Geography',
        arabicTitle: 'التاريخ والجغرافيا',
        icon: Icons.map_rounded,
        color: warmAmber,
        categoryTag: 'Social Studies',
      ),
      const AcademicSubject(
        id: 'mid_cs',
        title: 'Computer Science',
        arabicTitle: 'الإعلام الآلي',
        icon: Icons.computer_rounded,
        color: electricPurple,
        categoryTag: 'Technology',
      ),
    ];
  }

  static List<AcademicSubject> _getHighSchoolSubjects() {
    return [
      const AcademicSubject(
        id: 'high_math',
        title: 'Advanced Mathematics',
        arabicTitle: 'الرياضيات المتقدمة',
        icon: Icons.functions_rounded,
        color: brightCyan,
        categoryTag: 'Advanced Mathematics',
      ),
      const AcademicSubject(
        id: 'high_physics',
        title: 'Physics & Chemistry',
        arabicTitle: 'الفيزياء والكيمياء',
        icon: Icons.biotech_rounded,
        color: electricPurple,
        categoryTag: 'Physics & Chemistry',
      ),
      const AcademicSubject(
        id: 'high_sciences',
        title: 'Natural & Life Sciences',
        arabicTitle: 'علوم الطبيعة والحياة',
        icon: Icons.eco_rounded,
        color: neonEmerald,
        categoryTag: 'Natural Sciences',
      ),
      const AcademicSubject(
        id: 'high_philosophy',
        title: 'Philosophy & Logic',
        arabicTitle: 'الفلسفة والمنطق',
        icon: Icons.psychology_rounded,
        color: warmAmber,
        categoryTag: 'Philosophy',
      ),
      const AcademicSubject(
        id: 'high_arabic',
        title: 'Arabic Literature',
        arabicTitle: 'الأدب العربي',
        icon: Icons.auto_stories_rounded,
        color: coralRose,
        categoryTag: 'Languages',
      ),
      const AcademicSubject(
        id: 'high_cs',
        title: 'Computer Science & Algorithms',
        arabicTitle: 'الإعلام الآلي والخوارزميات',
        icon: Icons.code_rounded,
        color: brightCyan,
        categoryTag: 'Computer Science',
      ),
      const AcademicSubject(
        id: 'high_languages',
        title: 'Foreign Languages (EN/FR)',
        arabicTitle: 'اللغات الأجنبية (فرنسية / إنجليزية)',
        icon: Icons.translate_rounded,
        color: electricPurple,
        categoryTag: 'Foreign Languages',
      ),
      const AcademicSubject(
        id: 'high_economics',
        title: 'Economics & Accounting',
        arabicTitle: 'التسيير المحاسبي والاقتصاد',
        icon: Icons.trending_up_rounded,
        color: neonEmerald,
        categoryTag: 'Economics',
      ),
    ];
  }

  static List<AcademicSubject> _getUniversitySubjects() {
    return [
      const AcademicSubject(
        id: 'univ_cs',
        title: 'Computer Science & Algorithms',
        arabicTitle: 'علوم الحاسوب وهندسة البرمجيات',
        icon: Icons.terminal_rounded,
        color: brightCyan,
        categoryTag: 'Computer Science',
      ),
      const AcademicSubject(
        id: 'univ_ai',
        title: 'Artificial Intelligence & Data Science',
        arabicTitle: 'الذكاء الاصطناعي وعلم البيانات',
        icon: Icons.memory_rounded,
        color: electricPurple,
        categoryTag: 'Artificial Intelligence',
      ),
      const AcademicSubject(
        id: 'univ_math',
        title: 'Higher Mathematics & Analysis',
        arabicTitle: 'الرياضيات العليا والتحليل',
        icon: Icons.grain_rounded,
        color: neonEmerald,
        categoryTag: 'Higher Mathematics',
      ),
      const AcademicSubject(
        id: 'univ_med',
        title: 'Medical & Pharmaceutical Sciences',
        arabicTitle: 'العلوم الطبية والصيدلانية',
        icon: Icons.local_hospital_rounded,
        color: coralRose,
        categoryTag: 'Medicine',
      ),
      const AcademicSubject(
        id: 'univ_eng',
        title: 'Electrical & Mechanical Engineering',
        arabicTitle: 'الهندسة الكهربائية والميكانيكية',
        icon: Icons.precision_manufacturing_rounded,
        color: warmAmber,
        categoryTag: 'Engineering',
      ),
      const AcademicSubject(
        id: 'univ_mgmt',
        title: 'Economics, Business & Management',
        arabicTitle: 'إدارة الأعمال والاقتصاد الدولي',
        icon: Icons.business_center_rounded,
        color: brightCyan,
        categoryTag: 'Management',
      ),
    ];
  }
}
