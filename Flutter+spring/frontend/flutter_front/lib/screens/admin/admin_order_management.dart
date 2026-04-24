import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/core/utils/order_pdf_generator.dart';
import 'package:shajgoj/models/order_model.dart';
import 'package:shajgoj/services/api_config.dart';
import 'package:shajgoj/services/order_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminOrderManagementScreen extends StatefulWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  State<AdminOrderManagementScreen> createState() =>
      _AdminOrderManagementScreenState();
}

class _AdminOrderManagementScreenState
    extends State<AdminOrderManagementScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders =
        await OrderService.getAllOrders(); // ← backend থেকে সব অর্ডার
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  List<Order> get _filteredOrders {
    if (_selectedStatusFilter == 'All') return _orders;
    return _orders
        .where(
          (o) => o.status.toUpperCase() == _selectedStatusFilter.toUpperCase(),
        )
        .toList();
  }

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

  Future<void> _updateStatus(int orderId, String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Text('Change to "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Update',
              style: TextStyle(color: _getStatusColor(newStatus)),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    final success = await OrderService.updateOrderStatus(orderId, newStatus);

    setState(() => _isLoading = false);

    if (success) {
      Fluttertoast.showToast(
        msg: 'Status updated',
        backgroundColor: Colors.green,
      );
      _loadOrders();
    } else {
      Fluttertoast.showToast(
        msg: 'Failed to update',
        backgroundColor: Colors.red,
      );
    }
  }

void _showOrderDetails(Order order) {
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
              Text('Status: ${_getStatusText(order.status)}'),
              Text('Payment: ${order.paymentMethod}'),
              Text('User: ${order.userName}'),
              Text('Shipping: ${order.shippingAddressInfo}'),
              const SizedBox(height: 16),
              const Text(
                'Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...order.items.map(
                (item) => ListTile(
                  dense: true,
                  leading:
                      item.product.images != null &&
                          item.product.images!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            '${ApiConfig.baseUrl}${item.product.images!.first}',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                  title: Text(item.product.name),
                  subtitle: Text(
                    'x${item.quantity}  ৳${(item.product.price * item.quantity).toStringAsFixed(0)}',
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
          ElevatedButton.icon(
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('Download PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
            ),
            onPressed: () {
              Navigator.pop(context); // dialog বন্ধ
              generateAndDownloadOrderPdf(order, context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders (Admin)'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatusFilter,
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Orders')),
                      DropdownMenuItem(
                        value: 'PENDING',
                        child: Text('Pending'),
                      ),
                      DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                      DropdownMenuItem(
                        value: 'SHIPPED',
                        child: Text('Shipped'),
                      ),
                      DropdownMenuItem(
                        value: 'DELIVERED',
                        child: Text('Delivered'),
                      ),
                      DropdownMenuItem(
                        value: 'CANCELLED',
                        child: Text('Cancelled'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatusFilter = value!),
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadOrders,
                    child: _filteredOrders.isEmpty
                        ? const Center(child: Text('No orders found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = _filteredOrders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                                child: ExpansionTile(
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${DateFormat('dd MMM yy, hh:mm a').format(order.createdAt)} • ৳${order.totalAmount.toStringAsFixed(0)}',
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('User: ${order.userName}'),
                                          Text(
                                            'Shipping: ${order.shippingAddressInfo}',
                                          ),
                                          Text(
                                            'Payment: ${order.paymentMethod}',
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
                                              leading:
                                                  item.product.images != null &&
                                                      item
                                                          .product
                                                          .images!
                                                          .isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Image.network(
                                                        '${ApiConfig.baseUrl}${item.product.images!.first}',
                                                        width: 40,
                                                        height: 40,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : null,
                                              title: Text(item.product.name),
                                              subtitle: Text(
                                                'x${item.quantity}  ৳${(item.product.price * item.quantity).toStringAsFixed(0)}',
                                              ),
                                            ),
                                          ),
                                          const Divider(),
                                          const SizedBox(height: 16),

                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              if (order.status.toUpperCase() ==
                                                  'PENDING')
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _updateStatus(
                                                        order.orderId,
                                                        'PAID',
                                                      ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.blue,
                                                      ),
                                                  child: const Text(
                                                    'Mark Paid',
                                                  ),
                                                ),
                                              if (order.status.toUpperCase() ==
                                                  'PAID')
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _updateStatus(
                                                        order.orderId,
                                                        'SHIPPED',
                                                      ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.purple,
                                                      ),
                                                  child: const Text(
                                                    'Mark Shipped',
                                                  ),
                                                ),
                                              if (order.status.toUpperCase() ==
                                                  'SHIPPED')
                                                ElevatedButton(
                                                  onPressed: () =>
                                                      _updateStatus(
                                                        order.orderId,
                                                        'DELIVERED',
                                                      ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                  child: const Text(
                                                    'Mark Delivered',
                                                  ),
                                                ),
                                              if (order.status.toUpperCase() !=
                                                      'CANCELLED' &&
                                                  order.status.toUpperCase() !=
                                                      'DELIVERED')
                                                OutlinedButton(
                                                  onPressed: () =>
                                                      _updateStatus(
                                                        order.orderId,
                                                        'CANCELLED',
                                                      ),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.red,
                                                      ),
                                                  child: const Text(
                                                    'Cancel Order',
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
