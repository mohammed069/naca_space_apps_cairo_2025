import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naca_app_mobile/views/screens/weather_result_screen.dart';

void main() {
  testWidgets('WeatherResultScreen widget initializes correctly', (WidgetTester tester) async {
    // Test the weather result screen
    await tester.pumpWidget(
      MaterialApp(
        home: WeatherResultScreen(
          latitude: 30.0,
          longitude: 31.0,
          date: DateTime.now(),
          parameters: const ['T2M', 'RH2M', 'WS2M'],
        ),
      ),
    );

    // Verify the screen loads
    expect(find.byType(WeatherResultScreen), findsOneWidget);
    expect(find.text('Weather Data'), findsOneWidget);
    
    // Verify loading indicator appears initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Don't wait for async operations to complete in the test
    // This verifies the widget initializes correctly
  });
}