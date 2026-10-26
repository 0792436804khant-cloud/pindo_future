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

  factory StudentDashboardData.fallback(String studentName, String studentEmail) {
    return StudentDashboardData(
      student: StudentProfile(
        id: 1,
        name: studentName.isNotEmpty ? studentName : 'Student Demo',
        email: studentEmail.isNotEmpty ? studentEmail : 'student.demo@pindofuture.com',
        role: 'student',
      ),
      nextSession: const StudentNextSession(
        id: 101,
        sessionId: 'SES_8PP4LVG1',
        title: 'المتتاليات وحساب النهايات — تطبيقات البكالوريا',
        subject: 'الرياضيات (Mathematics)',
        teacherName: 'Professor Alan Turing',
        cohortName: 'فوج النخبة بكالوريا 2026 (علوم تجريبية)',
        scheduledAt: '2026-10-26T18:00:00Z',
        status: 'imminent',
        isLive: true,
        minutesRemaining: 15,
      ),
      subscriptions: const StudentSubscriptionSummary(
        packageName: 'باقة التميز (دروس مباشرة + المكتبة المحمية)',
        remainingCredits: 4,
        activeCohortsCount: 2,
        libraryAccess: true,
        status: 'active',
        expiresAt: '2026-11-20',
      ),
      todaySchedule: const [
        TodayScheduleItem(
          time: '18:00',
          subject: 'الرياضيات',
          teacher: 'Professor Alan Turing',
          topic: 'المتتاليات وحساب النهايات — تطبيقات بكالوريا',
          status: 'live',
        ),
        TodayScheduleItem(
          time: '20:00',
          subject: 'العلوم الفيزيائية',
          teacher: 'Dr. Marie Curie',
          topic: 'تطور كميات المادة في مزيج تفاعلي كيميائي',
          status: 'scheduled',
        ),
      ],
      recentRecordings: const [
        RecentRecordingItem(
          id: 1,
          title: 'حلول نموذجية لتمارين الميكانيكا وقوانين نيوتن',
          subject: 'الفيزياء',
          teacherName: 'Dr. Marie Curie',
          durationMinutes: 105,
          createdAt: 'أمس',
          isAccessible: true,
        ),
        RecentRecordingItem(
          id: 2,
          title: 'منهجية معالجة المقال الفلسفي للشعب العلمية',
          subject: 'الفلسفة',
          teacherName: 'Prof. Ibn Sina (Avicenna)',
          durationMinutes: 75,
          createdAt: 'منذ يومين',
          isAccessible: true,
        ),
      ],
      attendance: const StudentAttendanceSummary(
        attendanceRate: 96,
        attendedSessions: 14,
        totalSessions: 15,
      ),
      notifications: const [
        StudentNotificationItem(
          id: 1,
          title: 'الحصة بدأت الآن 🔴',
          body: 'انطلقت الآن حصة الرياضيات مع Professor Alan Turing. اضغط للدخول للبث.',
          type: 'live',
          time: 'الآن',
          isRead: false,
        ),
        StudentNotificationItem(
          id: 2,
          title: 'تسجيل حصة جديد متاح',
          body: 'تم رفع تسجيل حصة الفيزياء للدكتورة Marie Curie بمكتبتك المحمية.',
          type: 'library',
          time: 'منذ ساعتين',
          isRead: false,
        ),
        StudentNotificationItem(
          id: 3,
          title: 'تأكيد الاشتراك وتجديد الرصيد',
          body: 'تم تفعيل باقة (دروس البكالوريا + المكتبة) بنجاح. رصيدك الحالي: 4 حصص.',
          type: 'billing',
          time: 'أمس',
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
  final String time;
  final String subject;
  final String teacher;
  final String topic;
  final String status;

  const TodayScheduleItem({
    required this.time,
    required this.subject,
    required this.teacher,
    required this.topic,
    required this.status,
  });

  factory TodayScheduleItem.fromJson(Map<String, dynamic> json) {
    return TodayScheduleItem(
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
