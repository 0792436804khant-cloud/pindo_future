import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';

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
          // Header
          const Text(
            'حصصي والبرنامج الدراسي 🎓',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'تابع أفواجك المسجل بها، جدول الحصص الأسبوعي، وسجل حضورك وغيابك الموثّق.',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
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
                _subTabItem(0, 'أفواجي (Cohorts)', Icons.groups_rounded),
                _subTabItem(1, 'البرنامج الأسبوعي', Icons.calendar_month_rounded),
                _subTabItem(2, 'سجل الحضور', Icons.fact_check_rounded),
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
          title: 'فوج النخبة بكالوريا 2026 (شعبة علوم تجريبية)',
          subject: 'الرياضيات',
          teacherName: 'Professor Alan Turing',
          remainingCredits: 4,
          nextSession: 'اليوم 18:00 (المتتاليات وحساب النهايات)',
          sessionId: 'SES_8PP4LVG1',
          status: 'فعال',
        ),
        const SizedBox(height: 14),
        _cohortCard(
          title: 'فوج التفوق في الفيزياء والكيمياء',
          subject: 'العلوم الفيزيائية',
          teacherName: 'Dr. Marie Curie',
          remainingCredits: 6,
          nextSession: 'الأربعاء 17:30 (الميكانيكا وحركة الكواكب)',
          sessionId: 'SES_CURIE_01',
          status: 'فعال',
        ),
        const SizedBox(height: 16),
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
    required String title,
    required String subject,
    required String teacherName,
    required int remainingCredits,
    required String nextSession,
    required String sessionId,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.75),
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 12),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => widget.onJoinLiveClassroom(sessionId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brightCyan,
                    foregroundColor: const Color(0xFF070B14),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.sensors_rounded, size: 16),
                  label: const Text('دخول الحصة المباشرة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleView() {
    final days = [
      {'day': 'الأحد', 'time': '18:00', 'subject': 'الرياضيات', 'teacher': 'Alan Turing'},
      {'day': 'الإثنين', 'time': '20:00', 'subject': 'الفيزياء', 'teacher': 'Marie Curie'},
      {'day': 'الثلاثاء', 'time': '17:30', 'subject': 'العلوم الطبيعية', 'teacher': 'Ibn Sina'},
      {'day': 'الأربعاء', 'time': '18:00', 'subject': 'الرياضيات', 'teacher': 'Alan Turing'},
      {'day': 'الخميس', 'time': '19:00', 'subject': 'اللغة العربية والبلاغة', 'teacher': 'Fatima Al-Zahra'},
      {'day': 'الجمعة', 'time': '15:00', 'subject': 'محاكاة بكالوريا تجريبية', 'teacher': 'منصة Pindo Future'},
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
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: _electricPurple.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    d['day']!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d['subject']!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'الأستاذ: ${d['teacher']}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _brightCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  d['time']!,
                  style: const TextStyle(color: _brightCyan, fontSize: 11.5, fontWeight: FontWeight.bold),
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
      {'date': '2026-10-24', 'session': 'المتتاليات العددية', 'join': '18:02', 'leave': '19:35', 'duration': '93 دقيقة', 'status': 'حاضر'},
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
