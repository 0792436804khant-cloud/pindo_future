import '../../../../core/network/api_client.dart';

abstract class LibraryRemoteDataSource {
  Future<Map<String, dynamic>> fetchCohortLibrary(String token, int cohortId);
  Future<Map<String, dynamic>> requestRecordingStream(String token, int recordingId);
  Future<Map<String, dynamic>> requestMaterialAccess(String token, int materialId);
}

class LibraryRemoteDataSourceImpl implements LibraryRemoteDataSource {
  final ApiClient apiClient;

  LibraryRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> fetchCohortLibrary(String token, int cohortId) async {
    return await apiClient.get('/student/cohorts/$cohortId/library', token: token);
  }

  @override
  Future<Map<String, dynamic>> requestRecordingStream(String token, int recordingId) async {
    return await apiClient.get('/student/recordings/$recordingId/stream', token: token);
  }

  @override
  Future<Map<String, dynamic>> requestMaterialAccess(String token, int materialId) async {
    return await apiClient.get('/student/materials/$materialId/access', token: token);
  }
}
