class ExamPaperEntity {
  final int id;
  final String examCode;
  final String title;
  final String cycle; // bem, bac
  final String? stream;
  final String subject;
  final String subjectNameAr;
  final int year;
  final String sessionType;
  final int optionNumber;
  final int durationMinutes;
  final int coefficient;
  final int totalScore;
  final String? paperPdfUrl;
  final String? solutionPdfUrl;
  final String? description;
  final String difficultyLevel;
  final int exerciseCount;
  final int viewsCount;
  final int downloadsCount;

  const ExamPaperEntity({
    required this.id,
    required this.examCode,
    required this.title,
    required this.cycle,
    this.stream,
    required this.subject,
    required this.subjectNameAr,
    required this.year,
    required this.sessionType,
    required this.optionNumber,
    required this.durationMinutes,
    required this.coefficient,
    required this.totalScore,
    this.paperPdfUrl,
    this.solutionPdfUrl,
    this.description,
    required this.difficultyLevel,
    required this.exerciseCount,
    required this.viewsCount,
    required this.downloadsCount,
  });

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0 && minutes > 0) {
      return '$hours سا $minutes د';
    } else if (hours > 0) {
      return '$hours سا';
    }
    return '$minutes دقيقة';
  }

  String get cycleBadge => cycle.toUpperCase();

  bool get hasOfficialSolution => solutionPdfUrl != null && solutionPdfUrl!.isNotEmpty;

  String get streamDisplayAr {
    if (cycle.toLowerCase() == 'bem') {
      return 'التعليم المتوسط (عام)';
    }
    switch (stream) {
      case 'experimental_sciences':
        return 'علوم تجريبية';
      case 'mathematics':
        return 'رياضيات';
      case 'math_technical':
        return 'تقني رياضي';
      case 'management_economics':
        return 'تسيير واقتصاد';
      case 'foreign_languages':
        return 'لغات أجنبية';
      case 'literature_philosophy':
        return 'آداب وفلسفة';
      default:
        return stream ?? 'عام';
    }
  }
}
