import 'package:flutter/foundation.dart';

@immutable
class AdminDashboardModel {
  final AdminKpis kpis;
  final List<AdminPendingTeacherVerification> pendingVerifications;
  final List<AdminPendingPayout> pendingPayouts;

  const AdminDashboardModel({
    required this.kpis,
    required this.pendingVerifications,
    required this.pendingPayouts,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return AdminDashboardModel(
      kpis: AdminKpis.fromJson(data['kpis'] as Map<String, dynamic>? ?? {}),
      pendingVerifications: (data['pending_verifications'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => AdminPendingTeacherVerification.fromJson(e))
          .toList(),
      pendingPayouts: (data['pending_payouts'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((e) => AdminPendingPayout.fromJson(e))
          .toList(),
    );
  }

  factory AdminDashboardModel.mockFallback() {
    return const AdminDashboardModel(
      kpis: AdminKpis(
        totalStudentsCount: 1420,
        totalTeachersCount: 84,
        verifiedTeachersCount: 62,
        pendingVerificationsCount: 4,
        totalCohortsCount: 118,
        activeLiveSessionsCount: 6,
        grossRevenue: 4250000.0,
        platformCommission: 850000.0,
        teacherNetEarnings: 3400000.0,
        pendingPayoutsCount: 3,
        pendingPayoutsAmount: 95000.0,
        sfuClusterCapacity: 30000,
        sfuClusterStatus: '99.98% Operational',
      ),
      pendingVerifications: [
        AdminPendingTeacherVerification(
          id: 101,
          name: 'الأستاذ كمال بوزيد',
          email: 'kamal.math@pindofuture.com',
          teacherId: 'TCH_DZ_091',
          wilaya: 'الجزائر العاصمة',
          subjects: ['الرياضيات'],
          submittedAt: 'منذ ساعتين',
        ),
        AdminPendingTeacherVerification(
          id: 102,
          name: 'الأستاذة مريم شريف',
          email: 'meriem.physics@pindofuture.com',
          teacherId: 'TCH_DZ_092',
          wilaya: 'قسنطينة',
          subjects: ['الفيزياء', 'الكيمياء'],
          submittedAt: 'منذ 5 ساعات',
        ),
        AdminPendingTeacherVerification(
          id: 103,
          name: 'الأستاذ سمير عمارة',
          email: 'samir.sciences@pindofuture.com',
          teacherId: 'TCH_DZ_093',
          wilaya: 'وهران',
          subjects: ['العلوم الطبيعية'],
          submittedAt: 'أمس',
        ),
      ],
      pendingPayouts: [
        AdminPendingPayout(
          id: 301,
          reference: 'PO_20261027_DZ91A',
          teacherId: 12,
          teacherName: 'الأستاذ أحمد بوضياف',
          amount: 35000.0,
          currency: 'DZD',
          payoutMethod: 'BaridiMob',
          destinationAccount: '00799999000234567891',
          status: 'requested',
          requestedAt: 'منذ ساعتين',
        ),
        AdminPendingPayout(
          id: 302,
          reference: 'PO_20261027_DZ92B',
          teacherId: 15,
          teacherName: 'الأستاذ سفيان بن عيسى',
          amount: 42000.0,
          currency: 'DZD',
          payoutMethod: 'CCP (الحساب الجاري)',
          destinationAccount: '0012345678 Clé 45',
          status: 'requested',
          requestedAt: 'منذ 4 ساعات',
        ),
        AdminPendingPayout(
          id: 303,
          reference: 'PO_20261026_DZ88C',
          teacherId: 21,
          teacherName: 'الأستاذة أسماء رحال',
          amount: 18000.0,
          currency: 'DZD',
          payoutMethod: 'BaridiMob',
          destinationAccount: '00799999000876543210',
          status: 'requested',
          requestedAt: 'أمس',
        ),
      ],
    );
  }
}

@immutable
class AdminKpis {
  final int totalStudentsCount;
  final int totalTeachersCount;
  final int verifiedTeachersCount;
  final int pendingVerificationsCount;
  final int totalCohortsCount;
  final int activeLiveSessionsCount;
  final double grossRevenue;
  final double platformCommission;
  final double teacherNetEarnings;
  final int pendingPayoutsCount;
  final double pendingPayoutsAmount;
  final int sfuClusterCapacity;
  final String sfuClusterStatus;

  const AdminKpis({
    required this.totalStudentsCount,
    required this.totalTeachersCount,
    required this.verifiedTeachersCount,
    required this.pendingVerificationsCount,
    required this.totalCohortsCount,
    required this.activeLiveSessionsCount,
    required this.grossRevenue,
    required this.platformCommission,
    required this.teacherNetEarnings,
    required this.pendingPayoutsCount,
    required this.pendingPayoutsAmount,
    required this.sfuClusterCapacity,
    required this.sfuClusterStatus,
  });

  factory AdminKpis.fromJson(Map<String, dynamic> json) {
    return AdminKpis(
      totalStudentsCount: json['total_students_count'] is num
          ? (json['total_students_count'] as num).toInt()
          : 0,
      totalTeachersCount: json['total_teachers_count'] is num
          ? (json['total_teachers_count'] as num).toInt()
          : 0,
      verifiedTeachersCount: json['verified_teachers_count'] is num
          ? (json['verified_teachers_count'] as num).toInt()
          : 0,
      pendingVerificationsCount: json['pending_verifications_count'] is num
          ? (json['pending_verifications_count'] as num).toInt()
          : 0,
      totalCohortsCount: json['total_cohorts_count'] is num
          ? (json['total_cohorts_count'] as num).toInt()
          : 0,
      activeLiveSessionsCount: json['active_live_sessions_count'] is num
          ? (json['active_live_sessions_count'] as num).toInt()
          : 0,
      grossRevenue: json['gross_revenue'] is num
          ? (json['gross_revenue'] as num).toDouble()
          : 0.0,
      platformCommission: json['platform_commission'] is num
          ? (json['platform_commission'] as num).toDouble()
          : 0.0,
      teacherNetEarnings: json['teacher_net_earnings'] is num
          ? (json['teacher_net_earnings'] as num).toDouble()
          : 0.0,
      pendingPayoutsCount: json['pending_payouts_count'] is num
          ? (json['pending_payouts_count'] as num).toInt()
          : 0,
      pendingPayoutsAmount: json['pending_payouts_amount'] is num
          ? (json['pending_payouts_amount'] as num).toDouble()
          : 0.0,
      sfuClusterCapacity: json['sfu_cluster_capacity'] is num
          ? (json['sfu_cluster_capacity'] as num).toInt()
          : 30000,
      sfuClusterStatus: json['sfu_cluster_status']?.toString() ?? 'Operational',
    );
  }
}

@immutable
class AdminPendingTeacherVerification {
  final int id;
  final String name;
  final String email;
  final String teacherId;
  final String wilaya;
  final List<String> subjects;
  final String submittedAt;

  const AdminPendingTeacherVerification({
    required this.id,
    required this.name,
    required this.email,
    required this.teacherId,
    required this.wilaya,
    required this.subjects,
    required this.submittedAt,
  });

  factory AdminPendingTeacherVerification.fromJson(Map<String, dynamic> json) {
    return AdminPendingTeacherVerification(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name']?.toString() ?? 'أستاذ',
      email: json['email']?.toString() ?? '',
      teacherId: json['teacher_id']?.toString() ?? 'TEACHER',
      wilaya: json['wilaya']?.toString() ?? 'الجزائر',
      subjects: (json['subjects'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      submittedAt: json['submitted_at']?.toString() ?? 'مؤخراً',
    );
  }
}

@immutable
class AdminPendingPayout {
  final int id;
  final String reference;
  final int teacherId;
  final String teacherName;
  final double amount;
  final String currency;
  final String payoutMethod;
  final String destinationAccount;
  final String status;
  final String requestedAt;

  const AdminPendingPayout({
    required this.id,
    required this.reference,
    required this.teacherId,
    required this.teacherName,
    required this.amount,
    required this.currency,
    required this.payoutMethod,
    required this.destinationAccount,
    required this.status,
    required this.requestedAt,
  });

  factory AdminPendingPayout.fromJson(Map<String, dynamic> json) {
    return AdminPendingPayout(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      reference: json['reference']?.toString() ?? '',
      teacherId: json['teacher_id'] is num ? (json['teacher_id'] as num).toInt() : 0,
      teacherName: json['teacher_name']?.toString() ?? 'أستاذ',
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : 0.0,
      currency: json['currency']?.toString() ?? 'DZD',
      payoutMethod: json['payout_method']?.toString() ?? 'BaridiMob',
      destinationAccount: json['destination_account']?.toString() ?? '',
      status: json['status']?.toString() ?? 'requested',
      requestedAt: json['requested_at']?.toString() ?? 'مؤخراً',
    );
  }
}
