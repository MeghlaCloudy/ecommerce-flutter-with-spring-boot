import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/brand_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/brand_service.dart';
import 'package:shajgoj/screens/admin/add_edit_brand.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BrandListScreen extends StatefulWidget {
  const BrandListScreen({super.key});

  @override
  State<BrandListScreen> createState() => _BrandListScreenState();
}

class _BrandListScreenState extends State<BrandListScreen> {
  List<Brand> _brands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() => _isLoading = true);
    final brands = await BrandService.getAllBrands();
    setState(() {
      _brands = brands;
      _isLoading = false;
    });
  }

  Future<void> _deleteBrand(int id) async {
    final success = await BrandService.deleteBrand(id);
    if (success) {
      Fluttertoast.showToast(
        msg: 'Brand Deleted',
        backgroundColor: Colors.green,
      );
      _loadBrands(); // রিফ্রেশ
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
        title: const Text('Manage Brands'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditBrand()),
              );
              if (result == true) _loadBrands(); // Create সাকসেস হলে রিফ্রেশ
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _brands.isEmpty
          ? const Center(child: Text('No brands found'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _brands.length,
              itemBuilder: (context, index) {
                final brand = _brands[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: brand.logoUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(
                              '${ApiConfig.baseUrl}${brand.logoUrl}',
                            ),
                            onBackgroundImageError: (_, __) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.branding_watermark),
                          ),
                    title: Text(
                      brand.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: brand.description != null
                        ? Text(
                            brand.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
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
                                    AddEditBrand(brand: brand),
                              ),
                            );
                            if (result == true)
                              _loadBrands(); // Update সাকসেস হলে রিফ্রেশ
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Brand'),
                                content: Text(
                                  'Are you sure you want to delete "${brand.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              _deleteBrand(brand.id);
                            }
                          },
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
