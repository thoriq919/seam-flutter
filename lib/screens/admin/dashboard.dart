import 'package:flutter/material.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardHomePage();
  }
}

class DashboardHomePage extends StatefulWidget {
  const DashboardHomePage({super.key});

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('Notes');
  String currentHumidity = '0';
  String currentTime = '';
  List<Map<String, String>> humidityHistory = [];

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
        dataSnapshot.children.forEach((childSnapshot) {
          final lembap =
              (childSnapshot.child('tingkat_kelembapan').value ?? 0).toString();
          final waktu = childSnapshot.child('waktu').value as int?;
          final id = childSnapshot.key;

          if (waktu != null && id != null) {
            final formattedTime = DateFormat('HH:mm')
                .format(DateTime.fromMillisecondsSinceEpoch(waktu));

            historyList.add({
              'id': id,
              'tingkat_kelembapan': lembap,
              'waktu': formattedTime,
              'epoch': waktu.toString(),
            });
          }
        });

        // Sort by epoch time in descending order
        historyList.sort(
            (a, b) => int.parse(b['epoch']!).compareTo(int.parse(a['epoch']!)));
      }

      setState(() {
        humidityHistory = historyList;
        if (historyList.isNotEmpty) {
          currentHumidity = historyList.first['tingkat_kelembapan'] ?? '0';
          currentTime = historyList.first['waktu'] ?? '';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Kelembapan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 200,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 200,
                                    width: 200,
                                    child: CircularProgressIndicator(
                                      value:
                                          double.parse(currentHumidity) / 100,
                                      strokeWidth: 15,
                                      color: ColorTheme.primary,
                                      backgroundColor:
                                          Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$currentHumidity%',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: ColorTheme.primary,
                                        ),
                                      ),
                                      Text(
                                        currentTime,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'Log Kelembapan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: humidityHistory.length,
                              itemBuilder: (context, index) {
                                final humidity = humidityHistory[index];
                                return ListTile(
                                  leading: Icon(
                                    Icons.water_drop,
                                    color: ColorTheme.primary,
                                  ),
                                  title: Text(
                                    '${humidity['tingkat_kelembapan']} VWC',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${humidity['waktu']} WIB',
                                  ),
                                  trailing: Icon(
                                    double.parse(humidity[
                                                    'tingkat_kelembapan'] ??
                                                '0') >=
                                            50
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: double.parse(humidity[
                                                    'tingkat_kelembapan'] ??
                                                '0') >=
                                            50
                                        ? Colors.green
                                        : Colors.red,
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
                                              Text(
                                                  'Waktu: ${humidity['waktu']} WIB'),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: ColorTheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
