import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/course_visual_helper.dart';
import '../../../../core/widgets/bento_card.dart';
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
import '../../../monetization/data/datasources/monetization_remote_datasource.dart';
import '../../../monetization/data/repositories/monetization_repository_impl.dart';
import '../../../monetization/presentation/controllers/monetization_controller.dart';
import '../../../monetization/presentation/widgets/course_checkout_modal.dart';
import '../controllers/course_controller.dart';

/// Modern Full-Screen Course Details View with Glassmorphism, Bento Metrics & Hero Transitions
class CourseDetailsScreen extends StatefulWidget {
  final int courseId;
  final CourseEntity? initialCourse;
  final String heroTagPrefix;
  final CourseController controller;
  final bool isEnrolled;
  final int progressPercentage;
  final VoidCallback? onEnrollmentChanged;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    this.initialCourse,
    this.heroTagPrefix = 'course',
    required this.controller,
    this.isEnrolled = false,
    this.progressPercentage = 0,
    this.onEnrollmentChanged,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  CourseEntity? _course;
  bool _isLoading = false;
  late bool _enrolled;
  late int _progress;

  static const Color _bgDark = Color(0xFF070B14);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _neonGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _course = widget.initialCourse;
    _enrolled = widget.isEnrolled;
    _progress = widget.progressPercentage;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetails();
    });
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    await widget.controller.loadCourseDetails(widget.courseId);
    if (mounted) {
      setState(() {
        _course = widget.controller.selectedCourse ?? _course;
        _isLoading = false;
      });
    }
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
          roomTitle: _course?.title ?? 'Live Stage',
          controller: classroomController,
        ),
      ),
    );
  }

  Future<void> _enrollInCourse() async {
    final course = _course;
    if (course == null) return;

    if (!course.isFree && course.price > 0) {
      final apiClient = ApiClient();
      final authLocalDataSource = AuthLocalDataSourceImpl();
      final token = await authLocalDataSource.getToken() ?? '';
      final remoteDataSource = MonetizationRemoteDataSourceImpl(apiClient: apiClient);
      final repository = MonetizationRepositoryImpl(remoteDataSource: remoteDataSource);
      final monetizationController = MonetizationController(
        repository: repository,
        authToken: token,
      );

      if (mounted) {
        await CourseCheckoutModal.show(
          context: context,
          courseId: course.id,
          courseTitle: course.title,
          price: course.price,
          category: course.category,
          monetizationController: monetizationController,
          onPaymentSuccess: () {
            if (mounted) {
              setState(() {
                _enrolled = true;
                _progress = 0;
              });
            }
            widget.onEnrollmentChanged?.call();
          },
        );
      }
      return;
    }

    final success = await widget.controller.enrollInCourse(course.id);
    if (!mounted) return;

    if (success) {
      setState(() {
        _enrolled = true;
        _progress = 0;
      });
      widget.onEnrollmentChanged?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: _brightCyan, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text('Enrolled in "${course.title}" successfully!')),
            ],
          ),
          backgroundColor: _deepIndigo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(widget.controller.errorMessage ?? 'Failed to enroll in course.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;
    final category = course?.category ?? 'General';
    final gradient = CourseVisualHelper.getGradientForCategory(category);
    final categoryIcon = CourseVisualHelper.getIconForCategory(category);
    final title = course?.title ?? 'Course Details';

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Background ambient futuristic glowing orbs
          Positioned(
            top: 40,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
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
            bottom: 120,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
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

          // Main CustomScrollView
          CustomScrollView(
            slivers: [
              // 1. Hero Animated Sliver AppBar
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: _bgDark.withValues(alpha: 0.85),
                foregroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              gradient.first.withValues(alpha: 0.85),
                              _deepIndigo.withValues(alpha: 0.75),
                              _bgDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(color: Colors.transparent),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Hero Course Badge / Icon
                                  Hero(
                                    tag: '${widget.heroTagPrefix}_icon_${widget.courseId}',
                                    child: BentoIconAura(
                                      icon: categoryIcon,
                                      color: _brightCyan,
                                      size: 32,
                                      padding: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        FuturisticGlowBadge(
                                          label: category.toUpperCase(),
                                          color: _brightCyan,
                                        ),
                                        const SizedBox(height: 8),
                                        // Hero Course Title
                                        Hero(
                                          tag: '${widget.heroTagPrefix}_title_${widget.courseId}',
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Text(
                                              title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 21,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Main Content Body
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Summary Bento Row
                          _buildQuickMetricsRow(course)
                              .animate()
                              .fadeIn(duration: 350.ms)
                              .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOutQuad),
                          const SizedBox(height: 20),

                          // Enrollment Status Banner (if enrolled)
                          if (_enrolled)
                            _buildEnrolledBanner()
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 100.ms)
                                .scale(begin: const Offset(0.98, 0.98), end: const Offset(1, 1)),

                          if (_enrolled) const SizedBox(height: 20),

                          // Instructor Card
                          if (course?.teacherName != null)
                            _buildInstructorCard(course!)
                                .animate()
                                .fadeIn(duration: 400.ms, delay: 120.ms)
                                .slideY(begin: 0.06, end: 0),

                          const SizedBox(height: 20),

                          // Course Description
                          _buildDescriptionCard(course)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 160.ms)
                              .slideY(begin: 0.06, end: 0),

                          const SizedBox(height: 28),

                          // Curriculum Syllabus Header
                          Row(
                            children: [
                              const BentoIconAura(
                                icon: Icons.menu_book_rounded,
                                color: _brightCyan,
                                size: 20,
                                padding: 8,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Curriculum Syllabus (${course?.modules.length ?? 0} Modules)',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              if (_isLoading) ...[
                                const SizedBox(width: 14),
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _brightCyan,
                                  ),
                                ),
                              ],
                            ],
                          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                          const SizedBox(height: 16),

                          // Curriculum Modules List with Staggered Entrance
                          if (course != null && course.modules.isNotEmpty)
                            ...course.modules.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final mod = entry.value;
                              return _buildModuleCard(mod, idx)
                                  .animate()
                                  .fadeIn(
                                    duration: 350.ms,
                                    delay: (220 + idx * 60).ms,
                                    curve: Curves.easeOut,
                                  )
                                  .slideY(
                                    begin: 0.06,
                                    end: 0,
                                    duration: 350.ms,
                                    delay: (220 + idx * 60).ms,
                                    curve: Curves.easeOutQuad,
                                  );
                            })
                          else if (!_isLoading)
                            GlassmorphicContainer(
                              borderRadius: BorderRadius.circular(18),
                              borderColor: Colors.white.withValues(alpha: 0.12),
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Text(
                                  'No modules published for this curriculum yet.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 110), // Spacing for floating bar
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 3. Floating Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionBar(course),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMetricsRow(CourseEntity? course) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(20),
      borderColor: _brightCyan.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _metricItem(Icons.folder_open_rounded, '${course?.modulesCount ?? 0}', 'Modules', _brightCyan),
          Container(height: 32, width: 1, color: Colors.white.withValues(alpha: 0.15)),
          _metricItem(Icons.play_circle_outline_rounded, '${course?.lessonsCount ?? 0}', 'Lessons', _electricPurple),
          Container(height: 32, width: 1, color: Colors.white.withValues(alpha: 0.15)),
          _metricItem(Icons.people_outline_rounded, '${course?.enrolledStudentsCount ?? 0}', 'Students', const Color(0xFF38BDF8)),
          Container(height: 32, width: 1, color: Colors.white.withValues(alpha: 0.15)),
          _metricItem(
            Icons.payments_outlined,
            course == null
                ? 'FREE'
                : course.isFree
                    ? 'FREE'
                    : '${course.price.toStringAsFixed(0)} DZD',
            'Tuition',
            _neonGreen,
          ),
        ],
      ),
    );
  }

  Widget _metricItem(IconData icon, String val, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          val,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  Widget _buildEnrolledBanner() {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(18),
      borderColor: _neonGreen.withValues(alpha: 0.45),
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        colors: [
          _neonGreen.withValues(alpha: 0.18),
          const Color(0xFF065F46).withValues(alpha: 0.40),
          _bgDark,
        ],
      ),
      child: Row(
        children: [
          const BentoIconAura(
            icon: Icons.check_circle_rounded,
            color: _neonGreen,
            size: 24,
            padding: 10,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enrolled Student Access',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_progress% of course completed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const FuturisticGlowBadge(
            label: 'ACTIVE',
            color: _neonGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorCard(CourseEntity course) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(20),
      borderColor: _electricPurple.withValues(alpha: 0.30),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const BentoIconAura(
            icon: Icons.person_rounded,
            color: _electricPurple,
            size: 26,
            padding: 12,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        course.teacherName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: _brightCyan, size: 16),
                  ],
                ),
                if (course.teacherHeadline != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    course.teacherHeadline!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(CourseEntity? course) {
    final desc = course?.description ?? '';
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(20),
      borderColor: Colors.white.withValues(alpha: 0.15),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: _brightCyan, size: 18),
              SizedBox(width: 8),
              Text(
                'About This Masterclass',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc.isNotEmpty ? desc : 'Comprehensive syllabus crafted for hands-on, interactive mastery.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(CourseModuleEntity module, int index) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(18),
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
            size: 18,
            padding: 8,
          ),
          title: Text(
            module.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            '${module.lessons.length} lessons',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
          ),
          children: module.lessons.map(_buildLessonTile).toList(),
        ),
      ),
    );
  }

  Widget _buildLessonTile(CourseLessonEntity lesson) {
    IconData icon;
    Color iconColor;
    String typeLabel;

    if (lesson.isLiveSession) {
      icon = Icons.sensors;
      iconColor = const Color(0xFFEF4444);
      typeLabel = 'Live Classroom';
    } else if (lesson.isVideo) {
      icon = Icons.play_circle_fill;
      iconColor = _brightCyan;
      typeLabel = 'Video Lecture';
    } else {
      icon = Icons.description;
      iconColor = _electricPurple;
      typeLabel = 'Reading / Notes';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(
          lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '$typeLabel • ${lesson.durationMinutes} min',
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
        ),
        trailing: lesson.isLiveSession && lesson.sessionId != null
            ? FuturisticCapsuleButton(
                text: lesson.isLiveNow ? 'Join Live' : 'Enter Stage',
                icon: lesson.isLiveNow ? Icons.videocam : Icons.play_arrow,
                height: 34,
                fontSize: 11.5,
                accentColor: lesson.isLiveNow ? const Color(0xFFEF4444) : _brightCyan,
                secondaryColor: _electricPurple,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                onPressed: () => _enterLiveSession(lesson.sessionId!),
              )
            : null,
      ),
    );
  }

  Widget _buildBottomActionBar(CourseEntity? course) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _bgDark.withValues(alpha: 0.88),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.14), width: 1.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _enrolled ? 'ENROLLMENT STATUS' : 'TOTAL TUITION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _enrolled
                          ? 'Enrolled'
                          : course == null
                              ? 'FREE'
                              : course.isFree
                                  ? 'FREE'
                                  : '${course.price.toStringAsFixed(0)} DZD',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: _brightCyan,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_enrolled)
                  FuturisticCapsuleButton(
                    text: 'Resume Learning',
                    icon: Icons.school_rounded,
                    accentColor: _neonGreen,
                    secondaryColor: _brightCyan,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Select any lesson from the curriculum syllabus above to begin!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  )
                else
                  FuturisticCapsuleButton(
                    text: course?.isFree ?? true ? 'Enroll Free' : 'Checkout & Enroll',
                    icon: course?.isFree ?? true ? Icons.school_rounded : Icons.lock_open_rounded,
                    accentColor: _brightCyan,
                    secondaryColor: _electricPurple,
                    onPressed: _enrollInCourse,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
