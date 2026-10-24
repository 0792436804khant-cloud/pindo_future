import '../../domain/entities/exam_exercise_entity.dart';

class ExamExerciseModel extends ExamExerciseEntity {
  const ExamExerciseModel({
    required super.id,
    required super.examPaperId,
    required super.exerciseNumber,
    required super.title,
    super.topic,
    required super.points,
    super.instructions,
    super.officialMarkingRubric = const [],
    super.solutionExplanation,
  });

  factory ExamExerciseModel.fromJson(Map<String, dynamic> json) {
    List<ExamRubricStepEntity> rubric = [];
    if (json['official_marking_rubric'] is List) {
      rubric = (json['official_marking_rubric'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => ExamRubricStepEntity.fromJson(item))
          .toList();
    }

    return ExamExerciseModel(
      id: json['id'] as int? ?? 0,
      examPaperId: json['exam_paper_id'] as int? ?? 0,
      exerciseNumber: json['exercise_number'] as int? ?? 1,
      title: json['title']?.toString() ?? '',
      topic: json['topic']?.toString(),
      points: (json['points'] is num) ? (json['points'] as num).toDouble() : 4.0,
      instructions: json['instructions']?.toString(),
      officialMarkingRubric: rubric,
      solutionExplanation: json['solution_explanation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_paper_id': examPaperId,
    'exercise_number': exerciseNumber,
    'title': title,
    'topic': topic,
    'points': points,
    'instructions': instructions,
    'official_marking_rubric': officialMarkingRubric.map((r) => r.toJson()).toList(),
    'solution_explanation': solutionExplanation,
  };
}
