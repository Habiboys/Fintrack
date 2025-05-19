import 'dart:io' show Platform;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ApiService {
  // Base URL menggunakan localhost dengan port yang benar sesuai backend
  // static String baseUrl =
  //     Platform.isAndroid
  //         ? 'http://10.0.2.2:3000/api'
  //         : 'http://localhost:3000/api';

  static String baseUrl =
      Platform.isAndroid
          ? 'http://20.251.153.107:3000/api'
          : 'http://20.251.153.107:3000/api';

  // Initialize logger
  final _logger = Logger();

  // Headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      return {
        'Content-Type': 'application/json',
        'Authorization': token != null ? 'Bearer $token' : '',
      };
    } catch (e) {
      _logger.e('Error getting headers', error: e);
      return {'Content-Type': 'application/json'};
    }
  }

  // Generic GET request with logging
  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/$endpoint');

      _logger.d('GET Request: $uri');
      final response = await http.get(uri, headers: headers);
      _logger.d('GET Response: ${response.statusCode}');
      _logger.d(
        'Response body: ${response.body.length > 100 ? '${response.body.substring(0, 100)}...' : response.body}',
      );

      return _processResponse(response);
    } catch (e) {
      _logger.e('GET Error: $e');
      throw Exception('Failed to perform GET request: $e');
    }
  }

  // Generic POST request with logging
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/$endpoint');

      _logger.d('POST Request: $uri');
      _logger.d('POST Data: $data');
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(data),
      );
      _logger.d('POST Response: ${response.statusCode}');
      _logger.d(
        'Response body: ${response.body.length > 100 ? '${response.body.substring(0, 100)}...' : response.body}',
      );

      return _processResponse(response);
    } catch (e) {
      _logger.e('POST Error: $e');
      throw Exception('Failed to perform POST request: $e');
    }
  }

  // Generic PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      _logger.d('PUT Response: ${response.statusCode}');

      return _processResponse(response);
    } catch (e) {
      _logger.e('PUT Error: $e');
      throw Exception('Failed to perform PUT request: $e');
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );

      _logger.d('DELETE Response: ${response.statusCode}');

      return _processResponse(response);
    } catch (e) {
      _logger.e('DELETE Error: $e');
      throw Exception('Failed to perform DELETE request: $e');
    }
  }

  // Process HTTP response
  dynamic _processResponse(http.Response response) {
    try {
      // Log response status dan content type
      final contentType = response.headers['content-type'] ?? 'unknown';
      _logger.d(
        'Processing response: ${response.statusCode}, Content-Type: $contentType',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          _logger.d('Response body kosong');
          return null;
        }

        // Coba parse response body
        dynamic jsonData;
        try {
          jsonData = json.decode(response.body);

          // Log first 500 characters of response untuk debugging
          final logString = json.encode(jsonData);
          _logger.d(
            'Parsed JSON: ${logString.length > 200 ? '${logString.substring(0, 200)}...' : logString}',
          );

          return jsonData;
        } catch (e) {
          _logger.e('Invalid JSON response', error: e);
          _logger.e(
            'Raw response body: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}',
          );

          // Return response body as string jika tidak bisa di-parse sebagai JSON
          return {'message': response.body};
        }
      } else {
        // Handle 401 Unauthorized errors specially - clear token and will redirect user
        if (response.statusCode == 401) {
          _logger.w('Authentication error (401) - clearing token');
          _handleAuthError();
        }

        // Handle error response
        try {
          // Coba parse error response
          dynamic errorBody;
          try {
            errorBody = json.decode(response.body);
          } catch (parseError) {
            // Jika tidak bisa parse, gunakan body mentah
            _logger.e(
              'Failed to parse error response as JSON',
              error: parseError,
            );
            throw Exception(
              'API Error (${response.statusCode}): ${response.body}',
            );
          }

          final errorMessage =
              errorBody is Map
                  ? (errorBody['message'] ??
                      errorBody['error'] ??
                      'Unknown error occurred')
                  : 'Invalid error format';

          _logger.e('API Error: $errorMessage (${response.statusCode})');
          throw Exception('API Error (${response.statusCode}): $errorBody');
        } catch (e) {
          _logger.e('API Error with unparseable response', error: e);
          throw Exception(
            'API Error (${response.statusCode}): ${response.body}',
          );
        }
      }
    } catch (e) {
      _logger.e('Error processing response', error: e);
      rethrow;
    }
  }

  // Handle authentication errors by clearing the token
  Future<void> _handleAuthError() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      _logger.i('Token cleared due to authentication error');
    } catch (e) {
      _logger.e('Error clearing token', error: e);
    }
  }
}
