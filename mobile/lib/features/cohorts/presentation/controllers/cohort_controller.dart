import 'package:flutter/material.dart';
import '../../domain/entities/study_cohort_entity.dart';
import '../../domain/repositories/cohort_repository.dart';

enum CohortUiState { initial, loading, loaded, error }

class CohortController extends ChangeNotifier {
  final CohortRepository cohortRepository;

  CohortUiState _state = CohortUiState.initial;
  String? _errorMessage;
  String? _successMessage;

  // Teacher Cohort Data
  List<StudyCohortEntity> _teacherCohorts = [];
  StudyCohortEntity? _selectedCohort;
  List<Map<String, dynamic>> _cohortMembers = [];
  bool _isCreating = false;
  bool _isSubmittingVerification = false;

  // Student & Public Cohorts
  List<StudyCohortEntity> _publicCohorts = [];
  List<StudyCohortEntity> _studentCohorts = [];
  bool _isJoining = false;

  CohortController({required this.cohortRepository});

  CohortUiState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == CohortUiState.loading;

  List<StudyCohortEntity> get teacherCohorts => List.unmodifiable(_teacherCohorts);
  StudyCohortEntity? get selectedCohort => _selectedCohort;
  List<Map<String, dynamic>> get cohortMembers => List.unmodifiable(_cohortMembers);
  bool get isCreating => _isCreating;
  bool get isSubmittingVerification => _isSubmittingVerification;

  List<StudyCohortEntity> get publicCohorts => List.unmodifiable(_publicCohorts);
  List<StudyCohortEntity> get studentCohorts => List.unmodifiable(_studentCohorts);
  bool get isJoining => _isJoining;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Load teacher's cohorts
  Future<void> loadTeacherCohorts(String token) async {
    _state = CohortUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _teacherCohorts = await cohortRepository.getTeacherCohorts(token);
      _state = CohortUiState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CohortUiState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Create a new cohort
  Future<bool> createCohort(String token, Map<String, dynamic> body) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cohort = await cohortRepository.createCohort(token, body);
      _teacherCohorts = [cohort, ..._teacherCohorts];
      _successMessage = 'تم إنشاء الفوج بنجاح';
      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a cohort
  Future<bool> deleteCohort(String token, int cohortId) async {
    try {
      await cohortRepository.deleteCohort(token, cohortId);
      _teacherCohorts.removeWhere((c) => c.id == cohortId);
      _successMessage = 'تم حذف الفوج بنجاح';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load members of a cohort
  Future<void> loadCohortMembers(String token, int cohortId) async {
    try {
      _cohortMembers = await cohortRepository.getCohortMembers(token, cohortId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Manually add member to cohort
  Future<bool> addMember(String token, int cohortId, String identifier) async {
    try {
      final result = await cohortRepository.addCohortMember(token, cohortId, identifier);
      await loadCohortMembers(token, cohortId);
      await loadTeacherCohorts(token);
      _successMessage = result['message']?.toString() ?? 'تمت إضافة التلميذ بنجاح';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove member from cohort
  Future<bool> removeMember(String token, int cohortId, int studentId) async {
    try {
      await cohortRepository.removeCohortMember(token, cohortId, studentId);
      _cohortMembers.removeWhere((m) => m['student_id'] == studentId);
      await loadTeacherCohorts(token);
      _successMessage = 'تم حذف التلميذ من الفوج';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Schedule live session for cohort
  Future<bool> scheduleSession(String token, int cohortId, Map<String, dynamic> body) async {
    try {
      await cohortRepository.scheduleCohortSession(token, cohortId, body);
      _successMessage = 'تمت جدولة الحصة المباشرة للفوج بنجاح';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Public cohort discovery
  Future<void> loadPublicCohorts({
    String? academicLevel,
    String? stream,
    String? subject,
    String? search,
    int? wilaya,
  }) async {
    _state = CohortUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _publicCohorts = await cohortRepository.getPublicCohorts(
        academicLevel: academicLevel,
        stream: stream,
        subject: subject,
        search: search,
        wilaya: wilaya,
      );
      _state = CohortUiState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CohortUiState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Load student enrolled cohorts
  Future<void> loadStudentCohorts(String token) async {
    _state = CohortUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _studentCohorts = await cohortRepository.getStudentCohorts(token);
      _state = CohortUiState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CohortUiState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Join a cohort
  Future<bool> joinCohort(String token, int cohortId) async {
    _isJoining = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cohort = await cohortRepository.joinCohort(token, cohortId);
      _studentCohorts = [cohort, ..._studentCohorts];
      _successMessage = 'تم الانضمام إلى الفوج بنجاح!';
      _isJoining = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isJoining = false;
      notifyListeners();
      return false;
    }
  }

  /// Leave a cohort
  Future<bool> leaveCohort(String token, int cohortId) async {
    try {
      await cohortRepository.leaveCohort(token, cohortId);
      _studentCohorts.removeWhere((c) => c.id == cohortId);
      _successMessage = 'تمت مغادرة الفوج بنجاح';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Teacher submits verification documents
  Future<bool> submitVerification(String token, String document) async {
    _isSubmittingVerification = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await cohortRepository.requestVerification(token, document);
      _successMessage = 'تم إرسال طلب التوثيق للمراجعة بنجاح';
      _isSubmittingVerification = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmittingVerification = false;
      notifyListeners();
      return false;
    }
  }
}
