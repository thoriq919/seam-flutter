import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class EditSpendPage extends StatefulWidget {
  final DocumentSnapshot documentSnapshot;

  const EditSpendPage({super.key, required this.documentSnapshot});

  @override
  State<EditSpendPage> createState() => _EditSpendPageState();
}

class _EditSpendPageState extends State<EditSpendPage> {
  late TextEditingController _nameController;
  late TextEditingController _costController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.documentSnapshot['name']);
    _costController =
        TextEditingController(text: widget.documentSnapshot['cost'].toString());
    _selectedDate = (widget.documentSnapshot['date'] as Timestamp).toDate();
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

  void _updateSpend() {
    if (_nameController.text.isNotEmpty &&
        _costController.text.isNotEmpty &&
        _selectedDate != null) {
      widget.documentSnapshot.reference.update({
        'name': _nameController.text,
        'cost': double.parse(_costController.text),
        'date': Timestamp.fromDate(_selectedDate!),
      }).then((_) {
        Navigator.pop(context);
      });
    }
  }

  void _deleteSpend() {
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
                widget.documentSnapshot.reference.delete();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
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
          'Edit Spend',
          style: TextStyle(
              color: ColorTheme.blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        centerTitle: true,
      ),
      backgroundColor: ColorTheme.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInputForm(),
            const SizedBox(height: 20),
            _buildActionButtons(),
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
              labelText: 'Total',
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
          onPressed: _updateSpend,
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
              Text('Update Spend'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _deleteSpend,
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
              Text('Delete Spend'),
            ],
          ),
        ),
      ],
    );
  }
}
