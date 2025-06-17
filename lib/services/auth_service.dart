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
    
        if (responseData['jwt_token'] != null) {
          await storeToken(responseData['jwt_token']);
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
    try {
      final token = await getToken();

      // Jika tidak ada token, user tidak terotentikasi
      if (token == null) {
        return false;
      }

      // Coba ambil profile pengguna untuk memastikan token valid
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      _logger.d('Token validation status: ${response.statusCode}');

      // Jika response 200 OK, token valid
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Error validating token', error: e);
      return false;
    }
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
        _logger.w('Tidak ada token yang tersimpan.');
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Log response untuk debugging
      _logger.d('User profile response status: ${response.statusCode}');
      _logger.d('User profile response body: ${response.body}');

      // Cek apakah respons merupakan JSON yang valid
      dynamic responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        _logger.e('Invalid JSON response', error: e);
        return {
          'success': false,
          'message': 'Invalid response format: ${response.body}',
        };
      }

      if (response.statusCode == 200) {
        // Tambahkan log sukses
        _logger.i('User profile fetched successfully');

        return {
          'success': true,
          'data':
              responseData is Map
                  ? Map<String, dynamic>.from(responseData)
                  : {},
        };
      } else {
        _logger.w(
          'Failed to get user profile: ${response.statusCode}, message: ${responseData['message'] ?? 'Unknown error'}',
        );
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get user profile',
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      _logger.e('Get current user error', error: e);
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
