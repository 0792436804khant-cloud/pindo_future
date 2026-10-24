import '../../domain/entities/exam_exercise_entity.dart';
import '../../domain/entities/exam_paper_entity.dart';
import '../../domain/entities/exam_simulation_entity.dart';
import '../../domain/repositories/exam_bank_repository.dart';
import '../datasources/exam_remote_datasource.dart';
import '../models/exam_exercise_model.dart';
import '../models/exam_paper_model.dart';
import '../models/exam_simulation_model.dart';

class ExamBankRepositoryImpl implements ExamBankRepository {
  final ExamRemoteDataSource remoteDataSource;

  ExamBankRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ExamPaperEntity>> getExamPapers({
    String? cycle,
    String? stream,
    String? subject,
    int? year,
    String? search,
  }) async {
    final response = await remoteDataSource.fetchExams(
      cycle: cycle,
      stream: stream,
      subject: subject,
      year: year,
      search: search,
    );

    final data = response['data'] as List? ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => ExamPaperModel.fromJson(item))
        .toList();
  }

  @override
  Future<({ExamPaperEntity paper, List<ExamExerciseEntity> exercises})> getExamPaperDetails(int id) async {
    final response = await remoteDataSource.fetchExamDetails(id);
    final data = response['data'] as Map<String, dynamic>? ?? {};

    final examData = data['exam'] as Map<String, dynamic>? ?? {};
    final exercisesData = data['exercises'] as List? ?? [];

    final paper = ExamPaperModel.fromJson(examData);
    final exercises = exercisesData
        .whereType<Map<String, dynamic>>()
        .map((item) => ExamExerciseModel.fromJson(item))
        .toList();

    return (paper: paper, exercises: exercises);
  }

  @override
  Future<ExamSimulationEntity> startSimulation(String token, int examId) async {
    final response = await remoteDataSource.startSimulation(token, examId);
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final simData = data['simulation'] as Map<String, dynamic>? ?? {};
    return ExamSimulationModel.fromJson(simData);
  }

  @override
  Future<ExamSimulationEntity> updateSimulationProgress(
    String token,
    int simulationId, {
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  }) async {
    final response = await remoteDataSource.updateSimulationProgress(
      token,
      simulationId,
      timeSpentSeconds: timeSpentSeconds,
      completedExercises: completedExercises,
      studentNotes: studentNotes,
    );
    final simData = response['data'] as Map<String, dynamic>? ?? {};
    return ExamSimulationModel.fromJson(simData);
  }

  @override
  Future<ExamSimulationEntity> finishSimulation(
    String token,
    int simulationId, {
    double? selfAssessmentScore,
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  }) async {
    final response = await remoteDataSource.finishSimulation(
      token,
      simulationId,
      selfAssessmentScore: selfAssessmentScore,
      timeSpentSeconds: timeSpentSeconds,
      completedExercises: completedExercises,
      studentNotes: studentNotes,
    );
    final data = response['data'] as Map<String, dynamic>? ?? {};
    final simData = data['simulation'] as Map<String, dynamic>? ?? {};
    return ExamSimulationModel.fromJson(simData);
  }

  @override
  Future<List<ExamSimulationEntity>> getStudentSimulations(String token) async {
    final response = await remoteDataSource.fetchStudentSimulations(token);
    final data = response['data'] as List? ?? [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) => ExamSimulationModel.fromJson(item))
        .toList();
  }
}
