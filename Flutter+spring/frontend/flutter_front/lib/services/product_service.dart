import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';
import 'package:shajgoj/models/product_model.dart';

class ProductService {
  // Get all products (optional brand filter)
  static Future<List<Product>> getAllProducts({int? brandId}) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final uri = brandId != null
          ? Uri.parse('${ApiConfig.baseUrl}/api/products?brandId=$brandId')
          : Uri.parse('${ApiConfig.baseUrl}/api/products');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      print('Get products failed: ${response.statusCode} - ${response.body}');
      return [];
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  // Create product
  static Future<bool> createProduct({
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    String? sku,
    required int stockQuantity,
    int? brandId,
    List<int>? categoryIds,
    List<File>? images,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/api/products'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final productJson = jsonEncode({
        "name": name,
        if (description != null && description.isNotEmpty)
          "description": description,
        "price": price,
        if (discountPrice != null) "discountPrice": discountPrice,
        if (sku != null && sku.isNotEmpty) "sku": sku,
        "stockQuantity": stockQuantity,
        if (brandId != null) "brandId": brandId,
        if (categoryIds != null && categoryIds.isNotEmpty)
          "categoryIds": categoryIds,
      });

      request.files.add(
        http.MultipartFile.fromString(
          'product',
          productJson,
          contentType: MediaType('application', 'json'),
        ),
      );

      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              image.path,
              contentType: MediaType('image', image.path.split('.').last),
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Create Product Status: ${response.statusCode}');
      print('Create Product Body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error creating product: $e');
      return false;
    }
  }

  // Update product
  static Future<bool> updateProduct({
    required int id,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    String? sku,
    required int stockQuantity,
    int? brandId,
    List<int>? categoryIds,
    List<File>? newImages,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/api/products/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final productJson = jsonEncode({
        "name": name,
        if (description != null && description.isNotEmpty)
          "description": description,
        "price": price,
        if (discountPrice != null) "discountPrice": discountPrice,
        if (sku != null && sku.isNotEmpty) "sku": sku,
        "stockQuantity": stockQuantity,
        if (brandId != null) "brandId": brandId,
        if (categoryIds != null && categoryIds.isNotEmpty)
          "categoryIds": categoryIds,
      });

      request.files.add(
        http.MultipartFile.fromString(
          'product',
          productJson,
          contentType: MediaType('application', 'json'),
        ),
      );

      if (newImages != null && newImages.isNotEmpty) {
        for (var image in newImages) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              image.path,
              contentType: MediaType('image', image.path.split('.').last),
            ),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Update Product Status: ${response.statusCode}');
      print('Update Product Body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // Delete product
  static Future<bool> deleteProduct(int id) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/products/$id'),
        headers: headers,
      );

      print('Delete Product Status: ${response.statusCode}');
      print('Delete Product Body: ${response.body}');

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }
}
