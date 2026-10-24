import '../entities/whiteboard_snapshot_entity.dart';
import '../repositories/whiteboard_repository.dart';

class GetWhiteboardSnapshotsUseCase {
  final WhiteboardRepository repository;

  const GetWhiteboardSnapshotsUseCase(this.repository);

  Future<WhiteboardSnapshotEntity?> getLatest({
    required String sessionId,
    String? token,
  }) {
    return repository.getLatestSnapshot(
      sessionId: sessionId,
      token: token,
    );
  }

  Future<List<WhiteboardSnapshotEntity>> getHistory({
    required String sessionId,
    String? token,
  }) {
    return repository.getSnapshotHistory(
      sessionId: sessionId,
      token: token,
    );
  }
}
