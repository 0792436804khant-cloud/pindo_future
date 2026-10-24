import 'package:flutter_test/flutter_test.dart';
import 'package:pindo_future_mobile/features/health_check/domain/entities/health_status.dart';
import 'package:pindo_future_mobile/features/health_check/domain/repositories/health_repository.dart';
import 'package:pindo_future_mobile/features/health_check/domain/usecases/check_health_usecase.dart';

class MockHealthRepository implements HealthRepository {
  @override
  Future<HealthStatus> getHealthStatus() async {
    return HealthStatus(
      status: 'success',
      platform: 'Pindo Future Educational Platform',
      apiVersion: 'v1.0.0-foundation',
      timestamp: DateTime.parse('2026-10-08T19:00:00Z'),
      apiServiceStatus: 'operational',
      dbDriver: 'pgsql',
      isDatabaseConnected: true,
      dbError: null,
      sessionModel: 'dynamic_session_id',
      targetCapacity: '30,000 concurrent users',
      sfuInfrastructure: 'external_webrtc_delegated',
    );
  }
}

void main() {
  late CheckHealthUseCase useCase;
  late MockHealthRepository mockRepository;

  setUp(() {
    mockRepository = MockHealthRepository();
    useCase = CheckHealthUseCase(mockRepository);
  });

  test('should return HealthStatus from repository successfully', () async {
    final result = await useCase();

    expect(result.isHealthy, true);
    expect(result.dbDriver, 'pgsql');
    expect(result.isDatabaseConnected, true);
    expect(result.targetCapacity, '30,000 concurrent users');
  });
}
