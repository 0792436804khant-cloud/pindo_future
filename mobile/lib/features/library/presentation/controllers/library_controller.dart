import 'package:flutter/material.dart';
import '../../domain/repositories/library_repository.dart';

enum LibraryState { initial, loading, loaded, error }

class LibraryController extends ChangeNotifier {
  final LibraryRepository repository;

  LibraryState _state = LibraryState.initial;
  CohortLibraryData? _libraryData;
  String? _errorMessage;

  LibraryController({required this.repository});

  LibraryState get state => _state;
  CohortLibraryData? get libraryData => _libraryData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == LibraryState.loading;

  Future<void> loadCohortLibrary({required String token, required int cohortId}) async {
    _state = LibraryState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _libraryData = await repository.getCohortLibrary(token, cohortId);
      _state = LibraryState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LibraryState.error;
    }
    notifyListeners();
  }

  Future<StreamAccessData?> requestStream({required String token, required int recordingId}) async {
    try {
      return await repository.getRecordingStream(token, recordingId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<String?> requestMaterialDownload({required String token, required int materialId}) async {
    try {
      return await repository.getMaterialDownloadUrl(token, materialId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
