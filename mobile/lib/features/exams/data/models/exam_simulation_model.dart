import '../../domain/entities/exam_simulation_entity.dart';
import 'exam_paper_model.dart';

class ExamSimulationModel extends ExamSimulationEntity {
  const ExamSimulationModel({
    required super.id,
    required super.simulationCode,
    required super.examPaperId,
    required super.startedAt,
    super.endedAt,
    required super.timeSpentSeconds,
    super.completedExercises = const [],
    super.selfAssessmentScore,
    super.studentNotes,
    required super.status,
    super.examPaper,
  });

  factory ExamSimulationModel.fromJson(Map<String, dynamic> json) {
    List<int> completed = [];
    if (json['completed_exercises'] is List) {
      completed = (json['completed_exercises'] as List)
          .whereType<num>()
          .map((n) => n.toInt())
          .toList();
    }

    ExamPaperModel? paper;
    if (json['exam_paper'] is Map<String, dynamic>) {
      paper = ExamPaperModel.fromJson(json['exam_paper'] as Map<String, dynamic>);
    }

    return ExamSimulationModel(
      id: json['id'] as int? ?? 0,
      simulationCode: json['simulation_code']?.toString() ?? '',
      examPaperId: json['exam_paper_id'] as int? ?? 0,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      timeSpentSeconds: json['time_spent_seconds'] as int? ?? 0,
      completedExercises: completed,
      selfAssessmentScore: (json['self_assessment_score'] is num)
          ? (json['self_assessment_score'] as num).toDouble()
          : null,
      studentNotes: json['student_notes']?.toString(),
      status: json['status']?.toString() ?? 'in_progress',
      examPaper: paper,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'simulation_code': simulationCode,
    'exam_paper_id': examPaperId,
    'started_at': startedAt.toIso8601String(),
    'ended_at': endedAt?.toIso8601String(),
    'time_spent_seconds': timeSpentSeconds,
    'completed_exercises': completedExercises,
    'self_assessment_score': selfAssessmentScore,
    'student_notes': studentNotes,
    'status': status,
  };
}
