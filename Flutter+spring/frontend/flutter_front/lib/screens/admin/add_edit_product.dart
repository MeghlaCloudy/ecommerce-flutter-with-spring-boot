import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/brand_model.dart';
import 'package:shajgoj/models/category_model.dart';
import 'package:shajgoj/models/product_model.dart';
import 'package:shajgoj/services/brand_service.dart';
import 'package:shajgoj/services/category_service.dart';
import 'package:shajgoj/services/product_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddEditProduct extends StatefulWidget {
  final Product? product;

  const AddEditProduct({super.key, this.product});

  @override
  State<AddEditProduct> createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _skuController;
  late TextEditingController _stockController;

  int? _selectedBrandId;
  List<int> _selectedCategoryIds = [];
  List<File> _selectedImages = [];

  List<Brand> _brands = [];
  List<Category> _categories = [];

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.product?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
    _discountPriceController = TextEditingController(
      text: widget.product?.discountPrice?.toString() ?? '',
    );
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity.toString() ?? '',
    );

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final brands = await BrandService.getAllBrands();
    final categories = await CategoryService.getAllCategories();

    setState(() {
      _brands = brands;
      _categories = categories;
      _isLoading = false;
    });
  }

  /// ✅ Multiple image picker (এটা ঠিক আছে)
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)));
        if (_selectedImages.length > 5) {
          _selectedImages = _selectedImages.sublist(0, 5);
          Fluttertoast.showToast(
            msg: 'Maximum 5 images allowed',
            backgroundColor: Colors.orange,
          );
        }
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty && widget.product == null) {
      Fluttertoast.showToast(
        msg: 'Please select at least one image',
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final discountPrice = double.tryParse(_discountPriceController.text.trim());
    final sku = _skuController.text.trim().isEmpty
        ? null
        : _skuController.text.trim();
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    bool success;

    if (widget.product == null) {
      success = await ProductService.createProduct(
        name: name,
        description: description,
        price: price,
        discountPrice: discountPrice,
        sku: sku,
        stockQuantity: stock,
        brandId: _selectedBrandId,
        categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
        images: _selectedImages,
      );
    } else {
      success = await ProductService.updateProduct(
        id: widget.product!.id,
        name: name,
        description: description,
        price: price,
        discountPrice: discountPrice,
        sku: sku,
        stockQuantity: stock,
        brandId: _selectedBrandId,
        categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
        newImages: _selectedImages,
      );
    }

    setState(() => _isLoading = false);

    Fluttertoast.showToast(
      msg: success
          ? (widget.product == null ? 'Product Created!' : 'Product Updated!')
          : 'Failed to save product',
      backgroundColor: success ? Colors.green : Colors.red,
    );

    if (success) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add New Product'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          value!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value!.trim().isEmpty) return 'Required';
                              final p = double.tryParse(value);
                              if (p == null || p <= 0) return 'Invalid price';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _discountPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Discount Price',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _skuController,
                      decoration: InputDecoration(
                        labelText: 'SKU (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stock Quantity *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value!.trim().isEmpty) return 'Required';
                        final s = int.tryParse(value);
                        if (s == null || s < 0) return 'Invalid stock';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Brand Dropdown
                    DropdownButtonFormField<int>(
                      value: _selectedBrandId,
                      decoration: InputDecoration(
                        labelText: 'Brand *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _brands
                          .map(
                            (b) => DropdownMenuItem(
                              value: b.id,
                              child: Text(b.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedBrandId = value),
                      validator: (value) =>
                          value == null ? 'Select a brand' : null,
                    ),
                    const SizedBox(height: 24),

                    // Category Multi-Select
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((c) {
                        final isSelected = _selectedCategoryIds.contains(c.id);
                        return FilterChip(
                          label: Text(c.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected)
                                _selectedCategoryIds.add(c.id);
                              else
                                _selectedCategoryIds.remove(c.id);
                            });
                          },
                          selectedColor: AppColors.primaryPink.withOpacity(0.3),
                          checkmarkColor: AppColors.primaryPink,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Multiple Images Picker
                    Text(
                      'Product Images *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _isLoading ? null : _pickImages,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _selectedImages.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Tap to select images (max 5)',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              )
                            : ListView(
                                scrollDirection: Axis.horizontal,
                                children: _selectedImages
                                    .map(
                                      (file) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.file(
                                            file,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPink,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                widget.product == null
                                    ? 'Create Product'
                                    : 'Update Product',
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
