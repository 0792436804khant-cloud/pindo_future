import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl;

  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ?? ApiConstants.defaultBaseUrl;

  Map<String, String> _headers(String? token) {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {String? token}) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await client
          .get(uri, headers: _headers(token))
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response, uri);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Could not connect to $uri. Ensure backend is running ($e)',
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'Connection timed out while reaching Pindo Future API.',
      );
    } on FormatException catch (e) {
      throw ServerException(
        message: 'Failed to decode API JSON response: ${e.message}',
      );
    } catch (e) {
      throw NetworkException(
        message: 'Network error connecting to $uri ($e)',
      );
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await client
          .post(
            uri,
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response, uri);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Could not connect to $uri. Ensure backend is running ($e)',
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'Connection timed out while reaching Pindo Future API.',
      );
    } on FormatException catch (e) {
      throw ServerException(
        message: 'Failed to decode API JSON response: ${e.message}',
      );
    } catch (e) {
      throw NetworkException(
        message: 'Network error connecting to $uri ($e)',
      );
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await client
          .put(
            uri,
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response, uri);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Could not connect to $uri. Ensure backend is running ($e)',
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'Connection timed out while reaching Pindo Future API.',
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException(
        message: 'Network error connecting to $uri ($e)',
      );
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await client
          .delete(uri, headers: _headers(token))
          .timeout(ApiConstants.connectTimeout);

      return _handleResponse(response, uri);
    } on SocketException catch (e) {
      throw NetworkException(
        message: 'Could not connect to $uri. Ensure backend is running ($e)',
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'Connection timed out while reaching Pindo Future API.',
      );
    } catch (e) {
      if (e is ServerException || e is NetworkException) rethrow;
      throw NetworkException(
        message: 'Network error connecting to $uri ($e)',
      );
    }
  }

  dynamic _handleResponse(http.Response response, Uri uri) {
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      decoded = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String message = 'Received HTTP ${response.statusCode}';
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('message')) {
        message = decoded['message'].toString();
      }
      if (decoded.containsKey('errors') && decoded['errors'] is Map) {
        final errors = decoded['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        }
      }
    }

    throw ServerException(
      message: message,
      statusCode: response.statusCode,
    );
  }
}
