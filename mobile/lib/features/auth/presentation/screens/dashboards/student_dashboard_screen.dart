import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/widgets/glassmorphism.dart';
import '../../../../../core/widgets/bento_card.dart';
import '../../../../../core/widgets/pindo_brand_logo.dart';
import '../../../../classroom/data/datasources/classroom_remote_datasource.dart';
import '../../../../classroom/data/datasources/whiteboard_remote_datasource.dart';
import '../../../../classroom/data/repositories/classroom_repository_impl.dart';
import '../../../../classroom/data/repositories/whiteboard_repository_impl.dart';
import '../../../../classroom/domain/usecases/get_room_token_usecase.dart';
import '../../../../classroom/domain/usecases/get_whiteboard_snapshots_usecase.dart';
import '../../../../classroom/presentation/controllers/classroom_controller.dart';
import '../../../../classroom/presentation/screens/live_classroom_screen.dart';
import '../../../../classroom/services/livekit_room_service.dart';
import '../../../../courses/data/datasources/course_remote_datasource.dart';
import '../../../../courses/data/repositories/course_repository_impl.dart';
import '../../../../courses/presentation/controllers/course_controller.dart';
import '../../../../courses/presentation/screens/course_details_screen.dart';
import '../../../../courses/presentation/screens/student_courses_screen.dart';
import '../../../../courses/presentation/screens/teacher_showcase_screen.dart';
import '../../../../courses/presentation/widgets/academic_explorer_widget.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../domain/entities/user.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/user_account_settings_modal.dart';
import '../../../../cohorts/data/datasources/cohort_remote_datasource.dart';
import '../../../../cohorts/data/repositories/cohort_repository_impl.dart';
import '../../../../cohorts/presentation/controllers/cohort_controller.dart';
import '../../../../cohorts/presentation/screens/student_cohort_explorer_screen.dart';
import '../../../../exams/data/datasources/exam_remote_datasource.dart';
import '../../../../exams/data/repositories/exam_bank_repository_impl.dart';
import '../../../../exams/presentation/controllers/exam_bank_controller.dart';
import '../../../../exams/presentation/screens/exam_bank_explorer_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final User user;
  final AuthController authController;

  const StudentDashboardScreen({
    super.key,
    required this.user,
    required this.authController,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _sessionController = TextEditingController();

  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);

  @override
  void dispose() {
    _sessionController.dispose();
    super.dispose();
  }

  void _joinClassroom(String sessionId) {
    final cleanId = sessionId.trim();
    if (cleanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Session ID (e.g. SES_XXXX)'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Instantiate Clean Architecture Classroom dependencies
    final apiClient = ApiClient();
    final remoteDataSource = ClassroomRemoteDataSourceImpl(apiClient: apiClient);
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final repository = ClassroomRepositoryImpl(
      remoteDataSource: remoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );
    final getRoomTokenUseCase = GetRoomTokenUseCase(repository);
    final roomService = LiveKitRoomService();
    final whiteboardRemoteDataSource = WhiteboardRemoteDataSourceImpl(apiClient: apiClient);
    final whiteboardRepository = WhiteboardRepositoryImpl(remoteDataSource: whiteboardRemoteDataSource);
    final getWhiteboardSnapshotsUseCase = GetWhiteboardSnapshotsUseCase(whiteboardRepository);

    final classroomController = ClassroomController(
      getRoomTokenUseCase: getRoomTokenUseCase,
      roomService: roomService,
      getWhiteboardSnapshotsUseCase: getWhiteboardSnapshotsUseCase,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveClassroomScreen(
          sessionId: cleanId,
          roomTitle: 'Live Classroom ($cleanId)',
          controller: classroomController,
        ),
      ),
    );
  }

  void _navigateToStudentCourses() {
    final apiClient = ApiClient();
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final remoteDataSource = CourseRemoteDataSourceImpl(apiClient: apiClient);
    final courseRepository = CourseRepositoryImpl(
      remoteDataSource: remoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );
    final courseController = CourseController(courseRepository: courseRepository);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentCoursesScreen(controller: courseController),
      ),
    );
  }

  void _navigateToCohortExplorer() {
    final apiClient = ApiClient();
    final remoteDataSource = CohortRemoteDataSourceImpl(apiClient: apiClient);
    final repository = CohortRepositoryImpl(remoteDataSource: remoteDataSource);
    final controller = CohortController(cohortRepository: repository);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentCohortExplorerScreen(
          student: widget.user,
          cohortController: controller,
        ),
      ),
    );
  }

  void _navigateToExamBank() async {
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final token = await authLocalDataSource.getToken();
    final apiClient = ApiClient();
    final remoteDataSource = ExamRemoteDataSourceImpl(apiClient: apiClient);
    final repository = ExamBankRepositoryImpl(remoteDataSource: remoteDataSource);
    final controller = ExamBankController(repository: repository, userToken: token);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamBankExplorerScreen(controller: controller),
      ),
    );
  }

  void _navigateToCourseDetails(int courseId) {
    final apiClient = ApiClient();
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final remoteDataSource = CourseRemoteDataSourceImpl(apiClient: apiClient);
    final courseRepository = CourseRepositoryImpl(
      remoteDataSource: remoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );
    final courseController = CourseController(courseRepository: courseRepository);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailsScreen(
          courseId: courseId,
          heroTagPrefix: 'course',
          controller: courseController,
        ),
      ),
    );
  }

  void _navigateToTeacherShowcase(String teacherId) {
    final cleanId = teacherId.trim();
    if (cleanId.isEmpty) return;

    final apiClient = ApiClient();
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final remoteDataSource = CourseRemoteDataSourceImpl(apiClient: apiClient);
    final courseRepository = CourseRepositoryImpl(
      remoteDataSource: remoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );
    final courseController = CourseController(courseRepository: courseRepository);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeacherShowcaseScreen(
          teacherId: cleanId,
          controller: courseController,
        ),
      ),
    );
  }

  void _showExploreTeacherDialog() {
    final teacherIdController = TextEditingController(text: 'TCH_123');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18), width: 1.2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _electricPurple.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_search, color: _brightCyan, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Browse Instructor Showcase',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a Teacher ID to inspect their verified profile, public curriculums, and live streams:',
              style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: teacherIdController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Teacher ID (e.g. TCH_101)',
                labelStyle: const TextStyle(color: _brightCyan),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.08),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _brightCyan, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          GlassmorphicScaleButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
          ),
          FuturisticCapsuleButton(
            text: 'View Showcase',
            icon: Icons.visibility_rounded,
            height: 40,
            fontSize: 13,
            accentColor: _brightCyan,
            secondaryColor: _electricPurple,
            onPressed: () {
              Navigator.of(ctx).pop();
              _navigateToTeacherShowcase(teacherIdController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14), // Deep Cosmic Midnight
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.90),
        elevation: 0,
        title: const Row(
          children: [
            PindoBrandLogo(size: 28, showText: false, withGlow: true),
            SizedBox(width: 10),
            Text(
              'Student Hub',
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
            padding: const EdgeInsets.only(right: 6.0),
            child: GlassmorphicScaleButton(
              tooltip: 'Settings & Security',
              onPressed: () => UserAccountSettingsModal.show(
                context,
                user: user,
                authController: widget.authController,
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GlassmorphicScaleButton(
              tooltip: 'Sign Out',
              onPressed: () => widget.authController.logout(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(Icons.logout, color: Colors.white70, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Student Profile Glass Card
            _buildStudentProfileCard(user)
                .animate()
                .fadeIn(duration: 450.ms)
                .slideY(begin: -0.06, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 24),

            // 2. Interactive Academic Hierarchy (Level -> Year -> Subject -> Teachers)
            AcademicExplorerWidget(
              onOpenTeacherShowcase: _navigateToTeacherShowcase,
              onJoinLiveClassroom: _joinClassroom,
            ).animate().fadeIn(duration: 450.ms, delay: 80.ms),

            const SizedBox(height: 28),

            // 3. Quick Join Classroom by Session ID
            _buildSectionHeader(
              title: 'Join Live Classroom',
              icon: Icons.sensors,
              iconColor: _brightCyan,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 12),

            _buildQuickJoinCard()
                .animate()
                .fadeIn(duration: 450.ms, delay: 150.ms)
                .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 28),

            // 4. Modules & Courses Section
            _buildSectionHeader(
              title: 'Enrolled Academics & Curriculums',
              icon: Icons.menu_book,
              iconColor: _electricPurple,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 12),

            // Featured Masterclass Hero Card
            _buildFeaturedMasterclassCard()
                .animate()
                .fadeIn(duration: 450.ms, delay: 250.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic)
                .shimmer(duration: 2200.ms, delay: 600.ms),

            const SizedBox(height: 12),

            // Action Tiles List
            _buildStudentActionTiles()
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentProfileCard(User user) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(20),
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
          color: _electricPurple.withValues(alpha: 0.28),
          blurRadius: 28,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _brightCyan, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: _brightCyan.withValues(alpha: 0.45),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: _deepIndigo,
              radius: 26,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: _brightCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _brightCyan.withValues(alpha: 0.60)),
              boxShadow: [
                BoxShadow(
                  color: _brightCyan.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Text(
              'STUDENT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _brightCyan,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickJoinCard() {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(18),
      blurSigma: 16.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.10),
          _deepIndigo.withValues(alpha: 0.50),
          const Color(0xFF0F172A).withValues(alpha: 0.85),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter Session ID provided by your instructor to connect to live stream:',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                  ),
                  child: TextField(
                    controller: _sessionController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. SES_8PP4LVG1',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                      prefixIcon: const Icon(Icons.dialpad, color: _brightCyan, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: InputBorder.none,
                    ),
                    onSubmitted: _joinClassroom,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GlassmorphicScaleButton(
                pressedScale: 0.92,
                onPressed: () => _joinClassroom(_sessionController.text),
                builder: (context, isPressed, isHovered) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_electricPurple, _brightCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: isHovered ? 0.40 : 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _brightCyan.withValues(alpha: isHovered ? 0.45 : 0.25),
                          blurRadius: isHovered ? 16 : 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Connect',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF070B14),
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedMasterclassCard() {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(18),
      blurSigma: 16.0,
      borderWidth: 1.2,
      borderColor: _brightCyan.withValues(alpha: 0.35),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _deepIndigo.withValues(alpha: 0.90),
          _electricPurple.withValues(alpha: 0.75),
          const Color(0xFF0F172A).withValues(alpha: 0.85),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: _electricPurple.withValues(alpha: 0.30),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _navigateToCourseDetails(1),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Hero(
                  tag: 'course_icon_1',
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _brightCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _brightCyan.withValues(alpha: 0.50),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _brightCyan.withValues(alpha: 0.30),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.school, color: _brightCyan, size: 26),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _brightCyan.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _brightCyan.withValues(alpha: 0.40)),
                        ),
                        child: const Text(
                          'FEATURED MASTERCLASS',
                          style: TextStyle(
                            color: _brightCyan,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Hero(
                        tag: 'course_title_1',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            'Full-Stack Modern Web & Flutter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Tap to inspect curriculum syllabus with Hero transition',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: _brightCyan, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentActionTiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. Algerian Study Cohorts (Hero Bento Card)
        BentoCard(
          isHero: true,
          title: 'Study Cohorts & Algerian Streams (أفواج البكالوريا)',
          subtitle: 'Discover BAC & BEM peer study groups (شعب البكالوريا والمتوسط) led by verified teachers across 58 wilayas.',
          icon: Icons.groups_rounded,
          accentColor: const Color(0xFF10B981),
          secondaryAccent: _brightCyan,
          badgeText: 'BAC & BEM 2026',
          badgeColor: const Color(0xFF10B981),
          onTap: _navigateToCohortExplorer,
        ),

        const SizedBox(height: 14),

        // Phase 6: Algerian National Exam Bank & Timed Simulations (بنك الامتحانات وحوليات البكالوريا)
        BentoCard(
          isHero: true,
          title: 'National Exam Bank & Timed Simulations (بنك الامتحانات الرسمية)',
          subtitle: 'Practice with official BAC & BEM exam papers (2008–2025), ministerial answer keys (سلم التنقيط الوزاري), and real-time timed mock simulations.',
          icon: Icons.history_edu_rounded,
          accentColor: const Color(0xFFF59E0B),
          secondaryAccent: const Color(0xFF10B981),
          badgeText: 'BEM & BAC 2008-2025',
          badgeColor: const Color(0xFFF59E0B),
          onTap: _navigateToExamBank,
        ),

        const SizedBox(height: 14),

        // 1. Asymmetric Hero Bento Card (Wide card at top)
        BentoCard(
          isHero: true,
          title: 'My Courses & Academic Progress',
          subtitle: 'Track completion percentage, interactive syllabus milestones, and LiveKit WebRTC classroom routing.',
          icon: Icons.school_rounded,
          accentColor: _brightCyan,
          secondaryAccent: _electricPurple,
          badgeText: 'FEATURED HUB',
          badgeColor: _brightCyan,
          onTap: _navigateToStudentCourses,
          extraContent: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 13),
                    SizedBox(width: 5),
                    Text(
                      '4 Active Courses',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _electricPurple.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _electricPurple.withValues(alpha: 0.45)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: _brightCyan, size: 13),
                    SizedBox(width: 4),
                    Text(
                      '88% Syllabus Mastered',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 2. Asymmetric Grid of Smaller Square Cards Side-by-Side (Bento Layout)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BentoCard(
                title: 'Teacher Showcase',
                subtitle: 'Browse top verified instructors & preview studios',
                icon: Icons.explore_rounded,
                accentColor: _brightCyan,
                secondaryAccent: _deepIndigo,
                badgeText: 'STUDIO',
                badgeColor: _brightCyan,
                height: 172,
                onTap: _showExploreTeacherDialog,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BentoCard(
                title: 'Homework & Quizzes',
                subtitle: 'Submit coursework and inspect instructor grading',
                icon: Icons.assignment_turned_in_rounded,
                accentColor: const Color(0xFF10B981),
                secondaryAccent: _brightCyan,
                badgeText: 'PRACTICE',
                badgeColor: const Color(0xFF10B981),
                height: 172,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Homework submissions will open during live academic modules.'),
                      backgroundColor: _deepIndigo,
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BentoCard(
                title: 'Classroom Archives',
                subtitle: 'Catch up on recorded masterclasses & transcripts',
                icon: Icons.video_library_rounded,
                accentColor: const Color(0xFFF59E0B),
                secondaryAccent: const Color(0xFFEF4444),
                badgeText: 'REPLAY',
                badgeColor: const Color(0xFFF59E0B),
                height: 172,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Masterclass recordings sync automatically after each live session.'),
                      backgroundColor: _deepIndigo,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BentoCard(
                title: 'Live Study Rooms',
                subtitle: 'Collaborative peer whiteboards & groups',
                icon: Icons.groups_rounded,
                accentColor: const Color(0xFFEC4899),
                secondaryAccent: _electricPurple,
                badgeText: 'COMMUNITY',
                badgeColor: const Color(0xFFEC4899),
                height: 172,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Peer study rooms allow interactive whiteboard group collaboration.'),
                      backgroundColor: _deepIndigo,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
