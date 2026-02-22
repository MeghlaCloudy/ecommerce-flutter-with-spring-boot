import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/auth_service.dart';
import 'package:shajgoj/models/cart_item.dart';

class CartService {
  /// কার্টের সব আইটেম লোড করা (GET /api/cart)
  static Future<List<CartItem>> getCartItems() async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/cart'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        return items.map((json) => CartItem.fromJson(json)).toList();
      } else {
        print('Failed to load cart: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  /// কার্টে নতুন আইটেম যোগ করা (POST /api/cart/add)
  static Future<bool> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cart/add'),
        headers: headers,
        body: jsonEncode({'productId': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print(
          'Failed to add to cart: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  /// কার্ট আইটেমের quantity আপডেট করা (PUT /api/cart/update/{cartItemId})
  static Future<bool> updateCartItemQuantity(
    int cartItemId,
    int quantity,
  ) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/cart/update/$cartItemId'),
        headers: headers,
        body: jsonEncode({'quantity': quantity}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating quantity: $e');
      return false;
    }
  }

  /// কার্ট থেকে আইটেম রিমুভ করা (DELETE /api/cart/remove/{cartItemId})
  static Future<bool> removeFromCart(int cartItemId) async {
    try {
      final headers = await AuthService().headers(auth: true);
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/cart/remove/$cartItemId'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error removing item: $e');
      return false;
    }
  }

  /// কার্টের টোটাল অ্যামাউন্ট ক্যালকুলেট করা (লোকালি)
  static double calculateTotal(List<CartItem> items) {
    double total = 0.0;
    for (var item in items) {
      final price = item.discountPrice ?? item.price;
      total += price * item.quantity;
    }
    return total;
  }

  /// কার্টে কতগুলো আইটেম আছে (শুধু কাউন্ট, ব্যাজ দেখানোর জন্য)
  static Future<int> getCartCount() async {
    final items = await getCartItems();
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }
}
