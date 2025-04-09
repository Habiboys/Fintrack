import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fintrack/services/api_service.dart';
import 'package:logger/logger.dart';

class AuthService {
  // Remove the baseUrl definition and use ApiService.baseUrl instead
  // Update all instances of baseUrl to use ApiService.baseUrl
  
  // Initialize logger
  final _logger = Logger();

  // Store JWT token
  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  // Get stored JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Remove token on logout
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );
      // Replace print with logger
      _logger.d('Login Response Status: ${response.statusCode}');
      _logger.d('Login Response Body: ${response.body}');
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Store the token
        if (responseData['token'] != null) {
          await storeToken(responseData['token']);
        }
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      _logger.e('Login error', error: e);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(
    String fullname,
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'fullname': fullname,
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      // Replace print with logger
      _logger.d('Register Response Status: ${response.statusCode}');
      _logger.d('Register Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      _logger.e('Registration error', error: e);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    await removeToken();
  }

  // Get current user profile
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/auth/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data':
              responseData is Map
                  ? Map<String, dynamic>.from(responseData)
                  : {},
        };
      } else {
        _logger.w('Failed to get user profile: ${response.statusCode}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get user profile',
        };
      }
    } catch (e) {
      _logger.e('Get current user error', error: e);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
