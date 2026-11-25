import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/auth/domain/entities/user.dart';
import 'package:pindo_future_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:pindo_future_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pindo_future_mobile/features/auth/presentation/screens/login_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  String? lastRegisteredPhone;
  UserRole? lastRegisteredRole;

  @override
  Future<User> login({required String email, required String password}) async {
    return User(
      id: 1,
      name: 'Demo',
      email: email,
      role: UserRole.student,
      token: 'tok',
    );
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
    String? teacherId,
    String? studentId,
    String? relationship,
    List<String>? teachingLevels,
    List<String>? teachingYears,
    List<String>? teachingSubjects,
  }) async {
    lastRegisteredPhone = phone;
    lastRegisteredRole = role;
    return User(
      id: 2,
      name: name,
      email: email,
      phone: phone,
      role: role,
      token: 'tok_reg',
    );
  }

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<String?> getSavedToken() async => null;
}

AuthController _buildTestAuthController() {
  final repo = _FakeAuthRepository();
  return AuthController(
    loginUseCase: LoginUseCase(repo),
    registerUseCase: RegisterUseCase(repo),
    getCurrentUserUseCase: GetCurrentUserUseCase(repo),
    logoutUseCase: LogoutUseCase(repo),
    deleteAccountUseCase: DeleteAccountUseCase(repo),
  );
}

void main() {
  testWidgets(
    'Mobile viewport displays animated showcase banner before auth card and phone field for Student, Teacher, Parent',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authController = _buildTestAuthController();

      await tester.pumpWidget(
        MaterialApp(
          home: LoginScreen(authController: authController),
        ),
      );

      // Advance flutter_animate staggered entrance animations
      await tester.pump(const Duration(milliseconds: 900));

      // Step 1: Mobile animated showcase appears BEFORE the auth card
      expect(find.byKey(const Key('mobile_showcase_intro')), findsOneWidget);
      expect(find.text('SYSTEM SECURE • 30,000 CAPACITY LIVE SFU'), findsOneWidget);
      expect(find.text('Zero-Trust Account Defense'), findsOneWidget);
      expect(find.text('Guardian Oversight Engine'), findsOneWidget);
      expect(find.byKey(const Key('mobile_auth_workspace')), findsNothing);

      // Tap CTA to open Create Account workspace
      await tester.ensureVisible(find.byKey(const Key('mobile_showcase_continue_btn')));
      await tester.tap(find.byKey(const Key('mobile_showcase_continue_btn')));
      await tester.pump(const Duration(milliseconds: 600));

      // Step 2: Auth card workspace appears on Create Account tab
      expect(find.byKey(const Key('mobile_auth_workspace')), findsOneWidget);

      // Student role shows phone field
      expect(find.text('Phone Number / رقم الهاتف (للتواصل معك)'), findsOneWidget);

      // Switch to Teacher role -> phone field remains visible
      await tester.ensureVisible(find.text('Teacher'));
      await tester.tap(find.text('Teacher'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Phone Number / رقم الهاتف (للتواصل معك)'), findsOneWidget);

      // Switch to Parent role -> phone field remains visible
      await tester.ensureVisible(find.text('Parent'));
      await tester.tap(find.text('Parent'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Phone Number / رقم الهاتف (للتواصل معك)'), findsOneWidget);
    },
  );
}
