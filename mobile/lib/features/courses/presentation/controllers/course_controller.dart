import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_lesson_entity.dart';
import '../../domain/entities/course_module_entity.dart';
import '../../domain/entities/enrollment_entity.dart';
import '../../domain/entities/teacher_showcase_entity.dart';
import '../../domain/repositories/course_repository.dart';

enum CourseUiState {
  initial,
  loading,
  loaded,
  error,
}

class CourseController extends ChangeNotifier {
  final CourseRepository courseRepository;

  CourseUiState _state = CourseUiState.initial;
  String? _errorMessage;
  String? _successMessage;

  // Teacher Studio Data
  List<CourseEntity> _teacherCourses = [];
  CourseEntity? _selectedCourse;
  bool _isCreatingCourse = false;
  bool _isDeletingCourse = false;
  bool _isAddingModule = false;
  bool _isAddingLesson = false;

  // Public Showcase & Discovery Data
  TeacherShowcaseEntity? _teacherShowcase;
  List<CourseEntity> _publicCourses = [];
  bool _isLoadingShowcase = false;

  // Student Enrollment Data
  List<EnrollmentEntity> _enrolledCourses = [];
  bool _isEnrolling = false;

  CourseController({required this.courseRepository});

  // Getters
  CourseUiState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == CourseUiState.loading;

  List<CourseEntity> get teacherCourses => List.unmodifiable(_teacherCourses);
  CourseEntity? get selectedCourse => _selectedCourse;
  bool get isCreatingCourse => _isCreatingCourse;
  bool get isDeletingCourse => _isDeletingCourse;
  bool get isAddingModule => _isAddingModule;
  bool get isAddingLesson => _isAddingLesson;

  TeacherShowcaseEntity? get teacherShowcase => _teacherShowcase;
  List<CourseEntity> get publicCourses => List.unmodifiable(_publicCourses);
  bool get isLoadingShowcase => _isLoadingShowcase;

  List<EnrollmentEntity> get enrolledCourses => List.unmodifiable(_enrolledCourses);
  bool get isEnrolling => _isEnrolling;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // Teacher Studio Operations
  // -------------------------------------------------------------

