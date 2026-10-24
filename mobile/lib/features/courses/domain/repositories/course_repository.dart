import '../entities/course_entity.dart';
import '../entities/course_lesson_entity.dart';
import '../entities/course_module_entity.dart';
import '../entities/enrollment_entity.dart';
import '../entities/teacher_showcase_entity.dart';

abstract class CourseRepository {
  /// Teacher Studio APIs
  Future<List<CourseEntity>> getTeacherCourses();
  Future<CourseEntity> createCourse({
    required String title,
    String? description,
    String? category,
    double? price,
    String? status,
  });
  Future<void> deleteCourse(int courseId);
  Future<CourseEntity> getCourseDetails(int courseId);
  Future<CourseModuleEntity> addModule(int courseId, {required String title, int? order});
  Future<CourseLessonEntity> addLesson(
    int moduleId, {
    required String title,
    String? type,
    int? classroomSessionId,
    int? durationMinutes,
  });

  /// Public Showcase & Deep Link APIs
  Future<TeacherShowcaseEntity> getTeacherPublicShowcase(String teacherId);
  Future<List<CourseEntity>> getPublicCourses({String? category, String? search});

  /// Student Enrollment APIs
  Future<List<EnrollmentEntity>> getStudentEnrolledCourses();
  Future<EnrollmentEntity> enrollInCourse(int courseId);
  Future<void> updateCourseProgress(int courseId, int progressPercentage);
}
