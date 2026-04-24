import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shajgoj/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// 🔐 Login with username & password
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/api/auth/signin"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final token = data['jwtToken']; // তোমার backend-এ jwtToken আছে

        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwtToken', token);
          return {'success': true, 'token': token};
        }
      }

      // backend থেকে ErrorResponse আসতে পারে
      final errorData = jsonDecode(res.body);
      return {
        'success': false,
        'message': errorData['reason'] ?? 'Login failed (${res.statusCode})',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// 🆕 Register new user
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final res = await http.post(
        Uri.parse(
          "${ApiConfig.baseUrl}/api/auth/signup",
        ), // ← /api/ যোগ করা হয়েছে
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
          "email": email,
          "firstName": firstName,
          "lastName": lastName,
          // "roles": ["ROLE_USER"]  ← এটা রিমুভ করা হয়েছে (backend নেয় না)
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'message': 'Registration successful'};
      }

      // backend ErrorResponse থেকে message নেয়া
      final errorData = jsonDecode(res.body);
      return {
        'success': false,
        'message':
            errorData['reason'] ?? 'Registration failed (${res.statusCode})',
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// 🚪 Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwtToken');
  }

  /// 🔑 Get saved JWT
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  /// 📦 Build headers for HTTP requests
  Future<Map<String, String>> headers({bool auth = false}) async {
    final token = await getToken();

    if (auth && (token == null || token.isEmpty)) {
      throw Exception("No JWT token found. Please login first.");
    }

    return {
      "Content-Type": "application/json",
      if (auth && token != null) "Authorization": "Bearer $token",
    };
  }
}
