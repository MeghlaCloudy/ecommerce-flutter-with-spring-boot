import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shajgoj/models/checkout_request.dart';
import 'package:shajgoj/models/order_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';

class OrderService {
  // User: Create order from cart (Checkout)
  static Future<Order?> checkout(CheckoutRequest request) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) {
        print('No token found for checkout');
        return null;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/orders/checkout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      print('Checkout Status:----------------- ${response.statusCode}');
      print(
        'Checkout Response:------------------------------ ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return Order.fromJson(json);
      } else {
        print(
          'Checkout failed:----------------------------- ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Checkout error:--------------------------------------- $e');
      return null;
    }
  }

  // Admin: Get ALL orders
  static Future<List<Order>> getAllOrders() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/orders/all'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Get all orders status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        print('Get all orders failed: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get all orders error: $e');
      return [];
    }
  }

  // Admin: Update order status
  static Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus.toUpperCase()}),
      );

      print('Update status: ${response.statusCode} - ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Update status error: $e');
      return false;
    }
  }

  // User: Get my orders
  static Future<List<Order>> getUserOrders() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get user orders error: $e');
      return [];
    }
  }
}
