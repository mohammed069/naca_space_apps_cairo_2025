import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_colors.dart';
import 'views/screens/wrapper_screen.dart';
import 'views/screens/thresholds_screen.dart';
import 'abd/controller/weather_controller.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WeatherController()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()..loadSettings()),
      ],
      child: MaterialApp(
        title: 'NACA Weather App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
        ),
        home: const WrapperScreen(),
        routes: {
          '/settings': (context) => const ThresholdsScreen(),
        },
      ),
    );
  }
}
