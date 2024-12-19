import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

Future<void> exportToPDF(BuildContext context) async {
  // Reference to loading dialog
  bool isLoading = true;
  BuildContext? loadingContext;

  try {
    // Show loading dialog
    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          loadingContext = dialogContext;
          return PopScope(
            canPop: false,
            child: Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('Generating PDF...',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Fetch data from Firestore
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('pembayaran')
        .orderBy('createdAt', descending: true)
        .get();

    if (!context.mounted) return;

    if (snapshot.docs.isEmpty) {
      if (loadingContext != null && isLoading) {
        Navigator.pop(loadingContext!);
        isLoading = false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records found to export')),
      );
      return;
    }

    // Create PDF document
    final pdf = pw.Document();

    // Add page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Records',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
                        style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              _buildTable(pdfContext, snapshot.docs),
              pw.SizedBox(height: 20),
              _buildSummary(snapshot.docs),
            ],
          );
        },
      ),
    );

    // Save PDF
    final pdfBytes = await pdf.save();

    if (!context.mounted) return;

    // Close loading dialog before showing file picker
    if (loadingContext != null && isLoading) {
      Navigator.pop(loadingContext!);
      isLoading = false;
    }

    // Show file picker
    final String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save PDF File',
      fileName: 'payment_records_${DateTime.now().millisecondsSinceEpoch}.pdf',
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );

    if (!context.mounted) return;

    if (outputFile != null) {
      // Save file
      final String finalPath = outputFile.toLowerCase().endsWith('.pdf')
          ? outputFile
          : '$outputFile.pdf';

      final file = File(finalPath);
      await file.writeAsBytes(pdfBytes);

      print('PDF saved successfully at $finalPath');

      // Menampilkan snackbar setelah file disimpan
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF berhasil disimpan di ${file.path}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  } catch (e) {
    print('PDF Export Error: $e');
    // Close loading dialog if still showing
    if (loadingContext != null && isLoading) {
      Navigator.pop(loadingContext!);
      isLoading = false;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

// Helper function to build table
pw.Widget _buildTable(pw.Context context, List<QueryDocumentSnapshot> docs) {
  return pw.TableHelper.fromTextArray(
    context: context,
    headerDecoration: pw.BoxDecoration(
      color: PdfColors.grey300,
    ),
    headerHeight: 25,
    cellHeight: 40,
    cellAlignments: {
      0: pw.Alignment.centerLeft,
      1: pw.Alignment.center,
      2: pw.Alignment.center,
      3: pw.Alignment.centerRight,
      4: pw.Alignment.center,
    },
    data: <List<String>>[
      <String>['Name', 'Order ID', 'Quantity (KG)', 'Total (Rp)', 'Status'],
      ...docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return [
          data['nama']?.toString() ?? 'N/A',
          data['orderId']?.toString() ?? 'N/A',
          data['total_alpukat']?.toString() ?? '0',
          'Rp ${_formatNumber(data['total_bayar']?.toString() ?? '0')}',
          data['status']?.toString() ?? 'N/A',
        ];
      }).toList(),
    ],
    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
    cellStyle: const pw.TextStyle(fontSize: 10),
    border: pw.TableBorder.all(width: 0.5),
  );
}

// Helper function to build summary
pw.Widget _buildSummary(List<QueryDocumentSnapshot> docs) {
  num totalQuantity = 0;
  num totalAmount = 0;

  for (var doc in docs) {
    final data = doc.data() as Map<String, dynamic>;
    totalQuantity += data['total_alpukat'] ?? 0;
    totalAmount += data['total_bayar'] ?? 0;
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Ringkasan',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.Text('Total Transaksi: ${docs.length}'),
      pw.Text('Total Quantity: ${totalQuantity.toStringAsFixed(0)} KG'),
      pw.Text(
          'Total Amount: Rp ${_formatNumber(totalAmount.toStringAsFixed(0))}'),
    ],
  );
}

// Helper function to format numbers
String _formatNumber(String number) {
  try {
    final num = int.parse(number);
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  } catch (e) {
    return number;
  }
}
