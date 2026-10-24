import '../datasources/library_remote_datasource.dart';
import '../models/cohort_material_model.dart';
import '../models/session_recording_model.dart';
import '../../domain/repositories/library_repository.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remoteDataSource;

  LibraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CohortLibraryData> getCohortLibrary(String token, int cohortId) async {
    final response = await remoteDataSource.fetchCohortLibrary(token, cohortId);
    final rawRecordings = (response['recordings'] as List<dynamic>?) ?? [];
    final rawMaterials = (response['materials'] as List<dynamic>?) ?? [];

    final recordings = rawRecordings
        .map((item) => SessionRecordingModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final materials = rawMaterials
        .map((item) => CohortMaterialModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return CohortLibraryData(
      cohortInfo: (response['cohort'] as Map<String, dynamic>?) ?? {},
      isSubscribed: response['is_subscribed'] as bool? ?? false,
      requiresSubscription: response['requires_subscription'] as bool? ?? true,
      recordings: recordings,
      materials: materials,
    );
  }

  @override
  Future<StreamAccessData> getRecordingStream(String token, int recordingId) async {
    final response = await remoteDataSource.requestRecordingStream(token, recordingId);
    final watermark = (response['watermark'] as Map<String, dynamic>?) ?? {};

    return StreamAccessData(
      streamUrl: response['stream_url'] as String? ?? '',
      expiresAt: response['expires_at'] as String? ?? '',
      watermarkText: watermark['watermark_text'] as String? ?? 'Pindo Future Student',
    );
  }

  @override
  Future<String> getMaterialDownloadUrl(String token, int materialId) async {
    final response = await remoteDataSource.requestMaterialAccess(token, materialId);
    return response['download_url'] as String? ?? '';
  }
}
