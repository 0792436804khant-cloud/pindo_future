import '../entities/study_cohort_entity.dart';

abstract class CohortRepository {
  Future<List<StudyCohortEntity>> getTeacherCohorts(String token);
  Future<StudyCohortEntity> createCohort(String token, Map<String, dynamic> body);
  Future<StudyCohortEntity> getCohortDetails(String token, int cohortId);
  Future<void> deleteCohort(String token, int cohortId);
  Future<List<Map<String, dynamic>>> getCohortMembers(String token, int cohortId);
  Future<Map<String, dynamic>> addCohortMember(String token, int cohortId, String studentIdentifier);
  Future<void> removeCohortMember(String token, int cohortId, int studentId);
  Future<Map<String, dynamic>> scheduleCohortSession(String token, int cohortId, Map<String, dynamic> body);

  Future<List<StudyCohortEntity>> getPublicCohorts({
    String? academicLevel,
    String? stream,
    String? subject,
    String? search,
    int? wilaya,
  });

  Future<List<StudyCohortEntity>> getStudentCohorts(String token);
  Future<StudyCohortEntity> joinCohort(String token, int cohortId);
  Future<void> leaveCohort(String token, int cohortId);
  Future<Map<String, dynamic>> requestVerification(String token, String document);
}
