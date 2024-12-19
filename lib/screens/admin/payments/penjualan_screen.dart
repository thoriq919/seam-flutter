import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'index_screen.dart';

class PenjualanScreen extends StatefulWidget {
  @override
  _PenjualanScreenState createState() => _PenjualanScreenState();
}

class _PenjualanScreenState extends State<PenjualanScreen> {
  late final WebViewController _webViewController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String midtransClientKey = 'SB-Mid-server-RyxvpqiZ4B58BNp8anchaTFr';
  final String midtransBaseUrl =
      'https://app.sandbox.midtrans.com/snap/v1/transactions';

  final TextEditingController priceController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  Future<String?> createTransaction({
    required String orderId,
    required int amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(midtransBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('$midtransClientKey:')),
        },
        body: jsonEncode({
          'transaction_details': {
            'order_id': orderId,
            'gross_amount': amount,
          },
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['redirect_url'];
      } else {
        print('Midtrans error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating transaction: $e');
      return null;
    }
  }

  Future<void> saveTransactionToFirestore({
    required String orderId,
    required int amount,
    required String status,
    required int total,
    required String name,
  }) async {
    try {
      await _firestore.collection('pembayaran').doc(orderId).set({
        'nama': name,
        'orderId': orderId,
        'total_bayar': amount,
        'total_alpukat': total,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving transaction: $e');
    }
  }

  void startPayment() async {
    final orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
    final pricePerKg = int.tryParse(priceController.text) ?? 0;
    final quantityKg = int.tryParse(quantityController.text) ?? 0;
    final amount = pricePerKg * quantityKg;
    final name = nameController.text;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid price and quantity.')),
      );
      return;
    }

    final snapUrl = await createTransaction(orderId: orderId, amount: amount);

    if (snapUrl != null) {
      saveTransactionToFirestore(
        name: name,
        orderId: orderId,
        amount: amount,
        total: quantityKg,
        status: 'success',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Payment'),
            ),
            body: WebViewWidget(
              controller: WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse(snapUrl))
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onNavigationRequest: (NavigationRequest request) {
                      if (request.url.contains(
                          'https://app.sandbox.midtrans.com/snap/v1/')) {
                        if (request.url.contains('status_code=200')) {
                          saveTransactionToFirestore(
                            name: name,
                            orderId: orderId,
                            amount: amount,
                            total: quantityKg,
                            status: 'success',
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment Successful!')),
                          );
                        } else if (request.url.contains('status_code=201')) {
                          saveTransactionToFirestore(
                            name: name,
                            orderId: orderId,
                            amount: amount,
                            total: quantityKg,
                            status: 'pending',
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment Pending!')),
                          );
                        }
                        return NavigationDecision.prevent;
                      }
                      return NavigationDecision.navigate;
                    },
                  ),
                ),
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initiate payment.')),
      );
    }
  }

  void saveTransaction() async {
    final orderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
    final pricePerKg = int.tryParse(priceController.text) ?? 0;
    final quantityKg = int.tryParse(quantityController.text) ?? 0;
    final amount = pricePerKg * quantityKg;
    final name = nameController.text;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid price and quantity.')),
      );
      return;
    }

    await saveTransactionToFirestore(
      name: name,
      orderId: orderId,
      amount: amount,
      total: quantityKg,
      status: 'saved',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaction saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.white,
      appBar: AppBar(
        title: Text(
          'Midtrans Payment',
          style: TextStyle(
              color: ColorTheme.blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        backgroundColor: ColorTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorTheme.blackFont,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Harga Per KG',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Jumlah (KG)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.white,
                    ),
                    onPressed: startPayment,
                    child: Text(
                      'Pay Now',
                      style: TextStyle(color: ColorTheme.blackFont),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorTheme.blackFont,
                    ),
                    onPressed: saveTransaction,
                    child: Text(
                      'Save',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorTheme.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
