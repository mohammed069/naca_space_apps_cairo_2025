import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomThreshold {
  final double value;
  final String description;
  final DateTime createdAt;

  CustomThreshold({
    required this.value,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomThreshold.fromJson(Map<String, dynamic> json) {
    return CustomThreshold(
      value: json['value'].toDouble(),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum TemperatureUnit { celsius, fahrenheit }
enum WindSpeedUnit { kmh, ms, mph }
enum PressureUnit { hpa, atm, psi }
enum RadiationUnit { kwhm2, wm2, mwcm2 }

class SettingsProvider extends ChangeNotifier {
  static const String _thresholdsKey = 'custom_thresholds';
  static const String _temperatureUnitKey = 'temperature_unit';
  static const String _windSpeedUnitKey = 'wind_speed_unit';
  static const String _pressureUnitKey = 'pressure_unit';
  static const String _radiationUnitKey = 'radiation_unit';

  List<CustomThreshold> _customThresholds = [];
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  WindSpeedUnit _windSpeedUnit = WindSpeedUnit.ms;
  PressureUnit _pressureUnit = PressureUnit.hpa;
  RadiationUnit _radiationUnit = RadiationUnit.kwhm2;

  // Getters
  List<CustomThreshold> get customThresholds => _customThresholds;
  TemperatureUnit get temperatureUnit => _temperatureUnit;
  WindSpeedUnit get windSpeedUnit => _windSpeedUnit;
  PressureUnit get pressureUnit => _pressureUnit;
  RadiationUnit get radiationUnit => _radiationUnit;

  // Unit conversion methods
  double convertTemperature(double celsius) {
    switch (_temperatureUnit) {
      case TemperatureUnit.celsius:
        return celsius;
      case TemperatureUnit.fahrenheit:
        return (celsius * 9 / 5) + 32;
    }
  }

  double convertWindSpeed(double ms) {
    switch (_windSpeedUnit) {
      case WindSpeedUnit.ms:
        return ms;
      case WindSpeedUnit.kmh:
        return ms * 3.6;
      case WindSpeedUnit.mph:
        return ms * 2.237;
    }
  }

  double convertPressure(double hpa) {
    switch (_pressureUnit) {
      case PressureUnit.hpa:
        return hpa;
      case PressureUnit.atm:
        return hpa / 1013.25;
      case PressureUnit.psi:
        return hpa * 0.0145;
    }
  }

  double convertRadiation(double kwhm2) {
    switch (_radiationUnit) {
      case RadiationUnit.kwhm2:
        return kwhm2;
      case RadiationUnit.wm2:
        return kwhm2 * 1000;
      case RadiationUnit.mwcm2:
        return kwhm2 * 100;
    }
  }

  // Unit labels
  String get temperatureUnitLabel {
    switch (_temperatureUnit) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
    }
  }

  String get windSpeedUnitLabel {
    switch (_windSpeedUnit) {
      case WindSpeedUnit.ms:
        return 'm/s';
      case WindSpeedUnit.kmh:
        return 'km/h';
      case WindSpeedUnit.mph:
        return 'mph';
    }
  }

  String get pressureUnitLabel {
    switch (_pressureUnit) {
      case PressureUnit.hpa:
        return 'hPa';
      case PressureUnit.atm:
        return 'atm';
      case PressureUnit.psi:
        return 'psi';
    }
  }

  String get radiationUnitLabel {
    switch (_radiationUnit) {
      case RadiationUnit.kwhm2:
        return 'kWh/m²';
      case RadiationUnit.wm2:
        return 'W/m²';
      case RadiationUnit.mwcm2:
        return 'mW/cm²';
    }
  }

  // Initialize settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load custom thresholds
      final thresholdsJson = prefs.getString(_thresholdsKey);
      if (thresholdsJson != null) {
        final List<dynamic> thresholdsList = jsonDecode(thresholdsJson);
        _customThresholds = thresholdsList
            .map((json) => CustomThreshold.fromJson(json))
            .toList();
      }

      // Load units
      final tempUnitIndex = prefs.getInt(_temperatureUnitKey) ?? 0;
      _temperatureUnit = TemperatureUnit.values[tempUnitIndex];

      final windUnitIndex = prefs.getInt(_windSpeedUnitKey) ?? 0;
      _windSpeedUnit = WindSpeedUnit.values[windUnitIndex];

      final pressureUnitIndex = prefs.getInt(_pressureUnitKey) ?? 0;
      _pressureUnit = PressureUnit.values[pressureUnitIndex];

      final radiationUnitIndex = prefs.getInt(_radiationUnitKey) ?? 0;
      _radiationUnit = RadiationUnit.values[radiationUnitIndex];

      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // Save thresholds to SharedPreferences
  Future<void> _saveThresholds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final thresholdsJson = jsonEncode(
        _customThresholds.map((threshold) => threshold.toJson()).toList(),
      );
      await prefs.setString(_thresholdsKey, thresholdsJson);
    } catch (e) {
      print('Error saving thresholds: $e');
    }
  }

  // Add custom threshold
  Future<void> addThreshold(double value, String description) async {
    final threshold = CustomThreshold(
      value: value,
      description: description,
      createdAt: DateTime.now(),
    );
    
    _customThresholds.add(threshold);
    await _saveThresholds();
    notifyListeners();
  }

  // Remove custom threshold
  Future<void> removeThreshold(int index) async {
    if (index >= 0 && index < _customThresholds.length) {
      _customThresholds.removeAt(index);
      await _saveThresholds();
      notifyListeners();
    }
  }

  // Update temperature unit
  Future<void> updateTemperatureUnit(TemperatureUnit unit) async {
    _temperatureUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_temperatureUnitKey, unit.index);
    notifyListeners();
  }

  // Update wind speed unit
  Future<void> updateWindSpeedUnit(WindSpeedUnit unit) async {
    _windSpeedUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_windSpeedUnitKey, unit.index);
    notifyListeners();
  }

  // Update pressure unit
  Future<void> updatePressureUnit(PressureUnit unit) async {
    _pressureUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pressureUnitKey, unit.index);
    notifyListeners();
  }

  // Update radiation unit
  Future<void> updateRadiationUnit(RadiationUnit unit) async {
    _radiationUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_radiationUnitKey, unit.index);
    notifyListeners();
  }

  // Get unit symbol strings
  String getTemperatureUnitSymbol() {
    switch (_temperatureUnit) {
      case TemperatureUnit.celsius:
        return '°C';
      case TemperatureUnit.fahrenheit:
        return '°F';
    }
  }

  String getWindSpeedUnitSymbol() {
    switch (_windSpeedUnit) {
      case WindSpeedUnit.ms:
        return 'm/s';
      case WindSpeedUnit.kmh:
        return 'km/h';
      case WindSpeedUnit.mph:
        return 'mph';
    }
  }

  String getPressureUnitSymbol() {
    switch (_pressureUnit) {
      case PressureUnit.hpa:
        return 'hPa';
      case PressureUnit.atm:
        return 'atm';
      case PressureUnit.psi:
        return 'psi';
    }
  }

  String getRadiationUnitSymbol() {
    switch (_radiationUnit) {
      case RadiationUnit.kwhm2:
        return 'kWh/m²';
      case RadiationUnit.wm2:
        return 'W/m²';
      case RadiationUnit.mwcm2:
        return 'mW/cm²';
    }
  }
}