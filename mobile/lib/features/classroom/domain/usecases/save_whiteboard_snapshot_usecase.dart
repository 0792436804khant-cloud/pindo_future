import '../entities/whiteboard_snapshot_entity.dart';
import '../entities/whiteboard_stroke_entity.dart';
import '../repositories/whiteboard_repository.dart';

class SaveWhiteboardSnapshotUseCase {
  final WhiteboardRepository repository;

  const SaveWhiteboardSnapshotUseCase(this.repository);

  Future<WhiteboardSnapshotEntity> call({
    required String sessionId,
    required String title,
    required List<WhiteboardStrokeEntity> strokes,
    String? token,
  }) {
    return repository.saveSnapshot(
      sessionId: sessionId,
      title: title,
      strokes: strokes,
      token: token,
    );
  }
}
