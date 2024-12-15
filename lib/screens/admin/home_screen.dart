import 'dart:async';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/page/catat.dart';
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
  bool _canTriggerEvent = true;
  final FirebaseInAppMessaging _inAppMessaging =
      FirebaseInAppMessaging.instance;

  Timer? _triggerResetTimer;
  @override
  void initState() {
    super.initState();
    _handleTriggerEvent();
  }

  void _handleTriggerEvent() {
    if (_canTriggerEvent) {
      _inAppMessaging.triggerEvent("login_success");
      _canTriggerEvent = false;
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
    return const DashboardHomePage();
  }
}
