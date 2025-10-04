import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../abd/controller/weather_controller.dart';

class WarningsScreen extends StatelessWidget {
  final Map<String, double>? weatherData;
  final Map<String, double>? dailyData;
  final Map<String, dynamic>? location;
  final double? latitude;
  final double? longitude;
  final DateTime? date;

  const WarningsScreen({
    super.key,
    this.weatherData,
    this.dailyData,
    this.location,
    this.latitude,
    this.longitude,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    // Get arguments from navigation if not passed directly
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    // Prioritize dailyData over weatherData, and handle both coordinate and location inputs
    final data = dailyData ?? 
                 weatherData ?? 
                 args?['weatherData'] as Map<String, double>? ??
                 args?['dailyData'] as Map<String, double>?;
    
    final loc = location ?? args?['location'] as Map<String, dynamic>?;
    final selectedDate = date ?? args?['date'] as DateTime?;
    
    // Handle coordinates - either from direct parameters or from location object
    final lat = latitude ?? 
                args?['latitude'] as double? ?? 
                loc?['latitude'] as double?;
    final lng = longitude ?? 
                args?['longitude'] as double? ?? 
                loc?['longitude'] as double?;
    
    // Create unified location object for coordinates
    final unifiedLocation = loc ?? (lat != null && lng != null ? {
      'latitude': lat,
      'longitude': lng,
    } : null);

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
              // Header
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
                        'Weather Analysis & Warnings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: data == null 
                  ? Consumer<WeatherController>(
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
                                  'Analyzing weather data...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return _buildContent(weatherController);
                      },
                    )
                  : _buildAnalysisContent(data, unifiedLocation, selectedDate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(WeatherController weatherController) {
    final weather = weatherController.currentWeather!;
    
    // Sample categories for now
    final categories = [
      {'name': 'Health', 'icon': '🏥', 'warnings': ['High UV exposure expected', 'Air quality may be poor']},
      {'name': 'Energy', 'icon': '⚡', 'warnings': ['High AC usage recommended', 'Solar efficiency optimal']},
      {'name': 'Driving', 'icon': '🚗', 'warnings': ['Visibility good', 'Road conditions normal']},
      {'name': 'Events', 'icon': '🎉', 'warnings': ['Good weather for outdoor activities']},
      {'name': 'Tips', 'icon': '💡', 'warnings': ['Stay hydrated', 'Wear sunscreen']},
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Weather summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
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
            for (final category in categories) Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.2),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            category['icon'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              category['name'] as String,
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
                              color: Colors.blue.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(category['warnings'] as List).length}',
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
                        children: (category['warnings'] as List<String>).map((warning) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.info,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    warning,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
  }

  // التحليل الذكي للبيانات
  Widget _buildAnalysisContent(Map<String, double> data, Map<String, dynamic>? location, DateTime? date) {
    final analysis = _analyzeWeatherData(data);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General Weather Analysis
          _buildAnalysisCard(
            title: 'General Weather Analysis',
            content: analysis['general'] ?? 'Insufficient data for analysis',
            icon: Icons.analytics_outlined,
            color: const Color(0xFF4CAF50),
          ),
          
          const SizedBox(height: 16),
          
          // Critical Warnings
          if (analysis['warnings'].isNotEmpty) ...[
            _buildAnalysisCard(
              title: 'Weather Warnings ⚠️',
              content: analysis['warnings'].join('\n\n'),
              icon: Icons.warning_amber_outlined,
              color: const Color(0xFFFF5722),
            ),
            const SizedBox(height: 16),
          ],
          
          // Health Warnings
          if (analysis['healthWarnings'].isNotEmpty) ...[
            _buildAnalysisCard(
              title: 'Health & Safety Alerts 🏥',
              content: analysis['healthWarnings'].join('\n\n'),
              icon: Icons.medical_services_outlined,
              color: const Color(0xFFE91E63),
            ),
            const SizedBox(height: 16),
          ],
          
          // Solar Energy Analysis
          if (analysis['energyAnalysis'].isNotEmpty) ...[
            _buildAnalysisCard(
              title: 'Solar Energy Analysis ⚡',
              content: analysis['energyAnalysis'].join('\n') + '\n\n' + 
                      (analysis['energyRecommendations'] ?? ''),
              icon: Icons.wb_sunny_outlined,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 16),
          ],
          
          // Activity Recommendations
          if (analysis['activities'].isNotEmpty) ...[
            _buildAnalysisCard(
              title: 'Activity Recommendations 🎯',
              content: analysis['activities'].join('\n\n'),
              icon: Icons.directions_run_outlined,
              color: const Color(0xFF9C27B0),
            ),
            const SizedBox(height: 16),
          ],
          
          // General Recommendations
          _buildAnalysisCard(
            title: 'Tips & Recommendations 💡',
            content: analysis['recommendations'] ?? 'No specific recommendations',
            icon: Icons.lightbulb_outline,
            color: const Color(0xFF2196F3),
          ),
          
          const SizedBox(height: 16),
          
          // Data Summary
          _buildDataSummary(data),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSummary(Map<String, double> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Detailed Weather Data 📊',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.entries.map((entry) {
            final parameterDetails = _getParameterDetails(entry.key, entry.value);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(parameterDetails['icon'], color: parameterDetails['color'], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          parameterDetails['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '${entry.value.toStringAsFixed(1)}${parameterDetails['unit']}',
                        style: TextStyle(
                          color: parameterDetails['color'],
                          fontSize: 16, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    parameterDetails['description'],
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${parameterDetails['status']} ${parameterDetails['range']}',
                    style: TextStyle(
                      color: parameterDetails['statusColor'],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Map<String, dynamic> _getParameterDetails(String parameter, double value) {
    switch (parameter) {
      case 'T2M':
        String status, range, description;
        Color statusColor;
        if (value > 40) {
          status = '🔴 EXTREME HEAT';
          range = '(Normal: 20-30°C)';
          description = 'Extremely dangerous heat levels. Risk of heat stroke and dehydration.';
          statusColor = Colors.red;
        } else if (value > 35) {
          status = '🟠 VERY HOT';
          range = '(Normal: 20-30°C)';
          description = 'Very high temperature. Increased risk of heat-related illnesses.';
          statusColor = Colors.orange;
        } else if (value > 30) {
          status = '🟡 HOT';
          range = '(Normal: 20-30°C)';
          description = 'Warm weather conditions. Stay hydrated and seek shade.';
          statusColor = Colors.amber;
        } else if (value >= 20) {
          status = '🟢 IDEAL';
          range = '(Perfect range)';
          description = 'Perfect temperature for most outdoor activities and comfort.';
          statusColor = Colors.green;
        } else if (value >= 10) {
          status = '🔵 COOL';
          range = '(Normal: 20-30°C)';
          description = 'Cool weather. Light jacket recommended for comfort.';
          statusColor = Colors.blue;
        } else if (value >= 0) {
          status = '🟦 COLD';
          range = '(Normal: 20-30°C)';
          description = 'Cold conditions. Warm clothing essential for outdoor activities.';
          statusColor = Colors.blueAccent;
        } else {
          status = '🟣 FREEZING';
          range = '(Normal: 20-30°C)';
          description = 'Freezing temperatures. Risk of frostbite and hypothermia.';
          statusColor = Colors.purple;
        }
        return {
          'name': 'Air Temperature',
          'unit': '°C',
          'icon': Icons.thermostat,
          'color': Colors.orange,
          'description': description,
          'status': status,
          'range': range,
          'statusColor': statusColor,
        };
        
      case 'RH2M':
        String status, range, description;
        Color statusColor;
        if (value > 85) {
          status = '🔴 EXTREMELY HUMID';
          range = '(Ideal: 40-60%)';
          description = 'Oppressive humidity levels. Difficulty in cooling through perspiration.';
          statusColor = Colors.red;
        } else if (value > 70) {
          status = '🟠 VERY HUMID';
          range = '(Ideal: 40-60%)';
          description = 'High humidity makes it feel hotter and more uncomfortable.';
          statusColor = Colors.orange;
        } else if (value >= 40) {
          status = '🟢 COMFORTABLE';
          range = '(Perfect range)';
          description = 'Optimal humidity levels for comfort and health.';
          statusColor = Colors.green;
        } else if (value >= 25) {
          status = '🟡 DRY';
          range = '(Ideal: 40-60%)';
          description = 'Slightly dry conditions. May cause minor discomfort.';
          statusColor = Colors.amber;
        } else {
          status = '🔴 EXTREMELY DRY';
          range = '(Ideal: 40-60%)';
          description = 'Very dry air. Risk of respiratory irritation and dehydration.';
          statusColor = Colors.red;
        }
        return {
          'name': 'Relative Humidity',
          'unit': '%',
          'icon': Icons.water_drop,
          'color': Colors.blue,
          'description': description,
          'status': status,
          'range': range,
          'statusColor': statusColor,
        };
        
      case 'WS2M':
        String status, range, description;
        Color statusColor;
        if (value > 20) {
          status = '🔴 SEVERE WINDS';
          range = '(Normal: 0-10 m/s)';
          description = 'Dangerous wind speeds. Risk of flying debris and structural damage.';
          statusColor = Colors.red;
        } else if (value > 15) {
          status = '🟠 STRONG WINDS';
          range = '(Normal: 0-10 m/s)';
          description = 'Strong winds that may affect outdoor activities and transportation.';
          statusColor = Colors.orange;
        } else if (value > 10) {
          status = '🟡 MODERATE WINDS';
          range = '(Normal: 0-10 m/s)';
          description = 'Moderate winds providing natural cooling and ventilation.';
          statusColor = Colors.amber;
        } else if (value > 5) {
          status = '🟢 LIGHT BREEZE';
          range = '(Perfect range)';
          description = 'Pleasant light breeze enhances comfort and air circulation.';
          statusColor = Colors.green;
        } else {
          status = '🔵 CALM';
          range = '(Very light winds)';
          description = 'Very calm conditions with minimal air movement.';
          statusColor = Colors.blue;
        }
        return {
          'name': 'Wind Speed',
          'unit': ' m/s',
          'icon': Icons.air,
          'color': Colors.teal,
          'description': description,
          'status': status,
          'range': range,
          'statusColor': statusColor,
        };
        
      case 'PRECTOTCORR':
        String status, range, description;
        Color statusColor;
        if (value > 25) {
          status = '🔴 HEAVY RAINFALL';
          range = '(Light: <2mm)';
          description = 'Heavy precipitation. Flood risk and transportation disruption likely.';
          statusColor = Colors.red;
        } else if (value > 10) {
          status = '🟠 MODERATE RAIN';
          range = '(Light: <2mm)';
          description = 'Moderate to heavy rain. Outdoor activities should be postponed.';
          statusColor = Colors.orange;
        } else if (value > 2) {
          status = '🟡 LIGHT RAIN';
          range = '(Light: <2mm)';
          description = 'Light rain expected. Umbrella recommended for outdoor activities.';
          statusColor = Colors.amber;
        } else if (value > 0) {
          status = '🌦️ DRIZZLE';
          range = '(Very light)';
          description = 'Very light precipitation. Minimal impact on outdoor activities.';
          statusColor = Colors.lightBlue;
        } else {
          status = '☀️ NO RAIN';
          range = '(Dry conditions)';
          description = 'No precipitation expected. Clear conditions for outdoor activities.';
          statusColor = Colors.green;
        }
        return {
          'name': 'Precipitation',
          'unit': ' mm',
          'icon': Icons.umbrella,
          'color': Colors.lightBlue,
          'description': description,
          'status': status,
          'range': range,
          'statusColor': statusColor,
        };
        
      case 'ALLSKY_SFC_SW_DWN':
        String status, range, description;
        Color statusColor;
        if (value > 12) {
          status = '🔴 EXTREME SOLAR';
          range = '(Moderate: 5-8 kWh/m²)';
          description = 'Peak solar energy with dangerous UV levels. Excellent for solar panels (120%+ efficiency).';
          statusColor = Colors.red;
        } else if (value > 8) {
          status = '🟠 HIGH SOLAR';
          range = '(Moderate: 5-8 kWh/m²)';
          description = 'Strong solar radiation. Very good for solar energy generation (100%+ efficiency).';
          statusColor = Colors.orange;
        } else if (value > 5) {
          status = '🟡 MODERATE SOLAR';
          range = '(Good range)';
          description = 'Moderate solar energy levels. Good efficiency for solar panels (80%+ output).';
          statusColor = Colors.amber;
        } else if (value > 2) {
          status = '🟢 LOW SOLAR';
          range = '(Limited generation)';
          description = 'Low solar radiation. Limited energy generation capability (40-60% efficiency).';
          statusColor = Colors.green;
        } else {
          status = '🔵 MINIMAL SOLAR';
          range = '(Poor conditions)';
          description = 'Very low solar energy. Minimal generation potential (<30% efficiency).';
          statusColor = Colors.blue;
        }
        return {
          'name': 'Solar Radiation',
          'unit': ' kWh/m²',
          'icon': Icons.wb_sunny,
          'color': Colors.yellow,
          'description': description,
          'status': status,
          'range': range,
          'statusColor': statusColor,
        };
        
      default:
        return {
          'name': parameter,
          'unit': '',
          'icon': Icons.help,
          'color': Colors.white,
          'description': 'Weather parameter data',
          'status': 'DATA',
          'range': '',
          'statusColor': Colors.white,
        };
    }
  }

  Map<String, dynamic> _analyzeWeatherData(Map<String, double> data) {
    final warnings = <String>[];
    final energyAnalysis = <String>[];
    final healthWarnings = <String>[];
    final activities = <String>[];
    String generalAnalysis = '';
    String recommendations = '';
    String energyRecommendations = '';
    
    final temp = data['T2M'];
    final humidity = data['RH2M'];
    final windSpeed = data['WS2M'];
    final precipitation = data['PRECTOTCORR'];
    final solarRadiation = data['ALLSKY_SFC_SW_DWN'];
    
    // Detailed Temperature Analysis
    if (temp != null) {
      if (temp > 40) {
        warnings.add('🔴 EXTREME HEAT WARNING: ${temp.toStringAsFixed(1)}°C');
        healthWarnings.add('⚠️ Risk of heat stroke and dehydration');
        recommendations += '• URGENT: Stay indoors in air-conditioned spaces\n';
        recommendations += '• Drink water every 15-20 minutes\n';
        recommendations += '• Wear white or light-colored loose clothing\n';
        recommendations += '• Avoid outdoor activities between 10 AM - 4 PM\n';
        activities.add('🚫 Outdoor sports: NOT RECOMMENDED');
        activities.add('🏠 Indoor activities: HIGHLY RECOMMENDED');
      } else if (temp > 35) {
        warnings.add('🟠 HIGH HEAT ALERT: ${temp.toStringAsFixed(1)}°C');
        healthWarnings.add('⚠️ Increased risk of heat exhaustion');
        recommendations += '• Limit outdoor exposure during peak hours\n';
        recommendations += '• Increase fluid intake significantly\n';
        recommendations += '• Take frequent breaks in shade\n';
        recommendations += '• Monitor for signs of heat stress\n';
        activities.add('🏃 Light exercise: Early morning/evening only');
        activities.add('🌳 Outdoor work: Minimize and take frequent breaks');
      } else if (temp > 30) {
        warnings.add('🟡 Warm Weather Notice: ${temp.toStringAsFixed(1)}°C');
        recommendations += '• Stay hydrated throughout the day\n';
        recommendations += '• Wear breathable fabrics\n';
        recommendations += '• Use sunscreen if outdoors\n';
        activities.add('🏊 Swimming: EXCELLENT time');
        activities.add('☀️ Beach activities: GOOD (with precautions)');
      } else if (temp >= 20) {
        generalAnalysis += 'Perfect weather conditions for most outdoor activities. ';
        activities.add('🚶 Walking/Jogging: PERFECT conditions');
        activities.add('🚴 Cycling: IDEAL weather');
        activities.add('🏖️ Picnics: EXCELLENT');
      } else if (temp >= 10) {
        generalAnalysis += 'Cool but comfortable weather. ';
        recommendations += '• Wear light jacket or sweater\n';
        activities.add('🧥 Outdoor activities: Good with warm clothing');
      } else if (temp >= 0) {
        warnings.add('🟦 Cold Weather Alert: ${temp.toStringAsFixed(1)}°C');
        recommendations += '• Dress in warm layers\n';
        recommendations += '• Protect extremities (hands, feet, head)\n';
        recommendations += '• Limit outdoor exposure time\n';
        activities.add('❄️ Outdoor activities: Limited duration recommended');
      } else {
        warnings.add('🔵 FREEZING CONDITIONS: ${temp.toStringAsFixed(1)}°C');
        healthWarnings.add('⚠️ Risk of frostbite and hypothermia');
        recommendations += '• URGENT: Minimize outdoor exposure\n';
        recommendations += '• Wear insulated, waterproof clothing\n';
        recommendations += '• Keep moving to maintain circulation\n';
        activities.add('🚫 Prolonged outdoor activities: NOT SAFE');
      }
    }
    
    // Detailed Humidity Analysis
    if (humidity != null) {
      if (humidity > 85) {
        warnings.add('💧 EXTREME HUMIDITY: ${humidity.toStringAsFixed(1)}%');
        healthWarnings.add('⚠️ Severe discomfort, difficulty breathing');
        recommendations += '• Use dehumidifiers and air conditioning\n';
        recommendations += '• Avoid strenuous physical activities\n';
        recommendations += '• Stay in well-ventilated areas\n';
        recommendations += '• Change clothes frequently if sweating\n';
      } else if (humidity > 70) {
        warnings.add('💦 High Humidity Alert: ${humidity.toStringAsFixed(1)}%');
        healthWarnings.add('⚠️ Increased sweating, reduced cooling efficiency');
        recommendations += '• Use fans to improve air circulation\n';
        recommendations += '• Wear moisture-wicking fabrics\n';
        recommendations += '• Stay hydrated but don\'t overdrink\n';
      } else if (humidity < 25) {
        warnings.add('🏜️ EXTREMELY DRY CONDITIONS: ${humidity.toStringAsFixed(1)}%');
        healthWarnings.add('⚠️ Risk of dehydration, skin/respiratory irritation');
        recommendations += '• Use humidifiers indoors\n';
        recommendations += '• Apply moisturizer frequently\n';
        recommendations += '• Drink water regularly\n';
        recommendations += '• Consider nasal saline spray\n';
      } else if (humidity < 40) {
        warnings.add('🌵 Low Humidity Notice: ${humidity.toStringAsFixed(1)}%');
        recommendations += '• Increase fluid intake\n';
        recommendations += '• Use lip balm and moisturizer\n';
      } else {
        generalAnalysis += 'Humidity levels are comfortable. ';
      }
    }
    
    // Advanced Wind Analysis
    if (windSpeed != null) {
      if (windSpeed > 20) {
        warnings.add('💨 SEVERE WIND WARNING: ${windSpeed.toStringAsFixed(1)} m/s');
        healthWarnings.add('⚠️ Flying debris risk, difficulty walking');
        recommendations += '• URGENT: Avoid outdoor activities\n';
        recommendations += '• Secure all loose objects\n';
        recommendations += '• Stay away from trees and power lines\n';
        recommendations += '• Postpone driving if possible\n';
        activities.add('🚫 ALL outdoor activities: DANGEROUS');
      } else if (windSpeed > 15) {
        warnings.add('🌪️ Strong Wind Alert: ${windSpeed.toStringAsFixed(1)} m/s');
        recommendations += '• Exercise caution outdoors\n';
        recommendations += '• Secure lightweight objects\n';
        recommendations += '• Avoid high-rise areas\n';
        activities.add('⚠️ Outdoor sports: Use extreme caution');
      } else if (windSpeed > 10) {
        generalAnalysis += 'Moderate winds provide natural cooling effect. ';
        activities.add('🪁 Kite flying: EXCELLENT conditions');
        activities.add('⛵ Sailing: GOOD conditions');
      } else if (windSpeed > 5) {
        generalAnalysis += 'Light breeze enhances comfort. ';
        activities.add('🌸 Perfect for outdoor relaxation');
      } else {
        generalAnalysis += 'Calm conditions. ';
      }
    }
    
    // Comprehensive Precipitation Analysis
    if (precipitation != null && precipitation > 0) {
      if (precipitation > 25) {
        warnings.add('� HEAVY RAINFALL WARNING: ${precipitation.toStringAsFixed(1)} mm');
        healthWarnings.add('⚠️ Flood risk, transportation disruption');
        recommendations += '• URGENT: Avoid unnecessary travel\n';
        recommendations += '• Stay away from low-lying areas\n';
        recommendations += '• Keep emergency supplies ready\n';
        recommendations += '• Monitor local flood warnings\n';
        activities.add('🚫 All outdoor activities: CANCELLED');
      } else if (precipitation > 10) {
        warnings.add('🌧️ Moderate to Heavy Rain: ${precipitation.toStringAsFixed(1)} mm');
        recommendations += '• Carry waterproof gear\n';
        recommendations += '• Drive carefully, reduce speed\n';
        recommendations += '• Avoid walking in flooded areas\n';
        activities.add('🏠 Indoor activities: RECOMMENDED');
      } else if (precipitation > 2) {
        warnings.add('🌦️ Light Rain Expected: ${precipitation.toStringAsFixed(1)} mm');
        recommendations += '• Carry umbrella or light rain jacket\n';
        recommendations += '• Be cautious of slippery surfaces\n';
        activities.add('☔ Light outdoor activities: Possible with gear');
      } else {
        generalAnalysis += 'Light drizzle possible. ';
        recommendations += '• Keep umbrella handy as precaution\n';
      }
    }
    
    // Advanced Solar Energy & UV Analysis
    if (solarRadiation != null) {
      if (solarRadiation > 12) {
        energyAnalysis.add('⚡ PEAK SOLAR ENERGY: ${solarRadiation.toStringAsFixed(1)} kWh/m²');
        warnings.add('☀️ EXTREME UV RADIATION: Dangerous levels');
        healthWarnings.add('⚠️ Severe sunburn risk within minutes');
        energyRecommendations += '🔋 EXCELLENT for solar panels (120%+ efficiency)\n';
        energyRecommendations += '⚡ Peak energy generation time\n';
        energyRecommendations += '🏠 Ideal for solar water heating systems\n';
        recommendations += '• URGENT: Seek shade, avoid sun exposure\n';
        recommendations += '• Use SPF 50+ sunscreen every 2 hours\n';
        recommendations += '• Wear UV-protective clothing and sunglasses\n';
        recommendations += '• Limit outdoor time to early morning/late evening\n';
        activities.add('🚫 Sun exposure: EXTREMELY DANGEROUS');
      } else if (solarRadiation > 8) {
        energyAnalysis.add('☀️ HIGH SOLAR ENERGY: ${solarRadiation.toStringAsFixed(1)} kWh/m²');
        warnings.add('🌞 High UV Radiation: Protection required');
        energyRecommendations += '🔋 VERY GOOD for solar panels (100%+ efficiency)\n';
        energyRecommendations += '⚡ Strong energy generation potential\n';
        energyRecommendations += '💡 Great for solar-powered devices\n';
        recommendations += '• Use SPF 30+ sunscreen\n';
        recommendations += '• Wear hat and sunglasses\n';
        recommendations += '• Seek shade during peak hours (10 AM - 4 PM)\n';
        activities.add('🏖️ Beach activities: Use sun protection');
        activities.add('🧴 Sunscreen: MANDATORY');
      } else if (solarRadiation > 5) {
        energyAnalysis.add('🌤️ MODERATE SOLAR ENERGY: ${solarRadiation.toStringAsFixed(1)} kWh/m²');
        energyRecommendations += '🔋 GOOD for solar panels (80%+ efficiency)\n';
        energyRecommendations += '⚡ Decent energy generation\n';
        energyRecommendations += '🔧 Good for solar maintenance work\n';
        recommendations += '• Use SPF 15+ sunscreen for extended exposure\n';
        recommendations += '• Sunglasses recommended\n';
        activities.add('☀️ Outdoor activities: Generally safe');
      } else if (solarRadiation > 2) {
        energyAnalysis.add('⛅ LOW SOLAR ENERGY: ${solarRadiation.toStringAsFixed(1)} kWh/m²');
        energyRecommendations += '🔋 LIMITED solar efficiency (40-60%)\n';
        energyRecommendations += '☁️ Reduced energy generation\n';
        energyRecommendations += '🔄 Consider backup power sources\n';
        generalAnalysis += 'Cloudy conditions with minimal UV risk. ';
        activities.add('🌥️ Perfect for outdoor activities without sun concern');
      } else {
        energyAnalysis.add('☁️ MINIMAL SOLAR ENERGY: ${solarRadiation.toStringAsFixed(1)} kWh/m²');
        energyRecommendations += '🔋 POOR solar conditions (<30% efficiency)\n';
        energyRecommendations += '🌑 Minimal energy generation\n';
        energyRecommendations += '🔌 Rely on grid/battery power\n';
        generalAnalysis += 'Overcast conditions, no UV concerns. ';
      }
    }
    
    // Comprehensive analysis
    if (generalAnalysis.isEmpty) {
      generalAnalysis = 'Mixed weather conditions require attention to multiple factors.';
    }
    
    if (recommendations.isEmpty) {
      recommendations = '• Monitor weather updates regularly\n• Stay prepared for changing conditions';
    }
    
    return {
      'general': generalAnalysis,
      'warnings': warnings,
      'healthWarnings': healthWarnings,
      'energyAnalysis': energyAnalysis,
      'activities': activities,
      'recommendations': recommendations,
      'energyRecommendations': energyRecommendations,
    };
  }
}
