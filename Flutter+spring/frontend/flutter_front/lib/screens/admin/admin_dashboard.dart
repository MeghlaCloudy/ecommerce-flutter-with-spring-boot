import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/screens/admin/add_edit_brand.dart';
import 'package:shajgoj/screens/admin/add_edit_category.dart';
import 'package:shajgoj/screens/admin/add_edit_product.dart';
import 'package:shajgoj/screens/admin/admin_order_management.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Manage Your Store',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Control brands, categories, products, orders and more',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 32),

              // Management Cards
              _buildAdminCard(
                title: 'Brands',
                subtitle: 'Add, edit, delete brands & logos',
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

              _buildAdminCard(
                title: 'Categories',
                subtitle: 'Manage categories & images',
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

              _buildAdminCard(
                title: 'Products',
                subtitle: 'Add, edit products with images & details',
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
              const SizedBox(height: 16),

              // নতুন: Manage Orders Card
              _buildAdminCard(
                title: 'Manage Orders',
                subtitle:
                    'View all user orders, update status, download PDF invoices',
                icon: Icons.receipt_long,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminOrderManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Future Features
              const Divider(),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'More features coming soon...',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 40, color: AppColors.primaryPink),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryPink,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
