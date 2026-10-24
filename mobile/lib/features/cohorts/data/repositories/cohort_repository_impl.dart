import '../../data/datasources/cohort_remote_datasource.dart';
import '../../data/models/study_cohort_model.dart';
import '../../domain/entities/study_cohort_entity.dart';
import '../../domain/repositories/cohort_repository.dart';

class CohortRepositoryImpl implements CohortRepository {
  final CohortRemoteDataSource remoteDataSource;

  CohortRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StudyCohortEntity>> getTeacherCohorts(String token) async {
    final rawList = await remoteDataSource.fetchTeacherCohorts(token);
    return rawList
        .map((e) => StudyCohortModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StudyCohortEntity> createCohort(String token, Map<String, dynamic> body) async {
    final raw = await remoteDataSource.createCohort(token, body);
    return StudyCohortModel.fromJson(raw);
  }

  @override
  Future<StudyCohortEntity> getCohortDetails(String token, int cohortId) async {
    final raw = await remoteDataSource.fetchCohortDetails(token, cohortId);
    return StudyCohortModel.fromJson(raw);
  }

  @override
  Future<void> deleteCohort(String token, int cohortId) async {
    await remoteDataSource.deleteCohort(token, cohortId);
  }

  @override
  Future<List<Map<String, dynamic>>> getCohortMembers(String token, int cohortId) async {
    final rawList = await remoteDataSource.fetchCohortMembers(token, cohortId);
    return rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<Map<String, dynamic>> addCohortMember(
      String token, int cohortId, String studentIdentifier) async {
    return await remoteDataSource.addCohortMember(token, cohortId, studentIdentifier);
  }

  @override
  Future<void> removeCohortMember(String token, int cohortId, int studentId) async {
    await remoteDataSource.removeCohortMember(token, cohortId, studentId);
  }

  @override
  Future<Map<String, dynamic>> scheduleCohortSession(
      String token, int cohortId, Map<String, dynamic> body) async {
    return await remoteDataSource.scheduleCohortSession(token, cohortId, body);
  }

  @override
  Future<List<StudyCohortEntity>> getPublicCohorts({
    String? academicLevel,
    String? stream,
    String? subject,
    String? search,
    int? wilaya,
  }) async {
    final rawList = await remoteDataSource.fetchPublicCohorts(
      academicLevel: academicLevel,
      stream: stream,
      subject: subject,
      search: search,
      wilaya: wilaya,
    );
    return rawList
        .map((e) => StudyCohortModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<StudyCohortEntity>> getStudentCohorts(String token) async {
    final rawList = await remoteDataSource.fetchStudentCohorts(token);
    return rawList
        .map((e) => StudyCohortModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<StudyCohortEntity> joinCohort(String token, int cohortId) async {
    final raw = await remoteDataSource.joinCohort(token, cohortId);
    return StudyCohortModel.fromJson(raw);
  }

  @override
  Future<void> leaveCohort(String token, int cohortId) async {
    await remoteDataSource.leaveCohort(token, cohortId);
  }

  @override
  Future<Map<String, dynamic>> requestVerification(String token, String document) async {
    return await remoteDataSource.requestVerification(token, document);
  }
}
