import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/brand_model.dart';
import 'package:shajgoj/models/category_model.dart';
import 'package:shajgoj/models/product_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/brand_service.dart';
import 'package:shajgoj/services/category_service.dart';
import 'package:shajgoj/services/product_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddEditProduct extends StatefulWidget {
  final Product? product; // optional — null মানে Create মোড

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
  late TextEditingController _stockController;
  late TextEditingController _skuController;

  int? _selectedBrandId;
  List<int> _selectedCategoryIds = [];
  List<File> _newImages = []; // নতুন যোগ করা ছবি
  List<String> _existingImageUrls = []; // এডিট মোডে পুরোনো ছবির URL

  List<Brand> _brands = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Controllers initialize with existing data (if edit mode)
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
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity.toString() ?? '',
    );
    _skuController = TextEditingController(text: widget.product?.sku ?? '');

    // Edit মোডে পুরোনো ছবির URL লোড
    if (widget.product != null && widget.product!.images != null) {
      _existingImageUrls = List<String>.from(widget.product!.images!);
    }

    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() => _isLoading = true);

    final brands = await BrandService.getAllBrands();
    final categories = await CategoryService.getAllCategories();

    setState(() {
      _brands = brands;
      _categories = categories;
      _isLoading = false;

      // Edit মোডে pre-select brand & categories
      if (widget.product != null) {
        // Brand pre-select (name মিলিয়ে ID খুঁজে বের করা)
        final matchingBrand = _brands.firstWhere(
          (b) => b.name == widget.product!.brandName,
          orElse: () => Brand(id: 0, name: ''),
        );
        if (matchingBrand.id != 0) {
          _selectedBrandId = matchingBrand.id;
        }

        // Categories pre-select (name মিলিয়ে ID খুঁজে বের করা)
        if (widget.product!.categories != null &&
            widget.product!.categories!.isNotEmpty) {
          _selectedCategoryIds = _categories
              .where((c) => widget.product!.categories!.contains(c.name))
              .map((c) => c.id)
              .toList();
        }
      }
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.map((x) => File(x.path)));
      });
    }
  }

void _removeNewImage(int index) {
    // Future<void> না লিখে void করো (async দরকার নেই)
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newImages.isEmpty &&
        _existingImageUrls.isEmpty &&
        widget.product == null) {
      Fluttertoast.showToast(
        msg: 'At least one image is required',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final discountPrice = double.tryParse(_discountPriceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    bool success;

    if (widget.product == null) {
      // Create মোড
      success = await ProductService.createProduct(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: price,
        discountPrice: discountPrice,
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        stockQuantity: stock,
        brandId: _selectedBrandId,
        categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
        images: _newImages,
      );
    } else {
      // Update মোড
      success = await ProductService.updateProduct(
        id: widget.product!.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: price,
        discountPrice: discountPrice,
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        stockQuantity: stock,
        brandId: _selectedBrandId,
        categoryIds: _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds,
        newImages: _newImages.isEmpty ? null : _newImages,
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(
        msg: widget.product == null ? 'Product Created!' : 'Product Updated!',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to save product',
        backgroundColor: Colors.red,
      );
    }
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
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
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

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price & Discount
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
                              if (value == null || value.trim().isEmpty)
                                return 'Required';
                              if (double.tryParse(value) == null)
                                return 'Invalid number';
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
                              labelText: 'Discount Price (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stock & SKU
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Stock Quantity *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty)
                                return 'Required';
                              if (int.tryParse(value) == null)
                                return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _skuController,
                            decoration: InputDecoration(
                              labelText: 'SKU (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Brand Dropdown
                    DropdownButtonFormField<int?>(
                      value: _selectedBrandId,
                      decoration: InputDecoration(
                        labelText: 'Select Brand *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _brands.map((brand) {
                        return DropdownMenuItem<int>(
                          value: brand.id,
                          child: Text(brand.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedBrandId = value),
                      validator: (value) =>
                          value == null ? 'Select a brand' : null,
                    ),
                    const SizedBox(height: 16),

                    // Category Multi-select Chips
                    Text(
                      'Select Categories *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                          backgroundColor: Colors.grey[200],
                        );
                      }).toList(),
                    ),
                    if (_selectedCategoryIds.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'At least one category required',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Multiple Image Picker + Preview
                    Text(
                      'Product Images *',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),

                    // Existing Images (Edit মোডে)
                    if (isEdit && _existingImageUrls.isNotEmpty)
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImageUrls.length,
                          itemBuilder: (context, index) {
                            final url = _existingImageUrls[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  '${ApiConfig.baseUrl}$url',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 8),

                    // New Selected Images Preview
                    _newImages.isEmpty &&
                            (!isEdit || _existingImageUrls.isEmpty)
                        ? GestureDetector(
                            onTap: _pickImages,
                            child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      'Tap to select images',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _newImages.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _newImages.length) {
                                  return GestureDetector(
                                    onTap: _pickImages,
                                    child: Container(
                                      width: 120,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final file = _newImages[index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          file,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                     Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            _removeNewImage(
                                              index,
                                            ); // ← এখানে কল করো
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
                                isEdit ? 'Update Product' : 'Create Product',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
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
    _stockController.dispose();
    _skuController.dispose();
    super.dispose();
  }
}
