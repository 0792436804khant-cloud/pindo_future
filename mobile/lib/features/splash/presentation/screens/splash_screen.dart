import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/dashboards/admin_dashboard_screen.dart';
import '../../../auth/presentation/screens/dashboards/parent_dashboard_screen.dart';
import '../../../auth/presentation/screens/dashboards/student_dashboard_screen.dart';
import '../../../auth/presentation/screens/dashboards/teacher_dashboard_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  final AuthController authController;

  final VoidCallback? onFinished;

  const SplashScreen({
    super.key,
    required this.authController,
    this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScaleAnimation;
  late Animation<double> _glowAnimation;

  late AnimationController _contentFadeController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  late AnimationController _progressController;

  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // 1. Breathing / Pulsing Logo Animation (repeats smoothly)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _pulseScaleAnimation = Tween<double>(begin: 0.94, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _glowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // 2. Text and Subtitle Fade-In Entrance
    _contentFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentFadeController, curve: Curves.easeOut),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _contentFadeController, curve: Curves.easeOutCubic),
    );

    // 3. Shimmering Progress Bar
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    _contentFadeController.forward();
    _progressController.forward();

    // 4. Trigger Seamless Transition after boot animation
    _scheduleTransition();
  }

  void _scheduleTransition() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted || _isNavigating) return;

    setState(() => _isNavigating = true);

    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }

    final destination = _resolveDestination();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 750),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  Widget _resolveDestination() {
    final controller = widget.authController;

    if (controller.isAuthenticated && controller.currentUser != null) {
      final user = controller.currentUser!;
      switch (user.role) {
        case UserRole.admin:
          return AdminDashboardScreen(user: user, authController: controller);
        case UserRole.teacher:
          return TeacherDashboardScreen(user: user, authController: controller);
        case UserRole.student:
          return StudentDashboardScreen(user: user, authController: controller);
        case UserRole.parent:
          return ParentDashboardScreen(user: user, authController: controller);
      }
    }

    return LoginScreen(authController: controller);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _contentFadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070B14), // Deep Cosmic Midnight
      body: Stack(
        children: [
          // 1. Ambient Background Gradient & Cosmic Glow
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.15),
                  radius: 1.2,
                  colors: [
                    Color(0xFF1E1B4B), // Cosmic Indigo
                    Color(0xFF0F172A), // Slate Navy
                    Color(0xFF070B14), // Midnight Black
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // 2. Animated Ambient Mesh Glow Orbs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                final pulse = _pulseController.value;
                return CustomPaint(
                  painter: _SplashGlowPainter(pulse: pulse),
                );
              },
            ),
          ),

          // 3. Central Brand Stage
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Breathing Animated Logo
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final scale = _pulseScaleAnimation.value;
                    final glow = _glowAnimation.value;

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2DD4BF).withValues(alpha: 0.35 * glow),
                              blurRadius: 40 * glow,
                              spreadRadius: 8 * glow,
                            ),
                            BoxShadow(
                              color: const Color(0xFF6366F1).withValues(alpha: 0.45 * glow),
                              blurRadius: 60 * glow,
                              spreadRadius: 12 * glow,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'pindo_brand_logo_hero',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF0D9488), // Brand Teal
                                  Color(0xFF4F46E5), // Electric Indigo
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.40),
                                width: 2.0,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/pindo_logo_badge.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Icon(
                                      Icons.school,
                                      size: 58,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 36),

                // Slide & Fade Typography
                SlideTransition(
                  position: _contentSlideAnimation,
                  child: FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Title
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              fontFamily: 'Roboto',
                            ),
                            children: [
                              TextSpan(
                                text: 'Pindo ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: 'Future',
                                style: TextStyle(
                                  color: Color(0xFF2DD4BF), // Glowing Cyan Teal
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tagline Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.14),
                            ),
                          ),
                          child: const Text(
                            'Next-Gen Livestreaming & Learning Engine',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Futuristic Status & Progress Indicator
          Positioned(
            bottom: 42,
            left: 24,
            right: 24,
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Glowing Futuristic Progress Bar
                  SizedBox(
                    width: 180,
                    child: AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, _) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            backgroundColor: Colors.white.withValues(alpha: 0.08),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2DD4BF)),
                            minHeight: 3.0,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 12, color: Color(0xFF10B981)),
                      SizedBox(width: 6),
                      Text(
                        'Zero-Trust Sanctum Security • WebRTC Live SFU Gateway',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
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
    );
  }
}

class _SplashGlowPainter extends CustomPainter {
  final double pulse;

  _SplashGlowPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    // Breathing Center Aura
    final centerAura = Paint()
      ..color = const Color(0xFF0D9488).withValues(alpha: 0.16 + (pulse * 0.08))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.42),
      size.width * 0.35 * (0.95 + (pulse * 0.15)),
      centerAura,
    );

    // Deep Indigo Ambient
    final indigoAura = Paint()
      ..color = const Color(0xFF4F46E5).withValues(alpha: 0.12 + ((1.0 - pulse) * 0.06))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 130);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.40),
      size.width * 0.45,
      indigoAura,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashGlowPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}
