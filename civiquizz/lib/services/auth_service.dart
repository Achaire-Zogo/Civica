import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/url.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Store token
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Register with email, password and pseudo
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String pseudo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Url.register),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'spseudo': pseudo,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store token and user data if available after successful registration
        if (responseData['data'] != null && responseData['data']['token'] != null) {
          final token = responseData['data']['token'];
          await _storeToken(token);
          await storeUserData(responseData['data']);
        }
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'error': responseData['error'] ?? 'Unknown error',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  // Login with email and password
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Url.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['data']['token'];
        
        // Store token in SharedPreferences
        await _storeToken(token);
        
        // Store user data if available
        if (responseData['data'] != null) {
          await storeUserData(responseData['data']);
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'token': token,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'error': responseData['data'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }

  // Get authorization headers for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Check if email exists
  Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('${Url.checkEmail}?email=$email'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? '',
        'exists': response.statusCode == 200,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse(Url.changePassword),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': responseData['message'] ?? '',
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }
}
