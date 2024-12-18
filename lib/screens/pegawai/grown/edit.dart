import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seam_flutter/firestore.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class EditPencatatanPage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const EditPencatatanPage({super.key, required this.documentSnapshot});

  @override
  State<EditPencatatanPage> createState() => _EditPencatatanPageState();
}

class _EditPencatatanPageState extends State<EditPencatatanPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _tinggiController = TextEditingController();
  final TextEditingController _diameterController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  DateTime? selectedDate;
  final Firestore firestore = const Firestore();
  String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    DateTime tanggal =
        (widget.documentSnapshot['tanggal'] as Timestamp).toDate();

    setState(() {
      _idController.text = widget.documentSnapshot.id;
      selectedDate = tanggal;
      _tanggalController.text = DateFormat('yyyy-MM-dd').format(tanggal);
      _tinggiController.text = widget.documentSnapshot['tinggi'];
      _diameterController.text = widget.documentSnapshot['diameter'];
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: ColorTheme.primary,
            colorScheme: ColorScheme.light(primary: ColorTheme.primary),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            dialogBackgroundColor: ColorTheme.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
        _tanggalController.text = formattedDate;
      });
    }
  }

  void _ubahPencatatan() {
    if (selectedDate != null) {
      firestore.updateData(_idController.text, selectedDate!,
          _tinggiController.text, _diameterController.text);
      Navigator.pop(context);
    }
  }

  void _hapusPencatatan() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ColorTheme.white,
          title: Text(
            'Konfirmasi Hapus',
            style: TextStyle(color: ColorTheme.blackFont),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pencatatan ini?',
            style: TextStyle(color: ColorTheme.blackFont),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                firestore.hapusData(_idController.text);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Batal',
                  style: TextStyle(color: ColorTheme.blackFont),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTheme.blackFont),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Note',
          style: TextStyle(
              color: ColorTheme.blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        centerTitle: true,
      ),
      backgroundColor: ColorTheme.white,
      body: Column(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildInputForm(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Container(
      decoration: BoxDecoration(
        color: ColorTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 25),
            blurRadius: 15,
            spreadRadius: -25,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: _tanggalController,
            decoration: InputDecoration(
              labelText: 'Tanggal',
              labelStyle: TextStyle(color: ColorTheme.blackFont),
              suffixIcon:
                  Icon(Icons.calendar_today, color: ColorTheme.blackFont),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.blackFont),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.blackFont, width: 2),
              ),
            ),
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tinggiController,
            decoration: InputDecoration(
              labelText: 'Tinggi Alpukat (cm)',
              labelStyle: TextStyle(color: ColorTheme.blackFont),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.blackFont),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.blackFont, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _diameterController,
            decoration: InputDecoration(
              labelText: 'Diameter Alpukat (cm)',
              labelStyle: TextStyle(color: ColorTheme.blackFont),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.blackFont),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.blackFont, width: 2),
              ),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _ubahPencatatan,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorTheme.blackFont,
            foregroundColor: ColorTheme.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save),
              SizedBox(width: 10),
              Text('Simpan Perubahan'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _hapusPencatatan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete),
              SizedBox(width: 10),
              Text('Hapus Pencatatan'),
            ],
          ),
        ),
      ],
    );
  }
}
