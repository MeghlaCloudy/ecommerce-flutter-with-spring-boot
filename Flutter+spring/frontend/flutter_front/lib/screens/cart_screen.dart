import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/cart_item.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/cart_service.dart';
import 'package:shajgoj/widgets/custom_drawer.dart';
import 'package:shajgoj/screens/checkout_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart'; // ← নতুন ইমপোর্ট

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => _isLoading = true);
    final items = await CartService.getCartItems();
    print('CartScreen - Loaded items count: ${items.length}');
    setState(() {
      _cartItems = items;
      _isLoading = false;
    });
  }

  double get _subtotal {
    return _cartItems.fold<double>(0.0, (sum, item) {
      final price = item.product.discountPrice ?? item.product.price;
      return sum + price * item.quantity;
    });
  }

  double get _total {
    final total = _subtotal;
    print('Calculated total: $total');
    return total.isNaN || total.isInfinite ? 0.0 : total;
  }

  Future<void> _updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return;

    final success = await CartService.updateQuantity(item.id, newQuantity);
    if (success) {
      setState(() => item.quantity = newQuantity);
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to update quantity',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _removeItem(CartItem item) async {
    final success = await CartService.removeItem(item.id);
    if (success) {
      setState(() => _cartItems.remove(item));
      Fluttertoast.showToast(
        msg: 'Removed from cart',
        backgroundColor: Colors.green,
      );
      _loadCart();
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to remove item',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: AppColors.primaryPink,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            )
          : _cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadCart,
                    color: AppColors.primaryPink,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final item = _cartItems[index];
                        final product = item.product;
                        final quantity = item.quantity;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child:
                                      product.images != null &&
                                          product.images!.isNotEmpty
                                      ? CachedNetworkImage(
                                          // ← এখানে CachedNetworkImage ব্যবহার করা হলো
                                          imageUrl:
                                              '${ApiConfig.baseUrl}${product.images!.first}',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.broken_image),
                                        )
                                      : Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '৳${(product.discountPrice ?? product.price).toStringAsFixed(0)} × $quantity',
                                        style: const TextStyle(
                                          color: AppColors.primaryPink,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed: () => _updateQuantity(
                                              item,
                                              quantity - 1,
                                            ),
                                          ),
                                          Text(
                                            '$quantity',
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                            onPressed: () => _updateQuantity(
                                              item,
                                              quantity + 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeItem(item),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Cart Summary + Checkout
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 5,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '৳${_subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Shipping', style: TextStyle(fontSize: 16)),
                          Text(
                            'FREE',
                            style: TextStyle(color: Colors.green, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '৳${_total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_cartItems.isEmpty) {
                              Fluttertoast.showToast(
                                msg: 'Cart is empty',
                                backgroundColor: Colors.orange,
                              );
                              return;
                            }

                            final double safeTotal =
                                _total.isNaN || _total.isInfinite
                                ? 0.0
                                : _total;
                            print(
                              'Navigating to Checkout with total: $safeTotal',
                            );

                            Fluttertoast.showToast(
                              msg: 'Proceeding to Checkout',
                              backgroundColor: Colors.green,
                            );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CheckoutScreen(totalAmount: safeTotal),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryPink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'CHECKOUT',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
