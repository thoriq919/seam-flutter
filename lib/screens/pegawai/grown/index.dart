import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seam_flutter/screens/pegawai/grown/create.dart';
import 'package:seam_flutter/screens/pegawai/grown/edit.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class PencatatanIndexPage extends StatefulWidget {
  final String currentUser;
  const PencatatanIndexPage({super.key, required this.currentUser});

  @override
  State<PencatatanIndexPage> createState() => _PencatatanIndexPageState();
}

class _PencatatanIndexPageState extends State<PencatatanIndexPage> {
  List<DocumentSnapshot> _listPencatatan = [];
  String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _readPencatatan();
  }

  void _readPencatatan() {
    CollectionReference pencatatan =
        FirebaseFirestore.instance.collection('log_pertumbuhan');

    pencatatan.get().then((QuerySnapshot snapshot) {
      setState(() {
        _listPencatatan = snapshot.docs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_alt_outlined,
                                  color: ColorTheme.blackFont,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Growth Records',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ColorTheme.blackFont,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPencatatanList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPencatatanList() {
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _listPencatatan.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          var catatan = _listPencatatan[index];
          DateTime tanggal = (catatan['tanggal'] as Timestamp).toDate();
          String formattedDate = DateFormat('yyyy-MM-dd').format(tanggal);

          return ListTile(
            title: Text(
              formattedDate,
              style: TextStyle(
                color: ColorTheme.blackFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Height: ${catatan['tinggi']} cm, Diameter: ${catatan['diameter']} cm',
              style: TextStyle(color: ColorTheme.blackFont),
            ),
            trailing: Icon(Icons.edit, color: ColorTheme.blackFont),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPencatatanPage(
                    documentSnapshot: catatan,
                  ),
                ),
              ).then((_) => _readPencatatan());
            },
          );
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreatePencatatanPage(),
          ),
        ).then((_) => _readPencatatan());
      },
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
          Text('Tambah Catatan Baru'),
        ],
      ),
    );
  }
}
