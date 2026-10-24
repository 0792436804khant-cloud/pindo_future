import '../entities/exam_exercise_entity.dart';
import '../entities/exam_paper_entity.dart';
import '../entities/exam_simulation_entity.dart';

abstract class ExamBankRepository {
  Future<List<ExamPaperEntity>> getExamPapers({
    String? cycle,
    String? stream,
    String? subject,
    int? year,
    String? search,
  });

  Future<({ExamPaperEntity paper, List<ExamExerciseEntity> exercises})> getExamPaperDetails(int id);

  Future<ExamSimulationEntity> startSimulation(String token, int examId);

  Future<ExamSimulationEntity> updateSimulationProgress(
    String token,
    int simulationId, {
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  });

  Future<ExamSimulationEntity> finishSimulation(
    String token,
    int simulationId, {
    double? selfAssessmentScore,
    int? timeSpentSeconds,
    List<int>? completedExercises,
    String? studentNotes,
  });

  Future<List<ExamSimulationEntity>> getStudentSimulations(String token);
}
