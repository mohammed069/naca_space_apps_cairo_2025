import 'package:flutter/material.dart';
import 'package:naca_app_mobile/views/screens/fast_weather_result_screen.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/warnings': (context) => Container(), // Placeholder for warnings route
      },
      home: FastWeatherResultScreen(
        latitude: 30.0444,
        longitude: 31.2357,
        date: DateTime.now(),
        parameters: const ['T2M', 'RH2M', 'WS2M'],
      ),
    );
  }
}