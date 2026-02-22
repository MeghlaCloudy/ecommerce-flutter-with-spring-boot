import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';
import 'package:shajgoj/models/category_model.dart';

class CategoryService {
  // Get all categories
  static Future<List<Category>> getAllCategories() async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        print('Failed to load categories: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Create category with optional image
  static Future<bool> createCategory({
    required String name,
    File? imageFile,
    int? parentId,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/categories'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final categoryJson = jsonEncode({
        'name': name,
        if (parentId != null) 'parentId': parentId,
      });

      request.fields['category'] = categoryJson;

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType(
              'image',
              imageFile.path.endsWith('.png') ? 'png' : 'jpeg',
            ),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating category: $e');
      return false;
    }
  }

  // Update category with optional new image
  static Future<bool> updateCategory({
    required int id,
    required String name,
    File? newImageFile,
    int? parentId,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/categories/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final categoryJson = jsonEncode({
        'name': name,
        if (parentId != null) 'parentId': parentId,
      });

      request.fields['category'] = categoryJson;

      if (newImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', newImageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  // Delete category
  static Future<bool> deleteCategory(int id) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/categories/$id'),
        headers: headers,
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }
}
