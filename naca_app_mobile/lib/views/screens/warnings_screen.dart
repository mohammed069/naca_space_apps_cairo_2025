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
          // تحليل عام للطقس
          _buildAnalysisCard(
            title: 'General Weather Analysis',
            content: analysis['general'] ?? 'Insufficient data for analysis',
            icon: Icons.analytics_outlined,
            color: const Color(0xFF4CAF50),
          ),
          
          const SizedBox(height: 16),
          
          // التنبيهات والتحذيرات
          if (analysis['warnings'].isNotEmpty) ...[
            _buildAnalysisCard(
              title: 'Important Warnings',
              content: analysis['warnings'].join('\n\n'),
              icon: Icons.warning_amber_outlined,
              color: const Color(0xFFFF9800),
            ),
            const SizedBox(height: 16),
          ],
          
          // النصائح والتوصيات
          _buildAnalysisCard(
            title: 'Tips & Recommendations',
            content: analysis['recommendations'] ?? 'No specific recommendations',
            icon: Icons.lightbulb_outline,
            color: const Color(0xFF2196F3),
          ),
          
          const SizedBox(height: 16),
          
          // ملخص البيانات
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
              Icon(Icons.summarize_outlined, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Data Summary',
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
            final parameterNames = {
              'T2M': 'Temperature',
              'RH2M': 'Humidity',
              'WS2M': 'Wind Speed',
              'PRECTOTCORR': 'Precipitation',
              'ALLSKY_SFC_SW_DWN': 'Solar Radiation',
            };
            
            final units = {
              'T2M': '°C',
              'RH2M': '%',
              'WS2M': 'm/s',
              'PRECTOTCORR': 'mm',
              'ALLSKY_SFC_SW_DWN': 'kWh/m²',
            };
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    parameterNames[entry.key] ?? entry.key,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${entry.value.toStringAsFixed(1)}${units[entry.key] ?? ''}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Map<String, dynamic> _analyzeWeatherData(Map<String, double> data) {
    final warnings = <String>[];
    String generalAnalysis = '';
    String recommendations = '';
    
    final temp = data['T2M'];
    final humidity = data['RH2M'];
    final windSpeed = data['WS2M'];
    final precipitation = data['PRECTOTCORR'];
    final solarRadiation = data['ALLSKY_SFC_SW_DWN'];
    
    // Temperature analysis
    if (temp != null) {
      if (temp > 35) {
        warnings.add('🌡️ Very high temperature (${temp.toStringAsFixed(1)}°C)');
        recommendations += '• Avoid direct sunlight exposure\n';
        recommendations += '• Drink plenty of water\n';
        recommendations += '• Wear light-colored clothing\n';
      } else if (temp < 5) {
        warnings.add('🥶 Very low temperature (${temp.toStringAsFixed(1)}°C)');
        recommendations += '• Wear warm clothing\n';
        recommendations += '• Avoid staying outdoors for long periods\n';
      }
      
      if (temp >= 20 && temp <= 30) {
        generalAnalysis += 'Weather is moderate and suitable for outdoor activities. ';
      }
    }
    
    // Humidity analysis
    if (humidity != null) {
      if (humidity > 80) {
        warnings.add('💧 Very high humidity (${humidity.toStringAsFixed(1)}%)');
        recommendations += '• Use dehumidifier at home\n';
        recommendations += '• Avoid strenuous activities\n';
      } else if (humidity < 30) {
        warnings.add('🏜️ Very low humidity (${humidity.toStringAsFixed(1)}%)');
        recommendations += '• Use air humidifier\n';
        recommendations += '• Drink more fluids\n';
      }
    }
    
    // Wind speed analysis
    if (windSpeed != null) {
      if (windSpeed > 15) {
        warnings.add('💨 Strong winds (${windSpeed.toStringAsFixed(1)} m/s)');
        recommendations += '• Secure loose objects\n';
        recommendations += '• Avoid outdoor activities\n';
      } else if (windSpeed > 10) {
        generalAnalysis += 'Moderate winds help cool the atmosphere. ';
      }
    }
    
    // Precipitation analysis
    if (precipitation != null && precipitation > 0) {
      if (precipitation > 10) {
        warnings.add('🌧️ Heavy rain expected (${precipitation.toStringAsFixed(1)} mm)');
        recommendations += '• Carry an umbrella\n';
        recommendations += '• Avoid driving if possible\n';
        recommendations += '• Beware of water accumulation\n';
      } else {
        generalAnalysis += 'Light rain expected. ';
        recommendations += '• Carry an umbrella as precaution\n';
      }
    }
    
    // Solar radiation analysis
    if (solarRadiation != null) {
      if (solarRadiation > 8) {
        warnings.add('☀️ Strong solar radiation (${solarRadiation.toStringAsFixed(1)} kWh/m²)');
        recommendations += '• Use sunscreen\n';
        recommendations += '• Wear sunglasses\n';
      }
    }
    
    if (generalAnalysis.isEmpty) {
      generalAnalysis = 'Weather conditions are within normal ranges.';
    }
    
    if (recommendations.isEmpty) {
      recommendations = '• Enjoy your day!\n• Follow weather updates for changes';
    }
    
    return {
      'general': generalAnalysis,
      'warnings': warnings,
      'recommendations': recommendations,
    };
  }
}
