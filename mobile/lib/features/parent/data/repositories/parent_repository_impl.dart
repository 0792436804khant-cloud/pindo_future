import '../../domain/entities/child_academic_course_entity.dart';
import '../../domain/entities/child_attendance_record_entity.dart';
import '../../domain/entities/child_overview_entity.dart';
import '../../domain/entities/child_schedule_entity.dart';
import '../../domain/entities/guardian_note_entity.dart';
import '../../domain/repositories/parent_repository.dart';
import '../datasources/parent_remote_datasource.dart';

class ParentRepositoryImpl implements ParentRepository {
  final ParentRemoteDataSource remoteDataSource;

  ParentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ChildOverviewEntity>> getChildren(String token) async {
    final raw = await remoteDataSource.fetchChildren(token);
    return raw
        .map((item) => ChildOverviewEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ChildOverviewEntity> linkChild(
    String token, {
    String? email,
    String? linkingCode,
    String? relationship,
  }) async {
    final raw = await remoteDataSource.linkChild(
      token,
      email: email,
      linkingCode: linkingCode,
      relationship: relationship,
    );
    return ChildOverviewEntity.fromJson(raw);
  }

  @override
  Future<List<ChildAcademicCourseEntity>> getAcademics(String token, int studentId) async {
    final raw = await remoteDataSource.fetchAcademics(token, studentId);
    return raw
        .map((item) => ChildAcademicCourseEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getAttendance(String token, int studentId) async {
    final raw = await remoteDataSource.fetchAttendance(token, studentId);
    final summary = raw['summary'] as Map<String, dynamic>? ?? {};
    final dataList = (raw['data'] as List<dynamic>?) ?? [];
    final records = dataList
        .map((item) => ChildAttendanceRecordEntity.fromJson(item as Map<String, dynamic>))
        .toList();

    return {
      'summary': summary,
      'records': records,
    };
  }

  @override
  Future<List<ChildScheduleEntity>> getSchedule(String token, int studentId) async {
    final raw = await remoteDataSource.fetchSchedule(token, studentId);
    return raw
        .map((item) => ChildScheduleEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<GuardianNoteEntity>> getNotes(String token, int studentId) async {
    final raw = await remoteDataSource.fetchNotes(token, studentId);
    return raw
        .map((item) => GuardianNoteEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GuardianNoteEntity> addNote(
    String token,
    int studentId, {
    required String title,
    required String content,
    String? type,
  }) async {
    final raw = await remoteDataSource.createNote(
      token,
      studentId,
      title: title,
      content: content,
      type: type,
    );
    return GuardianNoteEntity.fromJson(raw);
  }

  @override
  Future<void> acknowledgeNote(String token, int noteId) async {
    await remoteDataSource.acknowledgeNote(token, noteId);
  }
}
