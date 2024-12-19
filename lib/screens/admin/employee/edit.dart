import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seam_flutter/models/user.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class EditUserScreen extends StatefulWidget {
  final UserModel user;

  const EditUserScreen({super.key, required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _phone;
  late String _address;

  @override
  void initState() {
    super.initState();
    _name = widget.user.nama;
    _email = widget.user.email;
    _phone = widget.user.telp;
    _address = widget.user.alamat;
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: ColorTheme.primary),
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorTheme.primary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorTheme.primary.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorTheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.white,
      appBar: AppBar(
        title: Text(
          'Edit Employee',
          style: TextStyle(
            color: ColorTheme.blackFont,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        elevation: 0,
        backgroundColor: ColorTheme.white,
        centerTitle: true,
        iconTheme: IconThemeData(color: ColorTheme.blackFont),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        initialValue: _name,
                        decoration: _buildInputDecoration(
                          'Name',
                          Icons.person_outline,
                        ),
                        onSaved: (value) => _name = value!,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _email,
                        decoration: _buildInputDecoration(
                          'Email',
                          Icons.email_outlined,
                        ),
                        onSaved: (value) => _email = value!,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _phone,
                        decoration: _buildInputDecoration(
                          'Phone',
                          Icons.phone_outlined,
                        ),
                        onSaved: (value) => _phone = value!,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter phone' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _address,
                        decoration: _buildInputDecoration(
                          'Address',
                          Icons.home_outlined,
                        ),
                        onSaved: (value) => _address = value!,
                        validator: (value) =>
                            value!.isEmpty ? 'Enter address' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTheme.blackFont,
                          foregroundColor: ColorTheme.white,
                        ),
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user.uid)
            .update({
          'nama': _name,
          'email': _email,
          'telp': _phone,
          'alamat': _address,
        });
        Navigator.pop(context); // Close the edit screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating user: $e")),
        );
      }
    }
  }
}
