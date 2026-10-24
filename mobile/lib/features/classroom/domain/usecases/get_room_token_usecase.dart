import '../entities/room_connection_details.dart';
import '../repositories/classroom_repository.dart';

class GetRoomTokenUseCase {
  final ClassroomRepository repository;

  GetRoomTokenUseCase(this.repository);

  Future<RoomConnectionDetails> call({
    required String sessionId,
    String? participantName,
  }) async {
    return await repository.getRoomToken(
      sessionId: sessionId,
      participantName: participantName,
    );
  }
}
