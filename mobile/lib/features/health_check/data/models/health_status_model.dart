import '../../domain/entities/health_status.dart';

class HealthStatusModel extends HealthStatus {
  const HealthStatusModel({
    required super.status,
    required super.platform,
    required super.apiVersion,
    required super.timestamp,
    required super.apiServiceStatus,
    required super.dbDriver,
    required super.isDatabaseConnected,
    super.dbError,
    required super.sessionModel,
    required super.targetCapacity,
    required super.sfuInfrastructure,
  });

  factory HealthStatusModel.fromJson(Map<String, dynamic> json) {
    final services = json['services'] as Map<String, dynamic>? ?? {};
    final db = services['database'] as Map<String, dynamic>? ?? {};
    final architecture = json['architecture'] as Map<String, dynamic>? ?? {};

    return HealthStatusModel(
      status: json['status'] as String? ?? 'unknown',
      platform: json['platform'] as String? ?? 'Pindo Future',
      apiVersion: json['api_version'] as String? ?? 'unknown',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      apiServiceStatus: services['api'] as String? ?? 'unknown',
      dbDriver: db['driver'] as String? ?? 'unknown',
      isDatabaseConnected: db['connected'] as bool? ?? false,
      dbError: db['error'] as String?,
      sessionModel: architecture['session_model'] as String? ?? 'session_id',
      targetCapacity: architecture['target_capacity'] as String? ?? '30,000',
      sfuInfrastructure:
          architecture['sfu_infrastructure'] as String? ?? 'external_webrtc',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'platform': platform,
      'api_version': apiVersion,
      'timestamp': timestamp.toIso8601String(),
      'services': {
        'api': apiServiceStatus,
        'database': {
          'driver': dbDriver,
          'connected': isDatabaseConnected,
          'error': dbError,
        },
      },
      'architecture': {
        'session_model': sessionModel,
        'target_capacity': targetCapacity,
        'sfu_infrastructure': sfuInfrastructure,
      },
    };
  }
}
