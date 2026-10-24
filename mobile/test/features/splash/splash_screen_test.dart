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
import 'package:pindo_future_mobile/features/splash/presentation/screens/splash_screen.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> login({required String email, required String password}) async => throw UnimplementedError();

  @override
  Future<void> logout() async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
    String? teacherId,
    String? studentId,
    String? relationship,
    List<String>? teachingLevels,
    List<String>? teachingYears,
    List<String>? teachingSubjects,
  }) async => throw UnimplementedError();

  @override
  Future<String?> getSavedToken() async => null;
}

void main() {
  group('SplashScreen Visual & Animation Tests', () {
    testWidgets('SplashScreen renders breathing logo, app title, and progress bar', (tester) async {
      final repo = _FakeAuthRepository();
      final authController = AuthController(
        loginUseCase: LoginUseCase(repo),
        registerUseCase: RegisterUseCase(repo),
        getCurrentUserUseCase: GetCurrentUserUseCase(repo),
        logoutUseCase: LogoutUseCase(repo),
        deleteAccountUseCase: DeleteAccountUseCase(repo),
      );

      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            authController: authController,
            onFinished: () => finished = true,
          ),
        ),
      );

      // Verify Title and Subtitle are present
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('Pindo Future'),
        ),
        findsOneWidget,
      );
      expect(find.text('Next-Gen Livestreaming & Learning Engine'), findsOneWidget);

      // Verify Hero logo exists
      expect(find.byType(Hero), findsOneWidget);

      // Verify progress indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Advance clock past the 2500ms transition threshold
      await tester.pump(const Duration(milliseconds: 2600));

      // Verify onFinished callback was invoked
      expect(finished, isTrue);
    });
  });
}
