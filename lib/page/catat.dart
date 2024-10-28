import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/firestore.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID Catatan',
              ),
              readOnly: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _tanggalController,
              decoration: const InputDecoration(labelText: 'Tanggal'),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            TextField(
              controller: _tinggiController,
              decoration: const InputDecoration(labelText: 'Tinggi Alpukat'),
            ),
            TextField(
              controller: _diameterController,
              decoration: const InputDecoration(labelText: 'Diameter Alpukat'),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 40.0,
              runSpacing: 20.0,
              children: [
                ElevatedButton(
                  onPressed: tambahCatat,
                  child: const Text('Tambah Catatan'),
                ),
                ElevatedButton(
                  onPressed: ubahCatat,
                  child: const Text('Edit Catatan'),
                ),
                ElevatedButton(
                  onPressed: hapusCatat,
                  child: const Text('Hapus Catatan'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _listCatat.length,
                itemBuilder: (context, index) {
                  var catatan = _listCatat[index];
                  // Konversi Timestamp ke DateTime
                  DateTime tanggal = (catatan['tanggal'] as Timestamp).toDate();
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(tanggal);

                  return ListTile(
                    title: Text('Tanggal    : $formattedDate'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tinggi Tanaman  : ${catatan['tinggi']}'),
                        Text('Diameter Tanaman  : ${catatan['diameter']}'),
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
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
