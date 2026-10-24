import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call({
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
    return await repository.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      role: role,
      teacherId: teacherId,
      studentId: studentId,
      relationship: relationship,
      teachingLevels: teachingLevels,
      teachingYears: teachingYears,
      teachingSubjects: teachingSubjects,
    );
  }
}
