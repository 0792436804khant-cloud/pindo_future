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
import '../../../../classroom/domain/usecases/save_whiteboard_snapshot_usecase.dart';
import '../../../../classroom/presentation/controllers/classroom_controller.dart';
import '../../../../classroom/presentation/screens/live_classroom_screen.dart';
import '../../../../classroom/services/livekit_room_service.dart';
import '../../../../courses/data/datasources/course_remote_datasource.dart';
import '../../../../courses/data/repositories/course_repository_impl.dart';
import '../../../../courses/presentation/controllers/course_controller.dart';
import '../../../../courses/presentation/screens/teacher_course_builder_screen.dart';
import '../../../../courses/presentation/screens/teacher_showcase_screen.dart';
import '../../../../monetization/data/datasources/monetization_remote_datasource.dart';
import '../../../../monetization/data/repositories/monetization_repository_impl.dart';
import '../../../../monetization/presentation/controllers/monetization_controller.dart';
import '../../../../monetization/presentation/screens/teacher_earnings_screen.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../domain/entities/user.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/teacher_profile_editor_modal.dart';
import '../../widgets/user_account_settings_modal.dart';
import '../../../../cohorts/data/datasources/cohort_remote_datasource.dart';
import '../../../../cohorts/data/repositories/cohort_repository_impl.dart';
import '../../../../cohorts/presentation/controllers/cohort_controller.dart';
import '../../../../cohorts/presentation/screens/teacher_cohort_studio_screen.dart';
import '../../../../courses/domain/entities/teacher_showcase_entity.dart';
import '../../../../teachers/presentation/widgets/teacher_verification_badge.dart';

class TeacherDashboardScreen extends StatefulWidget {
  final User user;
  final AuthController authController;

