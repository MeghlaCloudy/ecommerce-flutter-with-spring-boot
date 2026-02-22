import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/screens/admin/add_edit_brand.dart';
import 'package:shajgoj/screens/admin/add_edit_category.dart';
import 'package:shajgoj/screens/admin/add_edit_product.dart'; // ← এটা ইমপোর্ট করো

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Your Store',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Brand Management Card
              _buildAdminCard(
                title: 'Brands',
                subtitle: 'Add, Edit, Delete Brands & Logos',
                icon: Icons.branding_watermark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditBrand(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Category Card
              _buildAdminCard(
                title: 'Categories',
                subtitle: 'Manage Categories & Images',
                icon: Icons.category,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditCategory(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Product Card
              _buildAdminCard(
                title: 'Products',
                subtitle: 'Add, Edit Products with Images & Details',
                icon: Icons.shopping_bag,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddEditProduct(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Optional: আরও ফিচার যোগ করতে পারো
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'More Coming Soon...',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: AppColors.primaryPink),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primaryPink,
        ),
        onTap: onTap,
      ),
    );
  }
}
