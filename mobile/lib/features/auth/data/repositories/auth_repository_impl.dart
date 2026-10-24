import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await remoteDataSource.login(
        email: email,
        password: password,
      );

      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userJson, token: token);

      await localDataSource.saveToken(token);
      return userModel;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Authentication failed: $e');
    }
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
    try {
      final data = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role.name,
        teacherId: teacherId,
        studentId: studentId,
        relationship: relationship,
        teachingLevels: teachingLevels,
        teachingYears: teachingYears,
        teachingSubjects: teachingSubjects,
      );

      final token = data['token'] as String;
      final userJson = data['user'] as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userJson, token: token);

      await localDataSource.saveToken(token);
      return userModel;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Registration failed: $e');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      return await remoteDataSource.getMe(token);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException {
      // Token is invalid/expired on the server, purge local storage
      await localDataSource.deleteToken();
      return null;
    } catch (e) {
      throw ServerFailure('Failed to fetch user session: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        await remoteDataSource.logout(token);
      }
    } catch (_) {
      // Proceed with local logout regardless of remote response
    } finally {
      await localDataSource.deleteToken();
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final token = await localDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        await remoteDataSource.deleteAccount(token);
      }
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Account deletion failed: $e');
    } finally {
      await localDataSource.deleteToken();
    }
  }

  @override
  Future<String?> getSavedToken() async {
    return await localDataSource.getToken();
  }
}
