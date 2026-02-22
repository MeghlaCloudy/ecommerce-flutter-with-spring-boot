import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';
import 'package:shajgoj/models/product_model.dart';

class ProductService {
  // Get all products
  static Future<List<Product>> getAllProducts() async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        print('Failed to load products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // Create product with multiple images
  static Future<bool> createProduct({
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    String? sku,
    required int stockQuantity,
    int? brandId,
    List<int>? categoryIds,
    required List<File> images,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/products'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Product JSON part
      final productJson = jsonEncode({
        'name': name,
        if (description != null) 'description': description,
        'price': price,
        if (discountPrice != null) 'discountPrice': discountPrice,
        if (sku != null) 'sku': sku,
        'stockQuantity': stockQuantity,
        if (brandId != null) 'brandId': brandId,
        if (categoryIds != null && categoryIds.isNotEmpty)
          'categoryIds': categoryIds,
      });

      request.fields['product'] = productJson;

      // Multiple images
      for (var image in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images',
            image.path,
            contentType: MediaType(
              'image',
              image.path.endsWith('.png') ? 'png' : 'jpeg',
            ),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 201;
    } catch (e) {
      print('Error creating product: $e');
      return false;
    }
  }

  // Update product (multiple images optional)
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
        Uri.parse('${ApiConfig.baseUrl}/products/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final productJson = jsonEncode({
        'name': name,
        if (description != null) 'description': description,
        'price': price,
        if (discountPrice != null) 'discountPrice': discountPrice,
        if (sku != null) 'sku': sku,
        'stockQuantity': stockQuantity,
        if (brandId != null) 'brandId': brandId,
        if (categoryIds != null && categoryIds.isNotEmpty)
          'categoryIds': categoryIds,
      });

      request.fields['product'] = productJson;

      if (newImages != null && newImages.isNotEmpty) {
        for (var image in newImages) {
          request.files.add(
            await http.MultipartFile.fromPath('images', image.path),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }


    static Future<bool> deleteProduct(int id) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/products/$id'),
        headers: headers,
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }


  // Get single product by ID
  static Future<Product?> getProductById(int id) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        print('Failed to load product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }
}
