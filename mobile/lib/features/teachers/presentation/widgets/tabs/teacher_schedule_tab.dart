import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import '../modals/create_session_modal.dart';

class TeacherScheduleTab extends StatefulWidget {
  final List<TeacherScheduleItem> schedule;
  final List<TeacherCohortItem> cohorts;
  final VoidCallback onStartLiveSession;

  const TeacherScheduleTab({
    super.key,
    required this.schedule,
    required this.cohorts,
    required this.onStartLiveSession,
  });

  @override
  State<TeacherScheduleTab> createState() => _TeacherScheduleTabState();
}

class _TeacherScheduleTabState extends State<TeacherScheduleTab> {
  int _selectedDayIndex = 0;
  final List<String> _days = const ['اليوم', 'غداً', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Create Session Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📅 الجدول والبرامج الدراسية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'تنظيم مواعيد الحصص وإطلاق البث المباشر',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => CreateSessionModal.show(context, cohorts: widget.cohorts),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('برمجة حصة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brightCyan,
                  foregroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Days Selector Tabs
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final isSelected = _selectedDayIndex == idx;
                return InkWell(
                  onTap: () => setState(() => _selectedDayIndex = idx),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? _electricPurple : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? _brightCyan : Colors.white12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _days[idx],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Scheduled Classes List
          if (widget.schedule.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'لا توجد حصص مجدولة لهذا اليوم.\nاضغط على «برمجة حصة» لجدولة موعد جديد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.schedule.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, idx) {
                final item = widget.schedule[idx];
                return _buildSessionTimelineCard(context, item);
              },
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSessionTimelineCard(BuildContext context, TeacherScheduleItem item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _brightCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_filled, color: _brightCyan, size: 13),
                    const SizedBox(width: 5),
                    Text(
                      item.timeFormatted,
                      style: const TextStyle(color: _brightCyan, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'مجدولة مؤكدة',
                  style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            item.title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),

          const SizedBox(height: 4),

          Text(
            '${item.subject} • ${item.cohortName}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),

          const SizedBox(height: 14),

          // Action row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onStartLiveSession,
                  icon: const Icon(Icons.video_call_rounded, size: 18),
                  label: const Text('دخول غرفة البث الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إرسال إشعار تذكيري لجميع طلاب هذا الفوج.'),
                      backgroundColor: _electricPurple,
                    ),
                  );
                },
                tooltip: 'إرسال تذكير للطلاب',
                icon: const Icon(Icons.notification_add_rounded, color: _brightCyan, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
