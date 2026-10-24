import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/network/api_client.dart';
import '../../../../../core/utils/course_visual_helper.dart';
import '../../../../../core/widgets/bento_card.dart';
import '../../../../../core/widgets/glassmorphism.dart';
import '../../../../../core/widgets/pindo_brand_logo.dart';
import '../../../../auth/data/datasources/auth_local_datasource.dart';
import '../../../../auth/domain/entities/user.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../widgets/user_account_settings_modal.dart';
import '../../../../courses/data/datasources/course_remote_datasource.dart';
import '../../../../courses/data/repositories/course_repository_impl.dart';
import '../../../../courses/presentation/controllers/course_controller.dart';
import '../../../../courses/presentation/screens/teacher_showcase_screen.dart';
import '../../../../courses/presentation/widgets/academic_explorer_widget.dart';
import '../../../../parent/data/datasources/parent_remote_datasource.dart';
import '../../../../parent/data/repositories/parent_repository_impl.dart';
import '../../../../parent/domain/entities/child_overview_entity.dart';
import '../../../../parent/presentation/controllers/parent_controller.dart';

class ParentDashboardScreen extends StatefulWidget {
  final User user;
  final AuthController authController;

  const ParentDashboardScreen({
    super.key,
    required this.user,
    required this.authController,
  });

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  ParentController? _parentController;
  bool _isInitializing = true;

  static const Color _bgDark = Color(0xFF070B14);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _neonGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      final authLocalDataSource = AuthLocalDataSourceImpl();
      final token = await authLocalDataSource.getToken() ?? '';

      final apiClient = ApiClient();
      final remoteDataSource = ParentRemoteDataSourceImpl(apiClient: apiClient);
      final repository = ParentRepositoryImpl(remoteDataSource: remoteDataSource);

      final controller = ParentController(
        repository: repository,
        authToken: token,
      );

      await controller.loadChildren();

