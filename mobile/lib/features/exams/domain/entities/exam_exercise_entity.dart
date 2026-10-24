class ExamRubricStepEntity {
  final String step;
  final double points;

  const ExamRubricStepEntity({
    required this.step,
    required this.points,
  });

  factory ExamRubricStepEntity.fromJson(Map<String, dynamic> json) {
    return ExamRubricStepEntity(
      step: json['step']?.toString() ?? '',
      points: (json['points'] is num) ? (json['points'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'step': step,
    'points': points,
  };
}

class ExamExerciseEntity {
  final int id;
  final int examPaperId;
  final int exerciseNumber;
  final String title;
  final String? topic;
  final double points;
  final String? instructions;
  final List<ExamRubricStepEntity> officialMarkingRubric;
  final String? solutionExplanation;

  const ExamExerciseEntity({
    required this.id,
    required this.examPaperId,
    required this.exerciseNumber,
    required this.title,
    this.topic,
    required this.points,
    this.instructions,
    this.officialMarkingRubric = const [],
    this.solutionExplanation,
  });
}
