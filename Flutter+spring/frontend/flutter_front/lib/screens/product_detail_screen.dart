import 'package:flutter/material.dart';
import 'package:shajgoj/models/product_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../core/constanst/app_colors.dart'; // pubspec.yaml-এ যোগ করো

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;
  int _cartItemCount = 0; // পরে CartService থেকে আসবে

  @override
  Widget build(BuildContext context) {
    final discountPercent = widget.product.discountPrice != null && widget.product.discountPrice! < widget.product.price
        ? ((widget.product.price - widget.product.discountPrice!) / widget.product.price * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SHAJGOJ',
          style: TextStyle(color: AppColors.primaryPink, fontWeight: FontWeight.bold),
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
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
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

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 300,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1.0,
                  ),
                  items: widget.product.images != null && widget.product.images!.isNotEmpty
                      ? widget.product.images!.map((imgUrl) {
                    return Image.network(
                      '${ApiConfig.baseUrl}$imgUrl',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      ),
                    );
                  }).toList()
                      : [Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                  )],
                ),

                // Discount Badge
                if (discountPercent > 0)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$discountPercent% OFF',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Rating + Free Shipping
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < 4 ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        )),
                      ),
                      const SizedBox(width: 8),
                      const Text('(4.5)', style: TextStyle(color: Colors.grey)),
                      const Spacer(),
                      const Icon(Icons.local_shipping, color: Colors.green, size: 20),
                      const SizedBox(width: 4),
                      const Text('FREE SHIPPING', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    children: [
                      if (widget.product.discountPrice != null) ...[
                        Text(
                          '৳${widget.product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '৳${widget.product.discountPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.primaryPink,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else
                        Text(
                          '৳${widget.product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: AppColors.primaryPink,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    widget.product.description ?? 'No description available',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  // Quantity Selector
                  Row(
                    children: [
                      const Text('Quantity:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            Text('$_quantity', style: const TextStyle(fontSize: 18)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Fluttertoast.showToast(msg: 'Added to Cart', backgroundColor: Colors.green);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'ADD TO CART',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}