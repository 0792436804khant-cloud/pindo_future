import 'package:flutter/foundation.dart';

@immutable
class TeacherDashboardModel {
  final TeacherProfileInfo teacherProfile;
  final TeacherStats stats;
  final TeacherUpcomingSession? upcomingSession;
  final List<TeacherScheduleItem> todaySchedule;
  final List<TeacherNotificationItem> notifications;
  final List<TeacherCohortItem> cohorts;
  final List<TeacherTransactionItem> recentTransactions;

  const TeacherDashboardModel({
    required this.teacherProfile,
    required this.stats,
    this.upcomingSession,
    required this.todaySchedule,
    required this.notifications,
    required this.cohorts,
    required this.recentTransactions,
  });

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return TeacherDashboardModel(
      teacherProfile: TeacherProfileInfo.fromJson(data['teacher'] as Map<String, dynamic>? ?? {}),
      stats: TeacherStats.fromJson(data['stats'] as Map<String, dynamic>? ?? {}),
      upcomingSession: data['upcoming_session'] != null
          ? TeacherUpcomingSession.fromJson(data['upcoming_session'] as Map<String, dynamic>)
          : null,
      todaySchedule: (data['today_schedule'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TeacherScheduleItem.fromJson(e))
          .toList(),
      notifications: (data['notifications'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TeacherNotificationItem.fromJson(e))
          .toList(),
      cohorts: (data['cohorts'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TeacherCohortItem.fromJson(e))
          .toList(),
      recentTransactions: (data['recent_transactions'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TeacherTransactionItem.fromJson(e))
          .toList(),
    );
  }

  factory TeacherDashboardModel.mockFallback({
    String teacherName = 'الأستاذ محمد أمين بن عيسى',
    String teacherId = 'TCH_DZ_2027',
  }) {
    return TeacherDashboardModel(
      teacherProfile: TeacherProfileInfo(
        id: 1,
        name: teacherName,
        email: 'amine@pindofuture.com',
        teacherId: teacherId,
        avatarUrl: null,
        coverImageUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7?w=1200&q=80',
        isVerified: true,
        yearsOfExperience: 10,
        headline: 'أستاذ رئيسي للتعليم الثانوي ومعد دورات المتفوقين في الرياضيات',
        wilaya: 'الجزائر العاصمة (القبة)',
        bio: 'أستاذ رئيسي للتعليم الثانوي، مؤلف سلاسل النخبة في الرياضيات، ومشرف على دورات تأهيل المتفوقين في شهادة البكالوريا منذ 10 سنوات بأعلى معدلات وطنية.',
        subjects: const ['الرياضيات', 'الفيزياء'],
        levels: const ['ثالثة ثانوي', 'ثانية ثانوي', 'أولى ثانوي'],
        stories: const [
          TeacherStoryItem(
            id: 's1',
            text: '🔴 تنبيه هام لجميع طلاب فوج النخبة:\nالحصة التفاعلية المباشرة لمراجعة الدوال الأسية وحل المسائل الشاملة تبدأ اليوم عند الساعة 18:00 مساءً. يرجى تحميل ملف التمارين المرفق في الفوج والاستعداد!',
            imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=800&q=80',
            mediaType: 'video',
            timeAgo: 'منذ ساعتين',
            viewsCount: 238,
            isLiveAlert: true,
            tag: '🔴 بث مباشر اليوم',
            actionButtonText: 'الانتقال لقاعة البث المباشر',
          ),
          TeacherStoryItem(
            id: 's2',
            text: '💡 نصيحة ذهبية لطلاب البكالوريا دورة 2025:\nفي مسائل المتتاليات وحساب النهايات، ركزوا دائماً على كتابة الخطوات والتعليلات المنهجية (الاستدلال بالتراجع، التقارب...). المصحح يمنح العلامات على المنهجية خطوة بخطوة!',
            imageUrl: 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?w=800&q=80',
            mediaType: 'image',
            timeAgo: 'منذ 5 ساعات',
            viewsCount: 412,
            tag: '💡 نصيحة منهجية',
          ),
          TeacherStoryItem(
            id: 's3',
            text: '🏆 فخور بتألق تلاميذنا في بكالوريا 2024:\nأكثر من 45 طالباً في أفواجنا نالوا علامة 19/20 فما فوق في الرياضيات بمعدلات عامة تجاوزت 18/20. العاقبة لدفعة 2025 لمواصلة مسيرة التميز!',
            imageUrl: 'https://images.unsplash.com/photo-1523240795612-9a054b0db644?w=800&q=80',
            mediaType: 'image',
            timeAgo: 'أمس',
            viewsCount: 560,
            tag: '🏆 فخر ونتائج',
          ),
        ],
        workplaces: const [
          TeacherWorkplaceItem(
            id: 'w1',
            name: 'ثانوية حسيبة بن بوعلي — القبة',
            type: 'ثانوية عمومية',
            wilaya: 'الجزائر العاصمة',
            role: 'أستاذ رئيسي لمادة الرياضيات (أقسام البكالوريا)',
            period: '2016 — حتى الآن',
            isCurrent: true,
          ),
          TeacherWorkplaceItem(
            id: 'w2',
            name: 'أكاديمية النجاح لدروس الدعم والتفوق',
            type: 'أكاديمية تدريب ودعم مدرسي',
            wilaya: 'الجزائر العاصمة / القبة والرويبة',
            role: 'مشرف ومؤطر مادة الرياضيات للأفواج النموذجية',
            period: '2019 — حتى الآن',
            isCurrent: true,
          ),
          TeacherWorkplaceItem(
            id: 'w3',
            name: 'مدرسة الفتح الخاصة المعتمدة',
            type: 'مدرسة خاصة معتمدة',
            wilaya: 'الجزائر العاصمة / الدار البيضاء',
            role: 'أستاذ زائر ومحاضر للأقسام النهائية',
            period: '2021 — حتى الآن',
            isCurrent: true,
          ),
          TeacherWorkplaceItem(
            id: 'w4',
            name: 'استوديو بيندو للتعليم الرقمي التفاعلي',
            type: 'منصة رقمية وطنية',
            wilaya: 'عن بُعد (58 ولاية)',
            role: 'أستاذ معتمد ومؤطر دورات البكالوريا المباشرة',
            period: '2023 — حتى الآن',
            isCurrent: true,
          ),
        ],
        cohortSchedules: const [
          TeacherCohortScheduleItem(
            id: 'cs1',
            cohortName: 'فوج النخبة للبكالوريا (شعبة علوم تجريبية ورياضي)',
            subject: 'الرياضيات',
            levelAndStream: '3 ثانوي • علوم تجريبية + رياضيات',
            daysAndTimes: 'الجمعة 15:00 - 17:30 | السبت 18:00 - 20:30',
            location: 'أكاديمية النجاح (القبة) + بث مباشر بيندو',
            enrolledCount: 42,
            maxCapacity: 50,
            monthlyPrice: 3500.0,
            status: 'مفتوح للتسجيل',
          ),
          TeacherCohortScheduleItem(
            id: 'cs2',
            cohortName: 'الفوج النموذجي للتميز — ثانية ثانوي',
            subject: 'الرياضيات',
            levelAndStream: '2 ثانوي • شعبة علوم تجريبية',
            daysAndTimes: 'الثلاثاء 17:30 - 19:30 | الجمعة 09:00 - 11:00',
            location: 'مدرسة الفتح الخاصة + بث مباشر بيندو',
            enrolledCount: 23,
            maxCapacity: 35,
            monthlyPrice: 2800.0,
            status: 'مفتوح للتسجيل',
          ),
          TeacherCohortScheduleItem(
            id: 'cs3',
            cohortName: 'دورة المراجعة الشاملة وحل البكالوريات السابقة',
            subject: 'الرياضيات',
            levelAndStream: '3 ثانوي • جميع الشعب العلمية',
            daysAndTimes: 'السبت 14:00 - 17:30 (أسبوعياً)',
            location: 'عبر منصة بيندو التفاعلية مباشرة',
            enrolledCount: 56,
            maxCapacity: 60,
            monthlyPrice: 2000.0,
            status: 'آخر المقاعد المتبقية',
          ),
        ],
        studentResults: const [
          TeacherStudentResultItem(
            id: 'sr1',
            studentName: 'سارة مهدي',
            exam: 'بكالوريا 2024',
            stream: 'شعبة علوم تجريبية',
            mark: 19.5,
            generalAverage: 18.72,
            appreciation: 'مرتبة الشرف الأولى ولاية الجزائر 🏆',
            wilaya: 'الجزائر العاصمة',
            school: 'ثانوية الرياضيات بالقبة',
            testimonial: 'منهجية الأستاذ بن عيسى في تفكيك الدوال المركبة والمسائل الشاملة كانت السر الأكبر في حصولي على 19.5 في الرياضيات وبمعدل عام 18.72.',
          ),
          TeacherStudentResultItem(
            id: 'sr2',
            studentName: 'كريم بلقاسم',
            exam: 'بكالوريا 2024',
            stream: 'شعبة تقني رياضي (هندسة ميكانيكية)',
            mark: 20.0,
            generalAverage: 18.45,
            appreciation: 'العلامة الكاملة في الرياضيات 🌟',
            wilaya: 'وهران',
            school: 'ثانوية العقيد لطفي',
            testimonial: 'الحصص التفاعلية وسلاسل التمارين النموذجية جعلت امتحان الرياضيات الرسمي يبدو أسهل بكثير مما توقعت. شكراً أستاذنا الفاضل!',
          ),
          TeacherStudentResultItem(
            id: 'sr3',
            studentName: 'مريم بن زينة',
            exam: 'بكالوريا 2024',
            stream: 'شعبة رياضيات',
            mark: 19.0,
            generalAverage: 17.90,
            appreciation: 'تفوق واقتدار في شعبة الرياضيات 🎯',
            wilaya: 'قسنطينة',
            school: 'ثانوية يوغرطة',
            testimonial: 'كنت أواجه صعوبة في الهندسة الفضائية والاحتمالات، ولكن بعد الدورة المكثفة أصبحت النقطة المفضلة لدي في الامتحان.',
          ),
          TeacherStudentResultItem(
            id: 'sr4',
            studentName: 'ياسين حماوي',
            exam: 'بكالوريا 2024',
            stream: 'شعبة علوم تجريبية',
            mark: 18.5,
            generalAverage: 17.35,
            appreciation: 'امتياز وتألق في البكالوريا 🎖️',
            wilaya: 'سطيف',
            school: 'ثانوية مالك بن نبي',
            testimonial: 'الدورات المباشرة والتسجيلات عالية الجودة في منصة بيندو مكنتني من المراجعة في أي وقت ومن أي مكان.',
          ),
        ],
        facebookUrl: 'https://facebook.com/prof.amine.math',
        telegramUrl: 'https://t.me/prof_amine_math',
        youtubeUrl: 'https://youtube.com/@prof_amine_math',
      ),
      stats: const TeacherStats(
        enrolledStudentsCount: 65,
        activeCohortsCount: 3,
        scheduledSessionsCount: 4,
        completedSessionsCount: 28,
        expiredCreditsStudentsCount: 2,
        totalEarnings: 185000.0,
        grossSales: 210000.0,
        pendingEarnings: 15000.0,
        libraryRecordingsCount: 18,
      ),
      upcomingSession: const TeacherUpcomingSession(
        id: 101,
        sessionId: 'SES_MATH_BAC_01',
        title: 'دورة المراجعة الشاملة لمادة الرياضيات — التحضير للبكالوريا',
        cohortId: 1,
        cohortName: 'فوج النخبة للبكالوريا (شعبة علوم تجريبية ورياضي)',
        subject: 'الرياضيات',
        scheduledAt: 'اليوم، 18:00',
        status: 'scheduled',
        isLive: false,
        maxParticipants: 100,
        enrolledStudents: 42,
      ),
      todaySchedule: const [
        TeacherScheduleItem(
          id: 101,
          sessionId: 'SES_MATH_BAC_01',
          title: 'الحصة التفاعلية المباشرة: حل المسائل النموذجية والامتحانات الرسمية',
          cohortName: 'فوج النخبة للبكالوريا',
          subject: 'الرياضيات',
          timeFormatted: '18:00',
          status: 'scheduled',
        ),
        TeacherScheduleItem(
          id: 102,
          sessionId: 'SES_PHYS_2AS_02',
          title: 'الفيزياء: المتابعة الزمنية لتحول كيميائي وتطبيقات التمارين',
          cohortName: 'فيزياء — ثانية ثانوي علوم',
          subject: 'الفيزياء',
          timeFormatted: '20:15',
          status: 'scheduled',
        ),
      ],
      notifications: const [
        TeacherNotificationItem(
          id: 'n1',
          title: 'انضمام طالب جديد إلى الفوج',
          body: 'انضم الطالب «كريم بلقاسم» إلى فوج رياضيات بكالوريا 2027.',
          type: 'student',
          time: 'منذ 15 دقيقة',
          isRead: false,
        ),
        TeacherNotificationItem(
          id: 'n2',
          title: 'تأكيد عملية دفع بنجاح',
          body: 'تم استلام وتأكيد دفع اشتراك شهري رسمي (3,500 دج) عبر بريدي موب.',
          type: 'payment',
          time: 'منذ ساعة',
          isRead: false,
        ),
        TeacherNotificationItem(
          id: 'n3',
          title: 'تنبيه: اقتراب موعد الحصة المباشرة الرسمية',
          body: 'تبدأ الحصة المباشرة الرسمية اليوم عند الساعة 18:00 عبر الغرفة التفاعلية.',
          type: 'session',
          time: 'منذ ساعتين',
          isRead: true,
        ),
        TeacherNotificationItem(
          id: 'n4',
          title: 'معالجة التسجيل اكتملت بنجاح',
          body: 'تسجيل الحصة الرسمية أصبح متوفراً الآن في مكتبة الفوج بجودة عالية وعلامة مائية رقمية.',
          type: 'library',
          time: 'أمس',
          isRead: true,
        ),
      ],
      cohorts: const [
        TeacherCohortItem(
          id: 1,
          cohortCode: 'COHORT_BAC27_MATH',
          name: 'فوج النخبة للبكالوريا — الرياضيات (شعبة علوم تجريبية ورياضي)',
          subject: 'الرياضيات',
          academicLevel: 'ثالثة ثانوي',
          stream: 'علوم تجريبية + تقني رياضي',
          enrolledCount: 42,
          maxStudents: 60,
          monthlyPrice: 3500.0,
          isActive: true,
          hasLibrary: true,
        ),
        TeacherCohortItem(
          id: 2,
          cohortCode: 'COHORT_1AS_SCI',
          name: 'الفوج النموذجي — أولى ثانوي جذع مشترك علوم',
          subject: 'الرياضيات',
          academicLevel: 'أولى ثانوي',
          stream: 'جذع مشترك علوم وتكنولوجيا',
          enrolledCount: 23,
          maxStudents: 40,
          monthlyPrice: 2500.0,
          isActive: true,
          hasLibrary: true,
        ),
      ],
      recentTransactions: const [
        TeacherTransactionItem(
          id: 501,
          studentName: 'أحمد ياسين بن علي',
          title: 'اشتراك باقة دروس + مكتبة',
          amount: 3500.0,
          status: 'مؤكد',
          date: 'اليوم 14:20',
        ),
        TeacherTransactionItem(
          id: 502,
          studentName: 'سارة مرابط',
          title: 'اشتراك باقة دروس فقط',
          amount: 2500.0,
          status: 'مؤكد',
          date: 'أمس 19:10',
        ),
        TeacherTransactionItem(
          id: 503,
          studentName: 'بلال قادري',
          title: 'تجديد اشتراك شهري',
          amount: 3500.0,
          status: 'قيد المعالجة',
          date: 'منذ يومين',
        ),
      ],
    );
  }
}

@immutable
class TeacherProfileInfo {
  final int id;
  final String name;
  final String email;
  final String teacherId;
  final String? avatarUrl;
  final String? coverImageUrl;
  final bool isVerified;
  final int yearsOfExperience;
  final String headline;
  final String wilaya;
  final String bio;
  final List<String> subjects;
  final List<String> levels;
  final List<TeacherStoryItem> stories;
  final List<TeacherWorkplaceItem> workplaces;
  final List<TeacherCohortScheduleItem> cohortSchedules;
  final List<TeacherStudentResultItem> studentResults;
  final String? facebookUrl;
  final String? telegramUrl;
  final String? youtubeUrl;

  const TeacherProfileInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.teacherId,
    this.avatarUrl,
    this.coverImageUrl,
    required this.isVerified,
    required this.yearsOfExperience,
    required this.headline,
    this.wilaya = 'الجزائر العاصمة',
    this.bio = 'أستاذ متميز في المنهاج الجزائري ومؤطر دورات التفوق للبكالوريا.',
    required this.subjects,
    required this.levels,
    this.stories = const [],
    this.workplaces = const [],
    this.cohortSchedules = const [],
    this.studentResults = const [],
    this.facebookUrl = 'https://facebook.com',
    this.telegramUrl = 'https://t.me',
    this.youtubeUrl = 'https://youtube.com',
  });

  factory TeacherProfileInfo.fromJson(Map<String, dynamic> json) {
    return TeacherProfileInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : 1,
      name: json['name']?.toString() ?? 'الأستاذ',
      email: json['email']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? 'TEACHER',
      avatarUrl: json['avatar_url']?.toString(),
      coverImageUrl: json['cover_image_url']?.toString(),
      isVerified: json['is_verified'] == true,
      yearsOfExperience: json['years_of_experience'] is num
          ? (json['years_of_experience'] as num).toInt()
          : 5,
      headline: json['headline']?.toString() ?? 'أستاذ معتمد في المنصة',
      wilaya: json['wilaya']?.toString() ?? 'الجزائر العاصمة',
      bio: json['bio']?.toString() ?? 'أستاذ متميز في المنهاج الجزائري ومؤطر دورات التفوق للبكالوريا.',
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      levels: (json['levels'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      stories: (json['stories'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TeacherStoryItem.fromJson(e))
          .toList(),
      workplaces: (json['workplaces'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TeacherWorkplaceItem.fromJson(e))
          .toList(),
      cohortSchedules: (json['cohort_schedules'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TeacherCohortScheduleItem.fromJson(e))
          .toList(),
      studentResults: (json['student_results'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => TeacherStudentResultItem.fromJson(e))
          .toList(),
      facebookUrl: json['facebook_url']?.toString(),
      telegramUrl: json['telegram_url']?.toString(),
      youtubeUrl: json['youtube_url']?.toString(),
    );
  }
}

@immutable
class TeacherStoryItem {
  final String id;
  final String text;
  final String? imageUrl;
  final String? videoUrl;
  final String mediaType; // 'text', 'image', 'video'
  final String timeAgo;
  final int viewsCount;
  final bool isLiveAlert;
  final String? tag;
  final String? actionButtonText;
  final String? actionLink;

  const TeacherStoryItem({
    required this.id,
    required this.text,
    this.imageUrl,
    this.videoUrl,
    this.mediaType = 'text',
    required this.timeAgo,
    this.viewsCount = 0,
    this.isLiveAlert = false,
    this.tag,
    this.actionButtonText,
    this.actionLink,
  });

  factory TeacherStoryItem.fromJson(Map<String, dynamic> json) {
    return TeacherStoryItem(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      videoUrl: json['video_url']?.toString(),
      mediaType: json['media_type']?.toString() ?? (json['video_url'] != null ? 'video' : (json['image_url'] != null ? 'image' : 'text')),
      timeAgo: json['time_ago']?.toString() ?? 'الآن',
      viewsCount: json['views_count'] is num ? (json['views_count'] as num).toInt() : 0,
      isLiveAlert: json['is_live_alert'] == true,
      tag: json['tag']?.toString(),
      actionButtonText: json['action_button_text']?.toString(),
      actionLink: json['action_link']?.toString(),
    );
  }
}

@immutable
class TeacherWorkplaceItem {
  final String id;
  final String name;
  final String type;
  final String wilaya;
  final String role;
  final String period;
  final bool isCurrent;

  const TeacherWorkplaceItem({
    required this.id,
    required this.name,
    required this.type,
    required this.wilaya,
    required this.role,
    required this.period,
    this.isCurrent = true,
  });

  factory TeacherWorkplaceItem.fromJson(Map<String, dynamic> json) {
    return TeacherWorkplaceItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? 'مؤسسة تعليمية',
      wilaya: json['wilaya']?.toString() ?? 'الجزائر',
      role: json['role']?.toString() ?? 'أستاذ',
      period: json['period']?.toString() ?? 'حالياً',
      isCurrent: json['is_current'] != false,
    );
  }
}

@immutable
class TeacherCohortScheduleItem {
  final String id;
  final String cohortName;
  final String subject;
  final String levelAndStream;
  final String daysAndTimes;
  final String location;
  final int enrolledCount;
  final int maxCapacity;
  final double monthlyPrice;
  final String status;

  const TeacherCohortScheduleItem({
    required this.id,
    required this.cohortName,
    required this.subject,
    required this.levelAndStream,
    required this.daysAndTimes,
    required this.location,
    required this.enrolledCount,
    required this.maxCapacity,
    required this.monthlyPrice,
    required this.status,
  });

  factory TeacherCohortScheduleItem.fromJson(Map<String, dynamic> json) {
    return TeacherCohortScheduleItem(
      id: json['id']?.toString() ?? '',
      cohortName: json['cohort_name']?.toString() ?? '',
      subject: json['subject']?.toString() ?? 'الرياضيات',
      levelAndStream: json['level_and_stream']?.toString() ?? '',
      daysAndTimes: json['days_and_times']?.toString() ?? '',
      location: json['location']?.toString() ?? 'حضوري + عن بعد',
      enrolledCount: json['enrolled_count'] is num ? (json['enrolled_count'] as num).toInt() : 0,
      maxCapacity: json['max_capacity'] is num ? (json['max_capacity'] as num).toInt() : 50,
      monthlyPrice: json['monthly_price'] is num ? (json['monthly_price'] as num).toDouble() : 3500.0,
      status: json['status']?.toString() ?? 'مفتوح للتسجيل',
    );
  }
}

@immutable
class TeacherStudentResultItem {
  final String id;
  final String studentName;
  final String exam;
  final String stream;
  final double mark;
  final double? generalAverage;
  final String appreciation;
  final String wilaya;
  final String? school;
  final String testimonial;

  const TeacherStudentResultItem({
    required this.id,
    required this.studentName,
    required this.exam,
    required this.stream,
    required this.mark,
    this.generalAverage,
    required this.appreciation,
    required this.wilaya,
    this.school,
    required this.testimonial,
  });

  factory TeacherStudentResultItem.fromJson(Map<String, dynamic> json) {
    return TeacherStudentResultItem(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      exam: json['exam']?.toString() ?? 'بكالوريا',
      stream: json['stream']?.toString() ?? 'علوم تجريبية',
      mark: json['mark'] is num ? (json['mark'] as num).toDouble() : 18.0,
      generalAverage: json['general_average'] is num ? (json['general_average'] as num).toDouble() : null,
      appreciation: json['appreciation']?.toString() ?? 'امتياز',
      wilaya: json['wilaya']?.toString() ?? 'الجزائر العاصمة',
      school: json['school']?.toString(),
      testimonial: json['testimonial']?.toString() ?? '',
    );
  }
}

@immutable
class TeacherStats {
  final int enrolledStudentsCount;
  final int activeCohortsCount;
  final int scheduledSessionsCount;
  final int completedSessionsCount;
  final int expiredCreditsStudentsCount;
  final double totalEarnings;
  final double grossSales;
  final double pendingEarnings;
  final int libraryRecordingsCount;

  const TeacherStats({
    required this.enrolledStudentsCount,
    required this.activeCohortsCount,
    required this.scheduledSessionsCount,
    required this.completedSessionsCount,
    required this.expiredCreditsStudentsCount,
    required this.totalEarnings,
    required this.grossSales,
    required this.pendingEarnings,
    required this.libraryRecordingsCount,
  });

  factory TeacherStats.fromJson(Map<String, dynamic> json) {
    return TeacherStats(
      enrolledStudentsCount: json['enrolled_students_count'] is num
          ? (json['enrolled_students_count'] as num).toInt()
          : 0,
      activeCohortsCount: json['active_cohorts_count'] is num
          ? (json['active_cohorts_count'] as num).toInt()
          : 0,
      scheduledSessionsCount: json['scheduled_sessions_count'] is num
          ? (json['scheduled_sessions_count'] as num).toInt()
          : 0,
      completedSessionsCount: json['completed_sessions_count'] is num
          ? (json['completed_sessions_count'] as num).toInt()
          : 0,
      expiredCreditsStudentsCount: json['expired_credits_students_count'] is num
          ? (json['expired_credits_students_count'] as num).toInt()
          : 0,
      totalEarnings: json['total_earnings'] is num
          ? (json['total_earnings'] as num).toDouble()
          : 0.0,
      grossSales: json['gross_sales'] is num
          ? (json['gross_sales'] as num).toDouble()
          : 0.0,
      pendingEarnings: json['pending_earnings'] is num
          ? (json['pending_earnings'] as num).toDouble()
          : 0.0,
      libraryRecordingsCount: json['library_recordings_count'] is num
          ? (json['library_recordings_count'] as num).toInt()
          : 0,
    );
  }
}

@immutable
class TeacherUpcomingSession {
  final int id;
  final String sessionId;
  final String title;
  final int? cohortId;
  final String cohortName;
  final String subject;
  final String scheduledAt;
  final String status;
  final bool isLive;
  final int maxParticipants;
  final int enrolledStudents;

  const TeacherUpcomingSession({
    required this.id,
    required this.sessionId,
    required this.title,
    this.cohortId,
    required this.cohortName,
    required this.subject,
    required this.scheduledAt,
    required this.status,
    required this.isLive,
    required this.maxParticipants,
    required this.enrolledStudents,
  });

  factory TeacherUpcomingSession.fromJson(Map<String, dynamic> json) {
    return TeacherUpcomingSession(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      sessionId: json['session_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'حصة دراسية',
      cohortId: json['cohort_id'] is num ? (json['cohort_id'] as num).toInt() : null,
      cohortName: json['cohort_name']?.toString() ?? 'فوج عام',
      subject: json['subject']?.toString() ?? 'مادة دراسية',
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'scheduled',
      isLive: json['is_live'] == true || json['status'] == 'active',
      maxParticipants: json['max_participants'] is num
          ? (json['max_participants'] as num).toInt()
          : 100,
      enrolledStudents: json['enrolled_students'] is num
          ? (json['enrolled_students'] as num).toInt()
          : 0,
    );
  }
}

@immutable
class TeacherScheduleItem {
  final int id;
  final String sessionId;
  final String title;
  final String cohortName;
  final String subject;
  final String timeFormatted;
  final String status;

  const TeacherScheduleItem({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.cohortName,
    required this.subject,
    required this.timeFormatted,
    required this.status,
  });

  factory TeacherScheduleItem.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      sessionId: json['session_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'حصة',
      cohortName: json['cohort_name']?.toString() ?? 'فوج عام',
      subject: json['subject']?.toString() ?? 'مادة',
      timeFormatted: json['time_formatted']?.toString() ?? '00:00',
      status: json['status']?.toString() ?? 'scheduled',
    );
  }
}

@immutable
class TeacherNotificationItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final String time;
  final bool isRead;

  const TeacherNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    required this.isRead,
  });

  factory TeacherNotificationItem.fromJson(Map<String, dynamic> json) {
    return TeacherNotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      time: json['time']?.toString() ?? '',
      isRead: json['is_read'] == true,
    );
  }
}

@immutable
class TeacherCohortItem {
  final int id;
  final String cohortCode;
  final String name;
  final String subject;
  final String academicLevel;
  final String? stream;
  final int enrolledCount;
  final int maxStudents;
  final double monthlyPrice;
  final bool isActive;
  final bool hasLibrary;

