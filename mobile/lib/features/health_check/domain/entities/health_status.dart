class HealthStatus {
  final String status;
  final String platform;
  final String apiVersion;
  final DateTime timestamp;
  final String apiServiceStatus;
  final String dbDriver;
  final bool isDatabaseConnected;
  final String? dbError;
  final String sessionModel;
  final String targetCapacity;
  final String sfuInfrastructure;

  const HealthStatus({
    required this.status,
    required this.platform,
    required this.apiVersion,
    required this.timestamp,
    required this.apiServiceStatus,
    required this.dbDriver,
    required this.isDatabaseConnected,
    this.dbError,
    required this.sessionModel,
    required this.targetCapacity,
    required this.sfuInfrastructure,
  });

  bool get isHealthy => status == 'success' && apiServiceStatus == 'operational';
}
