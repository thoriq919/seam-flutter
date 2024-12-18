import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seam_flutter/screens/pegawai/spend/create.dart';
import 'package:seam_flutter/screens/pegawai/spend/edit.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class SpendIndexPage extends StatefulWidget {
  final String currentUser;
  const SpendIndexPage({super.key, required this.currentUser});

  @override
  State<SpendIndexPage> createState() => _SpendIndexPageState();
}

class _SpendIndexPageState extends State<SpendIndexPage> {
  List<DocumentSnapshot> _listSpend = [];
  String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _readSpend();
  }

  void _readSpend() {
    CollectionReference spend = FirebaseFirestore.instance.collection('spend');

    spend.get().then((QuerySnapshot snapshot) {
      setState(() {
        _listSpend = snapshot.docs;
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
                                  Icons.wallet_rounded,
                                  color: ColorTheme.blackFont,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Spend History',
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
                    _buildSpendList(),
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

  Widget _buildSpendList() {
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
        itemCount: _listSpend.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          var spend = _listSpend[index];
          DateTime date = (spend['date'] as Timestamp).toDate();
          String formattedDate = DateFormat('yyyy-MM-dd').format(date);

          return ListTile(
            title: Text(
              spend['name'],
              style: TextStyle(
                color: ColorTheme.blackFont,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Rp. ${spend['cost']}, \nTanggal: $formattedDate',
              style: TextStyle(color: ColorTheme.blackFont),
            ),
            trailing: Icon(Icons.edit, color: ColorTheme.blackFont),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditSpendPage(
                    documentSnapshot: spend,
                  ),
                ),
              ).then((_) => _readSpend());
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
            builder: (context) => const CreateSpendPage(),
          ),
        ).then((_) => _readSpend());
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
          Text('Add New Spend'),
        ],
      ),
    );
  }
}
