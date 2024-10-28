class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String alamat;
  final String telp;
  final String? foto;
  final String role;

  UserModel(
      {required this.uid,
      required this.email,
      required this.nama,
      required this.alamat,
      required this.telp,
      this.foto,
      required this.role});

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nama': nama,
      'alamat': alamat,
      'telp': telp,
      'foto': foto,
      'role': role,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      telp: map['telp'] ?? '',
      foto: map['foto'] ?? '',
      role: map['role'] ?? '',
    );
  }
}
