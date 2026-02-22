import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/category_model.dart';
import 'package:shajgoj/services/category_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddEditCategory extends StatefulWidget {
  final Category? category; // Edit মোডের জন্য (যদি চাও)

  const AddEditCategory({super.key, this.category});

  @override
  State<AddEditCategory> createState() => _AddEditCategoryState();
}

class _AddEditCategoryState extends State<AddEditCategory> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _selectedImage;
  int? _parentId;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _parentId = widget.category!.parentId;
      // পুরোনো imageUrl দেখানোর দরকার নেই — তুমি চাও না
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = widget.category == null
        ? await CategoryService.createCategory(
            name: _nameController.text.trim(),
            imageFile: _selectedImage,
            parentId: _parentId,
          )
        : await CategoryService.updateCategory(
            id: widget.category!.id,
            name: _nameController.text.trim(),
            newImageFile: _selectedImage, // নতুন ছবি দিলে আপডেট হবে
            parentId: _parentId,
          );

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(
        msg: widget.category == null
            ? 'Category Created!'
            : 'Category Updated!',
        backgroundColor: Colors.green,
      );
      Navigator.pop(context, true);
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to save',
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Category' : 'Add New Category'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 16),

              // Parent Category (অপশনাল - পরে যোগ করতে পারো)
              // DropdownButtonFormField<int?>(
              //   value: _parentId,
              //   decoration: InputDecoration(
              //     labelText: 'Parent Category (optional)',
              //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              //   ),
              //   items: [], // পরে Category list থেকে লোড করো
              //   onChanged: (value) => setState(() => _parentId = value),
              // ),
              // const SizedBox(height: 24),
              Text(
                'Category Image',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 150,
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tap to select image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isEdit ? 'Update Category' : 'Create Category',
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
    super.dispose();
  }
}
