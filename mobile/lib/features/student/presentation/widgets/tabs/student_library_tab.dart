import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/classroom/presentation/widgets/floating_student_watermark.dart';

class StudentLibraryTab extends StatefulWidget {
  final StudentDashboardData dashboardData;
  final Function(int recordingId) onOpenRecording;

  const StudentLibraryTab({
    super.key,
    required this.dashboardData,
    required this.onOpenRecording,
  });

  @override
  State<StudentLibraryTab> createState() => _StudentLibraryTabState();
}

class _StudentLibraryTabState extends State<StudentLibraryTab> {
  String _selectedFilter = 'الكل';
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  Widget build(BuildContext context) {
    final realItems = widget.dashboardData.recentRecordings.map((r) => {
      'id': r.id,
      'title': r.title,
      'subject': r.subject,
      'teacher': r.teacherName,
      'cohort': 'فوجك الدراسي',
      'duration': '${r.durationMinutes} دقيقة',
      'date': 'تسجيل حديث',
      'views': 'متاح',
      'hasNotes': true,
      'isProtected': true,
    }).toList();

    final filtered = _selectedFilter == 'الكل'
        ? realItems
        : realItems.where((i) => i['subject'] == _selectedFilter).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'مكتبتي التعليمية المحمية 📚',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'جميع تسجيلات الحصص السابقة، ملخصات الأساتذة، ومذكرات التمارين المحمية بعلامة مائية مضادة للتسريب.',
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Enhanced Anti-Piracy Security banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.15),
                  const Color(0xFF0F172A).withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.40)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Color(0xFF34D399), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'حماية قصوى ضد لقطات الشاشة وتسجيل الفيديو (FLAG_SECURE) 🔒',
                        style: TextStyle(color: Color(0xFF34D399), fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'يُمنع تسجيل أو تصوير الحلقات عتادياً. تعرض الفيديوهات بعلامة مائية ديناميكية مشفرة باسمك (${widget.dashboardData.student.name}).',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 10.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['الكل', 'الرياضيات', 'الفيزياء', 'الفلسفة'].map((cat) {
                final isSelected = _selectedFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = cat),
                    selectedColor: _brightCyan,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF070B14) : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: isSelected ? _brightCyan : Colors.white12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Recordings list
          if (filtered.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Icon(Icons.video_library_outlined, color: Colors.white.withValues(alpha: 0.35), size: 38),
                  const SizedBox(height: 12),
                  const Text(
                    'مكتبتك التعليمية فارغة حالياً',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ستتم أرشفة وحفظ تسجيلات جميع حصصك التفاعلية هنا تلقائياً بعد انتهائها، لتتمكن من مراجعتها في أي وقت.',
                    style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ...filtered.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _electricPurple.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item['subject']?.toString() ?? '',
                            style: const TextStyle(color: _brightCyan, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, color: Colors.white54, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              item['duration']?.toString() ?? '',
                              style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['title']?.toString() ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الأستاذ: ${item['teacher'] ?? ''} • ${item['cohort'] ?? ''}',
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, color: Color(0xFF10B981), size: 14),
                            const SizedBox(width: 4),
                            const Text('مشفر ومحمي', style: TextStyle(color: Color(0xFF34D399), fontSize: 11)),
                            const SizedBox(width: 10),
                            Text('تاريخ الحصة: ${item['date'] ?? ''}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => widget.onOpenRecording(item['id'] as int? ?? 0),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brightCyan,
                            foregroundColor: const Color(0xFF070B14),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 16),
                          label: const Text('تشغيل التسجيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
