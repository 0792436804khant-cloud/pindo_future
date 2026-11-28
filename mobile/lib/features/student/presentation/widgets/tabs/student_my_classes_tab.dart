import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chat_room_modal.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chats_hub_modal.dart';
import 'package:pindo_future_mobile/features/chat/services/cohort_chat_service.dart';
import '../views/cohort_session_history_view.dart';

class StudentMyClassesTab extends StatefulWidget {
  final StudentDashboardData dashboardData;
  final Function(String sessionId) onJoinLiveClassroom;
  final VoidCallback onOpenCohortsExplorer;

  const StudentMyClassesTab({
    super.key,
    required this.dashboardData,
    required this.onJoinLiveClassroom,
    required this.onOpenCohortsExplorer,
  });

  @override
  State<StudentMyClassesTab> createState() => _StudentMyClassesTabState();
}

class _StudentMyClassesTabState extends State<StudentMyClassesTab> {
  int _activeSubTab = 0; // 0: أفواجي, 1: البرنامج الأسبوعي, 2: سجل الحضور

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Cohort Chats Shortcut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حصصي والدروس المباشرة 🎓',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'بيئة دراستك التفاعلية، أفواجك، ومحادثات الدردشة الرسمية.',
                      style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => CohortChatsHubModal.show(
                  context,
                  currentUserName: widget.dashboardData.student.name,
                  currentUserRole: 'student',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _electricPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.forum_outlined, size: 16),
                label: Text(
                  'المحادثات (${CohortChatService().getTotalUnreadCount()})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sub-Tab Switcher (أفواجي | البرنامج الأسبوعي | سجل الحضور)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                _subTabItem(0, 'أفواجي المنخرط بها', Icons.groups_rounded),
                _subTabItem(1, 'البرنامج الأسبوعي', Icons.calendar_month_rounded),
                _subTabItem(2, 'سجل المواظبة', Icons.fact_check_rounded),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Active Sub-Tab View
          if (_activeSubTab == 0) _buildMyCohortsView(),
          if (_activeSubTab == 1) _buildWeeklyScheduleView(),
          if (_activeSubTab == 2) _buildAttendanceLedgerView(),
        ],
      ),
    );
  }

  Widget _subTabItem(int index, String label, IconData icon) {
    final isSelected = _activeSubTab == index;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeSubTab = index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? _electricPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: _electricPurple.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.white : Colors.white60),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white60,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyCohortsView() {
    final subs = widget.dashboardData.subscriptions;
    final nextSession = widget.dashboardData.nextSession;

    if (subs.activeCohortsCount == 0 && nextSession == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _brightCyan.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_outlined, color: _brightCyan, size: 36),
            ),
            const SizedBox(height: 16),
            const Text(
              'لم تنضم إلى أي فوج دراسي بعد',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'انضم إلى الأفواج الدراسية للأساتذة المعتمدين لمتابعة الحصص المباشرة والواجبات وسجلات الحضور والتقييمات.',
              style: TextStyle(color: Colors.white60, fontSize: 12.5, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onOpenCohortsExplorer,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brightCyan,
                foregroundColor: const Color(0xFF070B14),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('استكشاف الأفواج المتاحة للانضمام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (nextSession != null)
          _cohortCard(
            cohortId: nextSession.sessionId,
            title: nextSession.cohortName,
            subject: nextSession.subject,
            teacherName: nextSession.teacherName,
            remainingCredits: subs.remainingCredits,
            initialEnrollmentDate: 'فوج نشط ومسجل',
            nextSession: nextSession.isLive ? 'جارية الآن 🔴' : 'الحصة القادمة قريباً',
            status: 'فعال ومفعل ✓',
            statusColor: const Color(0xFF10B981),
          ),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: widget.onOpenCohortsExplorer,
          style: OutlinedButton.styleFrom(
            foregroundColor: _brightCyan,
            side: const BorderSide(color: _brightCyan),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('استكشاف والانضمام إلى أفواج إضافية'),
        ),
      ],
    );
  }

  Widget _cohortCard({
    required String cohortId,
    required String title,
    required String subject,
    required String teacherName,
    required int remainingCredits,
    required String initialEnrollmentDate,
    required String nextSession,
    required String status,
    required Color statusColor,
  }) {
    final student = widget.dashboardData.student;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'الرصيد: $remainingCredits حصص',
                style: const TextStyle(color: _brightCyan, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'المادة: $subject • الأستاذ: $teacherName',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: _brightCyan, size: 15),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'الحصة القادمة: $nextSession',
                    style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action 1: Live Join & Cohort Chat
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onJoinLiveClassroom(cohortId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brightCyan,
                    foregroundColor: const Color(0xFF070B14),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.sensors_rounded, size: 16),
                  label: const Text('دخول الحصة 🔴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => CohortChatRoomModal.show(
                    context,
                    cohortId: cohortId,
                    cohortName: title,
                    academicLevel: 'ثالثة ثانوي',
                    currentUserName: student.name,
                    currentUserRole: 'student',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.forum_outlined, size: 16, color: _brightCyan),
                  label: const Text('محادثة الفوج 💬', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Action 2: View Complete Session Table & History
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => CohortSessionHistoryView.open(
                context,
                cohortId: cohortId,
                cohortName: title,
                teacherName: teacherName,
                subject: subject,
                studentName: student.name,
                studentEmail: student.email,
                initialEnrollmentDate: initialEnrollmentDate,
                remainingCredits: remainingCredits,
                onJoinLiveClassroom: widget.onJoinLiveClassroom,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFDE68A),
                side: BorderSide(color: const Color(0xFFF59E0B).withValues(alpha: 0.6)),
                backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.table_chart_outlined, size: 16, color: Color(0xFFF59E0B)),
              label: const Text(
                'جدول الحصص الكامل وتفاصيل الاشتراكات 📊',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleView() {
    final schedule = widget.dashboardData.todaySchedule;
    final nextSession = widget.dashboardData.nextSession;

    if (schedule.isEmpty && nextSession == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_month_outlined, color: Colors.white.withValues(alpha: 0.35), size: 36),
            const SizedBox(height: 12),
            const Text(
              'البرنامج الأسبوعي فارغ حالياً',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'عند انضمامك إلى الأفواج الدراسية، ستظهر هنا مواعيد جميع حصصك المجدولة أسبوعياً.',
              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: schedule.map((d) {
        final dt = d.scheduledAt;
        final now = DateTime.now();
        final dateLabel = dt == null
            ? ''
            : (dt.year == now.year && dt.month == now.month && dt.day == now.day)
                ? 'اليوم'
                : '${dt.day}/${dt.month}';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _electricPurple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _electricPurple),
                ),
                child: Column(
                  children: [
                    Text(
                      d.time,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    if (dateLabel.isNotEmpty)
                      Text(
                        dateLabel,
                        style: const TextStyle(color: Colors.white70, fontSize: 9.5),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.cohortName.isNotEmpty ? '${d.subject} • ${d.cohortName}' : d.subject,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${d.teacher} • ${d.topic}${dateLabel.isNotEmpty ? ' ($dateLabel)' : ''}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttendanceLedgerView() {
    final attendance = widget.dashboardData.attendance;

    if (attendance.totalSessions == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(Icons.fact_check_outlined, color: Colors.white.withValues(alpha: 0.35), size: 36),
            const SizedBox(height: 12),
            const Text(
              'سجل الحضور فارغ',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'لم يتم تسجيل حضورك لأي حصة تفاعلية حتى الآن. احرص على حضور الحصص المباشرة لتسجيل مواظبتك.',
              style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final records = <Map<String, String>>[
      {
        'date': 'الحصة الأخيرة',
        'session': 'حصة تفاعلية معتمدة',
        'join': '--:--',
        'leave': '--:--',
        'duration': 'مكتملة',
        'status': 'حاضر',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rate Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_deepIndigo, Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _brightCyan.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('نسبة الحضور الإجمالية للفوج', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    '${attendance.attendanceRate}% مواظبة ممتازة',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'حضرت ${attendance.attendedSessions} من أصل ${attendance.totalSessions} حصة رسمية',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
              const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 36),
            ],
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'سجل الحضور والغياب الموثّق (قيد الحفظ الآلي):',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        ...records.map((r) {
          final isPresent = r['status'] == 'حاضر';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['session']!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text('التاريخ: ${r['date']} • المدة: ${r['duration']}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPresent
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isPresent ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                    ),
                  ),
                  child: Text(
                    r['status']!,
                    style: TextStyle(
                      color: isPresent ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
