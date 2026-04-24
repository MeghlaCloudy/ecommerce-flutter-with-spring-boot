import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shajgoj/core/constanst/app_colors.dart';
import 'package:shajgoj/models/checkout_request.dart';
import 'package:shajgoj/models/order_model.dart';
import 'package:shajgoj/screens/order_success_screen.dart';
import 'package:shajgoj/services/order_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController(text: 'Bangladesh');
  final _zipController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';

  bool _isLoading = false;

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('CheckoutScreen loaded with totalAmount: ${widget.totalAmount}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.primaryPink,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Amount'),
                                Text(
                                  '৳${(widget.totalAmount ?? 0.0).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryPink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Shipping'),
                                Text(
                                  'FREE',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Shipping Address
                    const Text(
                      'Shipping Address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street Address',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _zipController,
                      decoration: const InputDecoration(
                        labelText: 'Zip Code',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Payment Method
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery'),
                      value: 'Cash on Delivery',
                      groupValue: _paymentMethod,
                      onChanged: (value) =>
                          setState(() => _paymentMethod = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Online Payment (Coming Soon)'),
                      value: 'Online',
                      groupValue: _paymentMethod,
                      onChanged: null,
                    ),
                    const SizedBox(height: 32),

                    // Place Order Button (crash-proof + route to OrderSuccessScreen)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) {
                                  Fluttertoast.showToast(
                                    msg: 'Please fill all required fields',
                                    backgroundColor: Colors.orange,
                                  );
                                  return;
                                }

                                setState(() => _isLoading = true);

                                final request = CheckoutRequest(
                                  paymentMethod: _paymentMethod,
                                  street: _streetController.text.trim(),
                                  city: _cityController.text.trim(),
                                  country: _countryController.text.trim(),
                                  zipCode: _zipController.text.trim(),
                                );

                                print(
                                  'Sending checkout request:------------- ${request.toJson()}',
                                );

                                try {
                                  final Order?
                                  order = await OrderService.checkout(request).timeout(
                                    const Duration(seconds: 30),
                                    onTimeout: () {
                                      print(
                                        'Checkout timeout after 30s-----------------------------',
                                      );
                                      throw TimeoutException(
                                        'Checkout request timeout----------------------',
                                      );
                                    },
                                  );

                                  setState(() => _isLoading = false);

                                  if (order != null) {
                                    Fluttertoast.showToast(
                                      msg:
                                          'Order Placed Successfully!---------',
                                      backgroundColor: Colors.green,
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderSuccessScreen(order: order),
                                      ),
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          'Failed to place order - No order returned-------------------',
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                } catch (e, stack) {
                                  setState(() => _isLoading = false);
                                  print('Checkout error:----------------- $e');
                                  print(
                                    'Stack trace:----------------------- $stack',
                                  );
                                  Fluttertoast.showToast(
                                    msg:
                                        'Error placing order:------------------ $e',
                                    backgroundColor: Colors.red,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPink,
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
                            : const Text(
                                'PLACE ORDER',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
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
}
