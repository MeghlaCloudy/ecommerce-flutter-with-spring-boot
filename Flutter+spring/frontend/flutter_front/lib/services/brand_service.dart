import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';
import 'package:shajgoj/models/brand_model.dart';

class BrandService {
  static Future<List<Brand>> getAllBrands() async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/brands'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Brand.fromJson(json)).toList();
      }
      print('Get brands failed: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error getting brands: $e');
      return [];
    }
  }

  static Future<bool> createBrand({
    required String name,
    String? description,
    File? logoFile,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        print('No token - user not logged in');
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/brands'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      /// 🔹 Create Brand JSON (must match BrandDTO fields)
      final brandJson = jsonEncode({"name": name, "description": description});

      /// 🔹 Add JSON as multipart part named "brand"
      request.files.add(
        http.MultipartFile.fromString(
          'brand', // must match @RequestPart("brand")
          brandJson,
          contentType: MediaType('application', 'json'),
        ),
      );

      /// 🔹 Attach logo if exists
      if (logoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'logo', // must match @RequestPart("logo")
            logoFile.path,
            contentType: MediaType('image', 'jpeg'), // or detect dynamically
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Status:------------ ${response.statusCode}');
      print('Body:-------------- ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Exception in createBrand:--------------- $e');
      return false;
    }
  }

  // Update brand — এটাই ফিক্স করা হলো (এখন backend-এর সাথে মিলবে)
  static Future<bool> updateBrand({
    required int id,
    required String name,
    String? description,
    File? newLogoFile,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/api/brands/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Backend যেভাবে চায় — "brand" নামে JSON পাঠাও
      final brandJson = jsonEncode({
        "name": name,
        if (description != null && description.isNotEmpty)
          "description": description,
      });

      request.files.add(
        http.MultipartFile.fromString(
          'brand', // ← backend-এ @RequestPart("brand") আছে
          brandJson,
          contentType: MediaType('application', 'json'),
        ),
      );

      // নতুন লোগো থাকলে পাঠাও
      if (newLogoFile != null) {
        print('Attaching new logo: ${newLogoFile.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'logo', // ← backend-এ @RequestPart("logo")
            newLogoFile.path,
            contentType: MediaType('image', newLogoFile.path.split('.').last),
          ),
        );
      }

      print('Sending update request...');
      print('Fields: brand JSON → $brandJson');
      print('Files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update Response Status: ${response.statusCode}');
      print('Update Response Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Exception in updateBrand: $e');
      return false;
    }
  }

  // Delete brand
  static Future<bool> deleteBrand(int id) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/brands/$id'),
        headers: headers,
      );

      print('Delete Brand - Status: ${response.statusCode}');
      print('Delete Brand - Body: ${response.body}');

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting brand: $e');
      return false;
    }
  }
}
