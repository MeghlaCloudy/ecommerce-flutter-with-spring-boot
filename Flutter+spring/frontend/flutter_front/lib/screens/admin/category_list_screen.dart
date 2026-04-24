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
    setState(() => _isLoading = true);
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
        content: Text(
          'Are you sure you want to delete "$name"? This cannot be undone.',
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

    setState(() => _isLoading = true);

    final success = await CategoryService.deleteCategory(id);

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(
        msg: 'Category Deleted Successfully',
        backgroundColor: Colors.green,
        gravity: ToastGravity.BOTTOM,
      );
      _loadCategories();
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to delete category',
        backgroundColor: Colors.red,
        gravity: ToastGravity.BOTTOM,
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
        elevation: 0,
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
              if (result == true) _loadCategories();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadCategories,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        color: AppColors.primaryPink,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No categories found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Category'),
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
                            builder: (context) => const AddEditCategory(),
                          ),
                        );
                        if (result == true) _loadCategories();
                      },
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: category.imageUrl != null
                          ? CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(
                                '${ApiConfig.baseUrl}${category.imageUrl}',
                              ),
                              onBackgroundImageError: (_, __) =>
                                  const Icon(Icons.broken_image),
                              backgroundColor: Colors.grey[200],
                            )
                          : CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.category,
                                size: 32,
                                color: AppColors.primaryPink,
                              ),
                            ),
                      title: Text(
                        category.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: category.parentId != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Sub-category (Parent ID: ${category.parentId})',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            )
                          : const Text(
                              'Main Category',
                              style: TextStyle(color: Colors.grey),
                            ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit Category',
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
                            tooltip: 'Delete Category',
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
