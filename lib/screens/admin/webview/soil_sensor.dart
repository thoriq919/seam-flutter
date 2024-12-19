import 'package:flutter/material.dart';
import 'package:seam_flutter/screens/utils/color_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SoilSensor extends StatefulWidget {
  const SoilSensor({super.key});

  @override
  State<SoilSensor> createState() => _SoilSensorState();
}

class _SoilSensorState extends State<SoilSensor> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Aktifkan JavaScript
      ..loadRequest(Uri.parse(
          'https://wokwi.com/projects/414407125557841921')); // URL untuk dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorTheme.white,
        title: Text(
          "Soil Sensor",
          style: TextStyle(
              color: ColorTheme.blackFont,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: ColorTheme.blackFont,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
