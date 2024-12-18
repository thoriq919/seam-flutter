import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';
import 'package:seam_flutter/screens/remote_config/config.dart';
import 'dart:async';

class CreateSpendPage extends StatefulWidget {
  const CreateSpendPage({super.key});

  @override
  State<CreateSpendPage> createState() => _CreateSpendPageState();
}

class _CreateSpendPageState extends State<CreateSpendPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  DateTime? _selectedDate;
  final String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());
  late FirebaseRemoteConfigService _remoteConfigService;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _remoteConfigService = FirebaseRemoteConfigService();
    _initializeRemoteConfig();

    // Set interval refresh (contoh: setiap 30 detik)
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _fetchRemoteConfig();
    });
  }

  Future<void> _initializeRemoteConfig() async {
    await _remoteConfigService.initialize();
    setState(() {}); // Refresh UI setelah inisialisasi
  }

  Future<void> _fetchRemoteConfig() async {
    await _remoteConfigService.fetchAndActivate();
    setState(() {}); // Refresh UI setelah pembaruan konfigurasi
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
        _selectedDate = picked;
      });
    }
  }

  void _addSpend() {
    // Parsing warna dari Remote Config
    final String? snackbarColorHex = _remoteConfigService.fontColor;
    final Color snackbarColor = snackbarColorHex != null
        ? _hexToColor(snackbarColorHex)
        : Colors.green; // Warna default jika Remote Config gagal

    if (_nameController.text.isNotEmpty &&
        _costController.text.isNotEmpty &&
        _selectedDate != null) {
      FirebaseFirestore.instance.collection('spend').add({
        'name': _nameController.text,
        'cost': double.parse(_costController.text),
        'date': Timestamp.fromDate(_selectedDate!),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Spend data has been added'),
            backgroundColor: snackbarColor, // Warna dari Remote Config
          ),
        );
        Navigator.pop(context);
      });
    }
  }

  /// Fungsi untuk mengonversi hex color ke Color
  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  void dispose() {
    _timer.cancel(); // Hentikan timer saat widget dihancurkan
    super.dispose();
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
          'Create Spend',
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
                    _buildAddButton(),
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
            readOnly: true,
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
            onTap: () => _selectDate(context),
            controller: TextEditingController(
              text: _selectedDate == null
                  ? ''
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nama Pengeluaran',
              labelStyle: TextStyle(color: ColorTheme.blackFont),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.blackFont),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: ColorTheme.blackFont, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _costController,
            decoration: InputDecoration(
              labelText: 'Total Pengeluaran',
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

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: _addSpend,
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
          Icon(Icons.add),
          SizedBox(width: 10),
          Text('Add Spend'),
        ],
      ),
    );
  }
}
