import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/health_remote_datasource.dart';
import '../../data/repositories/health_repository_impl.dart';
import '../../domain/usecases/check_health_usecase.dart';
import '../controllers/health_controller.dart';
import '../widgets/health_metric_tile.dart';

class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  late final TextEditingController _urlController;
  late HealthController _controller;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConstants.defaultBaseUrl);
    _initController(_urlController.text);
  }

  void _initController(String baseUrl) {
    final apiClient = ApiClient(baseUrl: baseUrl);
    final remoteDataSource = HealthRemoteDataSourceImpl(apiClient: apiClient);
    final repository = HealthRepositoryImpl(remoteDataSource: remoteDataSource);
    final useCase = CheckHealthUseCase(repository);
    _controller = HealthController(checkHealthUseCase: useCase);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _urlController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pindo Future • Phase 0 Diagnostics',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vision header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor,
                    const Color(0xFF1E40AF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.rocket_launch, color: Colors.amberAccent, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Pindo Future Engine',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Foundation Verification (Laravel 11 API + PostgreSQL + Flutter Clean Architecture)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Base URL configuration field
            Text(
              'Backend API Endpoint',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.link, size: 20),
                      hintText: 'http://10.0.2.2:8080/api/v1',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Update Base URL',
                  onPressed: () {
                    _initController(_urlController.text.trim());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API URL updated')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Button
            ElevatedButton.icon(
              icon: _controller.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.network_check),
              label: Text(_controller.isLoading ? 'Verifying Services...' : 'Test Connection & PostgreSQL'),
              onPressed: _controller.isLoading
                  ? null
                  : () {
                      _controller.checkConnection();
                    },
            ),
            const SizedBox(height: 24),

            // Result Display
            if (_controller.isError)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connection Failed',
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _controller.errorMessage ?? 'Could not establish connection to Laravel.',
                            style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            if (_controller.isSuccess && _controller.healthStatus != null) ...[
              _buildSuccessCard(_controller.healthStatus!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessCard(dynamic status) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final isDbHealthy = status.isDatabaseConnected as bool;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 22),
            const SizedBox(width: 8),
            Text(
              'Backend API Handshake Verified',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        HealthMetricTile(
          icon: Icons.api,
          title: 'API Status & Version',
          value: '${status.apiServiceStatus.toUpperCase()} (${status.apiVersion})',
          valueColor: Colors.green.shade700,
        ),
        HealthMetricTile(
          icon: Icons.storage,
          title: 'Database Engine (PostgreSQL)',
          value: '${status.dbDriver.toUpperCase()} • ${isDbHealthy ? "Connected" : "Disconnected"}',
          valueColor: isDbHealthy ? Colors.green.shade700 : Colors.red.shade700,
          trailing: isDbHealthy
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : const Icon(Icons.cancel, color: Colors.red, size: 20),
        ),
        if (status.dbError != null)
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Text(
              'DB Notice: ${status.dbError}',
              style: TextStyle(color: Colors.orange.shade900, fontSize: 12),
            ),
          ),
        HealthMetricTile(
          icon: Icons.groups,
          title: 'Architecture Scaling Target',
          value: status.targetCapacity,
        ),
        HealthMetricTile(
          icon: Icons.meeting_room,
          title: 'Room Model',
          value: status.sessionModel,
        ),
        HealthMetricTile(
          icon: Icons.videocam,
          title: 'Video Infrastructure',
          value: status.sfuInfrastructure,
        ),
        HealthMetricTile(
          icon: Icons.access_time,
          title: 'Server Handshake Timestamp',
          value: dateFormat.format(status.timestamp.toLocal()),
        ),
      ],
    );
  }
}
