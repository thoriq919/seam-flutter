import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore extends StatelessWidget {
  const Firestore({super.key});

  Future<void> tambahData(DateTime tanggal, String tinggi, String diameter) {
    CollectionReference pertumbuhan =
        FirebaseFirestore.instance.collection('log_pertumbuhan');

    return pertumbuhan.add({
      'tanggal': Timestamp.fromDate(tanggal),
      'tinggi': tinggi,
      'diameter': diameter,
    });
  }

  Future<void> updateData(
      String id, DateTime newtanggal, String newtinggi, String newdiameter) {
    CollectionReference pertumbuhan =
        FirebaseFirestore.instance.collection('log_pertumbuhan');

    return pertumbuhan
        .doc(id)
        .update({
          'tanggal': Timestamp.fromDate(newtanggal),
          'tinggi': newtinggi,
          'diameter': newdiameter,
        })
        .then((value) => print("Data Tanaman berhasil ditambahkan"))
        .catchError(
            (error) => print("Data Tumbuhan gagal ditambahkan: $error"));
  }

  Future<void> hapusData(String id) {
    CollectionReference pertumbuhan =
        FirebaseFirestore.instance.collection("log_pertumbuhan");

    return pertumbuhan.doc(id).delete();
  }

  Future<void> tambahakun(String username, String password) {
    CollectionReference akun = FirebaseFirestore.instance.collection('user');

    return akun.add({
      'username': username,
      'password': password,
    });
  }

  Future<void> hapusAkun(String id) {
    CollectionReference akun = FirebaseFirestore.instance.collection("user");

    return akun.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
