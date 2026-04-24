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
        Uri.parse('${ApiConfig.baseUrl}/api/categories'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      }
      print('Get categories failed: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error getting categories: $e');
      return [];
    }
  }

  // Create category — backend-এর সাথে মিলিয়ে "category" JSON + "image"
  static Future<bool> createCategory({
    required String name,
    String? description, // backend-এ description নেই, তাই optional রাখলাম
    File? imageFile,
    int? parentId,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/categories'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // "category" নামে JSON পাঠাও (backend-এ @RequestPart("category"))
      final categoryJson = jsonEncode({
        "name": name,
        if (parentId != null) "parentId": parentId,
        // description backend-এ নেই, তাই পাঠালাম না
      });

      request.files.add(
        http.MultipartFile.fromString(
          'category',
          categoryJson,
          contentType: MediaType('application', 'json'),
        ),
      );

      // Image file (optional)
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // ← backend-এ @RequestPart("image")
            imageFile.path,
            contentType: MediaType('image', imageFile.path.split('.').last),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create Category Status: ${response.statusCode}');
      print('Create Category Body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating category: $e');
      return false;
    }
  }

  // Update category — একই প্যাটার্ন
  static Future<bool> updateCategory({
    required int id,
    required String name,
    String? description,
    File? newImageFile,
    int? parentId,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/api/categories/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final categoryJson = jsonEncode({
        "name": name,
        if (parentId != null) "parentId": parentId,
      });

      request.files.add(
        http.MultipartFile.fromString(
          'category',
          categoryJson,
          contentType: MediaType('application', 'json'),
        ),
      );

      if (newImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            newImageFile.path,
            contentType: MediaType('image', newImageFile.path.split('.').last),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update Category Status: ${response.statusCode}');
      print('Update Category Body: ${response.body}');

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
        Uri.parse('${ApiConfig.baseUrl}/api/categories/$id'),
        headers: headers,
      );

      print('Delete Category Status: ${response.statusCode}');
      print('Delete Category Body: ${response.body}');

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }
}
