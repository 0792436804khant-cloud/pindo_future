import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controller.dart';
import '../widgets/privacy_policy_modal.dart';
import '../../../../core/widgets/glassmorphism.dart';

class LoginScreen extends StatefulWidget {
  final AuthController authController;

  const LoginScreen({
    super.key,
    required this.authController,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _signInFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Sign In Controllers
  final _loginEmailController = TextEditingController(text: 'teacher.demo@pindofuture.com');
  final _loginPasswordController = TextEditingController(text: 'TeacherPassword123!');
  bool _loginObscurePassword = true;

  // Register Controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerTeacherIdController = TextEditingController();
  final _registerStudentIdController = TextEditingController();
  final _registerSubjectsController = TextEditingController(text: 'Advanced Mathematics, Physics & Chemistry');

  // Teacher Classification Form State
  final List<String> _teacherAvailableLevels = [
    'Primary School (Primaire)',
    'Middle School (CEM)',
    'High School (Secondary)',
    'University & Higher Ed',
  ];
  final Set<String> _teacherSelectedLevels = {'High School (Secondary)'};

  final List<String> _teacherAvailableYears = [
    '1AP', '2AP', '3AP', '4AP', '5AP',
    '1AM', '2AM', '3AM', '4AM (BEM)',
    '1AS', '2AS', '3AS (BAC)',
    'L1', 'L2', 'L3', 'Master / Engineer',
  ];
  final Set<String> _teacherSelectedYears = {'3AS (BAC)', '2AS'};

  UserRole _registerRole = UserRole.student;
  bool _registerObscurePassword = true;
  bool _registerObscureConfirmPassword = true;
  bool _agreedToSecurityPolicy = true;

  // Tabs: 0 = Sign In, 1 = Create Account
  int _activeTabIndex = 0;

  // Ambient mesh animation
  late AnimationController _ambientAnimationController;

  @override
  void initState() {
    super.initState();
    _ambientAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _registerPasswordController.addListener(() {
      setState(() {});
    });
    _registerConfirmPasswordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ambientAnimationController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerTeacherIdController.dispose();
    _registerStudentIdController.dispose();
    _registerSubjectsController.dispose();
    super.dispose();
  }

  // Password Security Analysis Engine
  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  String _getPasswordStrengthLabel(int score) {
    switch (score) {
      case 0:
        return 'No Password Entered';
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Moderate';
      case 4:
        return 'Strong';
      case 5:
        return 'Bulletproof Security';
      default:
        return 'Moderate';
    }
  }

  Color _getPasswordStrengthColor(int score) {
    switch (score) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF97316);
      case 3:
        return const Color(0xFFFBBF24);
      case 4:
        return const Color(0xFF3B82F6);
      case 5:
        return const Color(0xFF10B981);
      default:
        return Colors.grey.shade400;
    }
  }

  void _submitSignIn() {
    if (_signInFormKey.currentState?.validate() ?? false) {
      widget.authController.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
    }
  }

