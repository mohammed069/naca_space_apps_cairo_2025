import 'package:flutter/material.dart';
import 'lib/abd/service/weather_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing Weather API...');
  
  final weatherService = WeatherService();
  
  try {
    print('🌍 Testing Cairo weather...');
    final weather = await weatherService.getWeatherByCity('Cairo');
    print('✅ SUCCESS: ${weather.cityName} - ${weather.temperatureString}');
    print('📍 Description: ${weather.description}');
    print('🌡️ Feels like: ${weather.feelsLikeString}');
    
    print('\n⏰ Testing hourly forecast...');
    final hourly = await weatherService.getHourlyForecast('Cairo');
    print('✅ SUCCESS: Got ${hourly.length} hourly forecasts');
    
    print('\n📅 Testing weekly forecast...');
    final weekly = await weatherService.getWeeklyForecast('Cairo');
    print('✅ SUCCESS: Got ${weekly.length} daily forecasts');
    
  } catch (e) {
    print('❌ ERROR: $e');
  }
}