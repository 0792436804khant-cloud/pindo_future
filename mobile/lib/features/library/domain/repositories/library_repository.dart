import '../entities/cohort_material_entity.dart';
import '../entities/session_recording_entity.dart';

class CohortLibraryData {
  final Map<String, dynamic> cohortInfo;
  final bool isSubscribed;
  final bool requiresSubscription;
  final List<SessionRecordingEntity> recordings;
  final List<CohortMaterialEntity> materials;

  const CohortLibraryData({
    required this.cohortInfo,
    required this.isSubscribed,
    required this.requiresSubscription,
    required this.recordings,
    required this.materials,
  });
}

class StreamAccessData {
  final String streamUrl;
  final String expiresAt;
  final String watermarkText;

  const StreamAccessData({
    required this.streamUrl,
    required this.expiresAt,
    required this.watermarkText,
  });
}

abstract class LibraryRepository {
  Future<CohortLibraryData> getCohortLibrary(String token, int cohortId);
  Future<StreamAccessData> getRecordingStream(String token, int recordingId);
  Future<String> getMaterialDownloadUrl(String token, int materialId);
}
