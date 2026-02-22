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
        Uri.parse('${ApiConfig.baseUrl}/brands'),
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
        Uri.parse('${ApiConfig.baseUrl}/brands'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // সরাসরি field পাঠানো — backend যদি এভাবে নেয়
      request.fields['name'] = name;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      if (logoFile != null) {
        print('Attaching logo: ${logoFile.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'logo', // ← backend-এ MultipartFile-এর নাম 'logo' হলে এটা রাখো
            logoFile.path,
            contentType: MediaType('image', logoFile.path.split('.').last),
          ),
        );
      } else {
        print('No logo attached');
      }

      print('Sending request with fields: ${request.fields}');
      print('Files count: ${request.files.length}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create Response Status: ${response.statusCode}');
      print('Create Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }

      // এরর মেসেজ দেখানোর জন্য
      print('Failed: ${response.body}');
      return false;
    } catch (e) {
      print('Exception in createBrand: $e');
      return false;
    }
  }

  // Update (একইভাবে ফিক্স করা)
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

      request.fields['name'] = name;
      if (description != null && description.isNotEmpty) {
        request.fields['description'] = description;
      }

      if (newLogoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'logo',
            newLogoFile.path,
            contentType: MediaType('image', newLogoFile.path.split('.').last),
          ),
        );
      }

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
        Uri.parse('${ApiConfig.baseUrl}/brands/$id'),
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
