import 'package:flutter/material.dart';
import '../../../../../core/network/api_client.dart';
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
import '../../../../cohorts/data/datasources/cohort_remote_datasource.dart';
import '../../../../cohorts/data/repositories/cohort_repository_impl.dart';
import '../../../../cohorts/presentation/controllers/cohort_controller.dart';
import '../../../../cohorts/presentation/screens/student_cohort_explorer_screen.dart';
import '../../../../courses/data/datasources/course_remote_datasource.dart';
import '../../../../courses/data/repositories/course_repository_impl.dart';
import '../../../../courses/presentation/controllers/course_controller.dart';
import '../../../../courses/presentation/screens/teacher_showcase_screen.dart';
import '../../../../exams/data/datasources/exam_remote_datasource.dart';
import '../../../../exams/data/repositories/exam_bank_repository_impl.dart';
import '../../../../exams/presentation/controllers/exam_bank_controller.dart';
import '../../../../exams/presentation/screens/exam_bank_explorer_screen.dart';
import '../../../../library/presentation/screens/protected_recording_player_screen.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../domain/entities/user.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/user_account_settings_modal.dart';
import 'package:pindo_future_mobile/features/student/data/models/student_dashboard_model.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/student_bottom_nav_bar.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/tabs/student_home_tab.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/tabs/student_explore_tab.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/tabs/student_my_classes_tab.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/tabs/student_library_tab.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/tabs/student_my_account_tab.dart';
import 'package:pindo_future_mobile/features/student/presentation/widgets/modals/student_notifications_sheet.dart';

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
  int _currentTabIndex = 0;
  late StudentDashboardData _dashboardData;
  bool _isLoading = false;

  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _dashboardData = StudentDashboardData.fallback(widget.user.name, widget.user.email);
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get('/student/dashboard');
      if (response.statusCode == 200 && response.data != null && response.data['data'] != null) {
        if (mounted) {
          setState(() {
            _dashboardData = StudentDashboardData.fromJson(response.data['data'] as Map<String, dynamic>);
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
      // Graceful fallback to guaranteed pre-seeded data
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _joinClassroom(String sessionId) {
    final cleanId = sessionId.trim();
    if (cleanId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال رمز حصة صالح (مثل SES_XXXX)'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final remoteDataSource = ClassroomRemoteDataSourceImpl(apiClient: _apiClient);
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final repository = ClassroomRepositoryImpl(
      remoteDataSource: remoteDataSource,
      authLocalDataSource: authLocalDataSource,
    );
    final getRoomTokenUseCase = GetRoomTokenUseCase(repository);
    final roomService = LiveKitRoomService();
    final whiteboardRemoteDataSource = WhiteboardRemoteDataSourceImpl(apiClient: _apiClient);
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

  void _navigateToCohortExplorer() {
    final remoteDataSource = CohortRemoteDataSourceImpl(apiClient: _apiClient);
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

  void _navigateToTeacherShowcase(String teacherId) {
    final cleanId = teacherId.trim();
    if (cleanId.isEmpty) return;

    final authLocalDataSource = AuthLocalDataSourceImpl();
    final remoteDataSource = CourseRemoteDataSourceImpl(apiClient: _apiClient);
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

  void _navigateToExamBank() async {
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final token = await authLocalDataSource.getToken();
    final remoteDataSource = ExamRemoteDataSourceImpl(apiClient: _apiClient);
    final repository = ExamBankRepositoryImpl(remoteDataSource: remoteDataSource);
    final controller = ExamBankController(repository: repository, userToken: token);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExamBankExplorerScreen(controller: controller),
      ),
    );
  }

  void _openProtectedRecording(int recordingId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProtectedRecordingPlayerScreen(
          title: 'تسجيل الحصة التفاعلية المحمية',
          description: 'حصة دراسية مباشرة تم بثها عبر Pindo Future SFU مع العلامة المائية الرقمية.',
          streamUrl: 'https://pindofuture-production.up.railway.app/api/v1/student/recordings/$recordingId/stream',
          watermarkText: '${widget.user.name} • ${widget.user.email}',
        ),
      ),
    );
  }

  String _tabTitle(int index) {
    switch (index) {
      case 0:
        return 'مركز التلميذ • الرئيسية';
      case 1:
        return 'اكتشف الأساتذة والأفواج';
      case 2:
        return 'حصصي والبرنامج الدراسي';
      case 3:
        return 'مكتبتي المحمية';
      case 4:
        return 'حسابي والاشتراكات';
      default:
        return 'Pindo Future';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.90),
        elevation: 0,
        title: Row(
          children: [
            const PindoBrandLogo(size: 26, showText: false, withGlow: true),
            const SizedBox(width: 10),
            Text(
              _tabTitle(_currentTabIndex),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.5,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الإشعارات والتنبيهات',
            icon: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 21),
            onPressed: () => StudentNotificationsSheet.show(context, _dashboardData.notifications),
          ),
          IconButton(
            tooltip: 'الإعدادات والأمان',
            icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 20),
            onPressed: () => UserAccountSettingsModal.show(
              context,
              user: widget.user,
              authController: widget.authController,
            ),
          ),
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout, color: Colors.white70, size: 19),
            onPressed: () => widget.authController.logout(),
          ),
        ],
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTabIndex,
            children: [
              // Tab 0: الرئيسية (Home)
              StudentHomeTab(
                dashboardData: _dashboardData,
                onRefresh: _loadDashboardData,
                onJoinLiveClassroom: _joinClassroom,
                onOpenRecording: _openProtectedRecording,
                onOpenExamBank: _navigateToExamBank,
                onOpenWeeklySchedule: () => setState(() => _currentTabIndex = 2),
                onManageSubscriptions: () => setState(() => _currentTabIndex = 4),
                onOpenAccountSettings: () => UserAccountSettingsModal.show(
                  context,
                  user: widget.user,
                  authController: widget.authController,
                ),
              ),

              // Tab 1: اكتشف (Explore)
              StudentExploreTab(
                onOpenTeacherShowcase: _navigateToTeacherShowcase,
                onJoinLiveClassroom: _joinClassroom,
                onOpenCohortsExplorer: _navigateToCohortExplorer,
              ),

              // Tab 2: حصصي (My Classes)
              StudentMyClassesTab(
                dashboardData: _dashboardData,
                onJoinLiveClassroom: _joinClassroom,
                onOpenCohortsExplorer: _navigateToCohortExplorer,
              ),

              // Tab 3: مكتبتي (My Library)
              StudentLibraryTab(
                dashboardData: _dashboardData,
                onOpenRecording: _openProtectedRecording,
              ),

              // Tab 4: حسابي (My Account)
              StudentMyAccountTab(
                dashboardData: _dashboardData,
                onOpenAccountSettings: () => UserAccountSettingsModal.show(
                  context,
                  user: widget.user,
                  authController: widget.authController,
                ),
                onLogout: () => widget.authController.logout(),
              ),
            ],
          ),

          // Floating 5-Tab Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StudentBottomNavBar(
              currentIndex: _currentTabIndex,
              onTap: (index) => setState(() => _currentTabIndex = index),
              unreadNotificationsCount: _dashboardData.notifications.where((n) => !n.isRead).length,
            ),
          ),
        ],
      ),
    );
  }
}
