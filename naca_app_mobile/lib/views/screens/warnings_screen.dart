import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../abd/controller/weather_controller.dart';
import '../../abd/rules/rules_engine.dart';
import '../../abd/rules/weather_data.dart';
import '../../abd/rules/user_profile.dart';
import '../../abd/rules/rules_categories.dart';

class WarningsScreen extends StatelessWidget {
  const WarningsScreen({super.key});

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
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Weather Warnings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Warnings content
              Expanded(
                child: Consumer<WeatherController>(
                  builder: (context, weatherController, child) {
                    final weather = weatherController.currentWeather;
                    
                    if (weatherController.isLoading || weather == null) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(height: 16),
                            Text(
                              'Loading weather warnings...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Convert weather data to rules engine format
                    final weatherData = WeatherData(
                      temperature: weather.temperature,
                      minTemperature: weatherController.weeklyForecast?.isNotEmpty == true
                          ? weatherController.weeklyForecast!.first.minTemperature
                          : weather.temperature - 5,
                      maxTemperature: weatherController.weeklyForecast?.isNotEmpty == true
                          ? weatherController.weeklyForecast!.first.maxTemperature
                          : weather.temperature + 5,
                      humidity: weather.humidity.toDouble(),
                      windSpeed: weather.windSpeed,
                      solarRadiation: 400, // Default value, can be enhanced later
                      precipitation: 0, // Default value, can be enhanced later
                      pressure: weather.pressure.toDouble(),
                      visibility: 10000, // Default value, can be enhanced later
                    );

                    // Create user profile (can be enhanced with user settings later)
                    final userProfile = UserProfile();

                    // Generate warnings
                    final rulesEngine = RulesEngine();
                    final categorizedWarnings = rulesEngine.getWarningsByCategory(
                      weatherData,
                      userProfile,
                    );

                    return Container(
                      margin: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Weather summary card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    weather.cityName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${weather.temperatureString} • ${weather.description}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Warning categories
                            ...RulesCategory.values.map((category) {
                              final warnings = categorizedWarnings[category] ?? [];
                              
                              if (warnings.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return _buildWarningCategory(
                                category: category,
                                warnings: warnings,
                              );
                            }).toList(),

                            // No warnings message
                            if (categorizedWarnings.values.every((warnings) => warnings.isEmpty))
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: const Column(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 48,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'All Clear!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No weather warnings for current conditions.\nEnjoy your day!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningCategory({
    required RulesCategory category,
    required List<WeatherWarning> warnings,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(category).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(category).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${warnings.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Warnings list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: warnings.asMap().entries.map((entry) {
                final index = entry.key;
                final warning = entry.value;
                
                return Column(
                  children: [
                    _buildWarningItem(warning),
                    if (index < warnings.length - 1)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        height: 1,
                        color: Colors.white.withOpacity(0.1),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(WeatherWarning warning) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _getPriorityColor(warning.priority).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPriorityIcon(warning.priority),
            color: _getPriorityColor(warning.priority),
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                warning.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (warning.priority <= 2) // Priority 1-2 (critical/high)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _getPriorityLabel(warning.priority),
                    style: TextStyle(
                      color: _getPriorityColor(warning.priority),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(RulesCategory category) {
    switch (category) {
      case RulesCategory.health:
        return Colors.red;
      case RulesCategory.energy:
        return Colors.orange;
      case RulesCategory.driving:
        return Colors.blue;
      case RulesCategory.events:
        return Colors.green;
      case RulesCategory.tips:
        return Colors.purple;
    }
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: // critical
        return Colors.red;
      case 2: // high
        return Colors.orange;
      case 3: // medium
        return Colors.yellow;
      case 4: // low
      case 5: // very low
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case 1: // critical
        return Icons.dangerous;
      case 2: // high
        return Icons.warning;
      case 3: // medium
        return Icons.info;
      case 4: // low
      case 5: // very low
        return Icons.lightbulb_outline;
      default:
        return Icons.help_outline;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return 'CRITICAL';
      case 2:
        return 'HIGH PRIORITY';
      case 3:
        return 'Medium Priority';
      case 4:
        return 'Low Priority';
      case 5:
        return 'Very Low Priority';
      default:
        return 'Unknown Priority';
    }
  }
}