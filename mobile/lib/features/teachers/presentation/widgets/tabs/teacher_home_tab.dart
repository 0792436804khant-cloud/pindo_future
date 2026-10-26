import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import '../modals/create_cohort_modal.dart';
import '../modals/create_session_modal.dart';

class TeacherHomeTab extends StatelessWidget {
  final TeacherDashboardModel dashboard;
  final VoidCallback onStartLiveSession;
  final ValueChanged<int> onNavigateToTab;

  const TeacherHomeTab({
    super.key,
    required this.dashboard,
    required this.onStartLiveSession,
    required this.onNavigateToTab,
  });

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  @override
  Widget build(BuildContext context) {
    final stats = dashboard.stats;
    final upcoming = dashboard.upcomingSession;
    final schedule = dashboard.todaySchedule;

    return RefreshIndicator(
      color: _brightCyan,
      backgroundColor: const Color(0xFF0F172A),
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teacher Header Profile & Greeting
            _buildGreetingHeader(),

            const SizedBox(height: 20),

            // Upcoming / Live Session Hero Card
            _buildUpcomingSessionCard(context, upcoming),

            const SizedBox(height: 24),

            // Quick Actions Bar
            _buildQuickActionsRow(context),

            const SizedBox(height: 24),

            // 8 KPI Quick Stats Grid (Section 1 in specifications)
            _buildKpiStatsSection(stats),

            const SizedBox(height: 24),

            // Today's Schedule (Section 1.3 in specifications)
            _buildTodayScheduleSection(context, schedule),

            const SizedBox(height: 24),

            // Recent Alerts preview
            _buildRecentAlertsPreview(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingHeader() {
    final profile = dashboard.teacherProfile;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _brightCyan, width: 2),
            boxShadow: [
              BoxShadow(
                color: _brightCyan.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: _deepIndigo,
            backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
            child: profile.avatarUrl == null
                ? Text(
                    profile.name.isNotEmpty ? profile.name[0] : 'أ',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      'مرحباً، ${profile.name} 👋',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (profile.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.verified_rounded, color: _brightCyan, size: 18),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                profile.headline,
                style: const TextStyle(fontSize: 12, color: Colors.white60),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSessionCard(BuildContext context, TeacherUpcomingSession? session) {
    if (session == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _brightCyan.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_rounded, color: _brightCyan, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لا توجد حصص قادمة مبرمجة اليوم',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'اضغط على زر «برمجة حصة» لجدولة حصة مباشرة جديدة لأفواجك.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isLive = session.isLive;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLive
              ? [const Color(0xFFDC2626).withValues(alpha: 0.4), const Color(0xFF0F172A)]
              : [_deepIndigo.withValues(alpha: 0.6), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLive ? Colors.redAccent.withValues(alpha: 0.6) : _electricPurple.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isLive ? Colors.red.withValues(alpha: 0.25) : _electricPurple.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive ? Colors.red : _electricPurple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isLive ? Icons.sensors_rounded : Icons.schedule_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isLive ? 'الحصة مباشرة الآن' : 'الحصة القادمة',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, color: Colors.white70, size: 15),
                  const SizedBox(width: 4),
                  Text(
                    '${session.enrolledStudents} مسجل',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.school_outlined, color: _brightCyan, size: 15),
              const SizedBox(width: 6),
              Text(
                '${session.subject} • ${session.cohortName}',
                style: const TextStyle(color: _brightCyan, fontSize: 12.5, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                session.scheduledAt,
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: onStartLiveSession,
              icon: Icon(
                isLive ? Icons.meeting_room_rounded : Icons.videocam_rounded,
                size: 20,
              ),
              label: Text(
                isLive ? 'انضم إلى البث المباشر فوراً' : 'ابدأ البث المباشر الآن',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isLive ? Colors.redAccent : const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            title: 'إنشاء فوج',
            icon: Icons.group_add_rounded,
            color: const Color(0xFF10B981),
            onTap: () => CreateCohortModal.show(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            title: 'برمجة حصة',
            icon: Icons.more_time_rounded,
            color: _brightCyan,
            onTap: () => CreateSessionModal.show(context, cohorts: dashboard.cohorts),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            title: 'المداخيل',
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.amber,
            onTap: () => onNavigateToTab(3),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiStatsSection(TeacherStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 الإحصائيات العامة للمنصة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _buildStatCard('إجمالي الطلاب', '${stats.enrolledStudentsCount}', Icons.people_alt_rounded, const Color(0xFF10B981)),
            _buildStatCard('الأفواج النشطة', '${stats.activeCohortsCount}', Icons.groups_rounded, _brightCyan),
            _buildStatCard('حصص مكتملة', '${stats.completedSessionsCount}', Icons.check_circle_rounded, _electricPurple),
            _buildStatCard('حصص مجدولة', '${stats.scheduledSessionsCount}', Icons.pending_actions_rounded, Colors.orangeAccent),
            _buildStatCard('المداخيل المحققة', '${stats.totalEarnings.toStringAsFixed(0)} دج', Icons.monetization_on_rounded, Colors.amber),
            _buildStatCard('مداخيل قيد التأكيد', '${stats.pendingEarnings.toStringAsFixed(0)} دج', Icons.hourglass_top_rounded, Colors.amberAccent),
            _buildStatCard('انتهى رصيدهم', '${stats.expiredCreditsStudentsCount}', Icons.credit_card_off_rounded, Colors.redAccent),
            _buildStatCard('تسجيلات المكتبة', '${stats.libraryRecordingsCount}', Icons.video_library_rounded, const Color(0xFFEC4899)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayScheduleSection(BuildContext context, List<TeacherScheduleItem> schedule) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '📅 جدول حصص اليوم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            TextButton(
              onPressed: () => onNavigateToTab(2),
              child: const Text('عرض الجدول الأسبوعي', style: TextStyle(color: _brightCyan, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (schedule.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'لا توجد حصص إضافية مجدولة لليوم.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedule.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final item = schedule[idx];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _brightCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.timeFormatted,
                        style: const TextStyle(color: _brightCyan, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          Text(
                            '${item.subject} • ${item.cohortName}',
                            style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRecentAlertsPreview(BuildContext context) {
    final alerts = dashboard.notifications;
    if (alerts.isEmpty) return const SizedBox.shrink();

    final first = alerts.first;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _electricPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _electricPurple.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active_rounded, color: _brightCyan, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  first.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  first.body,
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
