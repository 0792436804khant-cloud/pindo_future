import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/course_visual_helper.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../../../../core/widgets/pindo_brand_logo.dart';
import '../../../classroom/data/datasources/classroom_remote_datasource.dart';
import '../../../classroom/data/repositories/classroom_repository_impl.dart';
import '../../../classroom/domain/usecases/get_room_token_usecase.dart';
import '../../../classroom/presentation/controllers/classroom_controller.dart';
import '../../../classroom/presentation/screens/live_classroom_screen.dart';
import '../../../classroom/services/livekit_room_service.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../controllers/course_controller.dart';

class TeacherCourseBuilderScreen extends StatefulWidget {
  final CourseController controller;

  const TeacherCourseBuilderScreen({
    super.key,
    required this.controller,
  });

  @override
  State<TeacherCourseBuilderScreen> createState() =>
      _TeacherCourseBuilderScreenState();
}

class _TeacherCourseBuilderScreenState
    extends State<TeacherCourseBuilderScreen> {
  int? _selectedCourseId;
  String _sidebarSearchQuery = '';
  String _sidebarStatusFilter = 'all'; // 'all', 'published', 'draft'

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _darkBg = Color(0xFF090D16);
  static const Color _dangerRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.controller.loadTeacherCourses();
      if (widget.controller.teacherCourses.isNotEmpty && mounted) {
        final firstId = widget.controller.teacherCourses.first.id;
        setState(() {
          _selectedCourseId = firstId;
        });
        widget.controller.loadCourseDetails(firstId);
      }
    });
  }

  CourseEntity? get _currentCourse {
    if (_selectedCourseId == null) return null;
    if (widget.controller.selectedCourse?.id == _selectedCourseId) {
      return widget.controller.selectedCourse;
    }
    try {
      return widget.controller.teacherCourses
          .firstWhere((c) => c.id == _selectedCourseId);
    } catch (_) {
      return widget.controller.selectedCourse;
    }
  }

  // ==========================================
  // DELETE COURSE CONFIRMATION DIALOG
  // ==========================================
  void _showDeleteCourseDialog(CourseEntity course) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1B4B).withValues(alpha: 0.95),
                  const Color(0xFF0F172A).withValues(alpha: 0.98),
                  Colors.black,
                ],
              ),
              border: Border.all(
                color: _dangerRed.withValues(alpha: 0.45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _dangerRed.withValues(alpha: 0.30),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _dangerRed.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _dangerRed.withValues(alpha: 0.60),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _dangerRed.withValues(alpha: 0.35),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: _dangerRed,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Course',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Permanent action • Cannot be undone',
                            style: TextStyle(
                              color: Color(0xFFF87171),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Category: ${course.category} • ${course.modulesCount} Modules • ${course.enrolledStudentsCount} Students',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Are you sure you want to permanently delete this course? All associated modules, lessons, and student enrollment records will be removed.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassmorphicScaleButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GlassmorphicScaleButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final deleted =
                            await widget.controller.deleteCourse(course.id);
                        if (!mounted) return;
                        if (deleted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF10B981), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Course "${course.title}" was deleted successfully.',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: const Color(0xFF0F172A),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color:
                                      _electricPurple.withValues(alpha: 0.4),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _dangerRed.withValues(alpha: 0.40),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_forever_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'Delete Permanently',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // CREATE COURSE DIALOG
  // ==========================================
  void _showCreateCourseDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final categoryController =
        TextEditingController(text: 'Computer Science & AI');
    final priceController = TextEditingController(text: '4500.00');
    String status = 'published';

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: StatefulBuilder(
          builder: (_, setDialogState) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 520,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _deepIndigo.withValues(alpha: 0.95),
                    const Color(0xFF0F172A).withValues(alpha: 0.98),
                    Colors.black,
                  ],
                ),
                border: Border.all(
                  color: _brightCyan.withValues(alpha: 0.40),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _brightCyan.withValues(alpha: 0.20),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _brightCyan.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _brightCyan.withValues(alpha: 0.50),
                              width: 1.2,
                            ),
                          ),
                          child: const Icon(Icons.add_box_rounded,
                              color: _brightCyan, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Create New Course',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDarkField(
                      controller: titleController,
                      label: 'Course Title *',
                      hint: 'e.g. Distributed WebRTC Systems 2026',
                      icon: Icons.title_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildDarkField(
                      controller: descController,
                      label: 'Description & Syllabus',
                      hint: 'Master building scalable real-time video architectures...',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDarkField(
                            controller: categoryController,
                            label: 'Category / Domain *',
                            hint: 'e.g. Computer Science & AI',
                            icon: Icons.category_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDarkField(
                            controller: priceController,
                            label: 'Tuition Fee (DZD)',
                            hint: '4500.00',
                            icon: Icons.monetization_on_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Publication Status:',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setDialogState(() => status = 'published'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: status == 'published'
                                    ? const Color(0xFF10B981)
                                        .withValues(alpha: 0.22)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: status == 'published'
                                      ? const Color(0xFF10B981)
                                      : Colors.white24,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    status == 'published'
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    size: 16,
                                    color: status == 'published'
                                        ? const Color(0xFF10B981)
                                        : Colors.white60,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Published',
                                    style: TextStyle(
                                      color: status == 'published'
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setDialogState(() => status = 'draft'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: status == 'draft'
                                    ? _brightCyan.withValues(alpha: 0.22)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: status == 'draft'
                                      ? _brightCyan
                                      : Colors.white24,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    status == 'draft'
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_outlined,
                                    size: 16,
                                    color: status == 'draft'
                                        ? _brightCyan
                                        : Colors.white60,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Draft',
                                    style: TextStyle(
                                      color: status == 'draft'
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GlassmorphicScaleButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 11),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FuturisticCapsuleButton(
                          text: 'Create Course',
                          icon: Icons.check_rounded,
                          accentColor: _brightCyan,
                          secondaryColor: _electricPurple,
                          onPressed: () async {
                            final title = titleController.text.trim();
                            if (title.isEmpty) return;

                            final price =
                                double.tryParse(priceController.text.trim()) ??
                                    0.0;
                            Navigator.of(ctx).pop();

                            final newCourse =
                                await widget.controller.createCourse(
                              title: title,
                              description: descController.text.trim(),
                              category: categoryController.text.trim(),
                              price: price,
                              status: status,
                            );

                            if (!mounted) return;
                            if (newCourse != null) {
                              setState(() {
                                _selectedCourseId = newCourse.id;
                              });
                              widget.controller.loadCourseDetails(newCourse.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Course "${newCourse.title}" created successfully.'),
                                  backgroundColor: _deepIndigo,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ADD MODULE DIALOG
  // ==========================================
  void _showAddModuleDialog(int courseId) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _deepIndigo.withValues(alpha: 0.95),
                  const Color(0xFF0F172A).withValues(alpha: 0.98),
                  Colors.black,
                ],
              ),
              border: Border.all(
                color: _electricPurple.withValues(alpha: 0.45),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _electricPurple.withValues(alpha: 0.25),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _electricPurple.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _electricPurple.withValues(alpha: 0.50),
                        ),
                      ),
                      child: const Icon(Icons.folder_open_rounded,
                          color: _electricPurple, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Add Curriculum Module',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildDarkField(
                  controller: titleController,
                  label: 'Module / Chapter Title',
                  hint: 'e.g. Module 2: WebRTC Protocol Internals',
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GlassmorphicScaleButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FuturisticCapsuleButton(
                      text: 'Add Module',
                      icon: Icons.add_rounded,
                      accentColor: _electricPurple,
                      secondaryColor: _brightCyan,
                      onPressed: () async {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        Navigator.of(ctx).pop();
                        final module = await widget.controller
                            .addModule(courseId, title: title);
                        if (!mounted) return;
                        if (module != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Module "${module.title}" added successfully.'),
                              backgroundColor: _deepIndigo,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ADD LESSON DIALOG
  // ==========================================
  void _showAddLessonDialog(int moduleId) {
    final titleController = TextEditingController();
    final durationController = TextEditingController(text: '45');
    String lessonType = 'live_session';

    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: StatefulBuilder(
          builder: (_, setDialogState) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 480,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _deepIndigo.withValues(alpha: 0.95),
                    const Color(0xFF0F172A).withValues(alpha: 0.98),
                    Colors.black,
                  ],
                ),
                border: Border.all(
                  color: _brightCyan.withValues(alpha: 0.40),
                  width: 1.4,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _brightCyan.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.post_add_rounded,
                            color: _brightCyan, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add Lesson to Module',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildDarkField(
                    controller: titleController,
                    label: 'Lesson Title *',
                    hint: 'e.g. Lesson 2: SFU Media Routing & Bandwidth',
                    icon: Icons.title_rounded,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: lessonType,
                              dropdownColor: const Color(0xFF0F172A),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13),
                              items: const [
                                DropdownMenuItem(
                                  value: 'live_session',
                                  child: Text('🔴 Live Classroom'),
                                ),
                                DropdownMenuItem(
                                  value: 'video',
                                  child: Text('🎥 Video Lecture'),
                                ),
                                DropdownMenuItem(
                                  value: 'document',
                                  child: Text('📄 PDF Resource'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => lessonType = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDarkField(
                          controller: durationController,
                          label: 'Duration (min)',
                          hint: '45',
                          icon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GlassmorphicScaleButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Cancel',
                              style: TextStyle(color: Colors.white70)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FuturisticCapsuleButton(
                        text: 'Add Lesson',
                        icon: Icons.check_rounded,
                        accentColor: _brightCyan,
                        secondaryColor: _electricPurple,
                        onPressed: () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) return;

                          final duration =
                              int.tryParse(durationController.text.trim()) ?? 45;
                          Navigator.of(ctx).pop();

                          final lesson = await widget.controller.addLesson(
                            moduleId,
                            title: title,
                            type: lessonType,
                            durationMinutes: duration,
                          );

                          if (!mounted) return;
                          if (lesson != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Lesson "${lesson.title}" added successfully.'),
                                backgroundColor: _deepIndigo,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _enterLiveSession(String sessionId) {
    final apiClient = ApiClient();
    final remoteDataSource =
        ClassroomRemoteDataSourceImpl(apiClient: apiClient);
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final repository = ClassroomRepositoryImpl(
      remoteDataSource: remoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );
    final getRoomTokenUseCase = GetRoomTokenUseCase(repository);
    final roomService = LiveKitRoomService();

    final classroomController = ClassroomController(
      getRoomTokenUseCase: getRoomTokenUseCase,
      roomService: roomService,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveClassroomScreen(
          sessionId: sessionId,
          controller: classroomController,
        ),
      ),
    );
  }

  // ==========================================
  // MAIN BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.90),
        elevation: 0,
        title: const Row(
          children: [
            PindoBrandLogo(size: 28, showText: false, withGlow: true),
            SizedBox(width: 10),
            Text(
              'Course Studio • Curriculum Builder',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GlassmorphicScaleButton(
              tooltip: 'Reload Courses',
              onPressed: () => widget.controller.loadTeacherCourses(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(Icons.refresh_rounded,
                    color: _brightCyan, size: 20),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FuturisticCapsuleButton(
        text: 'Create New Course',
        icon: Icons.add_rounded,
        accentColor: _brightCyan,
        secondaryColor: _electricPurple,
        onPressed: _showCreateCourseDialog,
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          if (widget.controller.isLoading &&
              widget.controller.teacherCourses.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: _brightCyan),
            );
          }

          final allCourses = widget.controller.teacherCourses;

          if (allCourses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(26),
                      decoration: BoxDecoration(
                        color: _electricPurple.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _electricPurple.withValues(alpha: 0.45),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _electricPurple.withValues(alpha: 0.35),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.menu_book_rounded,
                          size: 56, color: _brightCyan),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'No Courses Created Yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Build structured curriculum masterclasses, organize modules, and link live WebRTC classroom streams for your students.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FuturisticCapsuleButton(
                      text: 'Create First Course',
                      icon: Icons.add_rounded,
                      accentColor: _brightCyan,
                      secondaryColor: _electricPurple,
                      onPressed: _showCreateCourseDialog,
                    ),
                  ],
                ),
              ),
            );
          }

          // Filter sidebar courses
          final filteredCourses = allCourses.where((c) {
            if (_sidebarStatusFilter == 'published' && !c.isPublished) {
              return false;
            }
            if (_sidebarStatusFilter == 'draft' && c.isPublished) {
              return false;
            }
            if (_sidebarSearchQuery.isNotEmpty) {
              final q = _sidebarSearchQuery.toLowerCase();
              return c.title.toLowerCase().contains(q) ||
                  c.category.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          _selectedCourseId ??= allCourses.first.id;
          final currentCourse = _currentCourse ?? allCourses.first;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. LEFT SIDEBAR (My Courses List)
              SizedBox(
                width: 370,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                        width: 1.2,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Sidebar Header & Filter Bar
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _deepIndigo.withValues(alpha: 0.35),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'My Courses',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                FuturisticGlowBadge(
                                  label: '${allCourses.length} Total',
                                  color: _brightCyan,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Search field
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.14),
                                ),
                              ),
                              child: TextField(
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Search my courses...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    fontSize: 13,
                                  ),
                                  prefixIcon: const Icon(Icons.search_rounded,
                                      size: 18, color: _brightCyan),
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                onChanged: (val) => setState(
                                    () => _sidebarSearchQuery = val.trim()),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Filter Pills
                            Row(
                              children: [
                                _sidebarFilterChip(
                                    'all', 'All (${allCourses.length})'),
                                const SizedBox(width: 6),
                                _sidebarFilterChip(
                                  'published',
                                  'Published (${allCourses.where((c) => c.isPublished).length})',
                                ),
                                const SizedBox(width: 6),
                                _sidebarFilterChip(
                                  'draft',
                                  'Drafts (${allCourses.where((c) => !c.isPublished).length})',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Courses list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            final c = filteredCourses[index];
                            final isSelected = c.id == _selectedCourseId;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _electricPurple.withValues(alpha: 0.22)
                                    : Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? _brightCyan
                                      : Colors.white.withValues(alpha: 0.12),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color:
                                              _brightCyan.withValues(alpha: 0.20),
                                          blurRadius: 14,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setState(() => _selectedCourseId = c.id);
                                  widget.controller.loadCourseDetails(c.id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: c.isPublished
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFFF59E0B),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: (c.isPublished
                                                          ? const Color(0xFF10B981)
                                                          : const Color(0xFFF59E0B))
                                                      .withValues(alpha: 0.6),
                                                  blurRadius: 6,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          FuturisticGlowBadge(
                                            label: c.isPublished
                                                ? 'PUBLISHED'
                                                : 'DRAFT',
                                            color: c.isPublished
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF59E0B),
                                          ),
                                          const Spacer(),
                                          Text(
                                            c.isFree
                                                ? 'Free'
                                                : '${c.price.toStringAsFixed(0)} DZD',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          // Quick Trash/Delete Button on card
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: Color(0xFFF87171),
                                            ),
                                            tooltip: 'Delete Course',
                                            padding: EdgeInsets.zero,
                                            constraints:
                                                const BoxConstraints(),
                                            onPressed: () =>
                                                _showDeleteCourseDialog(c),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        c.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          fontSize: 14.5,
                                          color: isSelected
                                              ? _brightCyan
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.folder_outlined,
                                              size: 13, color: Colors.white60),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${c.modulesCount} modules',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white60),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(Icons.people_outline,
                                              size: 13, color: Colors.white60),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${c.enrolledStudentsCount} students',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white60),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. RIGHT PANEL (Course Curriculum Editor)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 950),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Course Details Hero Card with PROMINENT DELETE BUTTON
                          _buildModernCourseHeroCard(currentCourse),

                          const SizedBox(height: 24),

                          // 2. Modules & Curriculum Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _electricPurple.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _electricPurple.withValues(alpha: 0.40),
                                  ),
                                ),
                                child: const Icon(Icons.menu_book_rounded,
                                    color: _brightCyan, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Course Curriculum (${currentCourse.modules.length} Modules)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const Spacer(),
                              FuturisticCapsuleButton(
                                text: 'Add Module',
                                icon: Icons.add_rounded,
                                accentColor: _brightCyan,
                                secondaryColor: _electricPurple,
                                onPressed: () =>
                                    _showAddModuleDialog(currentCourse.id),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // 3. Modules List
                          if (currentCourse.modules.isEmpty)
                            GlassmorphicContainer(
                              borderRadius: BorderRadius.circular(20),
                              blurSigma: 14.0,
                              padding: const EdgeInsets.all(40),
                              gradient: LinearGradient(
                                colors: [
                                  _deepIndigo.withValues(alpha: 0.40),
                                  Colors.black.withValues(alpha: 0.50),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: _brightCyan.withValues(alpha: 0.14),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _brightCyan.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.folder_open_rounded,
                                      size: 42,
                                      color: _brightCyan,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Modules Added Yet',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Click "+ Add Module" to structure chapters, add video lectures, and link live classrooms.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...currentCourse.modules.map(
                              (module) => _buildModernModuleCard(
                                  module, currentCourse.id),
                            ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // SIDEBAR FILTER CHIP
  // ==========================================
  Widget _sidebarFilterChip(String filterKey, String label) {
    final isSelected = _sidebarStatusFilter == filterKey;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() => _sidebarStatusFilter = filterKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? _brightCyan.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _brightCyan : Colors.white12,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brightCyan.withValues(alpha: 0.25),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MODERN COURSE HERO CARD WITH DELETE BUTTON
  // ==========================================
  Widget _buildModernCourseHeroCard(CourseEntity course) {
    final categoryIcon =
        CourseVisualHelper.getIconForCategory(course.category);

    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(22),
      blurSigma: 16.0,
      borderWidth: 1.4,
      borderColor: _brightCyan.withValues(alpha: 0.35),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _deepIndigo.withValues(alpha: 0.85),
          _electricPurple.withValues(alpha: 0.70),
          const Color(0xFF0F172A).withValues(alpha: 0.95),
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: _electricPurple.withValues(alpha: 0.28),
          blurRadius: 28,
          offset: const Offset(0, 6),
        ),
      ],
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Icon, Category, Title, Status, and DELETE BUTTON
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _brightCyan.withValues(alpha: 0.16),
                  border: Border.all(
                    color: _brightCyan.withValues(alpha: 0.65),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _brightCyan.withValues(alpha: 0.50),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(categoryIcon, color: Colors.white, size: 26),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FuturisticGlowBadge(
                          label: course.category.toUpperCase(),
                          color: _brightCyan,
                        ),
                        const SizedBox(width: 8),
                        FuturisticGlowBadge(
                          label: course.status.toUpperCase(),
                          color: course.isPublished
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ==========================================
              // PROMINENT DELETE COURSE BUTTON
              // ==========================================
              GlassmorphicScaleButton(
                onPressed: () => _showDeleteCourseDialog(course),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: _dangerRed.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _dangerRed.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _dangerRed.withValues(alpha: 0.30),
                        blurRadius: 14,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_forever_rounded,
                          color: Color(0xFFF87171), size: 17),
                      SizedBox(width: 6),
                      Text(
                        'Delete Course',
                        style: TextStyle(
                          color: Color(0xFFF87171),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (course.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              course.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.80),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: 18),

          // Row 2: Metrics chips in glowing modern glass style
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _modernMetricChip(
                Icons.monetization_on_rounded,
                course.isFree
                    ? 'Tuition: Free'
                    : 'Tuition: ${course.price.toStringAsFixed(0)} DZD',
                const Color(0xFF10B981),
              ),
              _modernMetricChip(
                Icons.folder_open_rounded,
                '${course.modulesCount} Modules',
                _brightCyan,
              ),
              _modernMetricChip(
                Icons.play_circle_fill_rounded,
                '${course.lessonsCount} Lessons',
                _electricPurple,
              ),
              _modernMetricChip(
                Icons.groups_rounded,
                '${course.enrolledStudentsCount} Enrolled Students',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MODERN MODULE CARD
  // ==========================================
  Widget _buildModernModuleCard(CourseModuleEntity module, int courseId) {
    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 14.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _deepIndigo.withValues(alpha: 0.50),
          const Color(0xFF0F172A).withValues(alpha: 0.85),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _brightCyan.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _brightCyan.withValues(alpha: 0.40),
                  ),
                ),
                child: const Icon(Icons.folder_rounded,
                    color: _brightCyan, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  module.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              GlassmorphicScaleButton(
                onPressed: () => _showAddLessonDialog(module.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: _electricPurple.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _electricPurple.withValues(alpha: 0.50),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, size: 15, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Add Lesson',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (module.lessons.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'No lessons in this module. Add interactive sessions, video lectures, or study guides.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...module.lessons.map(_buildModernLessonTile),
        ],
      ),
    );
  }

  // ==========================================
  // MODERN LESSON TILE
  // ==========================================
  Widget _buildModernLessonTile(CourseLessonEntity lesson) {
    IconData icon;
    Color iconColor;
    String typeLabel;

    if (lesson.isLiveSession) {
      icon = Icons.sensors_rounded;
      iconColor = const Color(0xFFEF4444);
      typeLabel = 'Live Classroom';
    } else if (lesson.isVideo) {
      icon = Icons.play_circle_fill_rounded;
      iconColor = _brightCyan;
      typeLabel = 'Video Lecture';
    } else {
      icon = Icons.description_rounded;
      iconColor = const Color(0xFF10B981);
      typeLabel = 'Document Guide';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '$typeLabel • ${lesson.durationMinutes} min',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.60),
                        fontSize: 11.5,
                      ),
                    ),
                    if (lesson.sessionId != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color:
                                const Color(0xFFEF4444).withValues(alpha: 0.40),
                          ),
                        ),
                        child: Text(
                          lesson.sessionId!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFCA5A5),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (lesson.isLiveSession && lesson.sessionId != null)
            GlassmorphicScaleButton(
              onPressed: () => _enterLiveSession(lesson.sessionId!),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: lesson.isLiveNow
                        ? [const Color(0xFFDC2626), const Color(0xFFEF4444)]
                        : [_deepIndigo, _electricPurple],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      lesson.isLiveNow
                          ? Icons.videocam
                          : Icons.play_arrow_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      lesson.isLiveNow ? 'Join Live Stage' : 'Launch Session',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // DARK TEXTFIELD HELPER
  // ==========================================
  Widget _buildDarkField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 13,
              ),
              prefixIcon: Icon(icon, color: _brightCyan, size: 18),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // METRIC CHIP HELPER
  // ==========================================
  Widget _modernMetricChip(IconData icon, String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.90),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
