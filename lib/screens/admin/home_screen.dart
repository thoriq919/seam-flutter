// home_screen.dart
import 'dart:async';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/page/catat.dart';
import 'package:seam_flutter/page/realtime.dart';
import 'package:seam_flutter/screens/admin/dashboard.dart';
import 'package:seam_flutter/screens/admin/pegawai/pegawai_screen.dart';
import 'package:seam_flutter/screens/admin/settings/setting_screen.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _canTriggerEvent = true; // Tambahkan flag untuk mengontrol trigger
  final FirebaseInAppMessaging _inAppMessaging =
      FirebaseInAppMessaging.instance;

  // Tambahkan timer untuk reset flag
  Timer? _triggerResetTimer;
  @override
  void initState() {
    super.initState();
    // Trigger event saat halaman dibuka
    _handleTriggerEvent();
  }

  void _handleTriggerEvent() {
    if (_canTriggerEvent) {
      _inAppMessaging.triggerEvent("login_success");
      _canTriggerEvent = false; // Nonaktifkan trigger

      // Reset flag setelah beberapa waktu (misal 5 detik)
      _triggerResetTimer?.cancel();
      _triggerResetTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _canTriggerEvent = true;
          });
        }
      });
    }
  }

  final List<Widget> _pages = [
    const DashboardPage(),
    const PegawaiScreen(),
    const Catat(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: ColorTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.white,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: ColorTheme.primary,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Pegawai',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add),
                    label: 'Catat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
