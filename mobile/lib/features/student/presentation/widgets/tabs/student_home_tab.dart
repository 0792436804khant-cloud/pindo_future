import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/core/widgets/glassmorphism.dart';
import 'package:pindo_future_mobile/core/widgets/bento_card.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/student_notifications_sheet.dart';

class StudentHomeTab extends StatelessWidget {
  final StudentDashboardData dashboardData;
  final VoidCallback onRefresh;
  final Function(String sessionId) onJoinLiveClassroom;
  final Function(int recordingId) onOpenRecording;
  final VoidCallback onOpenExamBank;
  final VoidCallback onOpenWeeklySchedule;
  final VoidCallback onManageSubscriptions;
  final VoidCallback onOpenAccountSettings;

  const StudentHomeTab({
    super.key,
    required this.dashboardData,
    required this.onRefresh,
    required this.onJoinLiveClassroom,
    required this.onOpenRecording,
    required this.onOpenExamBank,
    required this.onOpenWeeklySchedule,
    required this.onManageSubscriptions,
    required this.onOpenAccountSettings,
  });

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  @override
  Widget build(BuildContext context) {
    final student = dashboardData.student;
    final nextSession = dashboardData.nextSession;
    final subscriptions = dashboardData.subscriptions;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: _brightCyan,
      backgroundColor: const Color(0xFF0F172A),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome & Greeting Bar
            _buildWelcomeBar(context, student),
            const SizedBox(height: 20),

            // 2. Next Session Hero Card (بطاقة الحصة القادمة)
            if (nextSession != null) ...[
              _buildNextSessionHeroCard(context, nextSession),
              const SizedBox(height: 20),
            ],

            // 3. Subscriptions & Credit Ledger Summary (اشتراكاتي ورصيدي)
            _buildSubscriptionsSummary(subscriptions),
            const SizedBox(height: 20),

            // 4. Today's Schedule (جدول اليوم)
            _buildTodayScheduleCard(context),
            const SizedBox(height: 20),

            // 5. Algerian National Exam Bank & Timed Simulations
            _buildExamBankBento(),
            const SizedBox(height: 20),

            // 6. Recent Protected Recordings (آخر التسجيلات)
            _buildRecentRecordingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBar(BuildContext context, StudentProfile student) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_brightCyan, _electricPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _brightCyan.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF0F172A),
                child: Text(
                  student.name.isNotEmpty ? student.name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'مرحباً، ${student.name.split(' ').first} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'منظومتك التعليمية الذكية • Pindo Future',
                  style: TextStyle(color: Colors.white60, fontSize: 11.5),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Notifications Bell
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                  onPressed: () => StudentNotificationsSheet.show(context, dashboardData.notifications),
                ),
                if (dashboardData.notifications.any((n) => !n.isRead))
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
              onPressed: onOpenAccountSettings,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextSessionHeroCard(BuildContext context, StudentNextSession session) {
    final bool isLive = session.isLive;

    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(22),
      blurSigma: 18.0,
      borderWidth: 1.4,
      borderColor: isLive ? const Color(0xFFEF4444).withValues(alpha: 0.6) : _brightCyan.withValues(alpha: 0.4),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          isLive
              ? const Color(0xFF7F1D1D).withValues(alpha: 0.85)
              : _deepIndigo.withValues(alpha: 0.85),
          const Color(0xFF1E1B4B).withValues(alpha: 0.70),
          const Color(0xFF0F172A).withValues(alpha: 0.90),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: isLive ? const Color(0xFFEF4444).withValues(alpha: 0.3) : _brightCyan.withValues(alpha: 0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isLive
                      ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                      : _brightCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLive ? const Color(0xFFEF4444) : _brightCyan,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isLive ? const Color(0xFFEF4444) : _brightCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLive ? 'الحصة بدأت الآن (بث حي)' : 'الحصة القادمة 🎥',
                      style: TextStyle(
                        color: isLive ? const Color(0xFFFCA5A5) : _brightCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isLive ? '🔴 LIVE' : 'اليوم 18:00',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Title & Subject
          Text(
            session.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.school_outlined, color: _brightCyan, size: 15),
              const SizedBox(width: 6),
              Text(
                '${session.subject} • ${session.teacherName}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.groups_outlined, color: Color(0xFF10B981), size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  session.cohortName,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Action Button
          ElevatedButton(
            onPressed: () => onJoinLiveClassroom(session.sessionId),
            style: ElevatedButton.styleFrom(
              backgroundColor: isLive ? const Color(0xFFEF4444) : _brightCyan,
              foregroundColor: isLive ? Colors.white : const Color(0xFF070B14),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLive ? Icons.sensors_rounded : Icons.login_rounded,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isLive ? 'ادخل إلى الحصة الآن 🔴' : 'تفاصيل ودخول الحصة',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsSummary(StudentSubscriptionSummary subs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'اشتراكاتي ورصيدي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: onManageSubscriptions,
              style: TextButton.styleFrom(
                foregroundColor: _brightCyan,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('إدارة الاشتراك ←', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // Card 1: Remaining Credits
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _brightCyan.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.confirmation_num_outlined, color: _brightCyan, size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'رصيد الحصص',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${subs.remainingCredits} حصص',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'متبقية في الباقة الحالية',
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Card 2: Library Status
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.video_library_rounded, color: Color(0xFF10B981), size: 16),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'المكتبة المحمية',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'متاحة ✓',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'وصول للتسجيلات والمذكرات',
                      style: TextStyle(color: Colors.white54, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayScheduleCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: _electricPurple, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'جدول اليوم',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: onOpenWeeklySchedule,
                style: TextButton.styleFrom(
                  foregroundColor: _brightCyan,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('البرنامج الأسبوعي ←', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...dashboardData.todaySchedule.map((item) {
            final isLive = item.status == 'live';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isLive ? _brightCyan.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isLive ? _brightCyan.withValues(alpha: 0.35) : Colors.white10,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _electricPurple.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.time,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.subject,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.teacher,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFEF4444)),
                        ),
                        child: const Text(
                          'جارٍ الآن',
                          style: TextStyle(color: Color(0xFFFCA5A5), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExamBankBento() {
    return BentoCard(
      isHero: true,
      title: 'بنك الامتحانات الرسمية والمحاكاة (BAC & BEM)',
      subtitle: 'تدرّب على مواضيع البكالوريا والتعليم المتوسط الرسمية (2008–2025) مع سلم التنقيط الوزاري ومحاكي الامتحانات الموقوت.',
      icon: Icons.history_edu_rounded,
      accentColor: const Color(0xFFF59E0B),
      secondaryAccent: const Color(0xFF10B981),
      badgeText: 'BEM & BAC 2008-2025',
      badgeColor: const Color(0xFFF59E0B),
      onTap: onOpenExamBank,
    );
  }

  Widget _buildRecentRecordingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.video_library_rounded, color: _brightCyan, size: 18),
            SizedBox(width: 8),
            Text(
              'آخر التسجيلات المتاحة لك',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...dashboardData.recentRecordings.map((rec) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => onOpenRecording(rec.id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _brightCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: _brightCyan, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.title,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${rec.subject} • ${rec.teacherName} • ${rec.durationMinutes} دقيقة',
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 12),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
