// ignore_for_file: avoid_print

import 'weather_data.dart';
import 'user_profile.dart';
import 'rules_engine.dart';
import 'rules_categories.dart';

/// Example usage and testing of the Rules Engine
class RulesEngineExample {
  static void runExamples() {
    final rulesEngine = RulesEngine();
    
    print('🌤️ Weather Rules Engine Examples\n');
    
    // Example 1: Normal weather conditions
    print('📊 Example 1: Normal Weather Conditions');
    final normalWeather = WeatherData(
      temperature: 22,
      minTemperature: 18,
      maxTemperature: 26,
      humidity: 60,
      windSpeed: 15,
      solarRadiation: 400,
      precipitation: 0,
      pressure: 1013,
      visibility: 10000,
    );
    
    final normalProfile = UserProfile();
    _printWarnings(rulesEngine.getWarnings(normalWeather, normalProfile));
    
    // Example 2: Extreme hot weather with health conditions
    print('\n📊 Example 2: Extreme Hot Weather with Health Conditions');
    final hotWeather = WeatherData(
      temperature: 38,
      minTemperature: 32,
      maxTemperature: 42,
      humidity: 85,
      windSpeed: 35,
      solarRadiation: 800,
      precipitation: 0,
      pressure: 1008,
      visibility: 5000,
    );
    
    final healthProfile = UserProfile(
      hasSinus: true,
      hasAsthma: true,
      hasOutdoorEvent: true,
    );
    _printWarnings(rulesEngine.getWarnings(hotWeather, healthProfile));
    
    // Example 3: Stormy weather with driving concerns
    print('\n📊 Example 3: Stormy Weather with Driving Concerns');
    final stormyWeather = WeatherData(
      temperature: 15,
      minTemperature: 12,
      maxTemperature: 18,
      humidity: 90,
      windSpeed: 65,
      solarRadiation: 50,
      precipitation: 25,
      pressure: 995,
      visibility: 150,
    );
    
    final drivingProfile = UserProfile(hasOutdoorEvent: false);
    _printWarnings(rulesEngine.getWarnings(stormyWeather, drivingProfile));
    
    // Example 4: Cold weather for elderly
    print('\n📊 Example 4: Cold Weather for Vulnerable Groups');
    final coldWeather = WeatherData(
      temperature: 2,
      minTemperature: -2,
      maxTemperature: 5,
      humidity: 70,
      windSpeed: 20,
      solarRadiation: 200,
      precipitation: 0,
      pressure: 1020,
      visibility: 8000,
    );
    
    final elderlyProfile = UserProfile(
      isElderly: true,
      hasHeartCondition: true,
    );
    _printWarnings(rulesEngine.getWarnings(coldWeather, elderlyProfile));
    
    // Example 5: Demonstrating categorized warnings
    print('\n📊 Example 5: Categorized Warnings');
    final mixedWeather = WeatherData(
      temperature: 32,
      minTemperature: 28,
      maxTemperature: 36,
      humidity: 75,
      windSpeed: 45,
      solarRadiation: 600,
      precipitation: 15,
      pressure: 1005,
      visibility: 300,
    );
    
    final mixedProfile = UserProfile(
      hasSinus: true,
      hasOutdoorEvent: true,
    );
    
    final categorizedWarnings = rulesEngine.getWarningsByCategory(mixedWeather, mixedProfile);
    _printCategorizedWarnings(categorizedWarnings);
    
    // Example 6: High priority warnings only
    print('\n📊 Example 6: High Priority Warnings Only');
    final highPriorityWarnings = rulesEngine.getHighPriorityWarnings(mixedWeather, mixedProfile);
    print('🚨 Critical and High Priority Warnings:');
    for (final warning in highPriorityWarnings) {
      print('   ${warning.toString()} (Priority: ${warning.priority})');
    }
    
    // Example 7: Warnings summary
    print('\n📊 Example 7: Warnings Summary');
    final summary = rulesEngine.getWarningsSummary(mixedWeather, mixedProfile);
    print('📈 Warnings Count by Category:');
    summary.forEach((category, count) {
      if (count > 0) {
        print('   ${category.icon} ${category.displayName}: $count warnings');
      }
    });
    
    print('\n🔍 Has Critical Warnings: ${rulesEngine.hasCriticalWarnings(mixedWeather, mixedProfile)}');
  }
  
  static void _printWarnings(List<WeatherWarning> warnings) {
    if (warnings.isEmpty) {
      print('   ✅ No warnings - Weather conditions are favorable!');
      return;
    }
    
    print('   ⚠️ Generated ${warnings.length} warnings:');
    for (final warning in warnings) {
      print('   ${warning.toString()} [${warning.category.displayName}]');
    }
  }
  
  static void _printCategorizedWarnings(Map<RulesCategory, List<WeatherWarning>> categorized) {
    print('   📋 Warnings organized by category:');
    
    for (final category in RulesCategory.values) {
      final warnings = categorized[category] ?? [];
      if (warnings.isNotEmpty) {
        print('   \n   ${category.icon} ${category.displayName.toUpperCase()} (${warnings.length} warnings):');
        for (final warning in warnings) {
          print('      • ${warning.message}');
        }
      }
    }
  }
}

/// Mock data for testing different scenarios
class MockWeatherScenarios {
  static WeatherData get perfectWeather => WeatherData(
    temperature: 24,
    minTemperature: 20,
    maxTemperature: 28,
    humidity: 50,
    windSpeed: 10,
    solarRadiation: 400,
    precipitation: 0,
    pressure: 1015,
    visibility: 15000,
  );
  
  static WeatherData get heatWave => WeatherData(
    temperature: 40,
    minTemperature: 35,
    maxTemperature: 45,
    humidity: 30,
    windSpeed: 20,
    solarRadiation: 900,
    precipitation: 0,
    pressure: 1005,
    visibility: 8000,
  );
  
  static WeatherData get blizzard => WeatherData(
    temperature: -5,
    minTemperature: -10,
    maxTemperature: 0,
    humidity: 90,
    windSpeed: 70,
    solarRadiation: 50,
    precipitation: 30,
    pressure: 980,
    visibility: 50,
  );
  
  static WeatherData get thunderstorm => WeatherData(
    temperature: 25,
    minTemperature: 20,
    maxTemperature: 30,
    humidity: 95,
    windSpeed: 55,
    solarRadiation: 80,
    precipitation: 40,
    pressure: 990,
    visibility: 200,
  );
  
  static UserProfile get healthyAdult => UserProfile();
  
  static UserProfile get asthmaticWithEvents => UserProfile(
    hasAsthma: true,
    hasOutdoorEvent: true,
  );
  
  static UserProfile get elderlyWithConditions => UserProfile(
    isElderly: true,
    hasHeartCondition: true,
    hasSinus: true,
  );
}