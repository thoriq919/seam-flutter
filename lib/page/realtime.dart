// pastikan import tetap sama
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class Realtime extends StatefulWidget {
  const Realtime({super.key});

  @override
  State<Realtime> createState() => _RealtimeState();
}

class _RealtimeState extends State<Realtime> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('Notes');
  List<Map<String, String>> _notes = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _databaseReference.onValue.listen((event) {
      final dataSnapshot = event.snapshot;
      final noteList = <Map<String, String>>[];

      if (dataSnapshot.exists) {
        dataSnapshot.children.forEach((childSnapshot) {
          final lembap =
              childSnapshot.child('tingkat_kelembapan').value as String?;
          final waktu = childSnapshot.child('waktu').value as int?;
          final id = childSnapshot.key;

          if (lembap != null && waktu != null && id != null) {
            final formattedTime = DateFormat('HH:mm')
                .format(DateTime.fromMillisecondsSinceEpoch(waktu));

            noteList.add({
              'id': id,
              'tingkat_kelembapan': lembap,
              'waktu': formattedTime,
            });
          }
        });
      }

      setState(() {
        _notes = noteList;
      });
    });
  }

  void _showDialog(String tingkatKelembapan, String waktu) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tingkat Kelembapan: $tingkatKelembapan'),
              Text('Waktu: $waktu'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return ListTile(
          title: Text(
              "Tingkat Kelembapan : ${note['tingkat_kelembapan']} VWC"),
          subtitle: Text("Waktu Identifikasi : ${note['waktu']} WIB "),
          onTap: () {
                    _showDialog(
                      note['tingkat_kelembapan'] ?? 'Data tidak tersedia',
                      note['waktu'] ?? 'Data tidak tersedia',
                    );
                  },
        );
      },
    );
  }
}
