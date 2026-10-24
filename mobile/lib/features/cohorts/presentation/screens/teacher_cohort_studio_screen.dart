import 'package:flutter/material.dart';
import '../../../../core/constants/algerian_education_constants.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../teachers/presentation/widgets/teacher_verification_badge.dart';
import '../../domain/entities/study_cohort_entity.dart';
import '../controllers/cohort_controller.dart';

class TeacherCohortStudioScreen extends StatefulWidget {
  final User teacher;
  final CohortController cohortController;

  const TeacherCohortStudioScreen({
    super.key,
    required this.teacher,
    required this.cohortController,
  });

  @override
  State<TeacherCohortStudioScreen> createState() => _TeacherCohortStudioScreenState();
}

class _TeacherCohortStudioScreenState extends State<TeacherCohortStudioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.teacher.token != null) {
        widget.cohortController.loadTeacherCohorts(widget.teacher.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.groups_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            const Text(
              'استوديو الأفواج التعليمية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            TeacherVerificationBadge(
              isVerified: widget.teacher.isTeacherVerified,
              size: 20,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              if (widget.teacher.token != null) {
                widget.cohortController.loadTeacherCohorts(widget.teacher.token!);
              }
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.cohortController,
        builder: (context, _) {
          final controller = widget.cohortController;

          if (controller.isLoading && controller.teacherCohorts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildVerificationBanner(context),
                const SizedBox(height: 16),
                _buildHeaderCard(context, controller),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أفواجي النشطة (${controller.teacherCohorts.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('فوج جديد'),
                      onPressed: () => _showCreateCohortModal(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (controller.teacherCohorts.isEmpty)
                  _buildEmptyState(context)
                else
                  ...controller.teacherCohorts.map((cohort) => _buildCohortCard(context, cohort)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerificationBanner(BuildContext context) {
    if (widget.teacher.isTeacherVerified) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: Color(0xFF10B981), size: 24),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'حسابك معتمد وموثق بشارة الاعتماد الرسمية لمنصة بيندو فيوتشر ✅',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF3B82F6), size: 24),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'احصل على شارة الأستاذ المعتمد لزيادة موثوقيتك لدى التلاميذ والأولياء.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            onPressed: () => _showVerificationRequestModal(context),
            child: const Text('طلب التوثيق', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, CohortController controller) {
    int totalStudents = controller.teacherCohorts.fold(0, (sum, c) => sum + c.enrolledCount);
    int totalSeats = controller.teacherCohorts.fold(0, (sum, c) => sum + c.maxStudents);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('الأفواج', '${controller.teacherCohorts.length}', Icons.class_outlined, const Color(0xFF10B981)),
          _buildStatDivider(),
          _buildStatItem('التلاميذ المسجلين', '$totalStudents', Icons.people_outline, const Color(0xFF3B82F6)),
          _buildStatDivider(),
          _buildStatItem('المقاعد الإجمالية', '$totalSeats', Icons.airline_seat_recline_normal, const Color(0xFFF59E0B)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(height: 36, width: 1, color: Colors.white.withValues(alpha: 0.1));
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
      ],
    );
  }

  Widget _buildCohortCard(BuildContext context, StudyCohortEntity cohort) {
    final occupancy = cohort.maxStudents > 0 ? (cohort.enrolledCount / cohort.maxStudents).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  cohort.name,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cohort.formattedPrice,
                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildBadge(cohort.academicLevel, const Color(0xFF3B82F6)),
              if (cohort.stream != null) _buildBadge(cohort.stream!, const Color(0xFF8B5CF6)),
              _buildBadge(cohort.subject, const Color(0xFFEC4899)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الاستيعاب: ${cohort.enrolledCount} / ${cohort.maxStudents} تلميذ',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
              ),
              Text(
                '${cohort.availableSeats} مقعد متبقي',
                style: TextStyle(
                  color: cohort.isFull ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: occupancy,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              color: cohort.isFull ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.video_call_rounded, size: 18),
                  label: const Text('جدولة حصة مباشرة'),
                  onPressed: () => _showScheduleSessionModal(context, cohort),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'إدارة التلاميذ',
                icon: const Icon(Icons.people_outline, color: Colors.white70),
                onPressed: () => _showManageMembersModal(context, cohort),
              ),
              IconButton(
                tooltip: 'حذف الفوج',
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                onPressed: () => _confirmDeleteCohort(context, cohort),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.groups_outlined, size: 64, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text(
              'لا توجد أفواج تعليمية بعد',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بإنشاء فوجك الأول لجمع تلاميذك وجدولة الحصص المباشرة والاشتراكات.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCohortModal(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '3000');
    final maxStudentsController = TextEditingController(text: '100');
    String selectedLevel = AlgerianEducationConstants.academicLevels.first;
    String selectedStream = AlgerianEducationConstants.secondaryStreams.first;
    String selectedSubject = AlgerianEducationConstants.subjects.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'إنشاء فوج تعليمي جديد',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'اسم الفوج (مثال: فوج النخبة - بكالوريا 2026)',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevel,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'المستوى الأكاديمي',
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: AlgerianEducationConstants.academicLevels.map((lvl) {
                    return DropdownMenuItem(value: lvl, child: Text(lvl, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedLevel = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStream,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'الشعبة الدراسية',
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: AlgerianEducationConstants.secondaryStreams.map((st) {
                    return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedStream = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSubject,
                  dropdownColor: const Color(0xFF0F172A),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'المادة التعليمية',
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: AlgerianEducationConstants.subjects.map((sub) {
                    return DropdownMenuItem(value: sub, child: Text(sub, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSubject = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: maxStudentsController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'الاستيعاب (تلميذ)',
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'السعر الشهري (دج)',
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    if (widget.teacher.token != null) {
                      await widget.cohortController.createCohort(widget.teacher.token!, {
                        'name': nameController.text.trim(),
                        'subject': selectedSubject,
                        'academic_level': selectedLevel,
                        'stream': selectedStream,
                        'max_students': int.tryParse(maxStudentsController.text) ?? 100,
                        'monthly_price': double.tryParse(priceController.text) ?? 0.0,
                      });
                    }
                  },
                  child: const Text('إنشاء وتفعيل الفوج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showScheduleSessionModal(BuildContext context, StudyCohortEntity cohort) {
    final titleController = TextEditingController(text: 'حصة مباشرة - ${cohort.name}');
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('جدولة حصة مباشرة لفوج: ${cohort.name}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'عنوان الحصة',
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'محاور الحصة والملخص',
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                if (widget.teacher.token != null) {
                  await widget.cohortController.scheduleSession(widget.teacher.token!, cohort.id, {
                    'title': titleController.text.trim(),
                    'description': descController.text.trim(),
                    'scheduled_at': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
                  });
                }
              },
              child: const Text('تأكيد وجدولة الحصة المباشرة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageMembersModal(BuildContext context, StudyCohortEntity cohort) {
    final identifierController = TextEditingController();

    if (widget.teacher.token != null) {
      widget.cohortController.loadCohortMembers(widget.teacher.token!, cohort.id);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => ListenableBuilder(
        listenable: widget.cohortController,
        builder: (context, _) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تلاميذ فوج: ${cohort.name}',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: identifierController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'أدخل بريد التلميذ أو معرفه (STU_...)',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: () async {
                      final id = identifierController.text.trim();
                      if (id.isEmpty || widget.teacher.token == null) return;
                      await widget.cohortController.addMember(widget.teacher.token!, cohort.id, id);
                      identifierController.clear();
                    },
                    child: const Text('إضافة'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: widget.cohortController.cohortMembers.isEmpty
                    ? Center(
                        child: Text(
                          'لا يوجد تلاميذ مسجلين في هذا الفوج حالياً',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                        ),
                      )
                    : ListView.builder(
                        itemCount: widget.cohortController.cohortMembers.length,
                        itemBuilder: (context, index) {
                          final member = widget.cohortController.cohortMembers[index];
                          final student = member['student'] as Map<String, dynamic>?;
                          final studentId = member['student_id'] as int? ?? student?['id'] as int? ?? 0;
                          final name = student?['name'] ?? 'تلميذ';
                          final email = student?['email'] ?? '';

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                              child: const Icon(Icons.person, color: Color(0xFF10B981)),
                            ),
                            title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFEF4444)),
                              onPressed: () async {
                                if (widget.teacher.token != null) {
                                  await widget.cohortController.removeMember(widget.teacher.token!, cohort.id, studentId);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteCohort(BuildContext context, StudyCohortEntity cohort) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('حذف الفوج التعليمي', style: TextStyle(color: Colors.white)),
        content: Text('هل أنت متأكد من حذف الفوج "${cohort.name}"؟ سيتم إلغاء تسجيل جميع التلاميذ.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              if (widget.teacher.token != null) {
                await widget.cohortController.deleteCohort(widget.teacher.token!, cohort.id);
              }
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showVerificationRequestModal(BuildContext context) {
    final docController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'طلب شارة الاعتماد والتوثيق الرسمية',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'أدخل مرجع الدبلوم الأكاديمي أو بطاقة التعريف الوطنية لمراجعتها من قِبل إدارة بيندو فيوتشر.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: docController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'رقم أو رابط الشهادة / الدبلوم (مثال: DIPLOMA_BAC_ENS_2022)',
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                final doc = docController.text.trim();
                if (doc.isEmpty || widget.teacher.token == null) return;
                Navigator.pop(ctx);
                await widget.cohortController.submitVerification(widget.teacher.token!, doc);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم استلام طلب التوثيق بنجاح وجاري تدقيقه ✅'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              child: const Text('إرسال طلب التوثيق'),
            ),
          ],
        ),
      ),
    );
  }
}
