import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<void> exportToPDF(BuildContext context) async {
  try {
    final pdf = pw.Document();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final QuerySnapshot snapshot =
        await _firestore.collection('pembayaran').get();
    final records = snapshot.docs;

    // Check if there are any records
    if (records.isEmpty) {
      Navigator.of(context).pop(); // Dismiss loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No records found to export')),
      );
      return;
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Payment Records', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Name', 'Order ID', 'Total', 'Status', 'Created At'],
                  ...records.map((record) {
                    return [
                      record['nama']?.toString() ?? 'N/A',
                      record['orderId']?.toString() ?? 'N/A',
                      record['total_bayar']?.toString() ?? '0',
                      record['status']?.toString() ?? 'N/A',
                      record['createdAt'] != null
                          ? record['createdAt'].toDate().toString()
                          : 'N/A',
                    ];
                  }).toList(),
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: pw.TextStyle(),
                border: pw.TableBorder.all(),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF
    final pdfBytes = await pdf.save();

    // Use File Picker to select save location
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF File',
      fileName: 'payment_records.pdf',
    );

    // Dismiss loading indicator
    Navigator.of(context).pop();

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsBytes(pdfBytes);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved successfully at $outputFile')),
      );
    } else {
      // User canceled file selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF export canceled')),
      );
    }
  } catch (e) {
    // Dismiss loading indicator if still shown
    Navigator.of(context).pop();

    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error exporting PDF: ${e.toString()}')),
    );
    print('PDF Export Error: $e');
  }
}
