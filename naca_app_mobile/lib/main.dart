import 'package:flutter/material.dart';
import 'package:naca_app_mobile/data/repo.dart';
import 'package:provider/provider.dart';
import 'core/app_colors.dart';
import 'views/screens/wrapper_screen.dart';
import 'abd/controller/weather_controller.dart';

void main() async {
  // Map<String, double> x = await AppRepo.initTest();
  // print("The probability is==================================> $x");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WeatherController(),
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
      ),
    );
  }
}
