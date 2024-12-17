import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:seam_flutter/blocs/auth/auth_bloc.dart';
import 'package:seam_flutter/blocs/auth/auth_state.dart';
import 'package:seam_flutter/screens/admin/components/custom_drawer.dart';
import 'package:seam_flutter/screens/auth/login_screen.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class DashboardHomePage extends StatefulWidget {
  final String currentUser;
  const DashboardHomePage({super.key, required this.currentUser});

  @override
  State<DashboardHomePage> createState() => _DashboardHomePageState();
}

class _DashboardHomePageState extends State<DashboardHomePage> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref('Notes');
  String currentHumidity = '0';
  String currentTime = '';
  List<Map<String, String>> humidityHistory = [];
  Map<String, IconData> arrowDirections = {};
  Map<String, Color> arrowColors = {};
  double averageHumidity = 0;
  String currentDate = DateFormat('MMMM d, yyyy').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void _fetchData() {
    _databaseReference.onValue.listen((event) {
      final dataSnapshot = event.snapshot;
      final historyList = <Map<String, String>>[];
      double totalHumidity = 0;

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
            totalHumidity += double.parse(lembap);
          }
        }

        historyList.sort(
            (a, b) => int.parse(b['epoch']!).compareTo(int.parse(a['epoch']!)));

        if (historyList.isNotEmpty) {
          averageHumidity = totalHumidity / historyList.length;
        }

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
            if (historyList.isNotEmpty) {
              currentHumidity = historyList.first['tingkat_kelembapan'] ?? '0';
              currentTime = historyList.first['waktu'] ?? '';
            }
          });
        }
      }
    });
  }

  String extractFirstTwoWords(String fullName) {
    List<String> words = fullName.split(' ');
    if (words.length < 2) {
      return fullName;
    }
    return '${words[0]} ${words[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorTheme.white,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () => _openDrawer(context),
              icon: Icon(Icons.menu_rounded, color: ColorTheme.blackFont),
            ),
          ),
        ),
        drawer: CustomDrawer(
          currentUsername: extractFirstTwoWords(widget.currentUser),
        ),
        backgroundColor: ColorTheme.white,
        body: SafeArea(
          child: Column(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            bottom: 20, left: 20, right: 20),
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
                                    Icons.bar_chart_rounded,
                                    color: ColorTheme.blackFont,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Statistics',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: ColorTheme.blackFont),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),
                                Text(
                                  currentDate,
                                  style: TextStyle(
                                    color: ColorTheme.blackFont,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                DecoratedIcon(
                                  icon: Icon(
                                    Icons.water_drop_rounded,
                                    color: ColorTheme.secondary,
                                    size: 20,
                                  ),
                                  decoration: const IconDecoration(
                                    border: IconBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Ave ${averageHumidity.toStringAsFixed(2)} %',
                                  style: TextStyle(color: ColorTheme.blackFont),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 250,
                              child: CircularPercentIndicator(
                                  radius: 120,
                                  center: Text(
                                    '$currentHumidity%',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: ColorTheme.blackFont,
                                    ),
                                  ),
                                  restartAnimation: true,
                                  backgroundWidth: 40,
                                  animation: true,
                                  lineWidth: 50,
                                  circularStrokeCap: CircularStrokeCap.round,
                                  progressColor: ColorTheme.primary,
                                  percent: double.parse(currentHumidity) / 100,
                                  backgroundColor: ColorTheme.secondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: humidityHistory.take(4).map((humidity) {
                          return Card(
                            color: ColorTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${humidity['tingkat_kelembapan']}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: ColorTheme.blackFont,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${humidity['waktu']}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: ColorTheme.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
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
