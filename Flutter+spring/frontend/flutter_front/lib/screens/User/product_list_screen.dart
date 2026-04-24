import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/product_model.dart';
import 'package:shajgoj/screens/product_detail_screen.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/cart_service.dart'; // ← CartService ইমপোর্ট করো
import 'package:shajgoj/services/product_service.dart';
import 'package:shajgoj/widgets/custom_drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCartCount();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await ProductService.getAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _loadCartCount() async {
    final count = await CartService.getCartCount();
    setState(() => _cartItemCount = count);
  }

  List<Product> get _filteredProducts {
    if (_searchController.text.isEmpty) return _products;
    final query = _searchController.text.toLowerCase();
    return _products
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
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
          'SHAJGOJ',
          style: TextStyle(
            color: AppColors.primaryPink,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  Fluttertoast.showToast(msg: 'Cart clicked');
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryPink,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppColors.primaryPink,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppColors.primaryPink,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppColors.primaryPink,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryPink,
                    ),
                  )
                : _filteredProducts.isEmpty
                ? const Center(child: Text('No products found'))
                : RefreshIndicator(
                    onRefresh: _loadProducts,
                    color: AppColors.primaryPink,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          child: ProductCard(product: product),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        color: AppColors.primaryPink,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      Fluttertoast.showToast(msg: 'Cart clicked');
                    },
                  ),
                  if (_cartItemCount > 0)
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ProductCard Widget
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final discountPercent =
        product.discountPrice != null && product.discountPrice! < product.price
        ? ((product.price - product.discountPrice!) / product.price * 100)
              .round()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (discountPercent > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                '$discountPercent% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: product.images != null && product.images!.isNotEmpty
                ? Image.network(
                    '${ApiConfig.baseUrl}${product.images!.first}',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 220,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    if (product.discountPrice != null) ...[
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '৳${product.discountPrice!.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primaryPink,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.primaryPink,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_shipping,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'FREE SHIPPING',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await CartService.addToCart(product.id);
                      if (success) {
                        // Cart count আপডেট করো (global হলে setState ব্যবহার করো)
                        Fluttertoast.showToast(
                          msg: 'Added to Cart',
                          backgroundColor: Colors.green,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'ADD TO CART',
                      style: TextStyle(
                        fontSize: 16,
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
