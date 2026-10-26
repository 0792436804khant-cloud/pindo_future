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
    String teacherName = 'الأستاذ أحمد بوضياف',
    String teacherId = 'TCH_DZ_2027',
  }) {
    return TeacherDashboardModel(
      teacherProfile: TeacherProfileInfo(
        id: 1,
        name: teacherName,
        email: 'teacher@pindofuture.com',
        teacherId: teacherId,
        avatarUrl: null,
        isVerified: true,
        yearsOfExperience: 8,
        headline: 'أستاذ متميز لمادة الرياضيات — بكالوريا وتعليم ثانوي',
        subjects: const ['الرياضيات', 'الفيزياء'],
        levels: const ['ثالثة ثانوي', 'ثانية ثانوي', 'أولى ثانوي'],
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
        title: 'المتتاليات العددية ودراسة الدوال الأسية الشاملة',
        cohortId: 1,
        cohortName: 'فوج الرياضيات — بكالوريا 2027',
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
          title: 'المتتاليات العددية ودراسة الدوال الأسية',
          cohortName: 'رياضيات — بكالوريا 2027',
          subject: 'الرياضيات',
          timeFormatted: '18:00',
          status: 'scheduled',
        ),
        TeacherScheduleItem(
          id: 102,
          sessionId: 'SES_PHYS_2AS_02',
          title: 'الناقلية والمحاليل الشاردية المعمقة',
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
          body: 'انضم الطالب «محمد أمين» إلى فوج رياضيات بكالوريا 2027.',
          type: 'student',
          time: 'منذ 15 دقيقة',
          isRead: false,
        ),
        TeacherNotificationItem(
          id: 'n2',
          title: 'تأكيد عملية دفع بنجاح',
          body: 'تم استلام وتأكيد دفع اشتراك شهري (3,500 دج) عبر بريدي موب.',
          type: 'payment',
          time: 'منذ ساعة',
          isRead: false,
        ),
        TeacherNotificationItem(
          id: 'n3',
          title: 'تنبيه: اقتراب موعد حصة المتتاليات',
          body: 'تبدأ الحصة المباشرة اليوم عند الساعة 18:00 (بقي ساعتان).',
          type: 'session',
          time: 'منذ ساعتين',
          isRead: true,
        ),
        TeacherNotificationItem(
          id: 'n4',
          title: 'معالجة التسجيل اكتملت',
          body: 'تسجيل حصة الأعداد المركبة أصبح متاحاً الآن في مكتبة الفوج.',
          type: 'library',
          time: 'أمس',
          isRead: true,
        ),
      ],
      cohorts: const [
        TeacherCohortItem(
          id: 1,
          cohortCode: 'COHORT_BAC27_MATH',
          name: 'رياضيات — بكالوريا 2027 (علوم تجريبية)',
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
          name: 'رياضيات — أولى ثانوي جذع مشترك علوم',
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
  final bool isVerified;
  final int yearsOfExperience;
  final String headline;
  final List<String> subjects;
  final List<String> levels;

  const TeacherProfileInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.teacherId,
    this.avatarUrl,
    required this.isVerified,
    required this.yearsOfExperience,
    required this.headline,
    required this.subjects,
    required this.levels,
  });

  factory TeacherProfileInfo.fromJson(Map<String, dynamic> json) {
    return TeacherProfileInfo(
      id: json['id'] is num ? (json['id'] as num).toInt() : 1,
      name: json['name']?.toString() ?? 'الأستاذ',
      email: json['email']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? 'TEACHER',
      avatarUrl: json['avatar_url']?.toString(),
      isVerified: json['is_verified'] == true,
      yearsOfExperience: json['years_of_experience'] is num
          ? (json['years_of_experience'] as num).toInt()
          : 5,
      headline: json['headline']?.toString() ?? 'أستاذ معتمد في المنصة',
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      levels: (json['levels'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
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
