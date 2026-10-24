import '../../../../core/network/api_client.dart';
import '../models/room_connection_details_model.dart';

abstract class ClassroomRemoteDataSource {
  Future<RoomConnectionDetailsModel> fetchRoomToken({
    required String sessionId,
    String? token,
    String? participantName,
  });
}

class ClassroomRemoteDataSourceImpl implements ClassroomRemoteDataSource {
  final ApiClient apiClient;

  ClassroomRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<RoomConnectionDetailsModel> fetchRoomToken({
    required String sessionId,
    String? token,
    String? participantName,
  }) async {
    final Map<String, dynamic> body = {};
    if (participantName != null && participantName.trim().isNotEmpty) {
      body['participant_name'] = participantName.trim();
    }

    final response = await apiClient.post(
      '/sessions/$sessionId/token',
      body: body.isNotEmpty ? body : null,
      token: token,
    );

    return RoomConnectionDetailsModel.fromJson(response as Map<String, dynamic>);
  }
}
