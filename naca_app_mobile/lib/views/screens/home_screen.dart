// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:naca_app_mobile/views/widgets/containr_widget.dart';
import '../../core/app_colors.dart';
import '../../abd/controller/weather_controller.dart';
import '../widgets/custom_form_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isHourly = true;
  Color backgroundColor = Colors.white24;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 HomeScreen initState called');
    // Load weather data for current location when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('🚀 PostFrameCallback executing...');
      final weatherController = Provider.of<WeatherController>(context, listen: false);
      debugPrint('🚀 WeatherController obtained, calling getAllWeatherDataForCurrentLocation...');
      weatherController.getAllWeatherDataForCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Column(
          children: [
            // Weather info section at top
            Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
              child: Consumer<WeatherController>(
                builder: (context, weatherController, child) {
                  final weather = weatherController.currentWeather;
                  
                  if (weatherController.isLoading) {
                    return const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Loading weather...',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    );
                  }
                  
                  if (weather == null) {
                    return const Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.white70, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Unable to load weather',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    );
                  }
                  
                  return Column(
                    children: [
                      Text(
                        weather.cityName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.temperatureString,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weather.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Feels like ${weather.feelsLikeString}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Expanded section with Stack
            Expanded(
              child: Stack(
                children: [
                  // Centered house image
                  const Center(
                    child: Image(image: AssetImage('assets/image/house.png')),
                  ),

                  // Bottom container above navigation bar
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 280,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 20),
                              CustomElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isHourly = true;
                                    backgroundColor = Colors.white24;
                                  });
                                },
                                text: 'Hourly',
                                width: 100,
                                height: 40,
                                gradientColors: isHourly ? [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ] : [
                                  AppColors.textSecondary.withValues(alpha: 0.3),
                                  AppColors.textSecondary.withValues(alpha: 0.2),
                                ],
                              ),
                              const Spacer(),
                              CustomElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isHourly = false;
                                    backgroundColor = Colors.black;
                                  });
                                },
                                text: 'Daily',
                                width: 100,
                                height: 40,
                                gradientColors: !isHourly ? [
                                  AppColors.primary,
                                  AppColors.primaryLight,
                                ] : [
                                  AppColors.textSecondary.withValues(alpha: 0.3),
                                  AppColors.textSecondary.withValues(alpha: 0.2),
                                ],
                              ),
                              SizedBox(width: 20),
                            ],
                          ),
                          SizedBox(height: 8),
                          Expanded(
                            child: Consumer<WeatherController>(
                              builder: (context, weatherController, child) {
                                if (isHourly) {
                                  final hourlyForecast = weatherController.hourlyForecast;
                                  
                                  if (weatherController.isLoadingHourly) {
                                    return const Center(
                                      child: CircularProgressIndicator(color: Colors.white),
                                    );
                                  }
                                  
                                  if (hourlyForecast == null || hourlyForecast.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No hourly data available',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  }
                                  
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: hourlyForecast.take(12).map((hourly) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: ContainerWidget(
                                            time: hourly.timeString,
                                            temperature: hourly.temperatureString,
                                            condition: hourly.condition,
                                            isHourly: true,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                } else {
                                  final weeklyForecast = weatherController.weeklyForecast;
                                  
                                  if (weatherController.isLoadingWeekly) {
                                    return const Center(
                                      child: CircularProgressIndicator(color: Colors.white),
                                    );
                                  }
                                  
                                  if (weeklyForecast == null || weeklyForecast.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No weekly data available',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    );
                                  }
                                  
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: weeklyForecast.map((daily) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 16),
                                          child: ContainerWidget(
                                            time: daily.dayName,
                                            temperature: daily.temperatureRangeString,
                                            condition: daily.condition,
                                            isHourly: false,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
