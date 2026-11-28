class StudentDashboardData {
  final StudentProfile student;
  final StudentNextSession? nextSession;
  final StudentSubscriptionSummary subscriptions;
  final List<TodayScheduleItem> todaySchedule;
  final List<RecentRecordingItem> recentRecordings;
  final StudentAttendanceSummary attendance;
  final List<StudentNotificationItem> notifications;

  const StudentDashboardData({
    required this.student,
    this.nextSession,
    required this.subscriptions,
    required this.todaySchedule,
    required this.recentRecordings,
    required this.attendance,
    required this.notifications,
  });

  factory StudentDashboardData.fromJson(Map<String, dynamic> json) {
    return StudentDashboardData(
      student: StudentProfile.fromJson(json['student'] as Map<String, dynamic>? ?? {}),
      nextSession: json['next_session'] != null
          ? StudentNextSession.fromJson(json['next_session'] as Map<String, dynamic>)
          : null,
      subscriptions: StudentSubscriptionSummary.fromJson(json['subscriptions'] as Map<String, dynamic>? ?? {}),
      todaySchedule: (json['today_schedule'] as List<dynamic>? ?? [])
          .map((e) => TodayScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentRecordings: (json['recent_recordings'] as List<dynamic>? ?? [])
          .map((e) => RecentRecordingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      attendance: StudentAttendanceSummary.fromJson(json['attendance'] as Map<String, dynamic>? ?? {}),
      notifications: (json['notifications'] as List<dynamic>? ?? [])
          .map((e) => StudentNotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory StudentDashboardData.empty(String studentName, String studentEmail) {
    return StudentDashboardData(
      student: StudentProfile(
        id: 1,
        name: studentName.isNotEmpty ? studentName : 'تلميذ جديد',
        email: studentEmail.isNotEmpty ? studentEmail : '',
        role: 'student',
      ),
      nextSession: null,
      subscriptions: const StudentSubscriptionSummary(
        packageName: 'لا يوجد اشتراك نشط حالياً',
        remainingCredits: 0,
        activeCohortsCount: 0,
        libraryAccess: false,
        status: 'inactive',
        expiresAt: '-',
      ),
      todaySchedule: const [],
      recentRecordings: const [],
      attendance: const StudentAttendanceSummary(
        attendanceRate: 100,
        attendedSessions: 0,
        totalSessions: 0,
      ),
      notifications: const [],
    );
  }

  factory StudentDashboardData.fallback(String studentName, String studentEmail) {
    return StudentDashboardData(
      student: StudentProfile(
        id: 1,
        name: studentName.isNotEmpty ? studentName : 'أحمد أمين قادري',
        email: studentEmail.isNotEmpty ? studentEmail : 'student.amine@pindofuture.com',
        role: 'student',
      ),
      nextSession: const StudentNextSession(
        id: 1,
        sessionId: 'SES_8PP4LVG1',
        title: 'المتتاليات والبرهان بالتراجع',
        subject: 'الرياضيات',
        teacherName: 'الأستاذ بن عيسى',
        cohortName: 'فوج النخبة للبكالوريا',
        scheduledAt: 'اليوم، 18:00',
        status: 'scheduled',
        isLive: false,
        minutesRemaining: 45,
      ),
      subscriptions: const StudentSubscriptionSummary(
        packageName: 'باقة الدروس + المكتبة',
        remainingCredits: 4,
        activeCohortsCount: 1,
        libraryAccess: true,
        status: 'active',
        expiresAt: '2026-11-20',
      ),
      todaySchedule: const [
        TodayScheduleItem(
          time: '18:00',
          subject: 'الرياضيات',
          teacher: 'الأستاذ بن عيسى',
          topic: 'حلول المسائل الشاملة',
          status: 'scheduled',
        ),
        TodayScheduleItem(
          time: '20:00',
          subject: 'الفيزياء',
          teacher: 'الأستاذة بلقاسم',
          topic: 'الميكانيكا وقوانين نيوتن',
          status: 'scheduled',
        ),
      ],
      recentRecordings: const [
        RecentRecordingItem(
          id: 1,
          title: 'حلول نموذجية لتمارين الميكانيكا',
          subject: 'الفيزياء',
          teacherName: 'الأستاذة بلقاسم',
          durationMinutes: 105,
          createdAt: '2026-10-24',
          isAccessible: true,
        ),
      ],
      attendance: const StudentAttendanceSummary(
        attendanceRate: 96,
        attendedSessions: 24,
        totalSessions: 25,
      ),
      notifications: const [
        StudentNotificationItem(
          id: 1,
          title: 'حصة قادمة',
          body: 'تبدأ حصة الرياضيات بعد قليل',
          type: 'session',
          time: '17:30',
          isRead: false,
        ),
        StudentNotificationItem(
          id: 2,
          title: 'تسجيل متاح',
          body: 'تمت إضافة تسجيل حصة الفيزياء',
          type: 'library',
          time: 'أمس',
          isRead: true,
        ),
        StudentNotificationItem(
          id: 3,
          title: 'رصيد الحصص',
          body: 'تبقى في رصيدك 4 حصص',
          type: 'credit',
          time: 'منذ يومين',
          isRead: true,
        ),
      ],
    );
  }
}

class StudentProfile {
  final int id;
  final String name;
  final String email;
  final String role;

  const StudentProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as int? ?? 1,
      name: json['name'] as String? ?? 'Student',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'student',
    );
  }
}

class StudentNextSession {
  final int id;
  final String sessionId;
  final String title;
  final String subject;
  final String teacherName;
  final String cohortName;
  final String scheduledAt;
  final String status;
  final bool isLive;
  final int minutesRemaining;

  const StudentNextSession({
    required this.id,
    required this.sessionId,
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.cohortName,
    required this.scheduledAt,
    required this.status,
    required this.isLive,
    required this.minutesRemaining,
  });

  factory StudentNextSession.fromJson(Map<String, dynamic> json) {
    return StudentNextSession(
      id: json['id'] as int? ?? 0,
      sessionId: json['session_id'] as String? ?? 'SES_000',
      title: json['title'] as String? ?? 'Upcoming Session',
      subject: json['subject'] as String? ?? 'Academics',
      teacherName: json['teacher_name'] as String? ?? 'Teacher',
      cohortName: json['cohort_name'] as String? ?? 'Cohort',
      scheduledAt: json['scheduled_at'] as String? ?? '',
      status: json['status'] as String? ?? 'scheduled',
      isLive: json['is_live'] as bool? ?? false,
      minutesRemaining: json['minutes_remaining'] as int? ?? 0,
    );
  }
}

class StudentSubscriptionSummary {
  final String packageName;
  final int remainingCredits;
  final int activeCohortsCount;
  final bool libraryAccess;
  final String status;
  final String expiresAt;

  const StudentSubscriptionSummary({
    required this.packageName,
    required this.remainingCredits,
    required this.activeCohortsCount,
    required this.libraryAccess,
    required this.status,
    required this.expiresAt,
  });

  factory StudentSubscriptionSummary.fromJson(Map<String, dynamic> json) {
    return StudentSubscriptionSummary(
      packageName: json['package_name'] as String? ?? 'باقة الدروس + المكتبة',
      remainingCredits: json['remaining_credits'] as int? ?? 0,
      activeCohortsCount: json['active_cohorts_count'] as int? ?? 0,
      libraryAccess: json['library_access'] as bool? ?? true,
      status: json['status'] as String? ?? 'active',
      expiresAt: json['expires_at'] as String? ?? '',
    );
  }
}

class TodayScheduleItem {
  final String sessionId;
  final String cohortName;
  final DateTime? scheduledAt;
  final String time;
  final String subject;
  final String teacher;
  final String topic;
  final String status;

  const TodayScheduleItem({
    this.sessionId = '',
    this.cohortName = '',
    this.scheduledAt,
    required this.time,
    required this.subject,
    required this.teacher,
    required this.topic,
    required this.status,
  });

  factory TodayScheduleItem.fromJson(Map<String, dynamic> json) {
    final rawScheduledAt = json['scheduled_at']?.toString();
    return TodayScheduleItem(
      sessionId: json['session_id'] as String? ?? '',
      cohortName: json['cohort_name'] as String? ?? '',
      scheduledAt: rawScheduledAt != null && rawScheduledAt.isNotEmpty
          ? DateTime.tryParse(rawScheduledAt)?.toLocal()
          : null,
      time: json['time'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      teacher: json['teacher'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      status: json['status'] as String? ?? 'scheduled',
    );
  }
}

class RecentRecordingItem {
  final int id;
  final String title;
  final String subject;
  final String teacherName;
  final int durationMinutes;
  final String createdAt;
  final bool isAccessible;

  const RecentRecordingItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.teacherName,
    required this.durationMinutes,
    required this.createdAt,
    required this.isAccessible,
  });

  factory RecentRecordingItem.fromJson(Map<String, dynamic> json) {
    return RecentRecordingItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      isAccessible: json['is_accessible'] as bool? ?? true,
    );
  }
}

class StudentAttendanceSummary {
  final int attendanceRate;
  final int attendedSessions;
  final int totalSessions;

  const StudentAttendanceSummary({
    required this.attendanceRate,
    required this.attendedSessions,
    required this.totalSessions,
  });

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummary(
      attendanceRate: json['attendance_rate'] as int? ?? 95,
      attendedSessions: json['attended_sessions'] as int? ?? 0,
      totalSessions: json['total_sessions'] as int? ?? 0,
    );
  }
}

class StudentNotificationItem {
  final int id;
  final String title;
  final String body;
  final String type;
  final String time;
  final bool isRead;

  const StudentNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    required this.isRead,
  });

  factory StudentNotificationItem.fromJson(Map<String, dynamic> json) {
    return StudentNotificationItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      time: json['time'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}
