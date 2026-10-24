import 'package:flutter/foundation.dart';
import '../../domain/entities/child_academic_course_entity.dart';
import '../../domain/entities/child_attendance_record_entity.dart';
import '../../domain/entities/child_overview_entity.dart';
import '../../domain/entities/child_schedule_entity.dart';
import '../../domain/entities/guardian_note_entity.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentController extends ChangeNotifier {
  final ParentRepository repository;
  final String authToken;

  ParentController({
    required this.repository,
    required this.authToken,
  });

  List<ChildOverviewEntity> _children = [];
  ChildOverviewEntity? _selectedChild;

  List<ChildAcademicCourseEntity> _academics = [];
  List<ChildAttendanceRecordEntity> _attendanceRecords = [];
  Map<String, dynamic> _attendanceSummary = {};
  List<ChildScheduleEntity> _schedule = [];
  List<GuardianNoteEntity> _notes = [];

  bool _isLoading = false;
  bool _isActionLoading = false;
  String? _errorMessage;
  String? _successMessage;
  int _activeTabIndex = 0;

  List<ChildOverviewEntity> get children => _children;
  ChildOverviewEntity? get selectedChild => _selectedChild;
  List<ChildAcademicCourseEntity> get academics => _academics;
  List<ChildAttendanceRecordEntity> get attendanceRecords => _attendanceRecords;
  Map<String, dynamic> get attendanceSummary => _attendanceSummary;
  List<ChildScheduleEntity> get schedule => _schedule;
  List<GuardianNoteEntity> get notes => _notes;
  bool get isLoading => _isLoading;
  bool get isActionLoading => _isActionLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get activeTabIndex => _activeTabIndex;

  void setActiveTab(int index) {
    _activeTabIndex = index;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadChildren() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _children = await repository.getChildren(authToken);
      if (_children.isNotEmpty) {
        if (_selectedChild == null || !_children.any((c) => c.id == _selectedChild!.id)) {
          _selectedChild = _children.first;
        } else {
          _selectedChild = _children.firstWhere((c) => c.id == _selectedChild!.id);
        }
        await loadChildDetails(_selectedChild!.id);
      } else {
        _selectedChild = null;
        _academics = [];
        _attendanceRecords = [];
        _attendanceSummary = {};
        _schedule = [];
        _notes = [];
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectChild(ChildOverviewEntity child) async {
    _selectedChild = child;
    notifyListeners();
    await loadChildDetails(child.id);
  }

  Future<void> loadChildDetails(int studentId) async {
    try {
      final futures = await Future.wait([
        repository.getAcademics(authToken, studentId),
        repository.getAttendance(authToken, studentId),
        repository.getSchedule(authToken, studentId),
        repository.getNotes(authToken, studentId),
      ]);

      _academics = futures[0] as List<ChildAcademicCourseEntity>;
      final attData = futures[1] as Map<String, dynamic>;
      _attendanceRecords = (attData['records'] as List<ChildAttendanceRecordEntity>?) ?? [];
      _attendanceSummary = (attData['summary'] as Map<String, dynamic>?) ?? {};
      _schedule = futures[2] as List<ChildScheduleEntity>;
      _notes = futures[3] as List<GuardianNoteEntity>;
    } catch (e) {
      _errorMessage = 'Failed to load student details: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<bool> linkChild({
    required String email,
    required String relationship,
    String? linkingCode,
  }) async {
    _isActionLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await repository.linkChild(
        authToken,
        email: email.trim(),
        relationship: relationship.trim(),
        linkingCode: linkingCode?.trim(),
      );
      _successMessage = 'Child successfully linked to your guardian portal!';
      await loadChildren();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendNote({
    required String title,
    required String content,
    String? type,
  }) async {
    if (_selectedChild == null) return false;

    _isActionLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newNote = await repository.addNote(
        authToken,
        _selectedChild!.id,
        title: title,
        content: content,
        type: type,
      );
      _notes.insert(0, newNote);
      _successMessage = 'Note sent to course instructors.';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  Future<void> acknowledgeNote(int noteId) async {
    try {
      await repository.acknowledgeNote(authToken, noteId);
      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        final old = _notes[index];
        _notes[index] = GuardianNoteEntity(
          id: old.id,
          title: old.title,
          content: old.content,
          type: old.type,
          isAcknowledged: true,
          createdAt: old.createdAt,
          authorName: old.authorName,
          authorRole: old.authorRole,
        );
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Could not acknowledge note: $e';
      notifyListeners();
    }
  }
}