  const TeacherDashboardScreen({
    super.key,
    required this.user,
    required this.authController,
  });

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late User _currentUser;
  String? _headline;
  String? _bio;
  String? _avatarUrl;
  int? _yearsOfExperience;
  List<String> _teachingSubjects = [];
  List<String> _teachingYears = [];
  List<String> _teachingLevels = [];
  List<StudentAchievementEntity> _studentAchievements = [];
  bool _isLoadingPlatform = false;
  bool _isCreatingSession = false;

  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _headline = widget.user.headline;
    _bio = widget.user.bio;
    _avatarUrl = widget.user.avatarUrl;
    _yearsOfExperience = widget.user.yearsOfExperience;
    _teachingSubjects = List<String>.from(widget.user.teachingSubjects);
    _teachingYears = List<String>.from(widget.user.teachingYears);
    _teachingLevels = List<String>.from(widget.user.teachingLevels);
    _loadTeacherPlatform();
  }

  Future<void> _loadTeacherPlatform() async {
    setState(() => _isLoadingPlatform = true);
    try {
      final apiClient = ApiClient();
      final authLocal = AuthLocalDataSourceImpl();
      final token = await authLocal.getToken();
      final response = await apiClient.get('/teacher/platform', token: token);

      if (response.statusCode == 200 && response.data['platform'] != null) {
        final platformData = response.data['platform'] as Map<String, dynamic>;
        final teacher = platformData['teacher'] as Map<String, dynamic>? ?? {};
        final platform = platformData['platform'] as Map<String, dynamic>? ?? {};
        final rawAchievements = (platform['student_achievements'] ?? teacher['student_achievements']) as List<dynamic>? ?? [];

        final parsedAchievements = rawAchievements
            .whereType<Map<String, dynamic>>()
            .map((a) => StudentAchievementEntity.fromJson(a))
            .toList();

        final rawLevels = (teacher['teaching_levels'] ?? platform['teaching_levels']) as List<dynamic>? ?? [];
        final rawYears = (teacher['teaching_years'] ?? platform['teaching_years']) as List<dynamic>? ?? [];
        final rawSubjects = (teacher['teaching_subjects'] ?? platform['teaching_subjects']) as List<dynamic>? ?? [];

        final avatar = (platform['avatar_url'] ?? teacher['avatar_url'])?.toString();
        final expRaw = platform['years_of_experience'] ?? teacher['years_of_experience'];
        final exp = expRaw is num ? expRaw.toInt() : int.tryParse(expRaw?.toString() ?? '');

        if (mounted) {
          setState(() {
            _headline = platform['headline'] as String? ?? _headline;
            _bio = platform['bio'] as String? ?? _bio;
            _avatarUrl = (avatar != null && avatar.trim().isNotEmpty) ? avatar : _avatarUrl;
            _yearsOfExperience = exp ?? _yearsOfExperience;
            _teachingLevels = rawLevels.map((e) => e.toString()).toList();
            _teachingYears = rawYears.map((e) => e.toString()).toList();
            _teachingSubjects = rawSubjects.map((e) => e.toString()).toList();
            _studentAchievements = parsedAchievements;

            _currentUser = _currentUser.copyWith(
              avatarUrl: _avatarUrl,
              yearsOfExperience: _yearsOfExperience,
              headline: _headline,
              bio: _bio,
              teachingLevels: _teachingLevels,
              teachingYears: _teachingYears,
              teachingSubjects: _teachingSubjects,
            );
            _isLoadingPlatform = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPlatform = false);
    }
  }

  void _openProfileEditorModal() {
    TeacherProfileEditorModal.show(
      context: context,
      user: _currentUser,
      initialHeadline: _headline,
      initialBio: _bio,
      initialAvatarUrl: _avatarUrl,
      initialExperience: _yearsOfExperience,
      initialSubjects: _teachingSubjects,
      initialYears: _teachingYears,
      initialLevels: _teachingLevels,
      initialAchievements: _studentAchievements,
      onSaveSuccess: (updatedUser, updatedAchievements) {
        setState(() {
          _currentUser = updatedUser;
          _headline = updatedUser.headline;
          _bio = updatedUser.bio;
          _avatarUrl = updatedUser.avatarUrl;
          _yearsOfExperience = updatedUser.yearsOfExperience;
          _teachingSubjects = updatedUser.teachingSubjects;
          _teachingYears = updatedUser.teachingYears;
          _teachingLevels = updatedUser.teachingLevels;
          _studentAchievements = updatedAchievements;
        });
      },
    );
  }

  void _showLaunchSessionDialog() {
    final titleController = TextEditingController(text: 'Live Masterclass');

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
              child: const Icon(Icons.sensors, color: _brightCyan, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Launch Dynamic Classroom',
              style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter lecture title. A dynamic Session ID will be generated and bound for up to 30,000 attendees via WebRTC SFU:',
              style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Session Title',
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
            text: 'Start & Broadcast',
            icon: Icons.sensors_rounded,
            height: 40,
            fontSize: 13,
            accentColor: _brightCyan,
            secondaryColor: _electricPurple,
            onPressed: () async {
              Navigator.of(ctx).pop();
              _createAndEnterSession(titleController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createAndEnterSession(String title) async {
    setState(() => _isCreatingSession = true);

    try {
      final apiClient = ApiClient();
      final authLocalDataSource = AuthLocalDataSourceImpl();
      final token = await authLocalDataSource.getToken();

      // 1. Create Dynamic Session via Laravel API
      final createResponse = await apiClient.post(
        '/teacher/sessions',
        body: {
          'title': title.isNotEmpty ? title : 'Live Classroom Session',
          'max_participants': 30000,
        },
        token: token,
      );

      final sessionData = createResponse['session'] as Map<String, dynamic>;
      final sessionId = sessionData['session_id'] as String;

      // 2. Start Session (Transition to Active)
      await apiClient.post(
        '/teacher/sessions/$sessionId/start',
        token: token,
      );

      // 3. Instantiate Classroom Clean Architecture Controller
      final remoteDataSource = ClassroomRemoteDataSourceImpl(apiClient: apiClient);
      final repository = ClassroomRepositoryImpl(
        remoteDataSource: remoteDataSource,
        authLocalDataSource: authLocalDataSource,
      );
      final getRoomTokenUseCase = GetRoomTokenUseCase(repository);
      final roomService = LiveKitRoomService();
      final whiteboardRemoteDataSource = WhiteboardRemoteDataSourceImpl(apiClient: apiClient);
      final whiteboardRepository = WhiteboardRepositoryImpl(remoteDataSource: whiteboardRemoteDataSource);
      final saveWhiteboardSnapshotUseCase = SaveWhiteboardSnapshotUseCase(whiteboardRepository);
      final getWhiteboardSnapshotsUseCase = GetWhiteboardSnapshotsUseCase(whiteboardRepository);

      final classroomController = ClassroomController(
        getRoomTokenUseCase: getRoomTokenUseCase,
        roomService: roomService,
        saveWhiteboardSnapshotUseCase: saveWhiteboardSnapshotUseCase,
        getWhiteboardSnapshotsUseCase: getWhiteboardSnapshotsUseCase,
      );

      if (mounted) {
        setState(() => _isCreatingSession = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LiveClassroomScreen(
              sessionId: sessionId,
              roomTitle: title,
              controller: classroomController,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreatingSession = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to launch classroom: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _navigateToCourseBuilder() {
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
        builder: (_) => TeacherCourseBuilderScreen(controller: courseController),
      ),
    );
  }

  void _navigateToCohortStudio() {
    final apiClient = ApiClient();
    final remoteDataSource = CohortRemoteDataSourceImpl(apiClient: apiClient);
    final repository = CohortRepositoryImpl(remoteDataSource: remoteDataSource);
    final controller = CohortController(cohortRepository: repository);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeacherCohortStudioScreen(
          teacher: _currentUser,
          cohortController: controller,
        ),
      ),
    );
  }

  void _navigateToPublicShowcase(String teacherId) {
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
          teacherId: teacherId,
          controller: courseController,
          isOwner: true,
        ),
      ),
    );
  }

  Future<void> _navigateToEarnings() async {
    final apiClient = ApiClient();
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final token = await authLocalDataSource.getToken() ?? '';
    final remoteDataSource = MonetizationRemoteDataSourceImpl(apiClient: apiClient);
    final repository = MonetizationRepositoryImpl(remoteDataSource: remoteDataSource);
    final controller = MonetizationController(repository: repository, authToken: token);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TeacherEarningsScreen(monetizationController: controller),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final deepLink = 'https://pindofuture.com/teacher/${user.teacherId ?? 'TCH_UNKNOWN'}';

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
              'Teacher Studio',
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
          if (_isLoadingPlatform)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _brightCyan),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: GlassmorphicScaleButton(
              tooltip: 'Settings & Security',
              onPressed: () => UserAccountSettingsModal.show(
                context,
                user: _currentUser,
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
            // 1. Teacher Profile Glassmorphic Hero Card
            _buildTeacherProfileCard(user)
                .animate()
                .fadeIn(duration: 450.ms)
                .slideY(begin: -0.06, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 24),

            // 2. Platforms Feature Spotlight (Deep Link)
            _buildSectionHeader(
              title: 'Public Showcase & Deep Link',
              icon: Icons.link,
              iconColor: _brightCyan,
            ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 12),

            _buildDeepLinkCard(deepLink, user)
                .animate()
                .fadeIn(duration: 450.ms, delay: 150.ms)
                .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),

            const SizedBox(height: 28),

            // 3. Studio & Classroom Action Tiles
            _buildSectionHeader(
              title: 'Classroom & Course Studio',
              icon: Icons.dashboard_customize,
              iconColor: _electricPurple,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 12),

            _buildStudioActionTiles()
                .animate()
                .fadeIn(duration: 500.ms, delay: 250.ms)
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

  Widget _buildTeacherProfileCard(User user) {
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
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: _deepIndigo,
                  radius: 30,
                  backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                      ? null
                      : Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'T',
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                        TeacherVerificationBadge(
                          isVerified: user.isTeacherVerified,
                          size: 18,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: _brightCyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _brightCyan.withValues(alpha: 0.60)),
                          ),
                          child: Text(
                            user.teacherId ?? 'TEACHER',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: _brightCyan,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (_yearsOfExperience != null && _yearsOfExperience! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.amber.shade700, Colors.orange.shade800],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.70)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium_rounded, size: 13, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  '$_yearsOfExperience Yrs Exp',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _headline ?? user.email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Teaching Classifications (Subjects & Years)
          if (_teachingSubjects.isNotEmpty || _teachingYears.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ..._teachingSubjects.map((sub) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _electricPurple.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _electricPurple.withValues(alpha: 0.40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_rounded, color: _brightCyan, size: 12),
                      const SizedBox(width: 4),
                      Text(sub, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
                ..._teachingYears.map((yr) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      Text(yr, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Quick Action: Edit Profile & Credentials
          Row(
            children: [
              Expanded(
                child: FuturisticCapsuleButton(
                  text: 'Edit Profile & Hall of Fame',
                  icon: Icons.tune_rounded,
                  accentColor: _brightCyan,
                  secondaryColor: _electricPurple,
                  height: 38,
                  fontSize: 12.5,
                  onPressed: _openProfileEditorModal,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_studentAchievements.length} Honors',
                      style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeepLinkCard(String deepLink, User user) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share this verified deep link to showcase your masterclasses & auto-enroll students worldwide:',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, size: 18, color: _brightCyan),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableText(
                    deepLink,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _brightCyan,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassmorphicScaleButton(
            pressedScale: 0.94,
            onPressed: () => _navigateToPublicShowcase(user.teacherId ?? 'TCH_123'),
            builder: (context, isPressed, isHovered) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_deepIndigo, _electricPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isHovered ? 0.35 : 0.20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _electricPurple.withValues(alpha: isHovered ? 0.45 : 0.25),
                      blurRadius: isHovered ? 16 : 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.preview_outlined, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Preview My Public Showcase',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudioActionTiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 0. Study Cohorts & Groups Studio (Hero Bento Card)
        BentoCard(
          isHero: true,
          title: 'Study Cohorts & Groups Studio (أفواج البكالوريا)',
          subtitle: 'Manage Algerian BAC & BEM student cohorts, seat capacity, monthly fees, and schedule dedicated live classes.',
          icon: Icons.groups_rounded,
          accentColor: const Color(0xFF10B981),
          secondaryAccent: _brightCyan,
          badgeText: 'COHORT ENGINE',
          badgeColor: const Color(0xFF10B981),
          onTap: _navigateToCohortStudio,
        ),

        const SizedBox(height: 14),

        // 1. Asymmetric Hero Bento Card (Wide card at top)
        BentoCard(
          isHero: true,
          title: 'Course Studio & Curriculum Builder',
          subtitle: 'Design structured curriculums, organize modular lessons, and link dynamic masterclass broadcasts.',
          icon: Icons.menu_book_rounded,
          accentColor: _electricPurple,
          secondaryAccent: _brightCyan,
          badgeText: 'PRIMARY STUDIO',
          badgeColor: _electricPurple,
          onTap: _navigateToCourseBuilder,
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
                    Icon(Icons.layers_outlined, color: _brightCyan, size: 13),
                    SizedBox(width: 5),
                    Text(
                      'Curriculum Architect Mode',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.45)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Color(0xFF10B981), size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Interactive Canvas Ready',
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
                title: 'Revenue & Payouts',
                subtitle: '80% instructor revenue split & gross sales KPIs',
                icon: Icons.account_balance_wallet_rounded,
                accentColor: _brightCyan,
                secondaryAccent: _deepIndigo,
                badgeText: '80% SPLIT',
                badgeColor: _brightCyan,
                height: 172,
                onTap: _navigateToEarnings,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BentoCard(
                title: 'Launch Live Stream',
                subtitle: 'Broadcast via LiveKit SFU (30,000 capacity)',
                icon: Icons.video_call_rounded,
                accentColor: const Color(0xFF10B981),
                secondaryAccent: _brightCyan,
                badgeText: 'SFU LIVE',
                badgeColor: const Color(0xFF10B981),
                height: 172,
                onTap: _isCreatingSession ? null : _showLaunchSessionDialog,
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
                title: 'Student Analytics',
                subtitle: 'Attendance, watch-time & real-time participation',
                icon: Icons.insights_rounded,
                accentColor: const Color(0xFFF59E0B),
                secondaryAccent: const Color(0xFFEF4444),
                badgeText: 'METRICS',
                badgeColor: const Color(0xFFF59E0B),
                height: 172,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student analytics sync in real-time with WebRTC metrics engine.'),
                      backgroundColor: _deepIndigo,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BentoCard(
                title: 'Whiteboard Studio',
                subtitle: 'Vector drawing, multi-layer canvas & tools',
                icon: Icons.draw_rounded,
                accentColor: const Color(0xFFEC4899),
                secondaryAccent: _electricPurple,
                badgeText: 'CANVAS',
                badgeColor: const Color(0xFFEC4899),
                height: 172,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Interactive Whiteboard Canvas is embedded in every live classroom.'),
                      backgroundColor: _deepIndigo,
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 3. Credentials & Student Honors Bento Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: BentoCard(
                title: 'Teacher Credentials & Degrees',
                subtitle: 'Photo, years of exp, teaching subjects & previous student honors',
                icon: Icons.workspace_premium_rounded,
                accentColor: Colors.amber,
                secondaryAccent: _brightCyan,
                badgeText: '${_studentAchievements.length} HONORS',
                badgeColor: Colors.amber,
                height: 172,
                onTap: _openProfileEditorModal,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BentoCard(
                title: 'Preview Public Showcase',
                subtitle: 'View how students and guardians experience your verified studio',
                icon: Icons.preview_rounded,
                accentColor: _brightCyan,
                secondaryAccent: _electricPurple,
                badgeText: 'PUBLIC VIEW',
                badgeColor: _brightCyan,
                height: 172,
                onTap: () => _navigateToPublicShowcase(_currentUser.teacherId ?? 'TCH_123'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
