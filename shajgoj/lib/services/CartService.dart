import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';

class CartService {
  /// Cart-এ কতগুলো আইটেম আছে (count) — backend থেকে আনা
  static Future<int> getCartCount() async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cart'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // CartDto-এ items লিস্ট থেকে count নেয়া
        final items = data['items'] as List<dynamic>? ?? [];
        int totalCount = 0;
        for (var item in items) {
          totalCount += (item['quantity'] as int? ?? 0);
        }
        return totalCount;
      } else {
        return 0; // এরর হলে 0 দেখাবে
      }
    } catch (e) {
      print('Cart count error: $e');
      return 0;
    }
  }
}
