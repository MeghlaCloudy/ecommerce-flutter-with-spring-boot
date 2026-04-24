import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/order_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/order_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await OrderService.getUserOrders(); // ← backend থেকে লোড
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  // Status text mapping
  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending';
      case 'PAID':
        return 'Paid';
      case 'SHIPPED':
        return 'Shipped';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Status color mapping
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'PAID':
        return Colors.blue;
      case 'SHIPPED':
        return Colors.purple;
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            )
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadOrders,
              color: AppColors.primaryPink,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          order.status,
                        ).withOpacity(0.2),
                        child: Icon(
                          Icons.local_shipping,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                      title: Text(
                        'Order #${order.orderId}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat(
                              'dd MMM yyyy, hh:mm a',
                            ).format(order.createdAt),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${_getStatusText(order.status)}',
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        '৳${order.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPink,
                        ),
                      ),
                      onTap: () {
                        // Order details dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Order #${order.orderId}'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)}',
                                  ),
                                  Text(
                                    'Status: ${_getStatusText(order.status)}',
                                  ),
                                  Text('Payment: ${order.paymentMethod}'),
                                  Text(
                                    'Delivered to: ${order.shippingAddressInfo}',
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Items:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ...order.items.map(
                                    (item) => ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        backgroundImage:
                                            item.product.images != null &&
                                                item.product.images!.isNotEmpty
                                            ? NetworkImage(
                                                '${ApiConfig.baseUrl}${item.product.images!.first}',
                                              )
                                            : null,
                                        child:
                                            item.product.images == null ||
                                                item.product.images!.isEmpty
                                            ? const Icon(
                                                Icons.image_not_supported,
                                              )
                                            : null,
                                      ),
                                      title: Text(item.product.name),
                                      subtitle: Text('x${item.quantity}'),
                                      trailing: Text(
                                        '৳${(item.product.price * item.quantity).toStringAsFixed(0)}',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
