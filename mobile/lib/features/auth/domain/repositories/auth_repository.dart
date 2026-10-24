import '../entities/user.dart';

abstract class AuthRepository {
  /// Authenticate user credentials and store session token
  Future<User> login({
    required String email,
    required String password,
  });

  /// Register a new user with role and generate session token
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
  });

  /// Fetch currently authenticated user profile
  Future<User?> getCurrentUser();

  /// Revoke session and purge secure token storage
  Future<void> logout();

  /// Permanently delete user account and purge secure storage (Apple Guideline 5.1.1(v))
  Future<void> deleteAccount();

  /// Retrieve cached Sanctum token
  Future<String?> getSavedToken();
}
