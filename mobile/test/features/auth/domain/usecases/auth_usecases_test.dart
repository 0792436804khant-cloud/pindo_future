import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/auth/domain/entities/user.dart';
import 'package:pindo_future_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pindo_future_mobile/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository implements AuthRepository {
  User? mockUser = const User(
    id: 2,
    name: 'Professor Alan Turing',
    email: 'teacher.demo@pindofuture.com',
    role: UserRole.teacher,
    teacherId: 'TCH_123',
    token: 'mock_sanctum_token',
  );
  bool logoutCalled = false;
  bool deleteAccountCalled = false;

  @override
  Future<User> login({required String email, required String password}) async {
    return mockUser ??
        const User(
          id: 2,
          name: 'Professor Alan Turing',
          email: 'teacher.demo@pindofuture.com',
          role: UserRole.teacher,
          teacherId: 'TCH_123',
          token: 'mock_sanctum_token',
        );
  }

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
  }) async {
    return User(
      id: 3,
      name: name,
      email: email,
      role: role,
      teacherId: teacherId ?? (role == UserRole.teacher ? 'TCH_AUTO' : null),
      studentId: studentId ?? (role == UserRole.student ? 'STU_AUTO' : null),
      teachingLevels: teachingLevels ?? [],
      teachingYears: teachingYears ?? [],
      teachingSubjects: teachingSubjects ?? [],
      token: 'mock_sanctum_token_reg',
    );
  }

  @override
  Future<User?> getCurrentUser() async {
    return mockUser;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
  }

  @override
  Future<String?> getSavedToken() async {
    return 'mock_sanctum_token';
  }
}

void main() {
  late MockAuthRepository mockRepository;
  late LoginUseCase loginUseCase;
  late RegisterUseCase registerUseCase;
  late GetCurrentUserUseCase getCurrentUserUseCase;
  late LogoutUseCase logoutUseCase;
  late DeleteAccountUseCase deleteAccountUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
    registerUseCase = RegisterUseCase(mockRepository);
    getCurrentUserUseCase = GetCurrentUserUseCase(mockRepository);
    logoutUseCase = LogoutUseCase(mockRepository);
    deleteAccountUseCase = DeleteAccountUseCase(mockRepository);
  });

  test('LoginUseCase should return teacher user with correct role and token', () async {
    final user = await loginUseCase(
      email: 'teacher.demo@pindofuture.com',
      password: 'TeacherPassword123!',
    );

    expect(user.role, UserRole.teacher);
    expect(user.isTeacher, true);
    expect(user.teacherId, 'TCH_123');
    expect(user.token, 'mock_sanctum_token');
  });

  test('RegisterUseCase should return student user when registering as student', () async {
    final user = await registerUseCase(
      name: 'Ada Lovelace',
      email: 'ada@pindofuture.com',
      password: 'Password123!',
      passwordConfirmation: 'Password123!',
      role: UserRole.student,
    );

    expect(user.role, UserRole.student);
    expect(user.isStudent, true);
    expect(user.name, 'Ada Lovelace');
  });

  test('RegisterUseCase should return parent user with studentId when registering as parent', () async {
    final user = await registerUseCase(
      name: 'Lady Byron',
      email: 'parent@pindofuture.com',
      password: 'ParentPassword123!',
      passwordConfirmation: 'ParentPassword123!',
      role: UserRole.parent,
      studentId: 'STU_ADA_2026',
      relationship: 'Mother',
    );

    expect(user.role, UserRole.parent);
    expect(user.isParent, true);
    expect(user.name, 'Lady Byron');
    expect(user.studentId, 'STU_ADA_2026');
  });

  test('GetCurrentUserUseCase should return current user', () async {
    final user = await getCurrentUserUseCase();
    expect(user?.role, UserRole.teacher);
    expect(user?.email, 'teacher.demo@pindofuture.com');
  });

  test('LogoutUseCase should invoke repository logout', () async {
    await logoutUseCase();
    expect(mockRepository.logoutCalled, true);
  });

  test('DeleteAccountUseCase should invoke repository deleteAccount', () async {
    await deleteAccountUseCase();
    expect(mockRepository.deleteAccountCalled, true);
  });
}
