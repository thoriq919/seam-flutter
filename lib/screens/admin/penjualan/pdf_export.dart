import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> exportToPDF() async {
  final pdf = pw.Document();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final QuerySnapshot snapshot =
      await _firestore.collection('pembayaran').get();
  final records = snapshot.docs;

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text('Payment Records', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              data: <List<String>>[
                <String>['Name', 'Order ID', 'Total', 'Status', 'Created At'],
                ...records.map((record) {
                  return [
                    record['nama']?.toString() ?? 'N/A',
                    record['orderId']?.toString() ?? 'N/A',
                    record['total_bayar']?.toString() ?? '0',
                    record['status']?.toString() ?? 'N/A',
                    record['createdAt']?.toDate().toString() ?? 'N/A',
                  ];
                }).toList(),
              ],
            ),
          ],
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/payment_records.pdf");
  await file.writeAsBytes(await pdf.save());
  print("PDF saved at ${file.path}");
}
