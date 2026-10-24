import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/classroom/domain/entities/room_connection_details.dart';
import 'package:pindo_future_mobile/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:pindo_future_mobile/features/classroom/domain/usecases/get_room_token_usecase.dart';

class MockClassroomRepository implements ClassroomRepository {
  RoomConnectionDetails? mockDetails;

  @override
  Future<RoomConnectionDetails> getRoomToken({
    required String sessionId,
    String? participantName,
  }) async {
    return mockDetails ??
        RoomConnectionDetails(
          serverUrl: 'wss://livekit.pindofuture.com',
          token: 'mock_jwt_token',
          sessionId: sessionId,
          role: 'teacher',
          identity: 'teacher_2',
          canPublish: true,
          canSubscribe: true,
          expiresIn: 21600,
        );
  }
}

void main() {
  late MockClassroomRepository repository;
  late GetRoomTokenUseCase useCase;

  setUp(() {
    repository = MockClassroomRepository();
    useCase = GetRoomTokenUseCase(repository);
  });

  test('GetRoomTokenUseCase returns publisher connection details for teacher', () async {
    final result = await useCase(sessionId: 'SES_4HP0TFRC');

    expect(result.sessionId, 'SES_4HP0TFRC');
    expect(result.serverUrl, 'wss://livekit.pindofuture.com');
    expect(result.token, 'mock_jwt_token');
    expect(result.isPublisher, true);
    expect(result.canPublish, true);
    expect(result.canSubscribe, true);
  });

  test('GetRoomTokenUseCase returns subscriber-only connection details for student', () async {
    repository.mockDetails = const RoomConnectionDetails(
      serverUrl: 'wss://livekit.pindofuture.com',
      token: 'mock_student_jwt',
      sessionId: 'SES_4HP0TFRC',
      role: 'student',
      identity: 'student_3',
      canPublish: false,
      canSubscribe: true,
      expiresIn: 21600,
    );

    final result = await useCase(sessionId: 'SES_4HP0TFRC');

    expect(result.role, 'student');
    expect(result.isPublisher, false);
    expect(result.isSubscriberOnly, true);
    expect(result.canPublish, false);
    expect(result.canSubscribe, true);
  });
}
