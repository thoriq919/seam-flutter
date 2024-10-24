import 'package:seam_flutter/models/user.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class SignInRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInRequested(this.email, this.password);
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String nama;
  final String alamat;
  final String telp;
  final String? foto;

  SignUpRequested({
    required this.email,
    required this.password,
    required this.nama,
    required this.alamat,
    required this.telp,
    this.foto,
  });
}

class SignOutRequested extends AuthEvent {}

class AuthStateChanged extends AuthEvent {
  final UserModel? user;
  const AuthStateChanged(this.user);
}
