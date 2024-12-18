import 'package:flutter/material.dart';
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
