import 'package:flutter/material.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class KelembapanScreen extends StatefulWidget {
  const KelembapanScreen({super.key});

  @override
  State<KelembapanScreen> createState() => _KelembapanScreenState();
}

class _KelembapanScreenState extends State<KelembapanScreen> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('Notes');
  List<Map<String, String>> humidityHistory = [];
  Map<String, IconData> arrowDirections = {};
  Map<String, Color> arrowColors = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    _databaseReference.onValue.listen((event) {
      final dataSnapshot = event.snapshot;
      final historyList = <Map<String, String>>[];

      if (dataSnapshot.exists) {
        for (var childSnapshot in dataSnapshot.children) {
          final lembap =
              (childSnapshot.child('tingkat_kelembapan').value ?? 0).toString();
          final waktu = childSnapshot.child('waktu').value as int?;
          final id = childSnapshot.key;

          if (waktu != null && id != null) {
            final entryDate =
                DateTime.fromMillisecondsSinceEpoch(waktu * 1000, isUtc: true);
            final formattedTime = DateFormat('HH:mm').format(entryDate);
            final formattedDate = DateFormat('yyyy-MM-dd').format(entryDate);

            historyList.add({
              'id': id,
              'tingkat_kelembapan': lembap,
              'waktu': formattedTime,
              'tanggal': formattedDate,
              'epoch': waktu.toString(),
            });
          }
        }

        historyList.sort(
            (a, b) => int.parse(b['epoch']!).compareTo(int.parse(a['epoch']!)));

        final newArrowDirections = <String, IconData>{};
        final newArrowColors = <String, Color>{};

        for (int i = 0; i < historyList.length - 1; i++) {
          final currentValue =
              double.parse(historyList[i]['tingkat_kelembapan'] ?? '0');
          final previousValue =
              double.parse(historyList[i + 1]['tingkat_kelembapan'] ?? '0');

          final id = historyList[i]['id']!;
          if (currentValue > previousValue) {
            newArrowDirections[id] = Icons.arrow_upward;
            newArrowColors[id] = ColorTheme.green;
          } else if (currentValue < previousValue) {
            newArrowDirections[id] = Icons.arrow_downward;
            newArrowColors[id] = ColorTheme.danger;
          } else {
            newArrowDirections[id] = Icons.remove;
            newArrowColors[id] = ColorTheme.grey;
          }
        }

        if (mounted) {
          setState(() {
            humidityHistory = historyList;
            arrowDirections = newArrowDirections;
            arrowColors = newArrowColors;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.white,
      appBar: AppBar(
        backgroundColor: ColorTheme.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Soil Moisture History',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorTheme.blackFont),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: humidityHistory.length,
                      itemBuilder: (context, index) {
                        final humidity = humidityHistory[index];
                        final humidityValue =
                            double.parse(humidity['tingkat_kelembapan'] ?? '0');
                        Color textColor;
                        if (humidityValue > 80) {
                          textColor = ColorTheme.green;
                        } else if (humidityValue >= 50) {
                          textColor = ColorTheme.warning;
                        } else {
                          textColor = ColorTheme.danger;
                        }
                        return ListTile(
                          leading: Icon(
                            Icons.water_drop,
                            color: ColorTheme.primary,
                          ),
                          title: Text(
                            '${humidity['tingkat_kelembapan']} VWC',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            '${humidity['waktu']} WIB',
                          ),
                          trailing: Icon(
                            arrowDirections[humidity['id']] ?? Icons.remove,
                            color: arrowColors[humidity['id']] ?? Colors.grey,
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Detail Catatan'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          'Tingkat Kelembapan: ${humidity['tingkat_kelembapan']} VWC'),
                                      Text('Waktu: ${humidity['waktu']} WIB'),
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
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTheme.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: ColorTheme.blackFont,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
