import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class AdminPencatatanIndexPage extends StatelessWidget {
  const AdminPencatatanIndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.white,
      appBar: AppBar(
        title: Text(
          'Growth Records',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorTheme.blackFont,
          ),
        ),
        backgroundColor: ColorTheme.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTheme.blackFont),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<QuerySnapshot>(
          future:
              FirebaseFirestore.instance.collection('log_pertumbuhan').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No records found.'));
            }

            List<DocumentSnapshot> _listPencatatan = snapshot.data!.docs;

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
              child: ListView.builder(
                itemCount: _listPencatatan.length,
                itemBuilder: (context, index) {
                  var catatan = _listPencatatan[index];
                  DateTime tanggal = (catatan['tanggal'] as Timestamp).toDate();
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(tanggal);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          formattedDate,
                          style: TextStyle(
                            color: ColorTheme.blackFont,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Height: \n${catatan['tinggi']} cm',
                              style: TextStyle(color: ColorTheme.blackFont),
                            ),
                            Text('Diameter: \n${catatan['diameter']} cm',
                                style: TextStyle(color: ColorTheme.blackFont))
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}