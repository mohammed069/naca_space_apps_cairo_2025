import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    debugPrint('🌍 LocationService: Starting getCurrentLocation...');
    bool serviceEnabled;
    LocationPermission permission;

    debugPrint('🌍 LocationService: Checking if location service is enabled...');
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('❌ LocationService: Location service is disabled');
      throw Exception('Location service is disabled. Please enable location from settings');
    }
    debugPrint('✅ LocationService: Location service is enabled');

    debugPrint('🌍 LocationService: Checking location permissions...');
    permission = await Geolocator.checkPermission();
    debugPrint('📋 LocationService: Current permission status: $permission');

    if (permission == LocationPermission.denied) {
      debugPrint('🙋‍♂️ LocationService: Requesting location permission...');
      permission = await Geolocator.requestPermission();
      debugPrint('📋 LocationService: Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        debugPrint('❌ LocationService: Location permission denied');
        throw Exception('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ LocationService: Location permission permanently denied');
      throw Exception('Location permission permanently denied. Please enable it from app settings');
    }

    try {
      debugPrint('📍 LocationService: Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      debugPrint('✅ LocationService: Position obtained successfully: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ LocationService: Failed to get position: $e');
      throw Exception('Failed to get current location: ${e.toString()}');
    }
  }
}