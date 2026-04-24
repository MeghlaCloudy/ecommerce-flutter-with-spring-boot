import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shajgoj/models/order_model.dart';

Future<void> generateAndDownloadOrderPdf(
  Order order,
  BuildContext context,
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Shajgoj Order Invoice',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Order ID: #${order.orderId}',
              style: pw.TextStyle(fontSize: 16),
            ),
            pw.Text(
              'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt)}',
            ),
            pw.Text('Customer: ${order.userName}'),
            pw.Text('Shipping Address: ${order.shippingAddressInfo}'),
            pw.Text('Payment Method: ${order.paymentMethod}'),
            pw.Text('Status: ${order.status}'),
            pw.SizedBox(height: 20),

            pw.Text(
              'Order Items:',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              headers: ['Product', 'Quantity', 'Unit Price', 'Total'],
              data: order.items.map((item) {
                final price = item.product.discountPrice ?? item.product.price;
                final total = price * item.quantity;
                return [
                  item.product.name,
                  item.quantity.toString(),
                  '৳${price.toStringAsFixed(0)}',
                  '৳${total.toStringAsFixed(0)}',
                ];
              }).toList(),
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
              },
            ),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Amount:',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '৳${order.totalAmount.toStringAsFixed(0)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Thank you for shopping with Shajgoj!',
              style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
            ),
          ],
        );
      },
    ),
  );

  // PDF সেভ + ডাউনলোড/ওপেন
  try {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/order_${order.orderId}.pdf');
    await file.writeAsBytes(await pdf.save());

    // PDF ওপেন করো (Android/iOS-এ)
    final result = await OpenFilex.open(file.path);

    if (result.type != ResultType.done) {
      Fluttertoast.showToast(
        msg: 'Failed to open PDF',
        backgroundColor: Colors.red,
      );
    }
  } catch (e) {
    Fluttertoast.showToast(
      msg: 'Error generating PDF: $e',
      backgroundColor: Colors.red,
    );
  }
}
