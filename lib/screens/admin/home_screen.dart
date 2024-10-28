import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: const Center(
        child: Text('Welcome to Home Screen'),
      ),
    );
  }
}
