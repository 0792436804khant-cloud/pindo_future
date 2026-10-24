import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../auth/data/datasources/auth_local_datasource.dart';
import '../../domain/entities/room_connection_details.dart';
import '../../domain/repositories/classroom_repository.dart';
import '../datasources/classroom_remote_datasource.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  final ClassroomRemoteDataSource remoteDataSource;
  final AuthLocalDataSource authLocalDataSource;

  ClassroomRepositoryImpl({
    required this.remoteDataSource,
    required this.authLocalDataSource,
  });

  @override
  Future<RoomConnectionDetails> getRoomToken({
    required String sessionId,
    String? participantName,
  }) async {
    try {
      final authToken = await authLocalDataSource.getToken();

      return await remoteDataSource.fetchRoomToken(
        sessionId: sessionId,
        token: authToken,
        participantName: participantName,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to obtain classroom streaming token: $e');
    }
  }
}
