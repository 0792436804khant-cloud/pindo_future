import 'exam_paper_entity.dart';

class ExamSimulationEntity {
  final int id;
  final String simulationCode;
  final int examPaperId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int timeSpentSeconds;
  final List<int> completedExercises;
  final double? selfAssessmentScore;
  final String? studentNotes;
  final String status; // in_progress, completed, abandoned
  final ExamPaperEntity? examPaper;

  const ExamSimulationEntity({
    required this.id,
    required this.simulationCode,
    required this.examPaperId,
    required this.startedAt,
    this.endedAt,
    required this.timeSpentSeconds,
    this.completedExercises = const [],
    this.selfAssessmentScore,
    this.studentNotes,
    required this.status,
    this.examPaper,
  });

  bool get isCompleted => status == 'completed';

  String get formattedTimeSpent {
    final minutes = timeSpentSeconds ~/ 60;
    final seconds = timeSpentSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
