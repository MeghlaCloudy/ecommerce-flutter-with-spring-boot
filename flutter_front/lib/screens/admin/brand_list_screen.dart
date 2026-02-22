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

  Future<void> _deleteBrand(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Brand'),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await BrandService.deleteBrand(id);

    if (success) {
      Fluttertoast.showToast(
        msg: 'Brand Deleted Successfully',
        backgroundColor: Colors.green,
        gravity: ToastGravity.BOTTOM,
      );
      _loadBrands();
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to delete brand. Please try again.',
        backgroundColor: Colors.red,
        gravity: ToastGravity.BOTTOM,
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
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Brand',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditBrand()),
              );
              if (result == true) _loadBrands();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh List',
            onPressed: _loadBrands,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBrands,
        color: AppColors.primaryPink,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _brands.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.branding_watermark_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No brands found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Brand'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddEditBrand(),
                          ),
                        );
                        if (result == true) _loadBrands();
                      },
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _brands.length,
                itemBuilder: (context, index) {
                  final brand = _brands[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: brand.logoUrl != null
                          ? CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(
                                '${ApiConfig.baseUrl}${brand.logoUrl}',
                              ),
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.broken_image),
                              backgroundColor: Colors.grey[200],
                            )
                          : CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.branding_watermark,
                                size: 32,
                                color: AppColors.primaryPink,
                              ),
                            ),
                      title: Text(
                        brand.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle:
                          brand.description != null &&
                              brand.description!.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                brand.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit Brand',
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditBrand(brand: brand),
                                ),
                              );
                              if (result == true) _loadBrands();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete Brand',
                            onPressed: () => _deleteBrand(brand.id, brand.name),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
