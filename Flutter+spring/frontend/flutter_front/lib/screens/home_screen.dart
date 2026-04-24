import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/core/constanst/app_strings.dart';
import 'package:shajgoj/models/product_model.dart';
import 'package:shajgoj/screens/product_detail_screen.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/product_service.dart';
import 'package:shajgoj/services/cart_service.dart';
import 'package:shajgoj/widgets/custom_drawer.dart';
import 'package:shajgoj/screens/cart_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _productsFuture;
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCartCount(); // ← প্রথমে count লোড করো
  }

  Future<void> _loadProducts() async {
    setState(() {
      _productsFuture = ProductService.getAllProducts();
    });
  }

  Future<void> _loadCartCount() async {
    final count = await CartService.getCartCount();
    print('Cart count loaded: $count'); // ← debug
    if (mounted) {
      setState(() => _cartItemCount = count);
    }
  }

  Future<void> _refresh() async {
    await _loadProducts();
    await _loadCartCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),

      appBar: AppBar(
        title: const Text(AppStrings.appName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  ).then((_) => _loadCartCount()); // ← Cart থেকে ফিরলে count আপডেট
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerCarousel(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Deals You Cannot Miss",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPink,
                  ),
                ),
              ),

              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    print('Product load error: ${snapshot.error}');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Error loading products: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No products available right now',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  final products = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        child: _buildProductCard(product),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    final discountPercent = product.discountPrice != null && product.discountPrice! < product.price
        ? ((product.price - product.discountPrice!) / product.price * 100).round()
        : 0;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: product.images != null && product.images!.isNotEmpty
                      ? Image.network(
                          '${ApiConfig.baseUrl}${product.images![0]}',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(child: Icon(Icons.broken_image, size: 50)),
                            );
                          },
                        )
                      : const Center(child: Icon(Icons.image_not_supported, size: 50)),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Text(
                            '৳${product.price.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryPink),
                          ),
                          if (product.discountPrice != null && product.discountPrice! > 0) ...[
                            const SizedBox(width: 12),
                            Text(
                              '৳${product.discountPrice!.toStringAsFixed(0)}',
                              style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(fontSize: 13, color: product.stockQuantity > 0 ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Add to Cart Button — এখানে count আপডেট করা হলো
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Add to Cart'),
                onPressed: () async {
                  final success = await CartService.addToCart(product.id, quantity: 1);
                  if (success) {
                    Fluttertoast.showToast(
                      msg: '${product.name} added to cart!',
                      backgroundColor: Colors.green,
                      gravity: ToastGravity.BOTTOM,
                    );
                    // Cart count আপডেট করো (এটাই মূল ফিক্স)
                    await _loadCartCount(); // ← এটা কল করলেই AppBar-এ count বাড়বে
                    setState(() {}); // নিশ্চিত রিবিল্ড
                  } else {
                    Fluttertoast.showToast(msg: 'Failed to add to cart', backgroundColor: Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// BannerCarousel (আগের মতোই রাখা হলো)
class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;

  final List<String> bannerUrls = [
    'https://bk.shajgoj.com/storage/2025/05/shajgoj-cosrx-exclusives-slider-app.png',
    'https://bk.shajgoj.com/storage/2026/01/shajgoj-treasure-of-glow-top-brand-3.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: CarouselSlider(
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            items: bannerUrls.map((url) {
              return Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.pink[100],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerUrls.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index ? AppColors.primaryPink : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}