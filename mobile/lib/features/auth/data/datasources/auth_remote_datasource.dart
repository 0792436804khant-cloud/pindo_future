import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? teacherId,
    String? studentId,
    String? relationship,
    List<String>? teachingLevels,
    List<String>? teachingYears,
    List<String>? teachingSubjects,
  });

  Future<UserModel> getMe(String token);

  Future<void> logout(String token);
  Future<void> deleteAccount(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.loginEndpoint,
      body: {
        'email': email,
        'password': password,
        'device_name': 'Flutter Mobile App',
      },
    );

    return response as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
    String? teacherId,
    String? studentId,
    String? relationship,
    List<String>? teachingLevels,
    List<String>? teachingYears,
    List<String>? teachingSubjects,
  }) async {
    final Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': role,
      'device_name': 'Flutter Mobile App',
    };

    if (teacherId != null && teacherId.trim().isNotEmpty) {
      body['teacher_id'] = teacherId.trim();
    }

    if (studentId != null && studentId.trim().isNotEmpty) {
      body['student_id'] = studentId.trim();
    }

    if (relationship != null && relationship.trim().isNotEmpty) {
      body['relationship'] = relationship.trim();
    }

    if (teachingLevels != null && teachingLevels.isNotEmpty) {
      body['teaching_levels'] = teachingLevels;
    }

    if (teachingYears != null && teachingYears.isNotEmpty) {
      body['teaching_years'] = teachingYears;
    }

    if (teachingSubjects != null && teachingSubjects.isNotEmpty) {
      body['teaching_subjects'] = teachingSubjects;
    }

    final response = await apiClient.post(
      ApiConstants.registerEndpoint,
      body: body,
    );

    return response as Map<String, dynamic>;
  }

  @override
  Future<UserModel> getMe(String token) async {
    final response = await apiClient.get(
      ApiConstants.meEndpoint,
      token: token,
    );

    final userJson = response['user'] as Map<String, dynamic>;
    return UserModel.fromJson(userJson, token: token);
  }

  @override
  Future<void> logout(String token) async {
    await apiClient.post(
      ApiConstants.logoutEndpoint,
      token: token,
    );
  }

  @override
  Future<void> deleteAccount(String token) async {
    await apiClient.delete(
      ApiConstants.deleteAccountEndpoint,
      token: token,
    );
  }
}
