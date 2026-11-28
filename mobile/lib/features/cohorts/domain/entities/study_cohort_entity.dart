import '../../../../core/constants/algerian_education_constants.dart';

class StudyCohortEntity {
  final int id;
  final String cohortCode;
  final int teacherId;
  final String? teacherName;
  final bool isTeacherVerified;
  final int? teacherWilaya;
  final String name;
  final String subject;
  final String academicLevel;
  final String? stream;
  final int maxStudents;
  final int enrolledCount;
  final double monthlyPrice;
  final double liveSessionsPrice;
  final double libraryPrice;
  final double bundlePrice;
  final bool includeLibrary;
  final int includedSessionsCount;
  final int extraSessionsCount;
  final bool extraSessionsIsPaid;
  final double extraSessionPriceDzd;
  final String? teacherBio;
  final String? teacherHeadline;
  final int? teacherYearsExperience;
  final String? teacherAvatarUrl;
  final List<String> teacherSubjects;
  final List<String> teacherYears;
  final List<Map<String, dynamic>> schedule;
  final bool isActive;
  final String? description;
  final List<dynamic> sessions;

  const StudyCohortEntity({
    required this.id,
    required this.cohortCode,
    required this.teacherId,
    this.teacherName,
    this.isTeacherVerified = false,
    this.teacherWilaya,
    required this.name,
    required this.subject,
    required this.academicLevel,
    this.stream,
    this.maxStudents = 100,
    this.enrolledCount = 0,
    this.monthlyPrice = 0.0,
    double? liveSessionsPrice,
    this.libraryPrice = 0.0,
    double? bundlePrice,
    this.includeLibrary = true,
    this.includedSessionsCount = 8,
    this.extraSessionsCount = 0,
    this.extraSessionsIsPaid = false,
    this.extraSessionPriceDzd = 0.0,
    this.teacherBio,
    this.teacherHeadline,
    this.teacherYearsExperience,
    this.teacherAvatarUrl,
    this.teacherSubjects = const [],
    this.teacherYears = const [],
    this.schedule = const [],
    this.isActive = true,
    this.description,
    this.sessions = const [],
  })  : liveSessionsPrice = liveSessionsPrice ?? monthlyPrice,
        bundlePrice = bundlePrice ?? monthlyPrice;

  bool get isFull => enrolledCount >= maxStudents;

  int get availableSeats => (maxStudents - enrolledCount).clamp(0, maxStudents);

  String get formattedPrice =>
      monthlyPrice == 0 ? 'مجاني' : '${monthlyPrice.toStringAsFixed(0)} دج/شهرياً';

  String get wilayaName => AlgerianEducationConstants.getWilayaName(teacherWilaya);
}
