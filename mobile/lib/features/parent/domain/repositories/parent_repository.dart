import '../entities/child_academic_course_entity.dart';
import '../entities/child_overview_entity.dart';
import '../entities/child_schedule_entity.dart';
import '../entities/guardian_note_entity.dart';

abstract class ParentRepository {
  Future<List<ChildOverviewEntity>> getChildren(String token);

  Future<ChildOverviewEntity> linkChild(
    String token, {
    String? email,
    String? linkingCode,
    String? relationship,
  });

  Future<List<ChildAcademicCourseEntity>> getAcademics(String token, int studentId);

  Future<Map<String, dynamic>> getAttendance(String token, int studentId);

  Future<List<ChildScheduleEntity>> getSchedule(String token, int studentId);

  Future<List<GuardianNoteEntity>> getNotes(String token, int studentId);

  Future<GuardianNoteEntity> addNote(
    String token,
    int studentId, {
    required String title,
    required String content,
    String? type,
  });

  Future<void> acknowledgeNote(String token, int noteId);
}
