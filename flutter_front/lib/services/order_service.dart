import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';
import 'package:shajgoj/models/order_model.dart';

class OrderService {
  /// লগইন ইউজারের সব অর্ডার লোড করা (GET /api/orders/my-orders)
  static Future<List<Order>> getMyOrders() async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/my-orders'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        print(
          'Failed to load orders: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    }
  }


  /// অ্যাডমিনের জন্য সব অর্ডার লোড করা (GET /api/orders/all)
  static Future<List<Order>> getAllOrders() async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/all'), // অ্যাডমিন এন্ডপয়েন্ট
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Order.fromJson(json)).toList();
      } else {
        print('Failed to load all orders: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error loading all orders: $e');
      return [];
    }
  }

  /// অর্ডার স্ট্যাটাস আপডেট করা (PUT /api/orders/{orderId}/status)
  static Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status'),
        headers: headers,
        body: jsonEncode({'status': newStatus}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }

  /// অর্ডার প্লেস করা (POST /api/orders)
  static Future<bool> placeOrder({
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    required String paymentMethod,
    required double totalAmount,
  }) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: headers,
        body: jsonEncode({
          'fullName': fullName,
          'phone': phone,
          'address': address,
          'city': city,
          'postalCode': postalCode,
          'paymentMethod': paymentMethod,
          'totalAmount': totalAmount,
          // backend যদি cart auto নেয় তাহলে cart items পাঠানোর দরকার নেই
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Order place failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error placing order: $e');
      return false;
    }
  }
}
