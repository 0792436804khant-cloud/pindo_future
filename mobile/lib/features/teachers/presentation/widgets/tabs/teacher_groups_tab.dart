import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import '../modals/create_cohort_modal.dart';
import '../modals/attendance_excel_sheet_modal.dart';
import '../modals/cohort_members_modal.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chat_room_modal.dart';
import 'package:pindo_future_mobile/features/chat/presentation/widgets/cohort_chats_hub_modal.dart';

class TeacherGroupsTab extends StatefulWidget {
  final List<TeacherCohortItem> cohorts;
  final Future<void> Function(Map<String, dynamic> payload)? onCreateCohort;
  final VoidCallback? onRefresh;
  final String? teacherName;
  final List<String> allowedTeachingYears;
  final List<String> allowedTeachingSubjects;

  const TeacherGroupsTab({
    super.key,
    required this.cohorts,
    this.onCreateCohort,
    this.onRefresh,
    this.teacherName,
    this.allowedTeachingYears = const [],
    this.allowedTeachingSubjects = const [],
  });

  @override
  State<TeacherGroupsTab> createState() => _TeacherGroupsTabState();
}

class _TeacherGroupsTabState extends State<TeacherGroupsTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final String _selectedFilter = 'الكل';

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCohorts = widget.cohorts.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.subject.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;
      if (_selectedFilter == 'النشطة فقط') return c.isActive;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Create Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '👥 إدارة الأفواج الدراسية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'تنظيم المجموعات، متابعة الطلاب، وسجلات الحضور',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => CohortChatsHubModal.show(context),
                    icon: const Icon(Icons.forum_outlined, size: 16, color: _brightCyan),
                    label: const Text('المحادثات 💬', style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _brightCyan),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => CreateCohortModal.show(
                      context,
                      onSave: widget.onCreateCohort,
                      allowedTeachingYears: widget.allowedTeachingYears,
                      allowedTeachingSubjects: widget.allowedTeachingSubjects,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('فوج جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search & Filter
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ابحث باسم الفوج أو المادة...',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
              prefixIcon: const Icon(Icons.search_rounded, color: _brightCyan, size: 20),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 16),

          // Cohort Cards List
          if (filteredCohorts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'لم يتم العثور على أي أفواج مطابقة للبحث.\nاضغط على «فوج جديد» لإنشاء أول فوج.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredCohorts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, idx) {
                final cohort = filteredCohorts[idx];
                return _buildCohortCard(context, cohort);
              },
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCohortCard(BuildContext context, TeacherCohortItem cohort) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cohort.isActive ? _electricPurple.withValues(alpha: 0.4) : Colors.white12,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
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
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _brightCyan.withValues(alpha: 0.4)),
                ),
                child: Text(
                  cohort.academicLevel,
                  style: const TextStyle(color: _brightCyan, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: cohort.isActive
                      ? const Color(0xFF10B981).withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  cohort.isActive ? '🟢 التسجيل مفتوح' : '🔴 التسجيل مغلق',
                  style: TextStyle(
                    color: cohort.isActive ? const Color(0xFF10B981) : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            cohort.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (cohort.stream != null) ...[
            const SizedBox(height: 3),
            Text(
              'شعبة: ${cohort.stream}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],

          const SizedBox(height: 12),

          // Details row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  icon: Icons.people_alt_rounded,
                  label: 'المسجلين',
                  value: '${cohort.enrolledCount}/${cohort.maxStudents}',
                  color: const Color(0xFF10B981),
                ),
                _buildMetric(
                  icon: Icons.payments_rounded,
                  label: 'الحصص المباشرة',
                  value: '${cohort.liveSessionsPrice.toStringAsFixed(0)} دج',
                  color: Colors.amber,
                ),
                _buildMetric(
                  icon: Icons.video_library_rounded,
                  label: cohort.hasLibrary ? 'المكتبة فقط' : 'المكتبة الرقمية',
                  value: cohort.hasLibrary ? '${cohort.libraryPrice.toStringAsFixed(0)} دج' : 'غير متاحة',
                  color: cohort.hasLibrary ? _brightCyan : Colors.white38,
                ),
                _buildMetric(
                  icon: Icons.all_inclusive_rounded,
                  label: 'الباقة المتكاملة',
                  value: '${cohort.bundlePrice.toStringAsFixed(0)} دج',
                  color: const Color(0xFFA855F7),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 1. Official Primary Cohort Chat Button (محادثة الفوج الرسمية)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => CohortChatRoomModal.show(
                context,
                cohortId: cohort.id.toString(),
                cohortName: cohort.name,
                academicLevel: cohort.academicLevel,
                currentUserName: widget.teacherName ?? 'الأستاذ',
                currentUserRole: 'teacher',
              ),
              icon: const Icon(Icons.forum_rounded, size: 17),
              label: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'محادثة الفوج والدردشة 💬',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, size: 12),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brightCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Action buttons for cohort
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AttendanceExcelSheetModal.show(
                    context,
                    cohortId: cohort.id,
                    cohortName: cohort.name,
                  ),
                  icon: const Icon(Icons.table_chart_rounded, size: 16, color: Color(0xFF10B981)),
                  label: const Text('جدول الحضور Excel', style: TextStyle(color: Colors.white, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF10B981)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => CohortMembersModal.show(
                    context,
                    cohortId: cohort.id,
                    cohortName: cohort.name,
                    onMembersChanged: widget.onRefresh,
                  ),
                  icon: const Icon(Icons.badge_rounded, size: 16),
                  label: const Text('قائمة الطلاب', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _electricPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
      ],
    );
  }
}
