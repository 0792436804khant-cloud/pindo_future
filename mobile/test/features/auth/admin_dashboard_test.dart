import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/auth/data/models/admin_dashboard_model.dart';
import 'package:pindo_future_mobile/features/auth/domain/entities/user.dart';
import 'package:pindo_future_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:pindo_future_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:pindo_future_mobile/features/auth/presentation/screens/dashboards/admin_dashboard_screen.dart';

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
  group('Admin Command Center Widget Tests', () {
    final testUser = User(
      id: 1,
      name: 'System Root Admin',
      email: 'admin@pindofuture.com',
      role: UserRole.admin,
    );

    test('AdminDashboardModel correctly instantiates fallback and parses numbers', () {
      final model = AdminDashboardModel.mockFallback();
      expect(model.kpis.totalStudentsCount, 1420);
      expect(model.kpis.grossRevenue, 4250000.0);
      expect(model.pendingVerifications.length, 3);
      expect(model.pendingPayouts.length, 3);
    });

    testWidgets('AdminDashboardScreen renders tabs and title', (tester) async {
      final repo = _FakeAuthRepository();
      final authController = AuthController(
        loginUseCase: LoginUseCase(repo),
        registerUseCase: RegisterUseCase(repo),
        getCurrentUserUseCase: GetCurrentUserUseCase(repo),
        logoutUseCase: LogoutUseCase(repo),
        deleteAccountUseCase: DeleteAccountUseCase(repo),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: AdminDashboardScreen(
            user: testUser,
            authController: authController,
          ),
        ),
      );

      // Verify dashboard headers & title
      expect(find.text('Admin Command Center — لوحة الإدارة'), findsOneWidget);
      expect(find.text('نظرة عامة'), findsOneWidget);
      expect(find.textContaining('توثيق الأساتذة'), findsOneWidget);
      expect(find.textContaining('طلبات السحب'), findsOneWidget);
      expect(find.text('مراقبة البث SFU'), findsOneWidget);
    });
  });
}
