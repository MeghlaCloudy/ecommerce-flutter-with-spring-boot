import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/core/constanst/app_strings.dart';

import 'package:shajgoj/screens/admin/add_edit_brand.dart';
import 'package:shajgoj/screens/admin/add_edit_category.dart';
import 'package:shajgoj/screens/admin/add_edit_product.dart';
import 'package:shajgoj/screens/admin/admin_dashboard.dart';
import 'package:shajgoj/screens/admin/brand_list_screen.dart';
import 'package:shajgoj/screens/admin/category_list_screen.dart';
import 'package:shajgoj/screens/admin/product_list_screen.dart';
import 'package:shajgoj/screens/cart_screen.dart';
import 'package:shajgoj/screens/home_screen.dart';
import 'package:shajgoj/screens/login_screen.dart';
import 'package:shajgoj/screens/order_history_screen.dart';
import 'package:shajgoj/screens/user/product_list_screen.dart'
    hide ProductListScreen;
import 'package:shajgoj/services/cart_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final List<String> categories = [
    'Makeup',
    'Skin',
    'Hair',
    'Personal Care',
    'Mom & Baby',
    'Fragrance',
    'Undergarments',
    'Combo',
    'Jewellery',
    'Clearance Sale',
    'Men',
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            color: AppColors.primaryPink,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Explore Beauty',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Home
          ListTile(
            leading: Icon(Icons.home, color: AppColors.primaryPink),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),

          // User Products List
          ListTile(
            leading: Icon(Icons.shopping_bag, color: AppColors.primaryPink),
            title: const Text('Products List'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListScreen(),
                ),
              );
            },
          ),

          // Cart (এখানে রিয়েল-টাইম count + refresh)
          ListTile(
            leading: Icon(Icons.shopping_cart, color: AppColors.primaryPink),
            title: const Text('Cart'),
            trailing: FutureBuilder<int>(
              future: CartService.getCartCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                final count = snapshot.data ?? 0;
                return count > 0
                    ? CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              ).then((_) {
                // CartScreen থেকে ফিরলে Drawer-এর count আপডেট হবে (optional)
                // যদি global state থাকে তাহলে setState বা provider দিয়ে আপডেট করো
              });
            },
          ),

          // My Orders
          ListTile(
            leading: Icon(Icons.history, color: AppColors.primaryPink),
            title: const Text('My Orders'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),

          // Login
          ListTile(
            leading: Icon(Icons.login, color: AppColors.primaryPink),
            title: const Text('Login'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),

          const Divider(),

          // Admin Section (Admin role check যোগ করা যেতে পারে পরে)
          ListTile(
            leading: Icon(Icons.dashboard, color: AppColors.primaryPink),
            title: const Text('Admin Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminDashboard()),
              );
            },
          ),

          ListTile(
            leading: Icon(
              Icons.branding_watermark,
              color: AppColors.primaryPink,
            ),
            title: const Text('All Brands'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BrandListScreen(),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.category, color: AppColors.primaryPink),
            title: const Text('Categories List'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryListScreen(),
                ),
              );
            },
          ),

          // All Categories (ExpansionTile)
          ExpansionTile(
            leading: Icon(Icons.category, color: AppColors.primaryPink),
            title: const Text('All Categories'),
            children: categories.map((category) {
              return ListTile(
                title: Text(category),
                contentPadding: const EdgeInsets.only(left: 60),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$category clicked')));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
