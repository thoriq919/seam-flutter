import 'dart:async';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/material.dart';
import 'package:seam_flutter/screens/admin/dashboard.dart';

class HomeScreen extends StatefulWidget {
  final String currentUser;
  const HomeScreen({super.key, this.currentUser = 'User'});

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
    final userToDisplay =
        widget.currentUser.isNotEmpty ? widget.currentUser : 'User';
    return DashboardHomePage(currentUser: userToDisplay);
  }
}
