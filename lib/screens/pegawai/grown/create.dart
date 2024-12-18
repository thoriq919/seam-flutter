import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:seam_flutter/firestore.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class CreatePencatatanPage extends StatefulWidget {
  const CreatePencatatanPage({super.key});

  @override
  State<CreatePencatatanPage> createState() => _CreatePencatatanPageState();
}

class _CreatePencatatanPageState extends State<CreatePencatatanPage> {
  final TextEditingController _tinggiController = TextEditingController();
  final TextEditingController _circumferenceController =
      TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();

  DateTime? selectedDate;
  final Firestore firestore = const Firestore();
  String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

  double _calculateCircularArea(double circumference) {
    double diameter = circumference / pi;

    double radius = diameter / 2;

    return pi * radius * radius;
  }

  void _tambahPencatatan() {
    if (selectedDate != null &&
        _tinggiController.text.isNotEmpty &&
        _circumferenceController.text.isNotEmpty) {
      double circularArea =
          _calculateCircularArea(double.parse(_circumferenceController.text));

      firestore.tambahData(
        selectedDate!,
        _tinggiController.text,
        circularArea.toStringAsFixed(2),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.white,
      appBar: AppBar(
        backgroundColor: ColorTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTheme.blackFont),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create Note',
          style: TextStyle(
              color: ColorTheme.blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildInputForm(),
                    const SizedBox(height: 20),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
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
            controller: _circumferenceController,
            decoration: InputDecoration(
              labelText: 'Lingkar Alpukat (cm)',
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

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _tambahPencatatan,
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
          Text('Simpan Pencatatan'),
        ],
      ),
    );
  }
}
