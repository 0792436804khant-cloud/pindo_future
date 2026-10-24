import 'package:flutter/material.dart';
import '../../../../core/widgets/glassmorphism.dart';
import '../../../../core/widgets/pindo_brand_logo.dart';
import '../../domain/entities/user.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  final AuthController authController;

  const RegisterScreen({
    super.key,
    required this.authController,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _teacherIdController = TextEditingController();
  final _studentIdController = TextEditingController();

  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;

  static const Color _bgDark = Color(0xFF070B14);
  static const Color _deepIndigo = Color(0xFF311B92);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _brightCyan = Color(0xFF00E5FF);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _teacherIdController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await widget.authController.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmController.text,
        role: _selectedRole,
        teacherId: _selectedRole == UserRole.teacher && _teacherIdController.text.trim().isNotEmpty
            ? _teacherIdController.text.trim()
            : null,
        studentId: _selectedRole == UserRole.parent && _studentIdController.text.trim().isNotEmpty
            ? _studentIdController.text.trim()
            : null,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = widget.authController;

    return Scaffold(
      backgroundColor: _bgDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Stack(
        children: [
          // Background ambient glowing orbs
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _deepIndigo.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _electricPurple.withValues(alpha: 0.30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: GlassmorphicContainer(
                    borderRadius: BorderRadius.circular(28),
                    borderColor: _brightCyan.withValues(alpha: 0.35),
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: PindoBrandLogo(
                              size: 64,
                              isVertical: true,
                              fontSize: 24,
                              textColor: Colors.white,
                              withGlow: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'Select your platform role and create your credentials',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Error Banner
                          if (authController.errorMessage != null) ...[
                            GlassmorphicContainer(
                              borderRadius: BorderRadius.circular(14),
                              borderColor: const Color(0xFFEF4444).withValues(alpha: 0.45),
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 18),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authController.errorMessage!,
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Role Selection (4 Strict Roles)
                          Text(
                            'Select Platform Role',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _rolePill(UserRole.student, 'Student', Icons.school_rounded),
                              _rolePill(UserRole.teacher, 'Teacher', Icons.record_voice_over_rounded),
                              _rolePill(UserRole.parent, 'Parent', Icons.family_restroom_rounded),
                              _rolePill(UserRole.admin, 'Admin', Icons.security_rounded),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Full Name
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hintText: 'e.g. Jane Doe',
                            prefixIcon: Icons.person_outline,
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Please enter your full name.'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Email Address
                          _buildTextField(
                            controller: _emailController,
                            label: 'Email Address',
                            hintText: 'name@pindofuture.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email.';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email address.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Teacher Platform ID (Conditional)
                          if (_selectedRole == UserRole.teacher) ...[
                            _buildTextField(
                              controller: _teacherIdController,
                              label: 'Custom Teacher ID (Optional)',
                              hintText: 'e.g. TCH_MATH_101 (Auto-generated if blank)',
                              prefixIcon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Student ID (Required for Parent / Guardian)
                          if (_selectedRole == UserRole.parent) ...[
                            _buildTextField(
                              controller: _studentIdController,
                              label: "Child's Student ID (Mandatory for Guardian)",
                              hintText: 'e.g. STU_ADA_2026, Student Email or ID',
                              prefixIcon: Icons.family_restroom,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Student ID is strictly required to create a parent account.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Password
                          _buildTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'Minimum 8 characters',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 20,
                                color: Colors.white54,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 8) {
                                return 'Password must contain at least 8 characters.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Confirmation
                          _buildTextField(
                            controller: _passwordConfirmController,
                            label: 'Confirm Password',
                            hintText: 'Re-enter your password',
                            prefixIcon: Icons.lock_clock_outlined,
                            obscureText: _obscurePassword,
                            validator: (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 26),

                          // Submit Button
                          FuturisticCapsuleButton(
                            text: 'Register as ${_selectedRole.displayName}',
                            icon: Icons.how_to_reg_rounded,
                            height: 48,
                            isLoading: authController.isAuthenticating,
                            accentColor: _brightCyan,
                            secondaryColor: _electricPurple,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
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
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
            prefixIcon: Icon(prefixIcon, color: _brightCyan, size: 20),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        ),
      ],
    );
  }

  Widget _rolePill(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;

    return GlassmorphicScaleButton(
      onPressed: () => setState(() => _selectedRole = role),
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
                : Colors.white.withValues(alpha: 0.14),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? _brightCyan : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _brightCyan : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
