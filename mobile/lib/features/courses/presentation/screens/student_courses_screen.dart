import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/course_visual_helper.dart';
import '../../../../core/widgets/bento_card.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../../../../core/widgets/pindo_brand_logo.dart';
import '../../../classroom/data/datasources/classroom_remote_datasource.dart';
import '../../../classroom/data/repositories/classroom_repository_impl.dart';
import '../../../classroom/domain/usecases/get_room_token_usecase.dart';
import '../../../classroom/presentation/controllers/classroom_controller.dart';
import '../../../classroom/presentation/screens/live_classroom_screen.dart';
import '../../../classroom/services/livekit_room_service.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../controllers/course_controller.dart';
import 'course_details_screen.dart';

class StudentCoursesScreen extends StatefulWidget {
  final CourseController controller;

  const StudentCoursesScreen({
    super.key,
    required this.controller,
  });

  @override
  State<StudentCoursesScreen> createState() => _StudentCoursesScreenState();
}

class _StudentCoursesScreenState extends State<StudentCoursesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'in_progress', 'completed'

  static const Color _bgDark = Color(0xFF070B14);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _neonGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadStudentEnrolledCourses();
    });
  }

  void _navigateToCourseDetails(EnrollmentEntity enrollment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailsScreen(
          courseId: enrollment.courseId,
          heroTagPrefix: 'course',
          controller: widget.controller,
          isEnrolled: true,
          progressPercentage: enrollment.progressPercentage,
          onEnrollmentChanged: () {
            widget.controller.loadStudentEnrolledCourses();
          },
        ),
      ),
    );
  }

  void _enterLiveSession(String sessionId) {
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final apiClient = ApiClient();
    final classroomRemoteDataSource = ClassroomRemoteDataSourceImpl(apiClient: apiClient);
    final classroomRepository = ClassroomRepositoryImpl(
      remoteDataSource: classroomRemoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );
    final getRoomTokenUseCase = GetRoomTokenUseCase(classroomRepository);
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

  void _showUpdateProgressDialog(EnrollmentEntity enrollment) {
    double currentProgress = enrollment.progressPercentage.toDouble();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => StatefulBuilder(
        builder: (_, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: GlassmorphicContainer(
              borderRadius: BorderRadius.circular(24),
              borderColor: _brightCyan.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BentoIconAura(
                        icon: Icons.trending_up_rounded,
                        color: _brightCyan,
                        size: 22,
                        padding: 10,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Update Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    enrollment.courseTitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completed Curriculum:',
                        style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                      FuturisticGlowBadge(
                        label: '${currentProgress.toInt()}%',
                        color: currentProgress >= 100 ? _neonGreen : _brightCyan,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: _brightCyan,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
                      thumbColor: _brightCyan,
                      overlayColor: _brightCyan.withValues(alpha: 0.2),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: currentProgress,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      onChanged: (val) {
                        setDialogState(() => currentProgress = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: FuturisticCapsuleButton(
                          text: 'Cancel',
                          isPrimary: false,
                          height: 42,
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FuturisticCapsuleButton(
                          text: 'Save Progress',
                          icon: Icons.check_circle_outline,
                          height: 42,
                          accentColor: _brightCyan,
                          secondaryColor: _electricPurple,
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await widget.controller.updateProgress(
                              enrollment.courseId,
                              currentProgress.toInt(),
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Course progress saved successfully!'),
                                  backgroundColor: _deepIndigo,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                        ),
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

  Future<void> _showCurriculumSheet(int courseId) async {
    await widget.controller.loadCourseDetails(courseId);
    if (!mounted) return;
    final course = widget.controller.selectedCourse;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.92),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              padding: const EdgeInsets.all(24),
              child: course == null
                  ? const Center(
                      child: Text(
                        'Curriculum details unavailable.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView(
                      controller: scrollController,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            FuturisticGlowBadge(
                              label: course.category.toUpperCase(),
                              color: _brightCyan,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (course.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            course.description,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13.5),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const BentoIconAura(
                              icon: Icons.menu_book_rounded,
                              color: _brightCyan,
                              size: 18,
                              padding: 6,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Syllabus & Modules (${course.modules.length})',
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (course.modules.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No modules defined for this curriculum.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              ),
                            ),
                          )
                        else
                          ...course.modules.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final mod = entry.value;
                            return _buildCurriculumModuleTile(mod, idx);
                          }),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurriculumModuleTile(CourseModuleEntity module, int index) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(16),
      borderColor: Colors.white.withValues(alpha: 0.12),
      margin: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: index == 0,
          collapsedIconColor: _brightCyan,
          iconColor: _brightCyan,
          leading: const BentoIconAura(
            icon: Icons.folder_rounded,
            color: _electricPurple,
            size: 16,
            padding: 8,
          ),
          title: Text(
            module.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          ),
          subtitle: Text(
            '${module.lessons.length} lessons',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
          ),
          children: module.lessons.map(_buildCurriculumLessonTile).toList(),
        ),
      ),
    );
  }

  Widget _buildCurriculumLessonTile(CourseLessonEntity lesson) {
    IconData icon;
    Color iconColor;
    String typeLabel;

    if (lesson.isLiveSession) {
      icon = Icons.sensors;
      iconColor = const Color(0xFFEF4444);
      typeLabel = 'Live Stage';
    } else if (lesson.isVideo) {
      icon = Icons.play_circle_fill;
      iconColor = _brightCyan;
      typeLabel = 'Video';
    } else {
      icon = Icons.description;
      iconColor = _electricPurple;
      typeLabel = 'Reading';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(lesson.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: Text(
          '$typeLabel • ${lesson.durationMinutes} mins',
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
        ),
        trailing: lesson.isLiveSession && lesson.sessionId != null
            ? FuturisticCapsuleButton(
                text: lesson.isLiveNow ? 'Join Live Now' : 'Enter Stage',
                icon: lesson.isLiveNow ? Icons.videocam : Icons.play_arrow,
                height: 32,
                fontSize: 11,
                accentColor: lesson.isLiveNow ? const Color(0xFFEF4444) : _brightCyan,
                secondaryColor: _electricPurple,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                onPressed: () => _enterLiveSession(lesson.sessionId!),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              color: _bgDark.withValues(alpha: 0.70),
            ),
          ),
        ),
        title: const Row(
          children: [
            PindoBrandLogo(size: 26, showText: false, withGlow: true),
            SizedBox(width: 10),
            Text(
              'My Enrolled Masterclasses',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _brightCyan),
            tooltip: 'Refresh My Courses',
            onPressed: () => widget.controller.loadStudentEnrolledCourses(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Background ambient glowing orbs
          Positioned(
            top: 20,
            left: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _deepIndigo.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _electricPurple.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: AnimatedBuilder(
              animation: widget.controller,
              builder: (context, _) {
                if (widget.controller.isLoading && widget.controller.enrolledCourses.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: _brightCyan));
                }

                final allEnrollments = widget.controller.enrolledCourses;

                if (allEnrollments.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: GlassmorphicContainer(
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const BentoIconAura(
                              icon: Icons.school_outlined,
                              color: _brightCyan,
                              size: 44,
                              padding: 16,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No Enrolled Courses Yet',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Explore instructor showcases to discover interactive masterclasses and live WebRTC streaming sessions.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13.5),
                            ),
                            const SizedBox(height: 24),
                            FuturisticCapsuleButton(
                              text: 'Discover Instructors & Courses',
                              icon: Icons.search_rounded,
                              accentColor: _brightCyan,
                              secondaryColor: _electricPurple,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final inProgressCount = allEnrollments.where((e) => !e.isCompleted).length;
                final completedCount = allEnrollments.where((e) => e.isCompleted).length;

                // Filter according to search and status tabs
                final filteredEnrollments = allEnrollments.where((e) {
                  if (_selectedFilter == 'in_progress' && e.isCompleted) return false;
                  if (_selectedFilter == 'completed' && !e.isCompleted) return false;
                  if (_searchQuery.isNotEmpty) {
                    final q = _searchQuery.toLowerCase();
                    return e.courseTitle.toLowerCase().contains(q) ||
                        (e.teacherName?.toLowerCase().contains(q) ?? false);
                  }
                  return true;
                }).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Bento Box Summary Metrics
                      _buildMetricsSummaryCard(
                        total: allEnrollments.length,
                        inProgress: inProgressCount,
                        completed: completedCount,
                      )
                          .animate()
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: -0.06, end: 0, duration: 350.ms, curve: Curves.easeOutCubic),
                      const SizedBox(height: 20),

                      // 2. Search & Filter Bar
                      GlassmorphicContainer(
                        borderRadius: BorderRadius.circular(20),
                        borderColor: Colors.white.withValues(alpha: 0.12),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Search Field
                            TextField(
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search my enrolled masterclasses or instructors...',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
                                prefixIcon: const Icon(Icons.search, color: _brightCyan, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                                        onPressed: () => setState(() => _searchQuery = ''),
                                      )
                                    : null,
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.05),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: _brightCyan, width: 1.5),
                                ),
                              ),
                              onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            ),
                            const SizedBox(height: 12),
                            // Filter Pills
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterTab('all', 'All Courses (${allEnrollments.length})'),
                                  const SizedBox(width: 8),
                                  _buildFilterTab('in_progress', 'In Progress ($inProgressCount)'),
                                  const SizedBox(width: 8),
                                  _buildFilterTab('completed', 'Completed ($completedCount)'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 60.ms)
                          .slideY(begin: -0.04, end: 0, duration: 400.ms, delay: 60.ms),
                      const SizedBox(height: 22),

                      // 3. Section Title
                      Row(
                        children: [
                          const BentoIconAura(
                            icon: Icons.menu_book_rounded,
                            color: _brightCyan,
                            size: 18,
                            padding: 6,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedFilter == 'completed'
                                ? 'Completed Masterclasses'
                                : _selectedFilter == 'in_progress'
                                    ? 'Active Masterclasses in Progress'
                                    : 'All Enrolled Masterclasses',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Showing ${filteredEnrollments.length} of ${allEnrollments.length}',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Enrollment Cards List
                      if (filteredEnrollments.isEmpty)
                        GlassmorphicContainer(
                          borderRadius: BorderRadius.circular(20),
                          borderColor: Colors.white.withValues(alpha: 0.12),
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                const BentoIconAura(
                                  icon: Icons.search_off_rounded,
                                  color: Colors.white38,
                                  size: 32,
                                  padding: 14,
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'No Matching Courses Found',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Try clearing your search query or selecting a different filter tab.',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredEnrollments.asMap().entries.map(
                              (entry) => _buildEnhancedEnrollmentCard(entry.value, entry.key),
                            ),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String filterKey, String label) {
    final isSelected = _selectedFilter == filterKey;
    return GlassmorphicScaleButton(
      onPressed: () => setState(() => _selectedFilter = filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _brightCyan.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _brightCyan.withValues(alpha: 0.60) : Colors.white.withValues(alpha: 0.12),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _brightCyan.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? _brightCyan : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsSummaryCard({
    required int total,
    required int inProgress,
    required int completed,
  }) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(22),
      borderColor: _brightCyan.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.collections_bookmark_rounded, '$total', 'Total Enrolled', _brightCyan),
          Container(height: 40, width: 1, color: Colors.white.withValues(alpha: 0.15)),
          _buildStatItem(Icons.play_circle_filled_rounded, '$inProgress', 'In Progress', _electricPurple),
          Container(height: 40, width: 1, color: Colors.white.withValues(alpha: 0.15)),
          _buildStatItem(Icons.check_circle_rounded, '$completed', 'Completed', _neonGreen),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedEnrollmentCard(EnrollmentEntity enrollment, int index) {
    final progress = enrollment.progressPercentage.clamp(0, 100);
    final isDone = enrollment.isCompleted;
    final gradient = CourseVisualHelper.getGradientForCategory(null);
    final categoryIcon = CourseVisualHelper.getIconForCategory(null);

    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(22),
      borderColor: isDone ? _neonGreen.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.14),
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Banner with Hero Elements
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDone
                    ? [const Color(0xFF065F46).withValues(alpha: 0.7), _neonGreen.withValues(alpha: 0.4), _bgDark]
                    : [gradient.first.withValues(alpha: 0.65), _deepIndigo.withValues(alpha: 0.5), _bgDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              children: [
                // Hero Course Icon
                Hero(
                  tag: 'course_icon_${enrollment.courseId}',
                  child: BentoIconAura(
                    icon: categoryIcon,
                    color: isDone ? _neonGreen : _brightCyan,
                    size: 26,
                    padding: 10,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Course Title
                      Hero(
                        tag: 'course_title_${enrollment.courseId}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            enrollment.courseTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      if (enrollment.teacherName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.verified, color: _brightCyan, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Instructor: ${enrollment.teacherName!}',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12.5),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FuturisticGlowBadge(
                  label: isDone ? 'COMPLETED' : '$progress% DONE',
                  color: isDone ? _neonGreen : _brightCyan,
                ),
              ],
            ),
          ),

          // 2. Body Details
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Bar with Milestone
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Learning Journey Progress',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    Text(
                      '$progress% of curriculum completed',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: isDone ? _neonGreen : _brightCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress / 100.0,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? _neonGreen : _brightCyan,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Curriculum Structure Chips
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _infoPill(Icons.folder_outlined, '${enrollment.totalModules} Modules'),
                    _infoPill(Icons.play_circle_outline, '${enrollment.totalLessons} Lessons'),
                    if (enrollment.liveLessonsCount > 0)
                      _infoPill(Icons.sensors, '${enrollment.liveLessonsCount} Live Streams', color: const Color(0xFFEF4444)),
                  ],
                ),

                // Next Live Session Active / Scheduled Card
                if (enrollment.nextLiveSessionId != null) ...[
                  const SizedBox(height: 16),
                  GlassmorphicContainer(
                    borderRadius: BorderRadius.circular(16),
                    borderColor: enrollment.isLiveNow ? const Color(0xFFEF4444).withValues(alpha: 0.5) : _electricPurple.withValues(alpha: 0.35),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        BentoIconAura(
                          icon: enrollment.isLiveNow ? Icons.sensors : Icons.event_available,
                          color: enrollment.isLiveNow ? const Color(0xFFEF4444) : _electricPurple,
                          size: 18,
                          padding: 8,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                enrollment.isLiveNow ? '🔴 LIVE BROADCASTING NOW' : 'NEXT UPCOMING SESSION',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: enrollment.isLiveNow ? const Color(0xFFEF4444) : _electricPurple,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                enrollment.nextLiveSessionTitle ?? 'Interactive SFU Classroom',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FuturisticCapsuleButton(
                          text: enrollment.isLiveNow ? 'Join Now' : 'Enter Stage',
                          icon: enrollment.isLiveNow ? Icons.videocam : Icons.play_arrow,
                          height: 36,
                          fontSize: 12,
                          accentColor: enrollment.isLiveNow ? const Color(0xFFEF4444) : _brightCyan,
                          secondaryColor: _electricPurple,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          onPressed: () => _enterLiveSession(enrollment.nextLiveSessionId!),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),
                Divider(height: 1, color: Colors.white.withValues(alpha: 0.12)),
                const SizedBox(height: 16),

                // Bottom Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FuturisticCapsuleButton(
                      text: 'Syllabus',
                      icon: Icons.list_alt_rounded,
                      isPrimary: false,
                      height: 38,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      onPressed: () => _showCurriculumSheet(enrollment.courseId),
                    ),
                    const SizedBox(width: 8),
                    FuturisticCapsuleButton(
                      text: 'Progress',
                      icon: Icons.trending_up_rounded,
                      isPrimary: false,
                      height: 38,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      onPressed: () => _showUpdateProgressDialog(enrollment),
                    ),
                    const SizedBox(width: 8),
                    FuturisticCapsuleButton(
                      text: 'Continue',
                      icon: Icons.arrow_forward_rounded,
                      height: 38,
                      fontSize: 12.5,
                      accentColor: _brightCyan,
                      secondaryColor: _electricPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onPressed: () => _navigateToCourseDetails(enrollment),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: (index * 75).ms,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 400.ms,
          delay: (index * 75).ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _infoPill(IconData icon, String label, {Color? color}) {
    final c = color ?? Colors.white70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
