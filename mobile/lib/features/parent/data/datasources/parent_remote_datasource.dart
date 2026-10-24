import '../../../../core/network/api_client.dart';

abstract class ParentRemoteDataSource {
  Future<List<dynamic>> fetchChildren(String token);

  Future<Map<String, dynamic>> linkChild(
    String token, {
    String? email,
    String? linkingCode,
    String? relationship,
  });

  Future<List<dynamic>> fetchAcademics(String token, int studentId);

  Future<Map<String, dynamic>> fetchAttendance(String token, int studentId);

  Future<List<dynamic>> fetchSchedule(String token, int studentId);

  Future<List<dynamic>> fetchNotes(String token, int studentId);

  Future<Map<String, dynamic>> createNote(
    String token,
    int studentId, {
    required String title,
    required String content,
    String? type,
  });

  Future<void> acknowledgeNote(String token, int noteId);
}

class ParentRemoteDataSourceImpl implements ParentRemoteDataSource {
  final ApiClient apiClient;

  ParentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<dynamic>> fetchChildren(String token) async {
    final response = await apiClient.get('/parent/children', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> linkChild(
    String token, {
    String? email,
    String? linkingCode,
    String? relationship,
  }) async {
    final body = <String, dynamic>{
      if (email != null && email.isNotEmpty) 'student_email': email,
      if (linkingCode != null && linkingCode.isNotEmpty) 'linking_code': linkingCode,
      if (relationship != null && relationship.isNotEmpty) 'relationship': relationship,
    };

    final response = await apiClient.post('/parent/link-child', body: body, token: token);
    return (response['child'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<List<dynamic>> fetchAcademics(String token, int studentId) async {
    final response = await apiClient.get('/parent/children/$studentId/academics', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> fetchAttendance(String token, int studentId) async {
    final response = await apiClient.get('/parent/children/$studentId/attendance', token: token);
    return response as Map<String, dynamic>? ?? {};
  }

  @override
  Future<List<dynamic>> fetchSchedule(String token, int studentId) async {
    final response = await apiClient.get('/parent/children/$studentId/schedule', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<List<dynamic>> fetchNotes(String token, int studentId) async {
    final response = await apiClient.get('/parent/children/$studentId/notes', token: token);
    return (response['data'] as List<dynamic>?) ?? [];
  }

  @override
  Future<Map<String, dynamic>> createNote(
    String token,
    int studentId, {
    required String title,
    required String content,
    String? type,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'content': content,
      'type': type ?? 'general',
    };

    final response = await apiClient.post(
      '/parent/children/$studentId/notes',
      body: body,
      token: token,
    );
    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  @override
  Future<void> acknowledgeNote(String token, int noteId) async {
    await apiClient.put('/parent/notes/$noteId/acknowledge', token: token);
  }
}
