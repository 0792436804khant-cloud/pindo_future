import '../entities/health_status.dart';
import '../repositories/health_repository.dart';

class CheckHealthUseCase {
  final HealthRepository repository;

  CheckHealthUseCase(this.repository);

  Future<HealthStatus> call() async {
    return await repository.getHealthStatus();
  }
}
