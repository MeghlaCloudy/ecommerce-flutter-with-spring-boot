import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/category_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/category_service.dart';
import 'package:shajgoj/screens/admin/add_edit_category.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    final categories = await CategoryService.getAllCategories();

    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _deleteCategory(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
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

    setState(() => _isLoading = true);

    final success = await CategoryService.deleteCategory(id);

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(
        msg: 'Category Deleted Successfully',
        backgroundColor: Colors.green,
      );
      _loadCategories(); // রিফ্রেশ করো
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to delete category',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Category',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCategory(),
                ),
              );

              if (result == true) {
                _loadCategories(); // Create সাকসেস হলে রিফ্রেশ
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No categories found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddEditCategory(),
                        ),
                      );
                      if (result == true) _loadCategories();
                    },
                    child: const Text('Add First Category'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadCategories,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: category.imageUrl != null
                          ? CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                '${ApiConfig.baseUrl}${category.imageUrl}',
                              ),
                              onBackgroundImageError: (exception, stackTrace) {
                                // পুরোনো ছবি লোড না হলে ডিফল্ট আইকন
                              },
                              child: category.imageUrl == null
                                  ? const Icon(Icons.category)
                                  : null,
                            )
                          : const CircleAvatar(
                              radius: 30,
                              child: Icon(Icons.category),
                            ),
                      title: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: category.parentId != null
                          ? Text(
                              'Sub-category (Parent ID: ${category.parentId})',
                            )
                          : const Text('Main Category'),
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
                                      AddEditCategory(category: category),
                                ),
                              );
                              if (result == true) _loadCategories();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteCategory(category.id, category.name),
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