  /// Load all courses owned by the authenticated teacher
  Future<void> loadTeacherCourses() async {
    _state = CourseUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _teacherCourses = await courseRepository.getTeacherCourses();
      _state = CourseUiState.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _state = CourseUiState.error;
    } catch (e) {
      _errorMessage = 'Failed to load courses: $e';
      _state = CourseUiState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Create a new course in Teacher Studio
  Future<CourseEntity?> createCourse({
    required String title,
    String? description,
    String? category,
    double? price,
    String? status,
  }) async {
    _isCreatingCourse = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final course = await courseRepository.createCourse(
        title: title,
        description: description,
        category: category,
        price: price,
        status: status,
      );

      _teacherCourses = [course, ..._teacherCourses];
      _selectedCourse = course;
      _successMessage = "Course '${course.title}' created successfully.";
      return course;
    } on Failure catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to create course: $e';
      return null;
    } finally {
      _isCreatingCourse = false;
      notifyListeners();
    }
  }

  /// Delete a course in Teacher Studio
  Future<bool> deleteCourse(int courseId) async {
    _isDeletingCourse = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await courseRepository.deleteCourse(courseId);
      _teacherCourses = _teacherCourses.where((c) => c.id != courseId).toList();

      if (_selectedCourse?.id == courseId) {
        _selectedCourse = _teacherCourses.isNotEmpty ? _teacherCourses.first : null;
        if (_selectedCourse != null) {
          loadCourseDetails(_selectedCourse!.id);
        }
      }

      _successMessage = 'Course deleted successfully.';
      _state = CourseUiState.loaded;
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to delete course: $e';
      return false;
    } finally {
      _isDeletingCourse = false;
      notifyListeners();
    }
  }

  /// Fetch full curriculum hierarchy for a course
  Future<void> loadCourseDetails(int courseId) async {
    _state = CourseUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCourse = await courseRepository.getCourseDetails(courseId);
      _state = CourseUiState.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _state = CourseUiState.error;
    } catch (e) {
      _errorMessage = 'Failed to load course details: $e';
      _state = CourseUiState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Add a curriculum module / chapter to the selected course
  Future<CourseModuleEntity?> addModule(int courseId, {required String title, int? order}) async {
    _isAddingModule = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final module = await courseRepository.addModule(courseId, title: title, order: order);

      if (_selectedCourse != null && _selectedCourse!.id == courseId) {
        final updatedModules = [..._selectedCourse!.modules, module];
        _selectedCourse = CourseEntity(
          id: _selectedCourse!.id,
          teacherId: _selectedCourse!.teacherId,
          title: _selectedCourse!.title,
          slug: _selectedCourse!.slug,
          description: _selectedCourse!.description,
          category: _selectedCourse!.category,
          price: _selectedCourse!.price,
          isFree: _selectedCourse!.isFree,
          thumbnailUrl: _selectedCourse!.thumbnailUrl,
          status: _selectedCourse!.status,
          modulesCount: updatedModules.length,
          lessonsCount: _selectedCourse!.lessonsCount,
          enrolledStudentsCount: _selectedCourse!.enrolledStudentsCount,
          modules: updatedModules,
          teacherName: _selectedCourse!.teacherName,
          teacherHeadline: _selectedCourse!.teacherHeadline,
        );
      }

      _successMessage = "Module '${module.title}' added.";
      return module;
    } on Failure catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to add module: $e';
      return null;
    } finally {
      _isAddingModule = false;
      notifyListeners();
    }
  }

  /// Add a lesson to a curriculum module (optionally bound to a live session)
  Future<CourseLessonEntity?> addLesson(
    int moduleId, {
    required String title,
    String? type,
    int? classroomSessionId,
    int? durationMinutes,
  }) async {
    _isAddingLesson = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final lesson = await courseRepository.addLesson(
        moduleId,
        title: title,
        type: type,
        classroomSessionId: classroomSessionId,
        durationMinutes: durationMinutes,
      );

      // Refresh course details to keep curriculum reactive
      if (_selectedCourse != null) {
        await loadCourseDetails(_selectedCourse!.id);
      }

      _successMessage = "Lesson '${lesson.title}' added.";
      return lesson;
    } on Failure catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to add lesson: $e';
      return null;
    } finally {
      _isAddingLesson = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // Public Showcase & Discovery Operations
  // -------------------------------------------------------------

  /// Load public teacher showcase (serves deep link: pindofuture.com/teacher/{teacher_id})
  Future<void> loadTeacherShowcase(String teacherId) async {
    _isLoadingShowcase = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _teacherShowcase = await courseRepository.getTeacherPublicShowcase(teacherId);
    } on Failure catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load teacher showcase: $e';
    } finally {
      _isLoadingShowcase = false;
      notifyListeners();
    }
  }

  /// Load public course catalog
  Future<void> loadPublicCourses({String? category, String? search}) async {
    _state = CourseUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _publicCourses = await courseRepository.getPublicCourses(category: category, search: search);
      _state = CourseUiState.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _state = CourseUiState.error;
    } catch (e) {
      _errorMessage = 'Failed to load public courses: $e';
      _state = CourseUiState.error;
    } finally {
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // Student Enrollment Operations
  // -------------------------------------------------------------

  /// Load all courses enrolled by the authenticated student
  Future<void> loadStudentEnrolledCourses() async {
    _state = CourseUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _enrolledCourses = await courseRepository.getStudentEnrolledCourses();
      _state = CourseUiState.loaded;
    } on Failure catch (e) {
      _errorMessage = e.message;
      _state = CourseUiState.error;
    } catch (e) {
      _errorMessage = 'Failed to load enrolled courses: $e';
      _state = CourseUiState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Enroll student in a course
  Future<bool> enrollInCourse(int courseId) async {
    _isEnrolling = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final enrollment = await courseRepository.enrollInCourse(courseId);
      _enrolledCourses = [enrollment, ..._enrolledCourses];
      _successMessage = "Enrolled successfully!";
      return true;
    } on Failure catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to enroll: $e';
      return false;
    } finally {
      _isEnrolling = false;
      notifyListeners();
    }
  }

  /// Update student's progress in an enrolled course
  Future<void> updateProgress(int courseId, int percentage) async {
    try {
      await courseRepository.updateCourseProgress(courseId, percentage);
      await loadStudentEnrolledCourses();
    } on Failure catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update progress: $e';
      notifyListeners();
    }
  }
}
