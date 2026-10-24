import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/health_remote_datasource.dart';
import '../../domain/entities/health_status.dart';
import '../../domain/repositories/health_repository.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource remoteDataSource;

  HealthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<HealthStatus> getHealthStatus() async {
    try {
      final model = await remoteDataSource.getHealth();
      return model;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}