  const TeacherCohortItem({
    required this.id,
    required this.cohortCode,
    required this.name,
    required this.subject,
    required this.academicLevel,
    this.stream,
    required this.enrolledCount,
    required this.maxStudents,
    required this.monthlyPrice,
    required this.isActive,
    required this.hasLibrary,
  });

  factory TeacherCohortItem.fromJson(Map<String, dynamic> json) {
    return TeacherCohortItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      cohortCode: json['cohort_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      academicLevel: json['academic_level']?.toString() ?? '',
      stream: json['stream']?.toString(),
      enrolledCount: json['enrolled_count'] is num ? (json['enrolled_count'] as num).toInt() : 0,
      maxStudents: json['max_students'] is num ? (json['max_students'] as num).toInt() : 50,
      monthlyPrice: json['monthly_price'] is num ? (json['monthly_price'] as num).toDouble() : 0.0,
      isActive: json['is_active'] != false,
      hasLibrary: json['has_library'] != false,
    );
  }
}

@immutable
class TeacherTransactionItem {
  final int id;
  final String studentName;
  final String title;
  final double amount;
  final String status;
  final String date;

  const TeacherTransactionItem({
    required this.id,
    required this.studentName,
    required this.title,
    required this.amount,
    required this.status,
    required this.date,
  });

  factory TeacherTransactionItem.fromJson(Map<String, dynamic> json) {
    return TeacherTransactionItem(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      studentName: json['student_name']?.toString() ?? 'طالب',
      title: json['title']?.toString() ?? 'اشتراك',
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : 0.0,
      status: json['status']?.toString() ?? 'مؤكد',
      date: json['date']?.toString() ?? '',
    );
  }
}