  void _submitRegister() async {
    if (!_agreedToSecurityPolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Security & Acceptable Use Policy to proceed.'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    if (_registerRole == UserRole.teacher) {
      if (_teacherSelectedLevels.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one Educational Level you teach.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
      if (_teacherSelectedYears.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one Academic Year / Grade you teach.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
      if (_registerSubjectsController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please specify the Subject(s) you teach.'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
        return;
      }
    }

    if (_registerFormKey.currentState?.validate() ?? false) {
      final success = await widget.authController.register(
        name: _registerNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        passwordConfirmation: _registerConfirmPasswordController.text,
        role: _registerRole,
        teacherId: _registerRole == UserRole.teacher && _registerTeacherIdController.text.trim().isNotEmpty
            ? _registerTeacherIdController.text.trim()
            : null,
        studentId: _registerRole == UserRole.parent && _registerStudentIdController.text.trim().isNotEmpty
            ? _registerStudentIdController.text.trim()
            : null,
        teachingLevels: _registerRole == UserRole.teacher ? _teacherSelectedLevels.toList() : null,
        teachingYears: _registerRole == UserRole.teacher ? _teacherSelectedYears.toList() : null,
        teachingSubjects: _registerRole == UserRole.teacher
            ? _registerSubjectsController.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
            : null,
      );

      if (success && mounted) {
        // Authenticated user is automatically routed by main.dart ListenableBuilder
      }
    }
  }

  void _quickFillDemo(String email, String password, UserRole role) {
    setState(() {
      _activeTabIndex = 0; // Switch to Sign In
      _loginEmailController.text = email;
      _loginPasswordController.text = password;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Populated credentials for ${role.name.toUpperCase()} ($email)'),
        backgroundColor: const Color(0xFF0D9488),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = widget.authController;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Stack(
        children: [
          // 1. Deep Cosmic Radial & Mesh Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.2, -0.4),
                  radius: 1.4,
                  colors: [
                    Color(0xFF1E1B4B), // Cosmic Indigo
                    Color(0xFF0F172A), // Slate Navy
                    Color(0xFF070B14), // Deep Midnight
                  ],
                  stops: [0.0, 0.50, 1.0],
                ),
              ),
            ),
          ),

          // 2. Animated Ambient Gradient Glow Orbs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientAnimationController,
              builder: (context, _) {
                final val = _ambientAnimationController.value;
                return CustomPaint(
                  painter: _AmbientGlowPainter(animationValue: val),
                );
              },
            ),
          ),

          // 3. Foreground Responsive Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWideScreen = constraints.maxWidth > 800;

                      if (isWideScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left Brand Hero Showcase
                            Expanded(
                              flex: 5,
                              child: _buildHeroShowcase(),
                            ),
                            const SizedBox(width: 50),

                            // Right Glassmorphic Auth Card
                            Expanded(
                              flex: 6,
                              child: _buildAuthGlassCard(authController),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildCompactMobileHeader(),
                            const SizedBox(height: 24),
                            _buildAuthGlassCard(authController),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Left Hero Showcase (Desktop & Tablet)
  // ==========================================
  Widget _buildHeroShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Official Pindo Future Brand Logo with Hero Flight
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'pindo_brand_logo_hero',
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2DD4BF).withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/pindo_logo_badge.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.school, color: Colors.white, size: 28);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: -0.5, fontFamily: 'Roboto'),
                children: [
                  TextSpan(text: 'Pindo ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                  TextSpan(text: 'Future', style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Live Security & SFU Status Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SYSTEM SECURE • 30,000 CAPACITY LIVE SFU',
                style: TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Brand Title
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, height: 1.15, fontFamily: 'Roboto'),
            children: [
              TextSpan(text: 'Next-Generation\n', style: TextStyle(color: Colors.white)),
              TextSpan(
                text: 'Livestreaming & Learning',
                style: TextStyle(
                  color: Color(0xFF2DD4BF),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text(
          'Empowering educators and students with high-concurrency WebRTC masterclasses, interactive whiteboards, Algerian Dinar (DZD) payments, and zero-trust account security.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),

        // 4 Modern Feature Cards
        _buildFeatureItem(
          icon: Icons.security,
          iconColor: const Color(0xFF10B981),
          title: 'Zero-Trust Account Defense',
          subtitle: 'Sanctum token hashing & active anti-brute force rate limiting.',
        ),
        const SizedBox(height: 14),
        _buildFeatureItem(
          icon: Icons.draw,
          iconColor: const Color(0xFF38BDF8),
          title: 'Interactive Vector Whiteboard',
          subtitle: 'Sub-50ms synchronized drawing, geometric tools & saved snapshots.',
        ),
        const SizedBox(height: 14),
        _buildFeatureItem(
          icon: Icons.payments,
          iconColor: const Color(0xFFF59E0B),
          title: 'Algerian Dinar (DZD) Monetization',
          subtitle: 'Automated 80/20 instructor splits, instant checkout & CCP disbursements.',
        ),
        const SizedBox(height: 14),
        _buildFeatureItem(
          icon: Icons.family_restroom,
          iconColor: const Color(0xFFA855F7),
          title: 'Guardian Oversight Engine',
          subtitle: 'Real-time parent portal tracking attendance and academic milestones.',
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMobileHeader() {
    return Column(
      children: [
        Hero(
          tag: 'pindo_brand_logo_hero',
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF4F46E5)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                'assets/images/pindo_logo_badge.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.school, color: Colors.white, size: 36),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            children: [
              TextSpan(text: 'Pindo ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              TextSpan(text: 'Future', style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Zero-Trust Secured Educational Workspace',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ],
    );
  }

  // ==========================================
  // Right Auth Glassmorphic Card
  // ==========================================
  Widget _buildAuthGlassCard(AuthController authController) {
    return GlassmorphicContainer(
      borderRadius: BorderRadius.circular(24),
      blurSigma: 20.0,
      borderWidth: 1.2,
      borderColor: Colors.white.withValues(alpha: 0.18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          const Color(0xFF1E1B4B).withValues(alpha: 0.65), // Cosmic Indigo
          const Color(0xFF0F172A).withValues(alpha: 0.85), // Deep Navy Slate
        ],
        stops: const [0.0, 0.45, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6366F1).withValues(alpha: 0.20),
          blurRadius: 32,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.50),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Animated Tab Switcher (Sign In vs Create Account)
          _buildAnimatedTabSwitcher(),
          const SizedBox(height: 22),

          // 2. Error Banner (If any)
          if (authController.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Color(0xFFF87171), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      authController.errorMessage!,
                      style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // 3. Tab Form Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _activeTabIndex == 0
                ? _buildSignInForm(authController)
                : _buildRegisterForm(authController),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 18),

          // 4. One-Tap Demo Credentials Helper
          _buildDemoAccountsQuickFill(),

          const SizedBox(height: 18),

          // 5. Apple & Google Compliant Privacy Policy & Terms Link
          Center(
            child: InkWell(
              onTap: () => PrivacyPolicyModal.show(context),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF2DD4BF), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Privacy Policy & Terms of Service',
                      style: TextStyle(
                        color: Color(0xFF2DD4BF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF2DD4BF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Animated Tab Switcher
  // ==========================================
  Widget _buildAnimatedTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF030712).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabPill(
              title: 'Sign In',
              icon: Icons.login,
              isSelected: _activeTabIndex == 0,
              onTap: () => setState(() => _activeTabIndex = 0),
            ),
          ),
          Expanded(
            child: _tabPill(
              title: 'Create Account',
              icon: Icons.person_add_alt_1,
              isSelected: _activeTabIndex == 1,
              onTap: () => setState(() => _activeTabIndex = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabPill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // Sign In Form View
  // ==========================================
  Widget _buildSignInForm(AuthController authController) {
    return Form(
      key: _signInFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGlassField(
            controller: _loginEmailController,
            label: 'Email Address',
            hint: 'name@pindofuture.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email address';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _buildGlassField(
            controller: _loginPasswordController,
            label: 'Password',
            hint: '••••••••••••',
            icon: Icons.lock_outline,
            obscureText: _loginObscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _loginObscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF94A3B8),
                size: 18,
              ),
              onPressed: () => setState(() => _loginObscurePassword = !_loginObscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password is required';
              return null;
            },
          ),
          const SizedBox(height: 14),

          // Security Protection Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield, color: Color(0xFF10B981), size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Protected by Sanctum Token Encryption & Anti-Brute-Force Rate Limiting.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dynamic Animated Submit Button
          _buildDynamicSubmitButton(
            label: 'Sign In to Workspace',
            icon: Icons.login,
            isLoading: authController.isAuthenticating,
            onPressed: _submitSignIn,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Register Form View with Live Security Meter
  // ==========================================
  Widget _buildRegisterForm(AuthController authController) {
    final passwordText = _registerPasswordController.text;
    final confirmPasswordText = _registerConfirmPasswordController.text;
    final strengthScore = _calculatePasswordStrength(passwordText);
    final strengthLabel = _getPasswordStrengthLabel(strengthScore);
    final strengthColor = _getPasswordStrengthColor(strengthScore);

    final bool hasLength = passwordText.length >= 8;
    final bool hasUpper = passwordText.contains(RegExp(r'[A-Z]'));
    final bool hasLower = passwordText.contains(RegExp(r'[a-z]'));
    final bool hasNumber = passwordText.contains(RegExp(r'[0-9]'));
    final bool hasSpecial = passwordText.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final bool passwordsMatch = passwordText.isNotEmpty && passwordText == confirmPasswordText;

    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Role Selection Cards
          const Text(
            'Select Workspace Role',
            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _rolePill(UserRole.student, 'Student', Icons.school),
              const SizedBox(width: 6),
              _rolePill(UserRole.teacher, 'Teacher', Icons.cast_for_education),
              const SizedBox(width: 6),
              _rolePill(UserRole.parent, 'Parent', Icons.family_restroom),
            ],
          ),
          const SizedBox(height: 16),

          _buildGlassField(
            controller: _registerNameController,
            label: 'Full Legal Name',
            hint: 'e.g. Ada Lovelace',
            icon: Icons.person_outline,
            validator: (v) => (v == null || v.trim().length < 2) ? 'Full name is required (min 2 chars)' : null,
          ),
          const SizedBox(height: 14),

          _buildGlassField(
            controller: _registerEmailController,
            label: 'Email Address',
            hint: 'name@domain.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),

          if (_registerRole == UserRole.teacher) ...[
            _buildGlassField(
              controller: _registerTeacherIdController,
              label: 'Instructor Profile ID (Optional Deep Link)',
              hint: 'e.g. TCH_ALAN_2026',
              icon: Icons.badge_outlined,
            ),
            const SizedBox(height: 14),

            _buildTeacherClassificationSection(),
            const SizedBox(height: 14),
          ],

          if (_registerRole == UserRole.parent) ...[
            _buildGlassField(
              controller: _registerStudentIdController,
              label: "Child's Student ID (Mandatory for Guardian Account)",
              hint: 'e.g. STU_ADA_2026, Student Email or ID',
              icon: Icons.family_restroom,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Student ID is strictly required to create a parent account';
                }
                return null;
              },
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF2DD4BF)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Security Rule: Guardian accounts require a verified Student ID to link parental oversight and protect student privacy.',
                      style: TextStyle(color: Color(0xFF99F6E4), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          _buildGlassField(
            controller: _registerPasswordController,
            label: 'Create Master Password',
            hint: 'Min 8 chars, uppercase, number & symbol',
            icon: Icons.lock_outline,
            obscureText: _registerObscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _registerObscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF94A3B8),
                size: 18,
              ),
              onPressed: () => setState(() => _registerObscurePassword = !_registerObscurePassword),
            ),
            validator: (v) {
              if (v == null || v.length < 8) return 'Password must be at least 8 characters';
              if (!v.contains(RegExp(r'[A-Z]'))) return 'Must include at least 1 uppercase letter';
              if (!v.contains(RegExp(r'[0-9]'))) return 'Must include at least 1 number';
              return null;
            },
          ),
          const SizedBox(height: 8),

          // Live Password Strength Bar
          if (passwordText.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Password Strength:', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                Text(
                  strengthLabel,
                  style: TextStyle(color: strengthColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (strengthScore / 5.0).clamp(0.0, 1.0),
                backgroundColor: Colors.white10,
                color: strengthColor,
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 10),

            // Security Rule Checklist
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF030712).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  _ruleCheck('At least 8 characters long', hasLength),
                  const SizedBox(height: 4),
                  _ruleCheck('Uppercase letter (A-Z)', hasUpper),
                  const SizedBox(height: 4),
                  _ruleCheck('Lowercase letter (a-z)', hasLower),
                  const SizedBox(height: 4),
                  _ruleCheck('Numeric digit (0-9)', hasNumber),
                  const SizedBox(height: 4),
                  _ruleCheck('Special symbol (!@#\$%^&*)', hasSpecial),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          _buildGlassField(
            controller: _registerConfirmPasswordController,
            label: 'Confirm Master Password',
            hint: 'Re-enter your password',
            icon: Icons.lock_reset,
            obscureText: _registerObscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _registerObscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: const Color(0xFF94A3B8),
                size: 18,
              ),
              onPressed: () => setState(() => _registerObscureConfirmPassword = !_registerObscureConfirmPassword),
            ),
            validator: (v) {
              if (v != _registerPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          if (confirmPasswordText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  passwordsMatch ? Icons.check_circle : Icons.cancel,
                  size: 14,
                  color: passwordsMatch ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 6),
                Text(
                  passwordsMatch ? 'Passwords match securely' : 'Passwords do not match yet',
                  style: TextStyle(
                    fontSize: 11,
                    color: passwordsMatch ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Security Agreement Checkbox
          CheckboxListTile(
            value: _agreedToSecurityPolicy,
            onChanged: (v) => setState(() => _agreedToSecurityPolicy = v ?? false),
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: const Color(0xFF0D9488),
            title: const Text(
              'I agree to Zero-Trust Security Policies & Sanctum Encryption Standards.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 14),

          // Dynamic Animated Register Button
          _buildDynamicSubmitButton(
            label: 'Create Secure Account',
            icon: Icons.person_add_alt_1,
            isLoading: authController.isAuthenticating,
            onPressed: _submitRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherClassificationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF311B92).withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.40)),
                ),
                child: const Icon(Icons.psychology_alt_rounded, color: Color(0xFF00E5FF), size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Teacher Teaching Specialization',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      'تصنيف الأستاذ: حدد الأطوار، السنوات، والمواد لتصنيفك للطلاب',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Levels Taught (Multi-select)
          const Text(
            '1. Educational Levels You Teach (الأطوار التعليمية):',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _teacherAvailableLevels.map((lvl) {
              final isSelected = _teacherSelectedLevels.contains(lvl);
              return GlassmorphicScaleButton(
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      _teacherSelectedLevels.remove(lvl);
                    } else {
                      _teacherSelectedLevels.add(lvl);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00E5FF) : Colors.white24,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        size: 13,
                        color: isSelected ? const Color(0xFF00E5FF) : Colors.white60,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lvl,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // 2. Years / Grades Taught (Multi-select)
          const Text(
            '2. Academic Years / Grades You Teach (السنوات الدراسية):',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _teacherAvailableYears.map((yr) {
              final isSelected = _teacherSelectedYears.contains(yr);
              return GlassmorphicScaleButton(
                onPressed: () {
                  setState(() {
                    if (isSelected) {
                      _teacherSelectedYears.remove(yr);
                    } else {
                      _teacherSelectedYears.add(yr);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7C4DFF).withValues(alpha: 0.35)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF7C4DFF) : Colors.white24,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        yr,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check, size: 12, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // 3. Subjects Taught
          _buildGlassField(
            controller: _registerSubjectsController,
            label: '3. Subjects You Teach (المواد المدرسة - مفصولة بفواصل):',
            hint: 'e.g. Advanced Mathematics, Physics & Chemistry',
            icon: Icons.menu_book_rounded,
          ),
          const SizedBox(height: 6),
          // Quick Tap Subject Pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              'Advanced Mathematics',
              'Physics & Chemistry',
              'Natural Sciences',
              'Arabic Literature',
              'Computer Science & Algorithms',
              'Philosophy',
            ].map((sub) {
              return GlassmorphicScaleButton(
                onPressed: () {
                  final current = _registerSubjectsController.text.trim();
                  if (current.isEmpty) {
                    _registerSubjectsController.text = sub;
                  } else if (!current.contains(sub)) {
                    _registerSubjectsController.text = '$current, $sub';
                  }
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Color(0xFF00E5FF), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        sub,
                        style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _ruleCheck(String label, bool isSatisfied) {
    return Row(
      children: [
        Icon(
          isSatisfied ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: isSatisfied ? const Color(0xFF10B981) : const Color(0xFF64748B),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSatisfied ? Colors.white70 : const Color(0xFF64748B),
            fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _rolePill(UserRole role, String label, IconData icon) {
    final isSelected = _registerRole == role;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _registerRole = role),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0D9488).withValues(alpha: 0.25) : const Color(0xFF030712).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF0D9488) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: isSelected ? const Color(0xFF2DD4BF) : const Color(0xFF94A3B8)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Quick-Fill Demo Accounts Section
  // ==========================================
  Widget _buildDemoAccountsQuickFill() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flash_on, color: Color(0xFFF59E0B), size: 14),
              SizedBox(width: 6),
              Text(
                'One-Tap Demo Credentials (Instant Access):',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _demoPill('👨‍🏫 Teacher', 'teacher.demo@pindofuture.com', 'TeacherPassword123!', UserRole.teacher),
              _demoPill('👩‍🎓 Student', 'student.demo@pindofuture.com', 'StudentPassword123!', UserRole.student),
              _demoPill('👩‍👧 Parent', 'parent.demo@pindofuture.com', 'ParentPassword123!', UserRole.parent),
              _demoPill('🛡️ Admin', 'admin@pindofuture.com', 'AdminPassword123!', UserRole.admin),
            ],
          ),
        ],
      ),
    );
  }

  Widget _demoPill(String label, String email, String password, UserRole role) {
    return GlassmorphicScaleButton(
      pressedScale: 0.92,
      onPressed: () => _quickFillDemo(email, password, role),
      builder: (context, isPressed, isHovered) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isHovered ? 0.12 : 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: isHovered ? 0.22 : 0.12)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        );
      },
    );
  }

  // ==========================================
  // True Glassmorphic Input Text Field
  // ==========================================
  Widget _buildGlassField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.2),
              ),
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                validator: validator,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  filled: false,
                  hintText: hint,
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  prefixIcon: Icon(icon, color: const Color(0xFF2DD4BF), size: 19),
                  suffixIcon: suffixIcon,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Dynamic Animated Submit Button
  // ==========================================
  Widget _buildDynamicSubmitButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return GlassmorphicScaleButton(
      pressedScale: 0.94,
      onPressed: isLoading ? null : onPressed,
      builder: (context, isPressed, isHovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0D9488), // Brand Teal
                Color(0xFF10B981), // Emerald
                Color(0xFF2563EB), // Royal Blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: isHovered ? 0.40 : 0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D9488).withValues(alpha: isHovered ? 0.55 : 0.38),
                blurRadius: isHovered ? 20 : 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Authenticating...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

// ==========================================
// Ambient Background Glow Painter
// ==========================================
class _AmbientGlowPainter extends CustomPainter {
  final double animationValue;

  _AmbientGlowPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Top-left Teal Orb
    final tealPaint = Paint()
      ..color = const Color(0xFF0D9488).withValues(alpha: 0.18 + (animationValue * 0.06))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * (0.2 + (animationValue * 0.05))),
      size.width * 0.35,
      tealPaint,
    );

    // Bottom-right Royal Blue Orb
    final bluePaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.14 + ((1 - animationValue) * 0.05))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 140);

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * (0.75 - (animationValue * 0.05))),
      size.width * 0.4,
      bluePaint,
    );

    // Subtle Center Emerald Pulse
    final centerPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.06 + (math.sin(animationValue * math.pi) * 0.04))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.25,
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AmbientGlowPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
