import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';
import 'package:shajgoj/models/brand_model.dart';

class BrandService {
  // Get all brands
  static Future<List<Brand>> getAllBrands() async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/brands'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Brand.fromJson(json)).toList();
      } else {
        print(
          'Failed to load brands: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error fetching brands: $e');
      return [];
    }
  }

  // Create brand with optional logo
  static Future<bool> createBrand({
    required String name,
    String? description,
    File? logoFile,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        print('Not logged in');
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/brands'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Brand JSON part
      final brandJson = jsonEncode({
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      });

      request.fields['brand'] = brandJson;

      // Logo image part (optional)
      if (logoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'logo',
            logoFile.path,
            contentType: http.MediaType(
              'image',
              logoFile.path.endsWith('.png') ? 'png' : 'jpeg',
            ),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('Brand created successfully');
        return true;
      } else {
        print('Create failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating brand: $e');
      return false;
    }
  }

  // Update brand with optional new logo
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
        Uri.parse('${ApiConfig.baseUrl}/brands/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final brandJson = jsonEncode({
        'name': name,
        if (description != null && description.isNotEmpty)
          'description': description,
      });

      request.fields['brand'] = brandJson;

      if (newLogoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('logo', newLogoFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating brand: $e');
      return false;
    }
  }

  // Delete brand
  static Future<bool> deleteBrand(int id) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/brands/$id'),
        headers: headers,
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting brand: $e');
      return false;
    }
  }
}
