import 'package:flutter/material.dart';
import 'package:pindo_future_mobile/core/network/api_client.dart';
import 'package:pindo_future_mobile/core/widgets/glassmorphism.dart';
import 'package:pindo_future_mobile/core/widgets/pindo_brand_logo.dart';
import 'package:pindo_future_mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pindo_future_mobile/features/auth/domain/entities/user.dart';
import 'package:pindo_future_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pindo_future_mobile/features/auth/presentation/widgets/teacher_profile_editor_modal.dart';
import 'package:pindo_future_mobile/features/auth/presentation/widgets/user_account_settings_modal.dart';
import 'package:pindo_future_mobile/features/classroom/data/datasources/classroom_remote_datasource.dart';
import 'package:pindo_future_mobile/features/classroom/data/repositories/classroom_repository_impl.dart';
import 'package:pindo_future_mobile/features/classroom/domain/usecases/get_room_token_usecase.dart';
import 'package:pindo_future_mobile/features/classroom/presentation/controllers/classroom_controller.dart';
import 'package:pindo_future_mobile/features/classroom/presentation/screens/live_classroom_screen.dart';
import 'package:pindo_future_mobile/features/classroom/services/livekit_room_service.dart';
import 'package:pindo_future_mobile/features/courses/data/datasources/course_remote_datasource.dart';
import 'package:pindo_future_mobile/features/courses/data/repositories/course_repository_impl.dart';
import 'package:pindo_future_mobile/features/courses/domain/entities/teacher_showcase_entity.dart';
import 'package:pindo_future_mobile/features/courses/presentation/controllers/course_controller.dart';
import 'package:pindo_future_mobile/features/courses/presentation/screens/teacher_course_builder_screen.dart';
import 'package:pindo_future_mobile/features/courses/presentation/screens/teacher_showcase_screen.dart';
import 'package:pindo_future_mobile/features/monetization/data/datasources/monetization_remote_datasource.dart';
import 'package:pindo_future_mobile/features/monetization/data/repositories/monetization_repository_impl.dart';
import 'package:pindo_future_mobile/features/monetization/presentation/controllers/monetization_controller.dart';
import 'package:pindo_future_mobile/features/monetization/presentation/screens/teacher_earnings_screen.dart';
import 'package:pindo_future_mobile/features/teachers/data/models/teacher_dashboard_model.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/modals/teacher_notifications_sheet.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_account_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_finance_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_groups_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_home_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/tabs/teacher_schedule_tab.dart';
import 'package:pindo_future_mobile/features/teachers/presentation/widgets/teacher_bottom_nav_bar.dart';

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
  int _currentTabIndex = 0;
  bool _isLoading = false;
  late TeacherDashboardModel _dashboard;
  late User _currentUser;

  static const Color _brightCyan = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _dashboard = TeacherDashboardModel.mockFallback(
      teacherName: widget.user.name.isNotEmpty ? widget.user.name : 'الأستاذ',
      teacherId: widget.user.teacherId ?? 'TCH_DZ_2027',
    );
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final authLocal = AuthLocalDataSourceImpl();
      final token = await authLocal.getToken();

      final response = await apiClient.get('/teacher/dashboard', token: token);
      if (response.statusCode == 200 && response.data['data'] != null) {
        if (mounted) {
          setState(() {
            _dashboard = TeacherDashboardModel.fromJson(response.data);
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {
      // Graceful fallback to mock data
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onTabSelected(int index) {
    setState(() => _currentTabIndex = index);
  }

  void _openNotificationsModal() {
    TeacherNotificationsSheet.show(context, _dashboard.notifications);
  }

  void _openProfileEditorModal() {
    TeacherProfileEditorModal.show(
      context: context,
      user: _currentUser,
      initialHeadline: _dashboard.teacherProfile.headline,
      initialBio: _currentUser.bio,
      initialAvatarUrl: _dashboard.teacherProfile.avatarUrl,
      initialExperience: _dashboard.teacherProfile.yearsOfExperience,
      initialSubjects: _dashboard.teacherProfile.subjects,
      initialYears: _currentUser.teachingYears,
      initialLevels: _dashboard.teacherProfile.levels,
      initialAchievements: const [],
      onSaveSuccess: (updatedUser, updatedAchievements) {
        setState(() {
          _currentUser = updatedUser;
        });
        _fetchDashboardData();
      },
    );
  }

  void _openSettingsModal() {
    UserAccountSettingsModal.show(
      context,
      user: _currentUser,
      authController: widget.authController,
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

  void _launchLiveSession() {
    final sessionId = _dashboard.upcomingSession?.sessionId ?? 'SES_MATH_BAC_01';
    final apiClient = ApiClient();
    final authLocalDataSource = AuthLocalDataSourceImpl();
    final classroomRemote = ClassroomRemoteDataSourceImpl(apiClient: apiClient);
    final classroomRepo = ClassroomRepositoryImpl(
      remoteDataSource: classroomRemote,
      authLocalDataSource: authLocalDataSource,
    );
    final getRoomToken = GetRoomTokenUseCase(classroomRepo);
    final livekitService = LiveKitRoomService();
    final classroomController = ClassroomController(
      getRoomTokenUseCase: getRoomToken,
      roomService: livekitService,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveClassroomScreen(
          sessionId: sessionId,
          roomTitle: _dashboard.upcomingSession?.title ?? 'حصة البث المباشر',
          controller: classroomController,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Teacher Studio — لوحة الأستاذ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          if (_isLoading)
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

          // Notifications Bell Button
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: GlassmorphicScaleButton(
              tooltip: 'الإشعارات والتنبيهات',
              onPressed: _openNotificationsModal,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white70, size: 19),
                  ),
                  if (_dashboard.notifications.any((n) => !n.isRead))
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: _brightCyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Settings Button
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: GlassmorphicScaleButton(
              tooltip: 'إعدادات الحساب',
              onPressed: _openSettingsModal,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 19),
              ),
            ),
          ),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GlassmorphicScaleButton(
              tooltip: 'تسجيل الخروج',
              onPressed: () => widget.authController.logout(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.white70, size: 19),
              ),
            ),
          ),
        ],
      ),

      // 5-Tab Body via IndexedStack
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          // 0. الرئيسية (Home)
          TeacherHomeTab(
            dashboard: _dashboard,
            onStartLiveSession: _launchLiveSession,
            onNavigateToTab: _onTabSelected,
          ),

          // 1. أفواجي (Groups Management)
          TeacherGroupsTab(
            cohorts: _dashboard.cohorts,
          ),

          // 2. الجدول (Schedule & Broadcasts)
          TeacherScheduleTab(
            schedule: _dashboard.todaySchedule,
            cohorts: _dashboard.cohorts,
            onStartLiveSession: _launchLiveSession,
          ),

          // 3. المداخيل (Finance & Payouts)
          TeacherFinanceTab(
            dashboard: _dashboard,
            onOpenDetailedEarnings: _navigateToEarnings,
          ),

          // 4. حسابي (My Account & External Platforms)
          TeacherAccountTab(
            dashboard: _dashboard,
            onEditProfile: _openProfileEditorModal,
            onOpenAccountSettings: _openSettingsModal,
            onSignOut: () => widget.authController.logout(),
            onPreviewShowcase: () => _navigateToPublicShowcase(_currentUser.teacherId ?? 'TCH_123'),
          ),
        ],
      ),

      // Floating Glassmorphic 5-Tab Navigation Bar
      bottomNavigationBar: TeacherBottomNavBar(
        currentIndex: _currentTabIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}
