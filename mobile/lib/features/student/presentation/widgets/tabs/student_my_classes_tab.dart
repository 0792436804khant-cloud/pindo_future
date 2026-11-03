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
    return Column(
      children: [
        _cohortCard(
          cohortId: 'SES_8PP4LVG1',
          title: 'فوج النخبة للبكالوريا — الرياضيات (شعبة علوم تجريبية ورياضي)',
          subject: 'الرياضيات',
          teacherName: 'الأستاذ محمد أمين بن عيسى',
          remainingCredits: 4,
          initialEnrollmentDate: '01 سبتمبر 2026',
          nextSession: 'اليوم 18:00 (المتتاليات والبرهان بالتراجع 🔴)',
          status: 'فعال ومفعل ✓',
          statusColor: const Color(0xFF10B981),
        ),
        const SizedBox(height: 14),
        _cohortCard(
          cohortId: 'SES_CURIE_01',
          title: 'فوج التفوق في العلوم الفيزيائية والكيمياء',
          subject: 'العلوم الفيزيائية',
          teacherName: 'الأستاذة كريمة بلقاسم',
          remainingCredits: 6,
          initialEnrollmentDate: '15 سبتمبر 2026',
          nextSession: 'الأربعاء 17:30 (المتابعة الزمنية والميكانيكا)',
          status: 'فعال ومفعل ✓',
          statusColor: const Color(0xFF10B981),
        ),
        const SizedBox(height: 14),
        _cohortCard(
          cohortId: 'SES_BIO_2026',
          title: 'فوج التميز في علوم الطبيعة والحياة',
          subject: 'علوم الطبيعة والحياة',
          teacherName: 'الأستاذ عبد الرحمن دحمان',
          remainingCredits: 1,
          initialEnrollmentDate: '20 سبتمبر 2026',
          nextSession: 'الخميس 18:00 (آليات تركيب البروتين والإنزيمات)',
          status: 'مستحق للتجديد قريباً ⚠️',
          statusColor: const Color(0xFFF59E0B),
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
    final days = [
      {'day': 'الأحد', 'time': '18:00', 'subject': 'الرياضيات — حل المسائل النموذجية', 'teacher': 'الأستاذ محمد أمين'},
      {'day': 'الإثنين', 'time': '20:00', 'subject': 'العلوم الفيزيائية — الميكانيكا والكهرباء', 'teacher': 'الأستاذة كريمة بلقاسم'},
      {'day': 'الثلاثاء', 'time': '17:30', 'subject': 'علوم الطبيعة والحياة — منهجية الاستدلال', 'teacher': 'الأستاذ عبد الرحمن'},
      {'day': 'الأربعاء', 'time': '18:00', 'subject': 'الرياضيات — الدوال والتطبيقات الرسمية', 'teacher': 'الأستاذ محمد أمين'},
      {'day': 'الخميس', 'time': '19:00', 'subject': 'اللغة العربية وفنون البلاغة', 'teacher': 'الأستاذ مراد زروقي'},
      {'day': 'الجمعة', 'time': '15:00', 'subject': 'جلسة المراجعة الشاملة للامتحانات الرسمية', 'teacher': 'إشراف المنصة'},
    ];

    return Column(
      children: days.map((d) {
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
                child: Text(
                  d['day']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['subject']!,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${d['teacher']} • ${d['time']}',
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

    final records = [
      {'date': '2026-10-24', 'session': 'حل المسائل الشاملة للبكالوريا', 'join': '18:02', 'leave': '19:35', 'duration': '93 دقيقة', 'status': 'حاضر'},
      {'date': '2026-10-21', 'session': 'الميكانيكا وقوانين نيوتن', 'join': '17:34', 'leave': '19:10', 'duration': '96 دقيقة', 'status': 'حاضر'},
      {'date': '2026-10-18', 'session': 'المقال الفلسفي', 'join': '18:15', 'leave': '19:30', 'duration': '75 دقيقة', 'status': 'متأخر'},
      {'date': '2026-10-15', 'session': 'التحولات النووية', 'join': '17:30', 'leave': '19:00', 'duration': '90 دقيقة', 'status': 'حاضر'},
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
