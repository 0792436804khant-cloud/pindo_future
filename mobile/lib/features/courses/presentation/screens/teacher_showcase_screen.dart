import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/course_visual_helper.dart';
import '../../../../core/widgets/glassmorphism.dart';
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
import '../../domain/entities/teacher_showcase_entity.dart';
import '../../../monetization/data/datasources/monetization_remote_datasource.dart';
import '../../../monetization/data/repositories/monetization_repository_impl.dart';
import '../../../monetization/presentation/controllers/monetization_controller.dart';
import '../../../monetization/presentation/widgets/course_checkout_modal.dart';
import '../controllers/course_controller.dart';
import 'course_details_screen.dart';
import 'teacher_course_builder_screen.dart';

class TeacherShowcaseScreen extends StatefulWidget {
  final String teacherId;
  final CourseController controller;
  final bool isOwner;

  const TeacherShowcaseScreen({
    super.key,
    required this.teacherId,
    required this.controller,
    this.isOwner = false,
  });

  @override
  State<TeacherShowcaseScreen> createState() => _TeacherShowcaseScreenState();
}

class _TeacherShowcaseScreenState extends State<TeacherShowcaseScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadTeacherShowcase(widget.teacherId);
    });
  }

  void _navigateToCourseDetails(CourseEntity course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailsScreen(
          courseId: course.id,
          initialCourse: course,
          heroTagPrefix: 'course',
          controller: widget.controller,
          isEnrolled: false,
          onEnrollmentChanged: () {
            widget.controller.loadTeacherShowcase(widget.teacherId);
          },
        ),
      ),
    );
  }

  void _copyDeepLink(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: _brightCyan, size: 20),
            SizedBox(width: 8),
            Text('Public showcase link copied to clipboard!'),
          ],
        ),
        backgroundColor: _deepIndigo,
        behavior: SnackBarBehavior.floating,
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

  Future<void> _enrollInCourse(CourseEntity course) async {
    if (!course.isFree && course.price > 0) {
      final apiClient = ApiClient();
      final authLocalDataSource = AuthLocalDataSourceImpl();
      final token = await authLocalDataSource.getToken() ?? '';
      final remoteDataSource = MonetizationRemoteDataSourceImpl(apiClient: apiClient);
      final repository = MonetizationRepositoryImpl(remoteDataSource: remoteDataSource);
      final monetizationController = MonetizationController(repository: repository, authToken: token);

      if (mounted) {
        await CourseCheckoutModal.show(
          context: context,
          courseId: course.id,
          courseTitle: course.title,
          price: course.price,
          category: course.category,
          monetizationController: monetizationController,
          onPaymentSuccess: () {
            widget.controller.loadTeacherShowcase(widget.teacherId);
          },
        );
      }
      return;
    }

    final success = await widget.controller.enrollInCourse(course.id);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Successfully enrolled in "${course.title}"!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.controller.loadTeacherShowcase(widget.teacherId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.controller.errorMessage ?? 'Enrollment failed.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCurriculumDetailsModal(CourseEntity course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _electricPurple.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _electricPurple.withValues(alpha: 0.40)),
                              ),
                              child: Text(
                                course.category.toUpperCase(),
                                style: const TextStyle(
                                  color: _brightCyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              course.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: _brightCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _brightCyan.withValues(alpha: 0.50)),
                        ),
                        child: Text(
                          course.isFree ? 'FREE' : '${course.price.toStringAsFixed(0)} DZD',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _brightCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (course.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      course.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                    ),
                  ],
                  const Divider(height: 32, color: Colors.white12),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: _brightCyan, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Curriculum & Lessons (${course.modulesCount} modules • ${course.lessonsCount} lessons)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (course.modules.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Syllabus being finalized by instructor.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    ...course.modules.map(_buildModuleTile),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isOwner ? _electricPurple : _deepIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: Colors.white24),
                      ),
                    ),
                    icon: Icon(widget.isOwner ? Icons.edit_note : Icons.school),
                    label: Text(
                      widget.isOwner
                          ? 'Edit in Course Studio'
                          : (course.isFree ? 'Enroll For Free' : 'Enroll Now — ${course.price.toStringAsFixed(0)} DZD'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (widget.isOwner) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TeacherCourseBuilderScreen(controller: widget.controller),
                          ),
                        );
                      } else {
                        _enrollInCourse(course);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleTile(CourseModuleEntity module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        collapsedIconColor: Colors.white70,
        iconColor: _brightCyan,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _electricPurple.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.folder, color: _brightCyan, size: 20),
        ),
        title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
        children: module.lessons.map(_buildLessonRow).toList(),
      ),
    );
  }

  Widget _buildLessonRow(CourseLessonEntity lesson) {
    IconData icon;
    Color iconColor;

    if (lesson.isLiveSession) {
      icon = Icons.sensors;
      iconColor = Colors.redAccent;
    } else if (lesson.isVideo) {
      icon = Icons.play_circle_outline;
      iconColor = _brightCyan;
    } else {
      icon = Icons.article_outlined;
      iconColor = _electricPurple;
    }

    return ListTile(
      dense: true,
      leading: Icon(icon, color: iconColor, size: 20),
      title: Text(lesson.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      subtitle: Text(
        '${lesson.durationMinutes} min • ${lesson.type.toUpperCase()}',
        style: const TextStyle(fontSize: 11, color: Colors.white60),
      ),
      trailing: lesson.isLiveSession && lesson.sessionId != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.40)),
              ),
              child: const Text('Live Stream Bound', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14), // Deep Cosmic Midnight
      appBar: AppBar(
        title: const Text(
          'Instructor Showcase',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
            letterSpacing: 0.2,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.90),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GlassmorphicScaleButton(
              tooltip: 'Refresh Showcase',
              onPressed: () => widget.controller.loadTeacherShowcase(widget.teacherId),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(Icons.refresh, color: _brightCyan, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          if (widget.controller.isLoadingShowcase && widget.controller.teacherShowcase == null) {
            return const Center(child: CircularProgressIndicator(color: _brightCyan));
          }

          if (widget.controller.errorMessage != null && widget.controller.teacherShowcase == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56, color: Color(0xFFF87171)),
                    const SizedBox(height: 16),
                    Text(
                      widget.controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _electricPurple,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () => widget.controller.loadTeacherShowcase(widget.teacherId),
                    ),
                  ],
                ),
              ),
            );
          }

          final showcase = widget.controller.teacherShowcase;
          if (showcase == null) {
            return const Center(child: Text('Instructor profile not found.', style: TextStyle(color: Colors.white70)));
          }

          // Extract unique categories
          final categories = <String>{'all'};
          for (final c in showcase.courses) {
            if (c.category.isNotEmpty) categories.add(c.category);
          }

          // Filter courses
          final filteredCourses = showcase.courses.where((c) {
            if (_selectedCategory != 'all' && c.category != _selectedCategory) return false;
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              return c.title.toLowerCase().contains(q) || c.description.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  // 1. Profile Hero Glass Card
                  _buildProfileHeroCard(showcase)
                      .animate()
                      .fadeIn(duration: 450.ms)
                      .slideY(begin: -0.06, end: 0, curve: Curves.easeOutCubic),
                  const SizedBox(height: 20),

                  // 2. Student Honors & Best Degrees Wall of Fame
                  if (showcase.studentAchievements.isNotEmpty || widget.isOwner) ...[
                    _buildStudentHonorsSection(showcase)
                        .animate()
                        .fadeIn(duration: 450.ms, delay: 60.ms)
                        .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                    const SizedBox(height: 24),
                  ],

                  // 3. Active Live Session Card (if live)
                  if (showcase.hasActiveLiveSession && showcase.activeSessionId != null) ...[
                    _buildActiveLiveSessionCard(showcase)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 80.ms)
                        .shimmer(duration: 1800.ms, delay: 500.ms),
                    const SizedBox(height: 20),
                  ],

                  // 3. Search and Category Glass Ribbon
                  _buildSearchAndFilters(categories)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 100.ms)
                      .slideY(begin: 0.06, end: 0, duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 24),

                  // 4. Header with Course Count
                  Row(
                    children: [
                      const Icon(Icons.school, color: _brightCyan, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Masterclasses & Curriculums',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        'Showing ${filteredCourses.length} of ${showcase.courses.length}',
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                  const SizedBox(height: 14),

                  // 5. Course Cards
                  if (filteredCourses.isEmpty)
                    GlassmorphicContainer(
                      padding: const EdgeInsets.all(40),
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.white.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          const Text(
                            'No Courses Found',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No courses match your search criteria.'
                                : 'This instructor has not published courses in this category yet.',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    )
                  else
                    ...filteredCourses.asMap().entries.map(
                          (entry) => _buildEnhancedCourseCard(entry.value, entry.key),
                        ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeroCard(TeacherShowcaseEntity showcase) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(22),
      blurSigma: 18.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.22),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _deepIndigo.withValues(alpha: 0.85),
          _electricPurple.withValues(alpha: 0.70),
          const Color(0xFF0F172A).withValues(alpha: 0.90),
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: _electricPurple.withValues(alpha: 0.30),
          blurRadius: 28,
          offset: const Offset(0, 6),
        ),
      ],
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _brightCyan, width: 2.0),
                  boxShadow: [
                    BoxShadow(
                      color: _brightCyan.withValues(alpha: 0.45),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: _deepIndigo,
                  backgroundImage: (showcase.avatarUrl != null && showcase.avatarUrl!.isNotEmpty)
                      ? NetworkImage(showcase.avatarUrl!)
                      : null,
                  child: (showcase.avatarUrl != null && showcase.avatarUrl!.isNotEmpty)
                      ? null
                      : Text(
                          showcase.name.isNotEmpty ? showcase.name[0].toUpperCase() : 'T',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          showcase.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _brightCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _brightCyan.withValues(alpha: 0.50)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified, size: 14, color: _brightCyan),
                              const SizedBox(width: 4),
                              Text(
                                showcase.teacherId,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _brightCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showcase.yearsOfExperience != null && showcase.yearsOfExperience! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade700.withValues(alpha: 0.35),
                                  Colors.orange.shade800.withValues(alpha: 0.35),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.70)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${showcase.yearsOfExperience} Yrs Exp',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      showcase.headline,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    if (showcase.bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        showcase.bio,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.65),
                          height: 1.4,
                        ),
                      ),
                    ],
                    // Subject and Years Classification Badges
                    if (showcase.teachingSubjects.isNotEmpty || showcase.teachingYears.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...showcase.teachingSubjects.map((s) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: _electricPurple.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _electricPurple.withValues(alpha: 0.40)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.menu_book_rounded, color: _brightCyan, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      s,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )),
                          ...showcase.teachingYears.map((y) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: _brightCyan.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _brightCyan.withValues(alpha: 0.35)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.school_rounded, color: _brightCyan, size: 12),
                                    const SizedBox(width: 4),
                                    Text(
                                      y,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white12),

          // Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric(
                Icons.menu_book,
                '${showcase.totalCourses}',
                'Courses',
              ),
              Container(height: 36, width: 1, color: Colors.white12),
              _buildStatMetric(
                Icons.sensors,
                '${showcase.totalSessions}',
                'Live Sessions',
              ),
              Container(height: 36, width: 1, color: Colors.white12),
              _buildStatMetric(
                Icons.groups,
                '${showcase.totalStudents}',
                'Enrolled Students',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Deep Link Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: _brightCyan, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    showcase.deepLinkUrl,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _brightCyan,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                  tooltip: 'Copy Deep Link',
                  onPressed: () => _copyDeepLink(showcase.deepLinkUrl),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 22, color: _brightCyan),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStudentHonorsSection(TeacherShowcaseEntity showcase) {
    final achievements = showcase.studentAchievements;

    if (achievements.isEmpty && !widget.isOwner) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.orange.shade800],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Hall of Fame: Top Student Degrees & Honors',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.50)),
                        ),
                        child: Text(
                          '${achievements.length} Verified',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Best degrees, BAC distinctions & competitive exam honors achieved by students of ${showcase.name}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (achievements.isEmpty)
          GlassmorphicContainer(
            borderRadius: BorderRadius.circular(18),
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                const Icon(Icons.military_tech_outlined, color: Colors.amber, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No Student Degrees Added Yet',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add previous students\' BAC & BEM certificates, degree photos, and honors from your Teacher Studio to build trust with new students.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.70), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 295,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final ach = achievements[index];
                return _buildDegreeCard(ach);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDegreeCard(StudentAchievementEntity ach) {
    return GlassmorphicScaleButton(
      pressedScale: 0.96,
      onPressed: () => _showDegreeCertificateLightbox(ach),
      builder: (context, isPressed, isHovered) {
        return Container(
          width: 275,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isHovered
                  ? _brightCyan.withValues(alpha: 0.70)
                  : Colors.white.withValues(alpha: 0.18),
              width: isHovered ? 1.5 : 1.0,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _deepIndigo.withValues(alpha: 0.60),
                const Color(0xFF0F172A).withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: isHovered
                    ? _brightCyan.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.40),
                blurRadius: isHovered ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: Degree Certificate Image Thumbnail
                Stack(
                  children: [
                    Container(
                      height: 135,
                      width: double.infinity,
                      color: const Color(0xFF0F172A),
                      child: (ach.photoUrl.isNotEmpty)
                          ? Image.network(
                              ach.photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: _deepIndigo.withValues(alpha: 0.5),
                                child: const Icon(Icons.school, size: 48, color: Colors.white24),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [_deepIndigo, _electricPurple],
                                ),
                              ),
                              child: const Center(
                                child: Icon(Icons.workspace_premium_rounded, size: 48, color: Colors.white38),
                              ),
                            ),
                    ),
                    // Gradient overlay at bottom of image
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Top Left Score / Grade Badge
                    if (ach.gradeOrScore.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber.shade700, Colors.orange.shade800],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.40),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                ach.gradeOrScore,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Tap to enlarge hint
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                      ),
                    ),
                    // Bottom Student Name & Year over image
                    Positioned(
                      bottom: 8,
                      left: 10,
                      right: 10,
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 14, color: _brightCyan),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ach.studentName.isNotEmpty ? ach.studentName : 'Student Honors',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (ach.year.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                ach.year,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Body: Degree Title & Description
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ach.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (ach.description.isNotEmpty)
                        Text(
                          ach.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      const SizedBox(height: 10),
                      const Row(
                        children: [
                          Icon(Icons.image_outlined, size: 13, color: _brightCyan),
                          SizedBox(width: 4),
                          Text(
                            'Click to view degree photo',
                            style: TextStyle(color: _brightCyan, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded, size: 10, color: _brightCyan),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDegreeCertificateLightbox(StudentAchievementEntity ach) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: _electricPurple.withValues(alpha: 0.35),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.amber.shade700, Colors.orange.shade800],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ach.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Certificate Image (or Placeholder)
                  if (ach.photoUrl.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: Container(
                        width: double.infinity,
                        color: Colors.black,
                        child: Image.network(
                          ach.photoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            padding: const EdgeInsets.all(40),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.broken_image_rounded, size: 48, color: Colors.white38),
                                SizedBox(height: 8),
                                Text('Photo could not be loaded.', style: TextStyle(color: Colors.white60)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Certificate Details Footer
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (ach.studentName.isNotEmpty) ...[
                              const Icon(Icons.person, size: 16, color: _brightCyan),
                              const SizedBox(width: 6),
                              Text(
                                ach.studentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const Spacer(),
                            if (ach.gradeOrScore.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.amber.shade700, Colors.orange.shade800],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ach.gradeOrScore,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (ach.year.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ach.year,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (ach.description.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                            ),
                            child: Text(
                              ach.description,
                              style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveLiveSessionCard(TeacherShowcaseEntity showcase) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(18),
      blurSigma: 16.0,
      borderWidth: 1.2,
      borderColor: Colors.redAccent.withValues(alpha: 0.5),
      gradient: LinearGradient(
        colors: [
          Colors.red.shade900.withValues(alpha: 0.85),
          _deepIndigo.withValues(alpha: 0.80),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.redAccent.withValues(alpha: 0.35),
          blurRadius: 18,
          offset: const Offset(0, 4),
        ),
      ],
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sensors, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Interactive WebRTC Classroom',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  showcase.activeSessionTitle ?? 'Live Masterclass Streaming',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _brightCyan,
              foregroundColor: const Color(0xFF070B14),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.videocam, size: 18),
            label: const Text('Join Live Stage', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => _enterLiveSession(showcase.activeSessionId!),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(Set<String> categories) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 14.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.16),
      gradient: LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.08),
          _deepIndigo.withValues(alpha: 0.35),
          const Color(0xFF0F172A).withValues(alpha: 0.85),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search instructor courses by topic or title...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                prefixIcon: const Icon(Icons.search, color: _brightCyan),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: Colors.white70),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
          if (categories.length > 2) ...[
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat == 'all' ? 'All Categories' : cat),
                      selected: isSelected,
                      selectedColor: _electricPurple,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: isSelected ? _brightCyan : Colors.white.withValues(alpha: 0.14),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEnhancedCourseCard(CourseEntity course, int index) {
    final gradient = CourseVisualHelper.getGradientForCategory(course.category);
    final categoryIcon = CourseVisualHelper.getIconForCategory(course.category);

    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 20),
      borderRadius: BorderRadius.circular(20),
      blurSigma: 16.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.10),
          _deepIndigo.withValues(alpha: 0.40),
          const Color(0xFF0F172A).withValues(alpha: 0.90),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToCourseDetails(course),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Color Gradient Header with Hero Transitions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _deepIndigo,
                      gradient.first,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    // Hero Course Icon
                    Hero(
                      tag: 'course_icon_${course.id}',
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Icon(categoryIcon, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              course.category.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Hero Course Title
                          Hero(
                            tag: 'course_title_${course.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                course.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price Tag Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        course.isFree ? 'FREE' : '${course.price.toStringAsFixed(0)} DZD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: course.isFree ? Colors.green.shade800 : _deepIndigo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Card Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (course.description.isNotEmpty) ...[
                      Text(
                        course.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Metadata Badges Row
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        _pill(Icons.folder_outlined, '${course.modulesCount} Modules'),
                        _pill(Icons.play_circle_outline, '${course.lessonsCount} Lessons'),
                        _pill(Icons.people_outline, '${course.enrolledStudentsCount} Enrolled'),
                      ],
                    ),

                    const Divider(height: 28, color: Colors.white12),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _brightCyan,
                            side: BorderSide(color: _brightCyan.withValues(alpha: 0.5)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.list_alt, size: 16),
                          label: const Text('Syllabus', style: TextStyle(fontWeight: FontWeight.w600)),
                          onPressed: () => _showCurriculumDetailsModal(course),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.arrow_forward, size: 16),
                          label: const Text('Details', style: TextStyle(fontWeight: FontWeight.w600)),
                          onPressed: () => _navigateToCourseDetails(course),
                        ),
                        const SizedBox(width: 8),
                        widget.isOwner
                            ? ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _electricPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.edit_note, size: 18),
                                label: const Text('Edit in Studio', style: TextStyle(fontWeight: FontWeight.bold)),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TeacherCourseBuilderScreen(controller: widget.controller),
                                    ),
                                  );
                                },
                              )
                            : ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _deepIndigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(color: _brightCyan.withValues(alpha: 0.6)),
                                  ),
                                ),
                                icon: const Icon(Icons.school, size: 18),
                                label: Text(
                                  course.isFree ? 'Enroll Free' : 'Enroll Now',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                onPressed: () => _enrollInCourse(course),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: (index * 75).ms,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.12,
          end: 0,
          duration: 450.ms,
          delay: (index * 75).ms,
          curve: Curves.easeOutQuad,
        );
  }

  Widget _pill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: _brightCyan),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
