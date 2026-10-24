import '../entities/health_status.dart';

abstract class HealthRepository {
  /// Fetches system health and verifies connection with Laravel backend and PostgreSQL
  Future<HealthStatus> getHealthStatus();
}
