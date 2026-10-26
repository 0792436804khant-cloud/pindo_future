class ApiConstants {
  static const String productionBaseUrl = 'https://pindofuture-production.up.railway.app/api/v1';

  /// Automatic base URL resolution based on runtime environment:
  /// - Configurable via --dart-define=API_BASE_URL=...
  /// - Defaults to live Railway Cloud Backend URL: https://pindofuture-production.up.railway.app/api/v1
  static String get defaultBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return productionBaseUrl;
  }

  // Diagnostic endpoints
  static const String healthEndpoint = '/health';
  static const String pingEndpoint = '/ping';

  // Authentication endpoints
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String meEndpoint = '/auth/me';
  static const String deleteAccountEndpoint = '/auth/account';

  // Connection timeout durations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
