import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/widgets/bento_card.dart';
import '../../../../../core/widgets/glassmorphism.dart';
import '../../../../../core/widgets/pindo_brand_logo.dart';
import '../../../domain/entities/user.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/user_account_settings_modal.dart';

class AdminDashboardScreen extends StatelessWidget {
  final User user;
  final AuthController authController;

  static const Color _bgDark = Color(0xFF070B14);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _neonGreen = Color(0xFF10B981);

  const AdminDashboardScreen({
    super.key,
    required this.user,
    required this.authController,
  });

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
              'Admin Command Center',
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
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            tooltip: 'Settings & Security',
            onPressed: () => UserAccountSettingsModal.show(
              context,
              user: user,
              authController: authController,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: () => authController.logout(),
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
              width: 300,
              height: 300,
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
            bottom: 60,
            left: -80,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Executive Admin Profile Banner
                  GlassmorphicContainer(
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
                    child: Row(
                      children: [
                        const BentoIconAura(
                          icon: Icons.admin_panel_settings_rounded,
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
                                    user.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const FuturisticGlowBadge(
                                    label: 'ROOT ADMIN',
                                    color: Color(0xFFF59E0B),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Full System Permissions • WebRTC SFU Cluster Supervisor',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.06, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 24),

                  // 2. Section Title
                  const Row(
                    children: [
                      BentoIconAura(
                        icon: Icons.dashboard_customize_rounded,
                        color: _brightCyan,
                        size: 18,
                        padding: 6,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Platform Administration Modules',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Bento Box Modules Grid
                  BentoCard(
                    isHero: true,
                    title: '30,000 Capacity Monitoring',
                    subtitle: 'Live WebRTC SFU cluster status, autoscaling nodes & health telemetry',
                    icon: Icons.speed_rounded,
                    accentColor: _brightCyan,
                    secondaryAccent: _electricPurple,
                    badgeText: '99.98% OPERATIONAL',
                    badgeColor: _neonGreen,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SFU Cluster telemetry: 30,000 peak stream channels ready.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(duration: 450.ms, delay: 100.ms)
                      .slideY(begin: 0.05, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: BentoCard(
                          title: 'User & Role Access',
                          subtitle: 'Supervise teachers, students, parents & RBAC access',
                          icon: Icons.people_alt_rounded,
                          accentColor: _electricPurple,
                          secondaryAccent: _brightCyan,
                          badgeText: 'USERS',
                          badgeColor: _electricPurple,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening user management roster...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: BentoCard(
                          title: 'Teacher Link Tracking',
                          subtitle: 'Audit deep links, referrals and 80% revenue share',
                          icon: Icons.link_rounded,
                          accentColor: _neonGreen,
                          secondaryAccent: _brightCyan,
                          badgeText: 'REVENUE',
                          badgeColor: _neonGreen,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Teacher revenue conversion tracking active.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 450.ms, delay: 160.ms)
                      .slideY(begin: 0.05, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 14),

                  BentoCard(
                    title: 'Global Security & Audit Trail',
                    subtitle: 'Authentication token validity, active sessions & security logs',
                    icon: Icons.security_rounded,
                    accentColor: const Color(0xFF38BDF8),
                    secondaryAccent: _deepIndigo,
                    badgeText: 'AUDIT',
                    badgeColor: const Color(0xFF38BDF8),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All platform security checks passing.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(duration: 450.ms, delay: 200.ms)
                      .slideY(begin: 0.05, end: 0, duration: 450.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
