import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/firestore.dart';
import 'package:intl/intl.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class Catat extends StatefulWidget {
  const Catat({super.key});

  @override
  State<Catat> createState() => _CatatState();
}

class _CatatState extends State<Catat> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  DateTime? selectedDate;
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  final Firestore firestore = Firestore();

  List<DocumentSnapshot> _listCatat = [];

  @override
  void initState() {
    super.initState();
    _clear();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        _tanggalController.text = formattedDate;
      });
    }
  }

  void tambahCatat() {
    if (selectedDate != null) {
      firestore.tambahData(
        selectedDate!,
        _tinggiController.text,
        _diameterController.text,
      );
    } else {
      print('Tanggal belum dipilih');
    }
    readCatat();
  }

  void ubahCatat() {
    if (selectedDate != null) {
      firestore.updateData(_idController.text, selectedDate!,
          _tinggiController.text, _diameterController.text);
    }
    readCatat();
  }

  void hapusCatat() {
    firestore.hapusData(_idController.text);
    readCatat();
  }

  void readCatat() {
    CollectionReference pertumbuhan =
        FirebaseFirestore.instance.collection('log_pertumbuhan');

    pertumbuhan.get().then((QuerySnapshot snapshot) {
      setState(() {
        _listCatat = snapshot.docs;
        print('Data yang diambil: ${snapshot.docs}');
      });
    });
  }

  void _clear() {
    readCatat();
    _idController.clear();
    _tinggiController.clear();
    selectedDate = null;
    _diameterController.clear();
  }


  // ... [Previous methods remain the same] ...

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, size),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ColorTheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildInputCard(),
                        const SizedBox(height: 20),
                        _buildButtonRow(),
                        const SizedBox(height: 20),
                        _buildCatatanList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: size.height * 0.1,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pencatatan Pertumbuhan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _idController,
            decoration: const InputDecoration(
              labelText: 'ID Catatan',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tanggalController,
            decoration: const InputDecoration(
              labelText: 'Tanggal',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tinggiController,
            decoration: const InputDecoration(
              labelText: 'Tinggi Alpukat (cm)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _diameterController,
            decoration: const InputDecoration(
              labelText: 'Diameter Alpukat (cm)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: tambahCatat,
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: ubahCatat,
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: hapusCatat,
          icon: const Icon(Icons.delete),
          label: const Text('Hapus'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCatatanList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _listCatat.length,
      itemBuilder: (context, index) {
        var catatan = _listCatat[index];
        DateTime tanggal = (catatan['tanggal'] as Timestamp).toDate();
        String formattedDate = DateFormat('yyyy-MM-dd').format(tanggal);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildInfoRow(Icons.height, 'Tinggi', '${catatan['tinggi']} cm'),
                const SizedBox(height: 4),
                _buildInfoRow(
                    Icons.circle_outlined, 'Diameter', '${catatan['diameter']} cm'),
              ],
            ),
            onTap: () {
              setState(() {
                _idController.text = catatan.id;
                selectedDate = tanggal;
                _tanggalController.text = formattedDate;
                _tinggiController.text = catatan['tinggi'];
                _diameterController.text = catatan['diameter'];
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}