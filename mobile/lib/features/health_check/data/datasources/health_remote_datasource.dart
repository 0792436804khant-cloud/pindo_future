import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/health_status_model.dart';

abstract class HealthRemoteDataSource {
  Future<HealthStatusModel> getHealth();
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final ApiClient apiClient;

  HealthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<HealthStatusModel> getHealth() async {
    final response = await apiClient.get(ApiConstants.healthEndpoint);
    return HealthStatusModel.fromJson(response as Map<String, dynamic>);
  }
}
