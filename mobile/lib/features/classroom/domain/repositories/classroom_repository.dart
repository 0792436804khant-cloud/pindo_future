import '../entities/room_connection_details.dart';

abstract class ClassroomRepository {
  /// Request a cryptographically signed LiveKit SFU access token for a Session ID
  Future<RoomConnectionDetails> getRoomToken({
    required String sessionId,
    String? participantName,
  });
}
