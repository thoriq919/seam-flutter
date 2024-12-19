import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/screens/admin/payments/penjualan_screen.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class IndexScreen extends StatefulWidget {
  @override
  _IndexScreenState createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _sortOrder = 'Newest';

  void _showBottomSheet(BuildContext context, DocumentSnapshot record) {
    final TextEditingController nameController =
        TextEditingController(text: record['nama']);
    final TextEditingController priceController =
        TextEditingController(text: record['total_bayar'].toString());
    final TextEditingController quantityController =
        TextEditingController(text: record['total_alpukat'].toString());

    showModalBottomSheet(
      backgroundColor: ColorTheme.white,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Edit Record',
                style: TextStyle(
                    color: ColorTheme.blackFont,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nama'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Total Bayar'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Jumlah (KG)'),
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
                      onPressed: () async {
                        await _firestore
                            .collection('pembayaran')
                            .doc(record.id)
                            .update({
                          'nama': nameController.text,
                          'total_bayar':
                              int.tryParse(priceController.text) ?? 0,
                          'total_alpukat':
                              int.tryParse(quantityController.text) ?? 0,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Transaksi Berhasil di Edit')),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Save Changes',
                        style: TextStyle(color: ColorTheme.blackFont),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _firestore
                            .collection('pembayaran')
                            .doc(record.id)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Transaksi berhasil dihapus')),
                        );
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> exportToPDF(BuildContext context) async {
    // Fetch data from Firestore
    final QuerySnapshot snapshot =
        await _firestore.collection('pembayaran').get();
    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records found to export')),
      );
      return;
    }

    // Create PDF document
    final pdf = pw.Document();

    // Add pagea
    pdf.addPage(
      pw.Page(
        build: (pw.Context pdfContext) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Payment Records',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.ListView.builder(
                itemCount: snapshot.docs.length,
                itemBuilder: (context, index) {
                  var data =
                      snapshot.docs[index].data() as Map<String, dynamic>;
                  print(data);
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Name: ${data['nama']}',
                          style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Order ID: ${data['orderId']}',
                          style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Status: ${data['status']}',
                          style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Total: ${data['total_bayar']}',
                          style: pw.TextStyle(fontSize: 18)),
                      pw.SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.white,
      appBar: AppBar(
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
        title: Text(
          'Payment Records',
          style: TextStyle(
              color: ColorTheme.blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              exportToPDF(context);
            },
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _sortOrder,
              items: <String>['Newest', 'Oldest'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _sortOrder = newValue!;
                });
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('pembayaran')
                    .orderBy('createdAt', descending: _sortOrder == 'Newest')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No records found.'));
                  }

                  final records = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name: ${record['nama']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Order ID: ${record['orderId']}'),
                              Text('Status: ${record['status']}'),
                              Text('Total: ${record['total_bayar']}'),
                              Text(
                                  'Created At: ${record['createdAt']?.toDate().toString() ?? 'N/A'}'),
                            ],
                          ),
                          onTap: () => _showBottomSheet(context, record),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorTheme.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PenjualanScreen()),
          );
        },
        tooltip: 'Add New Record',
        child: Icon(
          Icons.add,
          color: ColorTheme.white,
        ),
      ),
    );
  }
}
