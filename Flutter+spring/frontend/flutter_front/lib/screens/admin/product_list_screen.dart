import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/product_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/product_service.dart';
import 'package:shajgoj/screens/admin/add_edit_product.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await ProductService.getAllProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> _deleteProduct(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ProductService.deleteProduct(id);
    if (success) {
      Fluttertoast.showToast(
        msg: 'Product Deleted',
        backgroundColor: Colors.green,
      );
      _loadProducts();
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to delete',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditProduct()),
              );
              if (result == true) _loadProducts();
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text('No products found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading:
                        product.images != null && product.images!.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              '${ApiConfig.baseUrl}${product.images!.first}',
                            ),
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.broken_image),
                          )
                        : const CircleAvatar(child: Icon(Icons.shopping_bag)),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '৳${product.price} ${product.discountPrice != null ? '(৳${product.discountPrice})' : ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditProduct(product: product),
                              ),
                            );
                            if (result == true) _loadProducts();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteProduct(product.id, product.name),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
