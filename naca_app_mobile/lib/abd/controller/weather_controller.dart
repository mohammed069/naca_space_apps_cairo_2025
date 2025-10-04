import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../service/location_service.dart';
import '../service/weather_service.dart';
import '../model/weather_model.dart';
import '../../providers/settings_provider.dart';

class WeatherController extends ChangeNotifier {
  late final WeatherService _weatherService;
  late final LocationService _locationService;
  Weather? _currentWeather;
  List<HourlyWeather>? _hourlyForecast;
  List<DailyWeather>? _weeklyForecast;
  bool _isLoading = false;
  bool _isLoadingHourly = false;
  bool _isLoadingWeekly = false;
  String? _errorMessage;
  
  WeatherController() {
    _weatherService = WeatherService();
    _locationService = LocationService();
  }

  // Getters
  Weather? get currentWeather => _currentWeather;
  List<HourlyWeather>? get hourlyForecast => _hourlyForecast;
  List<DailyWeather>? get weeklyForecast => _weeklyForecast;
  bool get isLoading => _isLoading;
  bool get isLoadingHourly => _isLoadingHourly;
  bool get isLoadingWeekly => _isLoadingWeekly;
  String? get errorMessage => _errorMessage;

  Future<void> getWeatherForCity(String cityName) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final weather = await _weatherService.getWeatherByCity(cityName);
      _currentWeather = weather;
    } catch (e) {
      _errorMessage = e.toString();
      _currentWeather = null;
    }

    _setLoading(false);
  }

  Future<void> getWeatherForLocation(double lat, double lon) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final weather = await _weatherService.getWeatherByCoordinates(lat, lon);
      _currentWeather = weather;
    } catch (e) {
      _errorMessage = e.toString();
      _currentWeather = null;
    }

    _setLoading(false);
  }

  Future<void> getWeatherForCurrentLocation() async {
    debugPrint('🌍 Starting getWeatherForCurrentLocation...');
    _setLoading(true);
    _errorMessage = null;

    try {
      debugPrint('🌍 Getting current location...');
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        debugPrint('📍 Location obtained: ${position.latitude}, ${position.longitude}');
        final weather = await _weatherService.getWeatherByCoordinates(
          position.latitude,
          position.longitude
        );
        debugPrint('🌤️ Weather data obtained successfully for ${weather.cityName}');
        _currentWeather = weather;
      } else {
        debugPrint('❌ Could not get current location - position is null');
        throw Exception('Could not get your location');
      }
    } catch (e) {
      debugPrint('❌ Error in getWeatherForCurrentLocation: $e');
      _errorMessage = e.toString();
      _currentWeather = null;
    }

    _setLoading(false);
    debugPrint('🌍 getWeatherForCurrentLocation completed');
  }

  // Hourly Forecast Methods
  Future<void> getHourlyWeatherForCity(String cityName) async {
    _setLoadingHourly(true);
    _errorMessage = null;

    try {
      final forecast = await _weatherService.getHourlyForecast(cityName);
      _hourlyForecast = forecast;
    } catch (e) {
      _errorMessage = e.toString();
      _hourlyForecast = null;
    }

    _setLoadingHourly(false);
  }

  Future<void> getHourlyWeatherForLocation(double lat, double lon) async {
    _setLoadingHourly(true);
    _errorMessage = null;

    try {
      final forecast = await _weatherService.getHourlyForecastByCoordinates(lat, lon);
      _hourlyForecast = forecast;
    } catch (e) {
      _errorMessage = e.toString();
      _hourlyForecast = null;
    }

    _setLoadingHourly(false);
  }

  Future<void> getHourlyWeatherForCurrentLocation() async {
    _setLoadingHourly(true);
    _errorMessage = null;

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final forecast = await _weatherService.getHourlyForecastByCoordinates(
          position.latitude,
          position.longitude,
        );
        _hourlyForecast = forecast;
      } else {
        throw Exception('Could not get your location');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _hourlyForecast = null;
    }

    _setLoadingHourly(false);
  }

  // Weekly Forecast Methods
  Future<void> getWeeklyWeatherForCity(String cityName) async {
    _setLoadingWeekly(true);
    _errorMessage = null;

    try {
      final forecast = await _weatherService.getWeeklyForecast(cityName);
      _weeklyForecast = forecast;
    } catch (e) {
      _errorMessage = e.toString();
      _weeklyForecast = null;
    }

    _setLoadingWeekly(false);
  }

  Future<void> getWeeklyWeatherForLocation(double lat, double lon) async {
    _setLoadingWeekly(true);
    _errorMessage = null;

    try {
      final forecast = await _weatherService.getWeeklyForecastByCoordinates(lat, lon);
      _weeklyForecast = forecast;
    } catch (e) {
      _errorMessage = e.toString();
      _weeklyForecast = null;
    }

    _setLoadingWeekly(false);
  }

  Future<void> getWeeklyWeatherForCurrentLocation() async {
    _setLoadingWeekly(true);
    _errorMessage = null;

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final forecast = await _weatherService.getWeeklyForecastByCoordinates(
          position.latitude,
          position.longitude,
        );
        _weeklyForecast = forecast;
      } else {
        throw Exception('Could not get your location');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _weeklyForecast = null;
    }

    _setLoadingWeekly(false);
  }

  // Combined method to get all weather data at once
  Future<void> getAllWeatherDataForCity(String cityName) async {
    await Future.wait([
      getWeatherForCity(cityName),
      getHourlyWeatherForCity(cityName),
      getWeeklyWeatherForCity(cityName),
    ]);
  }

  Future<void> getAllWeatherDataForCurrentLocation() async {
    debugPrint('🚀 Starting getAllWeatherDataForCurrentLocation...');
    await Future.wait([
      getWeatherForCurrentLocation(),
      getHourlyWeatherForCurrentLocation(),
      getWeeklyWeatherForCurrentLocation(),
    ]);
    debugPrint('🚀 getAllWeatherDataForCurrentLocation completed');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearAllData() {
    _currentWeather = null;
    _hourlyForecast = null;
    _weeklyForecast = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingHourly(bool loading) {
    _isLoadingHourly = loading;
    notifyListeners();
  }

  void _setLoadingWeekly(bool loading) {
    _isLoadingWeekly = loading;
    notifyListeners();
  }
}