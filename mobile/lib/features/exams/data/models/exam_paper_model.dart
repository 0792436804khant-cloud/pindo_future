import '../../domain/entities/exam_paper_entity.dart';

class ExamPaperModel extends ExamPaperEntity {
  const ExamPaperModel({
    required super.id,
    required super.examCode,
    required super.title,
    required super.cycle,
    super.stream,
    required super.subject,
    required super.subjectNameAr,
    required super.year,
    required super.sessionType,
    required super.optionNumber,
    required super.durationMinutes,
    required super.coefficient,
    required super.totalScore,
    super.paperPdfUrl,
    super.solutionPdfUrl,
    super.description,
    required super.difficultyLevel,
    required super.exerciseCount,
    required super.viewsCount,
    required super.downloadsCount,
  });

  factory ExamPaperModel.fromJson(Map<String, dynamic> json) {
    return ExamPaperModel(
      id: json['id'] as int? ?? 0,
      examCode: json['exam_code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      cycle: json['cycle']?.toString() ?? 'bac',
      stream: json['stream']?.toString(),
      subject: json['subject']?.toString() ?? '',
      subjectNameAr: json['subject_name_ar']?.toString() ?? '',
      year: json['year'] as int? ?? DateTime.now().year,
      sessionType: json['session_type']?.toString() ?? 'main',
      optionNumber: json['option_number'] as int? ?? 1,
      durationMinutes: json['duration_minutes'] as int? ?? 180,
      coefficient: json['coefficient'] as int? ?? 5,
      totalScore: json['total_score'] as int? ?? 20,
      paperPdfUrl: json['paper_pdf_url']?.toString(),
      solutionPdfUrl: json['solution_pdf_url']?.toString(),
      description: json['description']?.toString(),
      difficultyLevel: json['difficulty_level']?.toString() ?? 'medium',
      exerciseCount: json['exercise_count'] as int? ?? 4,
      viewsCount: json['views_count'] as int? ?? 0,
      downloadsCount: json['downloads_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'exam_code': examCode,
    'title': title,
    'cycle': cycle,
    'stream': stream,
    'subject': subject,
    'subject_name_ar': subjectNameAr,
    'year': year,
    'session_type': sessionType,
    'option_number': optionNumber,
    'duration_minutes': durationMinutes,
    'coefficient': coefficient,
    'total_score': totalScore,
    'paper_pdf_url': paperPdfUrl,
    'solution_pdf_url': solutionPdfUrl,
    'description': description,
    'difficulty_level': difficultyLevel,
    'exercise_count': exerciseCount,
    'views_count': viewsCount,
    'downloads_count': downloadsCount,
  };
}
