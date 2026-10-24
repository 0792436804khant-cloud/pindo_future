import '../../domain/entities/whiteboard_snapshot_entity.dart';
import '../../domain/entities/whiteboard_stroke_entity.dart';
import '../../domain/repositories/whiteboard_repository.dart';
import '../datasources/whiteboard_remote_datasource.dart';

class WhiteboardRepositoryImpl implements WhiteboardRepository {
  final WhiteboardRemoteDataSource remoteDataSource;

  WhiteboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<WhiteboardSnapshotEntity> saveSnapshot({
    required String sessionId,
    required String title,
    required List<WhiteboardStrokeEntity> strokes,
    String? token,
  }) async {
    return await remoteDataSource.saveSnapshot(
      sessionId: sessionId,
      title: title,
      strokes: strokes,
      token: token,
    );
  }

  @override
  Future<WhiteboardSnapshotEntity?> getLatestSnapshot({
    required String sessionId,
    String? token,
  }) async {
    return await remoteDataSource.getLatestSnapshot(
      sessionId: sessionId,
      token: token,
    );
  }

  @override
  Future<List<WhiteboardSnapshotEntity>> getSnapshotHistory({
    required String sessionId,
    String? token,
  }) async {
    return await remoteDataSource.getSnapshotHistory(
      sessionId: sessionId,
      token: token,
    );
  }
}
