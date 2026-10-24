import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../../domain/entities/teacher_showcase_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_remote_datasource.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  CourseRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  Future<String> _getRequiredToken() async {
    final token = await authLocalDataSource.getToken();
    if (token == null || token.isEmpty) {
      throw const AuthFailure('Authentication required. Please sign in.');
    }
    return token;
  }

  @override
  Future<List<CourseEntity>> getTeacherCourses() async {
    try {
      final token = await _getRequiredToken();
      final list = await remoteDataSource.fetchTeacherCourses(token);
      return list.map((json) => CourseEntity.fromJson(json as Map<String, dynamic>)).toList();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch teacher courses: $e');
    }
  }

  @override
  Future<CourseEntity> createCourse({
    required String title,
    String? description,
    String? category,
    double? price,
    String? status,
  }) async {
    try {
      final token = await _getRequiredToken();
      final body = {
        'title': title,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (price != null) 'price': price,
        if (status != null) 'status': status,
      };

      final data = await remoteDataSource.createCourse(token, body);
      return CourseEntity.fromJson(data);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to create course: $e');
    }
  }

  @override
  Future<void> deleteCourse(int courseId) async {
    try {
      final token = await _getRequiredToken();
      await remoteDataSource.deleteCourse(token, courseId);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to delete course: $e');
    }
  }

  @override
  Future<CourseEntity> getCourseDetails(int courseId) async {
    try {
      final token = await authLocalDataSource.getToken();
      final data = await remoteDataSource.fetchCourseDetails(courseId, token: token);
      return CourseEntity.fromJson(data);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to load course details: $e');
    }
  }

  @override
  Future<CourseModuleEntity> addModule(int courseId, {required String title, int? order}) async {
    try {
      final token = await _getRequiredToken();
      final data = await remoteDataSource.addModule(token, courseId, title, order);
      return CourseModuleEntity.fromJson(data);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to add module: $e');
    }
  }

  @override
  Future<CourseLessonEntity> addLesson(
    int moduleId, {
    required String title,
    String? type,
    int? classroomSessionId,
    int? durationMinutes,
  }) async {
    try {
      final token = await _getRequiredToken();
      final body = {
        'title': title,
        if (type != null) 'type': type,
        if (classroomSessionId != null) 'classroom_session_id': classroomSessionId,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
      };

      final data = await remoteDataSource.addLesson(token, moduleId, body);
      return CourseLessonEntity.fromJson(data);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to add lesson: $e');
    }
  }

  @override
  Future<TeacherShowcaseEntity> getTeacherPublicShowcase(String teacherId) async {
    try {
      final data = await remoteDataSource.fetchTeacherPublicShowcase(teacherId);
      return TeacherShowcaseEntity.fromJson(data);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to load teacher showcase: $e');
    }
  }

  @override
  Future<List<CourseEntity>> getPublicCourses({String? category, String? search}) async {
    try {
      final list = await remoteDataSource.fetchPublicCourses(category: category, search: search);
      return list.map((json) => CourseEntity.fromJson(json as Map<String, dynamic>)).toList();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to fetch public courses: $e');
    }
  }

  @override
  Future<List<EnrollmentEntity>> getStudentEnrolledCourses() async {
    try {
      final token = await _getRequiredToken();
      final list = await remoteDataSource.fetchStudentEnrolledCourses(token);
      return list.map((json) => EnrollmentEntity.fromJson(json as Map<String, dynamic>)).toList();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch student enrolled courses: $e');
    }
  }

  @override
  Future<EnrollmentEntity> enrollInCourse(int courseId) async {
    try {
      final token = await _getRequiredToken();
      final data = await remoteDataSource.enrollInCourse(token, courseId);
      return EnrollmentEntity.fromJson(data);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to enroll in course: $e');
    }
  }

  @override
  Future<void> updateCourseProgress(int courseId, int progressPercentage) async {
    try {
      final token = await _getRequiredToken();
      await remoteDataSource.updateCourseProgress(token, courseId, progressPercentage);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update progress: $e');
    }
  }
}
