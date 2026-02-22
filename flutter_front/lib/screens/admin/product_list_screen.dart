import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/brand_model.dart';
import 'package:shajgoj/models/category_model.dart';
import 'package:shajgoj/models/product_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/brand_service.dart';
import 'package:shajgoj/services/category_service.dart';
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
  List<Product> _allProducts = []; // ফিল্টারের জন্য রাখা হলো
  List<Brand> _brands = [];
  List<Category> _categories = [];

  int? _selectedBrandId;
  List<int> _selectedCategoryIds = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final products = await ProductService.getAllProducts();
    final brands = await BrandService.getAllBrands();
    final categories = await CategoryService.getAllCategories();

    setState(() {
      _allProducts = products;
      _products = products;
      _brands = brands;
      _categories = categories;
      _isLoading = false;
    });
  }

  void _applyFilter() {
    List<Product> filtered = List.from(_allProducts);

    // Brand filter
    if (_selectedBrandId != null) {
      final selectedBrandName = _brands
          .firstWhere((b) => b.id == _selectedBrandId)
          .name;
      filtered = filtered
          .where((p) => p.brandName == selectedBrandName)
          .toList();
    }

    // Category filter (multiple)
    if (_selectedCategoryIds.isNotEmpty) {
      final selectedCategoryNames = _categories
          .where((c) => _selectedCategoryIds.contains(c.id))
          .map((c) => c.name)
          .toList();

      filtered = filtered.where((p) {
        if (p.categories == null) return false;
        return selectedCategoryNames.any(
          (name) => p.categories!.contains(name),
        );
      }).toList();
    }

    setState(() {
      _products = filtered;
    });
  }

  void _clearFilter() {
    setState(() {
      _selectedBrandId = null;
      _selectedCategoryIds = [];
      _products = List.from(_allProducts);
    });
  }

  Future<void> _deleteProduct(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "$name"? This cannot be undone.',
        ),
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

    setState(() => _isLoading = true);

    final success = await ProductService.deleteProduct(id);

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(
        msg: 'Product Deleted Successfully',
        backgroundColor: Colors.green,
      );
      _loadData();
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to delete product',
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
            tooltip: 'Add New Product',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditProduct()),
              );
              if (result == true) _loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Products',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<int?>(
                      value: _selectedBrandId,
                      decoration: InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('All Brands'),
                        ),
                        ..._brands.map(
                          (b) => DropdownMenuItem<int>(
                            value: b.id,
                            child: Text(b.name),
                          ),
                        ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedBrandId = value),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Wrap(
                      spacing: 8,
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategoryIds.contains(
                          cat.id,
                        );
                        return FilterChip(
                          label: Text(cat.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategoryIds.add(cat.id);
                              } else {
                                _selectedCategoryIds.remove(cat.id);
                              }
                            });
                          },
                          selectedColor: AppColors.primaryPink.withOpacity(0.3),
                          checkmarkColor: AppColors.primaryPink,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _clearFilter,
                          child: const Text('Clear'),
                        ),
                        ElevatedButton(
                          onPressed: _applyFilter,
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Product Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No products found',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddEditProduct(),
                              ),
                            );
                            if (result == true) _loadData();
                          },
                          child: const Text('Add First Product'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child:
                                      product.images != null &&
                                          product.images!.isNotEmpty
                                      ? Image.network(
                                          '${ApiConfig.baseUrl}${product.images![0]}',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      size: 50,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '৳${product.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: AppColors.primaryPink,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (product.discountPrice != null &&
                                        product.discountPrice! > 0)
                                      Text(
                                        '৳${product.discountPrice!.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Stock: ${product.stockQuantity}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEditProduct(product: product),
                                        ),
                                      );
                                      if (result == true) _loadData();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteProduct(
                                      product.id,
                                      product.name,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
