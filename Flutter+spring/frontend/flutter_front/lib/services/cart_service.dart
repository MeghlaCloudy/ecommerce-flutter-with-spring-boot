import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shajgoj/models/cart_item.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';

class CartService {
  // Get all cart items
  static Future<List<CartItem>> getCartItems() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        print('No token found for getCartItems');
        Fluttertoast.showToast(
          msg: 'Please login first',
          backgroundColor: Colors.red,
        );
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Get Cart - Status: ${response.statusCode}');
      print(
        'Get Cart - Response Body: ${response.body}',
      ); // ← এটা দেখো backend কী পাঠাচ্ছে

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] ?? [];
        print('Backend items count: ${items.length}');

        return items.map((json) {
          print('Parsing cart item: $json');
          return CartItem.fromJson(json);
        }).toList();
      } else {
        print('Get cart failed: ${response.statusCode} - ${response.body}');
        Fluttertoast.showToast(
          msg: 'Failed to load cart',
          backgroundColor: Colors.red,
        );
        return [];
      }
    } catch (e) {
      print('Cart error: $e');
      Fluttertoast.showToast(
        msg: 'Error loading cart',
        backgroundColor: Colors.red,
      );
      return [];
    }
  }

  // Update quantity
  static Future<bool> updateQuantity(int cartItemId, int quantity) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/cart/update/$cartItemId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'quantity': quantity}),
      );

      print('Update quantity status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Update quantity error: $e');
      return false;
    }
  }

  // Remove item
  static Future<bool> removeItem(int cartItemId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/cart/remove/$cartItemId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Remove item status: ${response.statusCode}');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Remove item error: $e');
      return false;
    }
  }

  // Get total cart count (for badge)
  static Future<int> getCartCount() async {
    final items = await getCartItems();
    final count = items.fold(0, (sum, item) => sum + item.quantity);
    print('Calculated cart count: $count');
    return count;
  }

  // Add to Cart
  static Future<bool> addToCart(int productId, {int quantity = 1}) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        Fluttertoast.showToast(
          msg: 'Please login first',
          backgroundColor: Colors.red,
        );
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/cart/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );

      print('Add to Cart Status:------------ ${response.statusCode}');
      print('Add to Cart Response:------------------ ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: 'Added to Cart',
          backgroundColor: Colors.green,
        );
        return true;
      } else {
        print('Add to cart failed: ${response.statusCode} - ${response.body}');
        Fluttertoast.showToast(
          msg: 'Failed to add to cart',
          backgroundColor: Colors.red,
        );
        return false;
      }
    } catch (e) {
      print('Add to cart error: $e');
      Fluttertoast.showToast(
        msg: 'Error adding to cart',
        backgroundColor: Colors.red,
      );
      return false;
    }
  }
}
