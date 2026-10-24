import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/exam_exercise_entity.dart';
import '../../domain/entities/exam_paper_entity.dart';
import '../../domain/entities/exam_simulation_entity.dart';
import '../../domain/repositories/exam_bank_repository.dart';

class ExamBankController extends ChangeNotifier {
  final ExamBankRepository repository;
  final String? userToken;

  ExamBankController({
    required this.repository,
    this.userToken,
  });

  // Filters
  String _selectedCycle = 'all'; // all, bac, bem
  String? _selectedStream;
  String? _selectedSubject;
  int? _selectedYear;
  String _searchQuery = '';

  // Data states
  List<ExamPaperEntity> _exams = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Single paper details
  ExamPaperEntity? _selectedExam;
  List<ExamExerciseEntity> _currentExercises = [];
  bool _isLoadingDetails = false;

  // Timed Simulation Engine
  ExamSimulationEntity? _activeSimulation;
  Timer? _simulationTimer;
  int _remainingSeconds = 0;
  int _elapsedSeconds = 0;
  bool _isSimulationRunning = false;
  final Set<int> _completedExerciseNumbers = {};
  String _simulationNotes = '';
  List<ExamSimulationEntity> _studentHistory = [];

  // Getters
  String get selectedCycle => _selectedCycle;
  String? get selectedStream => _selectedStream;
  String? get selectedSubject => _selectedSubject;
  int? get selectedYear => _selectedYear;
  String get searchQuery => _searchQuery;

  List<ExamPaperEntity> get exams => List.unmodifiable(_exams);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ExamPaperEntity? get selectedExam => _selectedExam;
  List<ExamExerciseEntity> get currentExercises => List.unmodifiable(_currentExercises);
  bool get isLoadingDetails => _isLoadingDetails;

  ExamSimulationEntity? get activeSimulation => _activeSimulation;
  int get remainingSeconds => _remainingSeconds;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isSimulationRunning => _isSimulationRunning;
  Set<int> get completedExerciseNumbers => Set.unmodifiable(_completedExerciseNumbers);
  String get simulationNotes => _simulationNotes;
  List<ExamSimulationEntity> get studentHistory => List.unmodifiable(_studentHistory);

  String get formattedRemainingTime {
    final hours = _remainingSeconds ~/ 3600;
    final minutes = (_remainingSeconds % 3600) ~/ 60;
    final seconds = _remainingSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isNearTimeLimit => _remainingSeconds <= 1800 && _remainingSeconds > 0; // <= 30 mins
  bool get isCriticalTimeLimit => _remainingSeconds <= 300 && _remainingSeconds > 0; // <= 5 mins

  // Filter setters
  void setCycle(String cycle) {
    _selectedCycle = cycle;
    if (cycle == 'bem') {
      _selectedStream = null; // BEM has no streams
    }
    notifyListeners();
    loadExams();
  }

  void setStream(String? stream) {
    _selectedStream = stream;
    notifyListeners();
    loadExams();
  }

  void setSubject(String? subject) {
    _selectedSubject = subject;
    notifyListeners();
    loadExams();
  }

  void setYear(int? year) {
    _selectedYear = year;
    notifyListeners();
    loadExams();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
    loadExams();
  }

  Future<void> loadExams() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cycleFilter = _selectedCycle == 'all' ? null : _selectedCycle;
      _exams = await repository.getExamPapers(
        cycle: cycleFilter,
        stream: _selectedStream,
        subject: _selectedSubject,
        year: _selectedYear,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );
    } catch (e) {
      _errorMessage = 'تعذر تحميل مواضيع الامتحانات، يرجى المحاولة ثانية ($e)';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExamDetails(int examId) async {
    _isLoadingDetails = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.getExamPaperDetails(examId);
      _selectedExam = result.paper;
      _currentExercises = result.exercises;
    } catch (e) {
      _errorMessage = 'تعذر تحميل تفاصيل الامتحان ($e)';
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // --- Timed Simulation Engine Methods ---

  Future<void> startSimulation(ExamPaperEntity paper) async {
    if (userToken == null || userToken!.isEmpty) {
      _errorMessage = 'يرجى تسجيل الدخول لبدء محاكاة الامتحان المؤقتة.';
      notifyListeners();
      return;
    }

    _selectedExam = paper;
    _remainingSeconds = paper.durationMinutes * 60;
    _elapsedSeconds = 0;
    _completedExerciseNumbers.clear();
    _simulationNotes = '';
    _isSimulationRunning = true;
    notifyListeners();

    try {
      _activeSimulation = await repository.startSimulation(userToken!, paper.id);

      // Start ticking timer
      _simulationTimer?.cancel();
      _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          _elapsedSeconds++;
          notifyListeners();

          // Sync progress periodically every 60 seconds
          if (_elapsedSeconds % 60 == 0 && _activeSimulation != null) {
            _syncSimulationProgress();
          }
        } else {
          timer.cancel();
          _isSimulationRunning = false;
          notifyListeners();
        }
      });
    } catch (e) {
      _errorMessage = 'تعذر بدء المحاكاة ($e)';
      _isSimulationRunning = false;
      notifyListeners();
    }
  }

  void toggleExerciseCompleted(int exerciseNumber) {
    if (_completedExerciseNumbers.contains(exerciseNumber)) {
      _completedExerciseNumbers.remove(exerciseNumber);
    } else {
      _completedExerciseNumbers.add(exerciseNumber);
    }
    notifyListeners();
    _syncSimulationProgress();
  }

  void updateSimulationNotes(String notes) {
    _simulationNotes = notes;
    notifyListeners();
  }

  Future<void> _syncSimulationProgress() async {
    if (_activeSimulation == null || userToken == null) return;
    try {
      await repository.updateSimulationProgress(
        userToken!,
        _activeSimulation!.id,
        timeSpentSeconds: _elapsedSeconds,
        completedExercises: _completedExerciseNumbers.toList(),
        studentNotes: _simulationNotes,
      );
    } catch (_) {
      // Background sync failures shouldn't block the student's exam timer
    }
  }

  Future<bool> finishSimulation({
    required double selfAssessmentScore,
    String? notes,
  }) async {
    if (_activeSimulation == null || userToken == null) return false;

    _simulationTimer?.cancel();
    _isSimulationRunning = false;
    notifyListeners();

    try {
      final completed = await repository.finishSimulation(
        userToken!,
        _activeSimulation!.id,
        selfAssessmentScore: selfAssessmentScore,
        timeSpentSeconds: _elapsedSeconds,
        completedExercises: _completedExerciseNumbers.toList(),
        studentNotes: notes ?? _simulationNotes,
      );

      _activeSimulation = completed;
      notifyListeners();
      await loadStudentSimulations();
      return true;
    } catch (e) {
      _errorMessage = 'تعذر تسجيل نتيجة المحاكاة ($e)';
      notifyListeners();
      return false;
    }
  }

  void cancelSimulation() {
    _simulationTimer?.cancel();
    _isSimulationRunning = false;
    _activeSimulation = null;
    _remainingSeconds = 0;
    _elapsedSeconds = 0;
    _completedExerciseNumbers.clear();
    _simulationNotes = '';
    notifyListeners();
  }

  Future<void> loadStudentSimulations() async {
    if (userToken == null || userToken!.isEmpty) return;

    try {
      _studentHistory = await repository.getStudentSimulations(userToken!);
      notifyListeners();
    } catch (_) {}
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
