import '../../../../core/network/api_client.dart';

abstract class ExamRemoteDataSource {
  Future<Map<String, dynamic>> fetchExams({
    String? cycle,
    String? stream,
    String? subject,
    int? year,
    String? search,
  });

  Future<Map<String, dynamic>> fetchExamDetails(int id);

  Future<Map<String, dynamic>> startSimulation(String token, int examId);

  Future<Map<String, dynamic>> updateSimulationProgress(
    String token,
    int simulationId, {
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  });

  Future<Map<String, dynamic>> finishSimulation(
    String token,
    int simulationId, {
    double? selfAssessmentScore,
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  });

  Future<Map<String, dynamic>> fetchStudentSimulations(String token);
}

class ExamRemoteDataSourceImpl implements ExamRemoteDataSource {
  final ApiClient apiClient;

  ExamRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> fetchExams({
    String? cycle,
    String? stream,
    String? subject,
    int? year,
    String? search,
  }) async {
    final params = <String>[];
    if (cycle != null && cycle.isNotEmpty) params.add('cycle=$cycle');
    if (stream != null && stream.isNotEmpty) params.add('stream=$stream');
    if (subject != null && subject.isNotEmpty) params.add('subject=$subject');
    if (year != null) params.add('year=$year');
    if (search != null && search.isNotEmpty) params.add('search=${Uri.encodeComponent(search)}');

    final queryString = params.isNotEmpty ? '?${params.join('&')}' : '';
    final res = await apiClient.get('/exams$queryString');
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchExamDetails(int id) async {
    final res = await apiClient.get('/exams/$id');
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> startSimulation(String token, int examId) async {
    final res = await apiClient.post('/exams/$examId/simulations/start', token: token);
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateSimulationProgress(
    String token,
    int simulationId, {
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  }) async {
    final body = <String, dynamic>{};
    if (timeSpentSeconds != null) body['time_spent_seconds'] = timeSpentSeconds;
    if (completedExercises != null) body['completed_exercises'] = completedExercises;
    if (studentNotes != null) body['student_notes'] = studentNotes;

    final res = await apiClient.put(
      '/exams/simulations/$simulationId/progress',
      body: body,
      token: token,
    );
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> finishSimulation(
    String token,
    int simulationId, {
    double? selfAssessmentScore,
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  }) async {
    final body = <String, dynamic>{};
    if (selfAssessmentScore != null) body['self_assessment_score'] = selfAssessmentScore;
    if (timeSpentSeconds != null) body['time_spent_seconds'] = timeSpentSeconds;
    if (completedExercises != null) body['completed_exercises'] = completedExercises;
    if (studentNotes != null) body['student_notes'] = studentNotes;

    final res = await apiClient.post(
      '/exams/simulations/$simulationId/finish',
      body: body,
      token: token,
    );
    return res as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> fetchStudentSimulations(String token) async {
    final res = await apiClient.get('/student/exam-simulations', token: token);
    return res as Map<String, dynamic>;
  }
}
