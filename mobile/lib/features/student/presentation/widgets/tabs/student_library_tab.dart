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

  final List<Map<String, dynamic>> _libraryItems = [
    {
      'id': 1,
      'title': 'حلول نموذجية لتمارين الميكانيكا وقوانين نيوتن',
      'subject': 'الفيزياء',
      'teacher': 'Dr. Marie Curie',
      'cohort': 'فوج التفوق في الفيزياء',
      'duration': '105 دقيقة',
      'date': '2026-10-24',
      'views': 'مشاهدة واحدة',
      'hasNotes': true,
      'isProtected': true,
    },
    {
      'id': 2,
      'title': 'المتتاليات وحساب النهايات — دورة البكالوريا المكثفة',
      'subject': 'الرياضيات',
      'teacher': 'Professor Alan Turing',
      'cohort': 'فوج النخبة بكالوريا 2026',
      'duration': '90 دقيقة',
      'date': '2026-10-22',
      'views': 'مكتمل',
      'hasNotes': true,
      'isProtected': true,
    },
    {
      'id': 3,
      'title': 'منهجية معالجة المقال الفلسفي للشعب العلمية والرياضية',
      'subject': 'الفلسفة',
      'teacher': 'Prof. Ibn Sina',
      'cohort': 'فوج المنهجية الفلسفية',
      'duration': '75 دقيقة',
      'date': '2026-10-19',
      'views': 'لم تتم المشاهدة بعد',
      'hasNotes': true,
      'isProtected': true,
    },
    {
      'id': 4,
      'title': 'التحولات النووية والانشطار والاندماج النووي',
      'subject': 'الفيزياء',
      'teacher': 'Dr. Marie Curie',
      'cohort': 'فوج التفوق في الفيزياء',
      'duration': '95 دقيقة',
      'date': '2026-10-15',
      'views': 'مكتمل',
      'hasNotes': false,
      'isProtected': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedFilter == 'الكل'
        ? _libraryItems
        : _libraryItems.where((i) => i['subject'] == _selectedFilter).toList();

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

          // Security banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Color(0xFF34D399), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'تسجيلاتك محمية ومشفرة. تُعرض بعلامة مائية شخصية (${widget.dashboardData.student.name}) لحماية حقوق الأستاذ والتلميذ.',
                    style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 11.5),
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
                          item['subject']!,
                          style: const TextStyle(color: _brightCyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: Colors.white54, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            item['duration']!,
                            style: const TextStyle(color: Colors.white60, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['title']!,
                    style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الأستاذ: ${item['teacher']} • ${item['cohort']}',
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
                          Text('تاريخ الحصة: ${item['date']}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => widget.onOpenRecording(item['id'] as int),
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