      if (mounted) {
        setState(() {
          _parentController = controller;
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || _parentController == null) {
      return const Scaffold(
        backgroundColor: _bgDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _brightCyan),
              SizedBox(height: 16),
              Text(
                'Connecting to Guardian Oversight Portal...',
                style: TextStyle(color: Colors.white70, fontSize: 13.5),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _parentController!,
      builder: (context, _) {
        final ctrl = _parentController!;
        final selectedChild = ctrl.selectedChild;

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
            title: Row(
              children: [
                const PindoBrandLogo(size: 26, showText: false, withGlow: true),
                const SizedBox(width: 10),
                Text(
                  'Guardian Portal • ${widget.user.name}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: _brightCyan),
                tooltip: 'Refresh Portal Data',
                onPressed: () => ctrl.loadChildren(),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                tooltip: 'Settings & Security',
                onPressed: () => UserAccountSettingsModal.show(
                  context,
                  user: widget.user,
                  authController: widget.authController,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                tooltip: 'Sign Out',
                onPressed: () => widget.authController.logout(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              // Background ambient glowing orbs
              Positioned(
                top: 20,
                right: -60,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _deepIndigo.withValues(alpha: 0.40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -70,
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

              SafeArea(
                child: ctrl.isLoading
                    ? const Center(child: CircularProgressIndicator(color: _brightCyan))
                    : RefreshIndicator(
                        color: _brightCyan,
                        backgroundColor: const Color(0xFF0F172A),
                        onRefresh: () => ctrl.loadChildren(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildParentHeader(ctrl)
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideY(begin: -0.06, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                              const SizedBox(height: 18),

                              _buildChildSelectorBar(ctrl)
                                  .animate()
                                  .fadeIn(duration: 350.ms, delay: 60.ms),
                              const SizedBox(height: 18),

                              if (ctrl.errorMessage != null) ...[
                                _buildAlertBanner(ctrl.errorMessage!, isError: true, onDismiss: ctrl.clearMessages),
                                const SizedBox(height: 12),
                              ],
                              if (ctrl.successMessage != null) ...[
                                _buildAlertBanner(ctrl.successMessage!, isError: false, onDismiss: ctrl.clearMessages),
                                const SizedBox(height: 12),
                              ],

                              if (selectedChild == null) ...[
                                _buildEmptyChildrenState(ctrl),
                              ] else ...[
                                _buildKpiOverview(selectedChild)
                                    .animate()
                                    .fadeIn(duration: 450.ms, delay: 100.ms)
                                    .slideY(begin: 0.05, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
                                const SizedBox(height: 22),

                                _buildTabBar(ctrl)
                                    .animate()
                                    .fadeIn(duration: 350.ms, delay: 160.ms),
                                const SizedBox(height: 16),

                                _buildTabContent(ctrl, selectedChild),
                              ],

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // Header Card
  // ==========================================
  Widget _buildParentHeader(ParentController ctrl) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(24),
      borderColor: _brightCyan.withValues(alpha: 0.35),
      padding: const EdgeInsets.all(22),
      gradient: LinearGradient(
        colors: [
          _deepIndigo.withValues(alpha: 0.70),
          _electricPurple.withValues(alpha: 0.35),
          const Color(0xFF0F172A).withValues(alpha: 0.85),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 620;

          final guardianInfo = Row(
            children: [
              const BentoIconAura(
                icon: Icons.shield_rounded,
                color: _brightCyan,
                size: 32,
                padding: 14,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const FuturisticGlowBadge(
                          label: 'GUARDIAN',
                          color: _brightCyan,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.email,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${ctrl.children.length} Student${ctrl.children.length == 1 ? '' : 's'} Linked for Oversight',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 11.5),
                    ),
                  ],
                ),
              ),
            ],
          );

          final linkButton = FuturisticCapsuleButton(
            text: 'Link Child',
            icon: Icons.person_add_rounded,
            height: 42,
            accentColor: _brightCyan,
            secondaryColor: _electricPurple,
            onPressed: () => _showLinkChildDialog(ctrl),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                guardianInfo,
                const SizedBox(height: 16),
                linkButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: guardianInfo),
              const SizedBox(width: 16),
              linkButton,
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // Child Selector Bar
  // ==========================================
  Widget _buildChildSelectorBar(ParentController ctrl) {
    if (ctrl.children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Student for Oversight:',
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ctrl.children.map((child) {
              final isSelected = ctrl.selectedChild?.id == child.id;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GlassmorphicScaleButton(
                  onPressed: () => ctrl.selectChild(child),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _brightCyan.withValues(alpha: 0.22)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? _brightCyan.withValues(alpha: 0.65)
                            : Colors.white.withValues(alpha: 0.12),
                        width: isSelected ? 1.4 : 1.0,
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
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: isSelected ? _brightCyan : _electricPurple,
                          child: Text(
                            child.name.isNotEmpty ? child.name[0].toUpperCase() : 'S',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black87 : Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${child.name} • ${child.relationship}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Executive KPI Stat Cards
  // ==========================================
  Widget _buildKpiOverview(ChildOverviewEntity child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 650;

        final kpis = [
          _buildKpiCard(
            title: 'Academic Progress',
            primaryValue: '${child.averageProgress.toStringAsFixed(1)}%',
            subtitle: '${child.completedCoursesCount} of ${child.enrolledCoursesCount} Completed',
            icon: Icons.school_rounded,
            color: _brightCyan,
            progress: child.averageProgress / 100,
          ),
          _buildKpiCard(
            title: 'Live Watch-Time',
            primaryValue: '${child.totalWatchMinutes.toStringAsFixed(0)} mins',
            subtitle: '${child.sessionsAttendedCount} Sessions Attended',
            icon: Icons.access_time_filled_rounded,
            color: _electricPurple,
            progress: (child.totalWatchMinutes / 120).clamp(0.0, 1.0),
          ),
          _buildKpiCard(
            title: 'Instructor Notes',
            primaryValue: '${child.notesCount}',
            subtitle: child.notesCount > 0 ? 'Feedback & Inquiries' : 'No Pending Alerts',
            icon: Icons.mark_email_unread_rounded,
            color: const Color(0xFFF59E0B),
            badge: child.notesCount > 0 ? '${child.notesCount} Note' : null,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: kpis
                .map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: card,
                    ))
                .toList(),
          );
        }

        return Row(
          children: kpis
              .map((card) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: card,
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String primaryValue,
    required String subtitle,
    required IconData icon,
    required Color color,
    double? progress,
    String? badge,
  }) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(20),
      borderColor: color.withValues(alpha: 0.30),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              BentoIconAura(
                icon: icon,
                color: color,
                size: 18,
                padding: 8,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                primaryValue,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 8),
                FuturisticGlowBadge(
                  label: badge,
                  color: color,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11.5, color: Colors.white.withValues(alpha: 0.55)),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // Tab Bar
  // ==========================================
  Widget _buildTabBar(ParentController ctrl) {
    final tabs = [
      {'title': 'Academics', 'icon': Icons.school_rounded},
      {'title': 'Attendance', 'icon': Icons.access_time_filled_rounded},
      {'title': 'Schedule', 'icon': Icons.calendar_month_rounded},
      {'title': 'Notes', 'icon': Icons.forum_rounded},
      {'title': 'Instructors', 'icon': Icons.hub_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = ctrl.activeTabIndex == index;

          return Expanded(
            child: GlassmorphicScaleButton(
              onPressed: () => ctrl.setActiveTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            _brightCyan.withValues(alpha: 0.25),
                            _electricPurple.withValues(alpha: 0.25),
                          ],
                        )
                      : null,
                  border: isSelected
                      ? Border.all(color: _brightCyan.withValues(alpha: 0.60), width: 1.2)
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 16,
                      color: isSelected ? _brightCyan : Colors.white60,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tab['title'] as String,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.white60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================
  // Tab Content Switcher
  // ==========================================
  Widget _buildTabContent(ParentController ctrl, ChildOverviewEntity child) {
    switch (ctrl.activeTabIndex) {
      case 0:
        return _buildAcademicsTab(ctrl);
      case 1:
        return _buildAttendanceTab(ctrl);
      case 2:
        return _buildScheduleTab(ctrl);
      case 3:
        return _buildNotesTab(ctrl, child);
      case 4:
        return AcademicExplorerWidget(
          onOpenTeacherShowcase: _navigateToTeacherShowcase,
        );
      default:
        return _buildAcademicsTab(ctrl);
    }
  }

  // ------------------------------------------
  // Tab 0: Academics & Courses
  // ------------------------------------------
  Widget _buildAcademicsTab(ParentController ctrl) {
    if (ctrl.academics.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.school_outlined,
        title: 'No Course Enrollments Found',
        message: 'This student has not enrolled in any masterclasses yet.',
      );
    }

    return Column(
      children: ctrl.academics.map((course) {
        final gradient = LinearGradient(
          colors: CourseVisualHelper.getGradientForCategory(course.category),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
        final isCompleted = course.progressPercentage >= 100;

        return GlassmorphicContainer(
          borderRadius: BorderRadius.circular(20),
          borderColor: isCompleted ? _neonGreen.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.12),
          margin: const EdgeInsets.only(bottom: 14),
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FuturisticGlowBadge(
                      label: course.category.toUpperCase(),
                      color: Colors.white,
                    ),
                    FuturisticGlowBadge(
                      label: isCompleted ? '✓ Completed' : '${course.progressPercentage}% Progress',
                      color: isCompleted ? _neonGreen : Colors.white,
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: _brightCyan),
                        const SizedBox(width: 4),
                        Text(
                          course.teacherName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${course.completedLessons} of ${course.totalLessons} Lessons',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _brightCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: course.progressPercentage / 100,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? _neonGreen : _brightCyan,
                        ),
                        minHeight: 7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ------------------------------------------
  // Tab 1: Attendance & Watch-Time
  // ------------------------------------------
  Widget _buildAttendanceTab(ParentController ctrl) {
    if (ctrl.attendanceRecords.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.timer_off_outlined,
        title: 'No Live Attendance Records',
        message: 'No recorded attendance for live masterclasses yet.',
      );
    }

    final summary = ctrl.attendanceSummary;
    final totalHours = (summary['total_watch_hours'] as num?)?.toDouble() ?? 0.0;
    final totalMins = (summary['total_watch_minutes'] as num?)?.toDouble() ?? 0.0;
    final totalSessions = summary['total_sessions_attended'] as int? ?? 0;

    return Column(
      children: [
        // Summary Header
        GlassmorphicContainer(
          borderRadius: BorderRadius.circular(18),
          borderColor: _brightCyan.withValues(alpha: 0.30),
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttendanceMetric('Total Sessions', '$totalSessions', _brightCyan),
              Container(height: 32, width: 1, color: Colors.white.withValues(alpha: 0.15)),
              _buildAttendanceMetric('Watch-Time', '${totalMins.toStringAsFixed(0)}m', _electricPurple),
              Container(height: 32, width: 1, color: Colors.white.withValues(alpha: 0.15)),
              _buildAttendanceMetric('Hours', '${totalHours.toStringAsFixed(1)}h', _neonGreen),
            ],
          ),
        ),
        // Records List
        ...ctrl.attendanceRecords.map((att) {
          return GlassmorphicContainer(
            borderRadius: BorderRadius.circular(16),
            borderColor: Colors.white.withValues(alpha: 0.12),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const BentoIconAura(
                  icon: Icons.live_tv_rounded,
                  color: _electricPurple,
                  size: 20,
                  padding: 10,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        att.sessionTitle,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Session: ${att.sessionId}',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.55)),
                      ),
                      if (att.joinedAt != null)
                        Text(
                          'Joined: ${att.joinedAt!.split('T').first}',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45)),
                        ),
                    ],
                  ),
                ),
                FuturisticGlowBadge(
                  label: '${att.durationMinutes.toStringAsFixed(0)} mins',
                  color: _brightCyan,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAttendanceMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.65)),
        ),
      ],
    );
  }

  // ------------------------------------------
  // Tab 2: Masterclass Schedule
  // ------------------------------------------
  Widget _buildScheduleTab(ParentController ctrl) {
    if (ctrl.schedule.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.calendar_today_outlined,
        title: 'No Upcoming Classroom Sessions',
        message: 'No live sessions currently scheduled for this curriculum.',
      );
    }

    return Column(
      children: ctrl.schedule.map((session) {
        return GlassmorphicContainer(
          borderRadius: BorderRadius.circular(16),
          borderColor: session.isLive ? const Color(0xFFEF4444).withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.12),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              BentoIconAura(
                icon: session.isLive ? Icons.sensors : Icons.schedule,
                color: session.isLive ? const Color(0xFFEF4444) : Colors.white70,
                size: 20,
                padding: 10,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (session.isLive)
                          const FuturisticGlowBadge(
                            label: 'LIVE NOW',
                            color: Color(0xFFEF4444),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Course: ${session.courseTitle}',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.65)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Instructor: ${session.teacherName} • Session: ${session.sessionId}',
                      style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.45)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ------------------------------------------
  // Tab 3: Guardian Notes & Feedback
  // ------------------------------------------
  Widget _buildNotesTab(ParentController ctrl, ChildOverviewEntity child) {
    return Column(
      children: [
        // Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Instructor Commendations & Alerts',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            FuturisticCapsuleButton(
              text: 'New Inquiry',
              icon: Icons.add_comment_rounded,
              height: 38,
              fontSize: 12,
              accentColor: _brightCyan,
              secondaryColor: _electricPurple,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              onPressed: () => _showSendNoteDialog(ctrl, child),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (ctrl.notes.isEmpty)
          _buildEmptyTab(
            icon: Icons.chat_bubble_outline,
            title: 'No Guardian Notes Yet',
            message: 'You can submit an inquiry or question to course instructors above.',
          )
        else
          ...ctrl.notes.map((note) {
            final isAlert = note.type == 'attendance_alert';
            final isReport = note.type == 'progress_report';

            Color bannerColor = _brightCyan;
            if (isAlert) bannerColor = const Color(0xFFEF4444);
            if (isReport) bannerColor = _neonGreen;

            return GlassmorphicContainer(
              borderRadius: BorderRadius.circular(18),
              borderColor: bannerColor.withValues(alpha: 0.30),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      FuturisticGlowBadge(
                        label: note.type.toUpperCase().replaceAll('_', ' '),
                        color: bannerColor,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (!note.isAcknowledged)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: _brightCyan,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Acknowledge', style: TextStyle(fontSize: 12)),
                          onPressed: () => ctrl.acknowledgeNote(note.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    note.content,
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8), height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 13, color: Colors.white.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text(
                        '${note.authorName} (${note.authorRole})',
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
                      ),
                      const Spacer(),
                      Text(
                        note.createdAt.split('T').first,
                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // ==========================================
  // Empty State
  // ==========================================
  Widget _buildEmptyChildrenState(ParentController ctrl) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(36),
      child: Column(
        children: [
          const BentoIconAura(
            icon: Icons.group_add_rounded,
            color: _brightCyan,
            size: 40,
            padding: 16,
          ),
          const SizedBox(height: 18),
          const Text(
            'No Student Accounts Linked',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect your child or student account to view real-time learning progress, live classroom attendance, and instructor commendations.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 22),
          FuturisticCapsuleButton(
            text: 'Link Student Account',
            icon: Icons.person_add_rounded,
            accentColor: _brightCyan,
            secondaryColor: _electricPurple,
            onPressed: () => _showLinkChildDialog(ctrl),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(20),
      borderColor: Colors.white.withValues(alpha: 0.12),
      padding: const EdgeInsets.all(36),
      child: Center(
        child: Column(
          children: [
            BentoIconAura(
              icon: icon,
              color: Colors.white38,
              size: 32,
              padding: 14,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.65)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertBanner(String message, {required bool isError, required VoidCallback onDismiss}) {
    final alertColor = isError ? const Color(0xFFEF4444) : _neonGreen;

    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(14),
      borderColor: alertColor.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      gradient: LinearGradient(
        colors: [
          alertColor.withValues(alpha: 0.18),
          alertColor.withValues(alpha: 0.06),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: alertColor,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: Colors.white54),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Dialog: Link Child
  // ==========================================
  void _showLinkChildDialog(ParentController ctrl) {
    final emailController = TextEditingController();
    final relationshipController = TextEditingController(text: 'Parent');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: GlassmorphicContainer(
            borderRadius: BorderRadius.circular(24),
            borderColor: _brightCyan.withValues(alpha: 0.35),
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BentoIconAura(
                        icon: Icons.person_add_rounded,
                        color: _brightCyan,
                        size: 22,
                        padding: 10,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Link Student Account',
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
                    'Enter your student\'s registered email address on Pindo Future to link their progress:',
                    style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: 'Student Email Address',
                      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      hintText: 'e.g. student.demo@pindofuture.com',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                      prefixIcon: const Icon(Icons.email_outlined, color: _brightCyan, size: 20),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _brightCyan, width: 1.5),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Student email is required';
                      if (!val.contains('@')) return 'Enter a valid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: relationshipController,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: InputDecoration(
                      labelText: 'Your Relationship',
                      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      hintText: 'e.g. Mother, Father, Guardian',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                      prefixIcon: const Icon(Icons.family_restroom_outlined, color: _electricPurple, size: 20),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _electricPurple, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
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
                          text: 'Link Account',
                          icon: Icons.link_rounded,
                          height: 42,
                          accentColor: _brightCyan,
                          secondaryColor: _electricPurple,
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.of(ctx).pop();
                              await ctrl.linkChild(
                                email: emailController.text.trim(),
                                relationship: relationshipController.text.trim(),
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

  // ==========================================
  // Dialog: Send Note / Inquiry
  // ==========================================
  void _showSendNoteDialog(ParentController ctrl, ChildOverviewEntity child) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedType = 'general';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: GlassmorphicContainer(
              borderRadius: BorderRadius.circular(24),
              borderColor: _electricPurple.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const BentoIconAura(
                            icon: Icons.forum_rounded,
                            color: _electricPurple,
                            size: 22,
                            padding: 10,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Inquiry for ${child.name}',
                              style: const TextStyle(
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
                      const SizedBox(height: 12),
                      Text(
                        'Direct communication with instructors and academic mentors:',
                        style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.7)),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedType,
                            dropdownColor: const Color(0xFF0F172A),
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            icon: const Icon(Icons.keyboard_arrow_down, color: _brightCyan),
                            items: const [
                              DropdownMenuItem(value: 'general', child: Text('General Inquiry')),
                              DropdownMenuItem(value: 'progress_report', child: Text('Academic Progress Question')),
                              DropdownMenuItem(value: 'attendance_alert', child: Text('Attendance Notice')),
                            ],
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedType = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: titleController,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        decoration: InputDecoration(
                          labelText: 'Subject / Title',
                          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: _brightCyan, width: 1.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Subject title is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: contentController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        decoration: InputDecoration(
                          labelText: 'Message Body',
                          labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: _electricPurple, width: 1.5),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Message body is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 22),
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
                              text: 'Send Message',
                              icon: Icons.send_rounded,
                              height: 42,
                              accentColor: _brightCyan,
                              secondaryColor: _electricPurple,
                              onPressed: () async {
                                if (formKey.currentState?.validate() ?? false) {
                                  Navigator.of(ctx).pop();
                                  await ctrl.sendNote(
                                    title: titleController.text.trim(),
                                    content: contentController.text.trim(),
                                    type: selectedType,
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
        ),
      ),
    );
  }
}
