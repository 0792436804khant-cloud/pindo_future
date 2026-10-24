import '../../../../core/network/api_client.dart';

abstract class CohortRemoteDataSource {
  Future<List<dynamic>> fetchTeacherCohorts(String token);
  Future<Map<String, dynamic>> createCohort(String token, Map<String, dynamic> body);
  Future<Map<String, dynamic>> fetchCohortDetails(String token, int cohortId);
  Future<void> deleteCohort(String token, int cohortId);
  Future<List<dynamic>> fetchCohortMembers(String token, int cohortId);
  Future<Map<String, dynamic>> addCohortMember(String token, int cohortId, String studentIdentifier);
  Future<void> removeCohortMember(String token, int cohortId, int studentId);
  Future<Map<String, dynamic>> scheduleCohortSession(String token, int cohortId, Map<String, dynamic> body);

  Future<List<dynamic>> fetchPublicCohorts({
    String? academicLevel,
    String? stream,
    String? subject,
    String? search,
    int? wilaya,
  });

  Future<List<dynamic>> fetchStudentCohorts(String token);
  Future<Map<String, dynamic>> joinCohort(String token, int cohortId);
  Future<void> leaveCohort(String token, int cohortId);
  Future<Map<String, dynamic>> requestVerification(String token, String document);
}

class CohortRemoteDataSourceImpl implements CohortRemoteDataSource {
  final ApiClient apiClient;

  CohortRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> fetchTeacherCohorts(String token) async {
    final response = await apiClient.get('/teacher/cohorts', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> createCohort(String token, Map<String, dynamic> body) async {
    final response = await apiClient.post('/teacher/cohorts', body: body, token: token);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<Map<String, dynamic>> fetchCohortDetails(String token, int cohortId) async {
    final response = await apiClient.get('/teacher/cohorts/$cohortId', token: token);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<void> deleteCohort(String token, int cohortId) async {
    await apiClient.delete('/teacher/cohorts/$cohortId', token: token);
  }

  @override
  Future<List<dynamic>> fetchCohortMembers(String token, int cohortId) async {
    final response = await apiClient.get('/teacher/cohorts/$cohortId/members', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> addCohortMember(String token, int cohortId, String studentIdentifier) async {
    final response = await apiClient.post(
      '/teacher/cohorts/$cohortId/members',
      body: {'student_identifier': studentIdentifier},
      token: token,
    );
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<void> removeCohortMember(String token, int cohortId, int studentId) async {
    await apiClient.delete('/teacher/cohorts/$cohortId/members/$studentId', token: token);
  }

  @override
  Future<Map<String, dynamic>> scheduleCohortSession(String token, int cohortId, Map<String, dynamic> body) async {
    final response = await apiClient.post('/teacher/cohorts/$cohortId/sessions', body: body, token: token);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<List<dynamic>> fetchPublicCohorts({
    String? academicLevel,
    String? stream,
    String? subject,
    String? search,
    int? wilaya,
  }) async {
    final queryParams = <String, String>{};
    if (academicLevel != null && academicLevel.isNotEmpty) {
      queryParams['academic_level'] = academicLevel;
    }
    if (stream != null && stream.isNotEmpty) {
      queryParams['stream'] = stream;
    }
    if (subject != null && subject.isNotEmpty) {
      queryParams['subject'] = subject;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (wilaya != null) {
      queryParams['wilaya'] = wilaya.toString();
    }

    final queryString = queryParams.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final endpoint = queryString.isEmpty ? '/cohorts' : '/cohorts?$queryString';
    final response = await apiClient.get(endpoint);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<List<dynamic>> fetchStudentCohorts(String token) async {
    final response = await apiClient.get('/student/cohorts', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> joinCohort(String token, int cohortId) async {
    final response = await apiClient.post('/student/cohorts/$cohortId/join', body: {}, token: token);
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<void> leaveCohort(String token, int cohortId) async {
    await apiClient.delete('/student/cohorts/$cohortId/leave', token: token);
  }

  @override
  Future<Map<String, dynamic>> requestVerification(String token, String document) async {
    final response = await apiClient.post(
      '/teacher/verification/request',
      body: {'national_id_or_diploma': document},
      token: token,
    );
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }
}
