import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seam_flutter/blocs/auth/auth_bloc.dart';
import 'package:seam_flutter/blocs/auth/auth_event.dart';
import 'package:seam_flutter/blocs/auth/auth_state.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _telpController = TextEditingController();
  String? _foto;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() => _isLoading = true);

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_photos')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        await storageRef.putFile(File(image.path));
        final downloadUrl = await storageRef.getDownloadURL();

        setState(() {
          _foto = downloadUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _namaController.dispose();
    _alamatController.dispose();
    _telpController.dispose();
    super.dispose();
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorTheme.white,
        appBar: AppBar(
          title: Text(
            'Register Employee',
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
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: ColorTheme.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorTheme.primary,
                                    width: 3,
                                  ),
                                ),
                                child: _foto != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _foto!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 80,
                                        color: ColorTheme.white,
                                      ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: ColorTheme.primary,
                                  radius: 20,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.camera_alt,
                                      color: ColorTheme.white,
                                    ),
                                    onPressed:
                                        _isLoading ? null : _pickAndUploadImage,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
                              children: [
                                TextFormField(
                                  controller: _namaController,
                                  decoration: _buildInputDecoration(
                                    'Nama',
                                    Icons.person_outline,
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter your name'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  decoration: _buildInputDecoration(
                                    'Email',
                                    Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your email';
                                    }
                                    if (!EmailValidator.validate(value!)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: _buildInputDecoration(
                                    'Password',
                                    Icons.lock_outlined,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: ColorTheme.primary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter a password';
                                    }
                                    if (value!.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  decoration: _buildInputDecoration(
                                    'Confirm Password',
                                    Icons.lock_outline,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: ColorTheme.primary,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value != _passwordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _alamatController,
                                  decoration: _buildInputDecoration(
                                    'Alamat',
                                    Icons.home_outlined,
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter your address'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _telpController,
                                  keyboardType: TextInputType.phone,
                                  decoration: _buildInputDecoration(
                                    'Telepon',
                                    Icons.phone_outlined,
                                  ),
                                  validator: (value) => value?.isEmpty ?? true
                                      ? 'Please enter your phone number'
                                      : null,
                                ),
                                const SizedBox(height: 24),
                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, state) {
                                    return state is AuthLoading
                                        ? const CircularProgressIndicator()
                                        : ElevatedButton(
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                context.read<AuthBloc>().add(
                                                      SignUpRequested(
                                                        email: _emailController
                                                            .text
                                                            .trim(),
                                                        password:
                                                            _passwordController
                                                                .text,
                                                        nama: _namaController
                                                            .text
                                                            .trim(),
                                                        alamat:
                                                            _alamatController
                                                                .text
                                                                .trim(),
                                                        telp: _telpController
                                                            .text
                                                            .trim(),
                                                        foto: _foto,
                                                      ),
                                                    );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  ColorTheme.blackFont,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Register',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
