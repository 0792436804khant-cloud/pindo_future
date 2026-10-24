import '../../../../core/network/api_client.dart';
import '../../domain/entities/whiteboard_stroke_entity.dart';
import '../models/whiteboard_snapshot_model.dart';

abstract class WhiteboardRemoteDataSource {
  Future<WhiteboardSnapshotModel> saveSnapshot({
    required String sessionId,
    required String title,
    required List<WhiteboardStrokeEntity> strokes,
    String? token,
  });

  Future<WhiteboardSnapshotModel?> getLatestSnapshot({
    required String sessionId,
    String? token,
  });

  Future<List<WhiteboardSnapshotModel>> getSnapshotHistory({
    required String sessionId,
    String? token,
  });
}

class WhiteboardRemoteDataSourceImpl implements WhiteboardRemoteDataSource {
  final ApiClient apiClient;

  WhiteboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<WhiteboardSnapshotModel> saveSnapshot({
    required String sessionId,
    required String title,
    required List<WhiteboardStrokeEntity> strokes,
    String? token,
  }) async {
    final payload = {
      'snapshot_title': title,
      'stroke_count': strokes.length,
      'vector_data': strokes.map((s) => s.toJson()).toList(),
    };

    final response = await apiClient.post(
      '/sessions/$sessionId/whiteboard/snapshots',
      body: payload,
      token: token,
    );

    final snapshotJson = response['snapshot'] as Map<String, dynamic>? ?? {};
    return WhiteboardSnapshotModel.fromJson(snapshotJson, defaultSessionId: sessionId);
  }

  @override
  Future<WhiteboardSnapshotModel?> getLatestSnapshot({
    required String sessionId,
    String? token,
  }) async {
    final response = await apiClient.get(
      '/sessions/$sessionId/whiteboard/latest',
      token: token,
    );

    final hasSnapshot = response['has_snapshot'] as bool? ?? false;
    if (!hasSnapshot || response['snapshot'] == null) {
      return null;
    }

    final snapshotJson = response['snapshot'] as Map<String, dynamic>;
    return WhiteboardSnapshotModel.fromJson(snapshotJson, defaultSessionId: sessionId);
  }

  @override
  Future<List<WhiteboardSnapshotModel>> getSnapshotHistory({
    required String sessionId,
    String? token,
  }) async {
    final response = await apiClient.get(
      '/sessions/$sessionId/whiteboard/history',
      token: token,
    );

    final rawSnapshots = response['snapshots'] as List<dynamic>? ?? [];
    return rawSnapshots
        .whereType<Map<String, dynamic>>()
        .map((j) => WhiteboardSnapshotModel.fromJson(j, defaultSessionId: sessionId))
        .toList();
  }
}
