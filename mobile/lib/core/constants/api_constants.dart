import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String productionBaseUrl = 'https://pindofuture-production.up.railway.app/api/v1';

  /// Automatic base URL resolution based on runtime environment:
  /// - Release Mode: Production Railway HTTPS URL
  /// - Android Emulator: 10.0.2.2 points to host machine localhost
  /// - iOS Simulator / Desktop / Web: 127.0.0.1 / localhost
  static String get defaultBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }
    if (kReleaseMode) {
      return productionBaseUrl;
    }
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
      return 'http://$host:8080/api/v1';
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    return 'http://127.0.0.1:8080/api/v1';
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
