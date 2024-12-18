import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/screens/admin/penjualan/penjualan_screen.dart';
import 'pdf_export.dart';

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
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Record', style: TextStyle(fontSize: 20)),
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
                    // Wrap the button in an Expanded widget
                    child: ElevatedButton(
                      onPressed: () async {
                        // Update the record in Firestore
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
                      child: Text('Save Changes'),
                    ),
                  ),
                  SizedBox(width: 8), // Add some spacing between the buttons
                  Expanded(
                    // Wrap the button in an Expanded widget
                    child: ElevatedButton(
                      onPressed: () async {
                        // Delete the record from Firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () {
              // Call the PDF export function
              exportToPDF(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Dropdown for selecting sort order
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
                    return ListTile(
                      title: Text(record['nama']),
                      subtitle: Text(
                          'Order ID: ${record['orderId']} - Status: ${record['status']} - Total: ${record['total_bayar']}'),
                      trailing: Text(
                          record['createdAt']?.toDate().toString() ?? 'N/A'),
                      onTap: () => _showBottomSheet(
                          context, record), // Show BottomSheet on tap
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PenjualanScreen()), // Navigate to the create screen
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Record',
      ),
    );
  }
}
