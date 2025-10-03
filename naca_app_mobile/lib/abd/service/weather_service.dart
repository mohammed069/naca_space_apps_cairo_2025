import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../model/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.weatherapi.com/v1';
  static const String _apiKey = 'f972848eccb249ab878212732252408';

  late final Dio _dio;

  WeatherService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint('DIO: $o'),
    ));
  }

  Future<Weather> getWeatherByCity(String cityName) async {
    try {
      debugPrint('Making API call for city: $cityName');

      final response = await _dio.get(
        '/current.json',
        queryParameters: {
          'key': _apiKey,
          'q': cityName,
          'aqi': 'no',
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data.containsKey('location') && data.containsKey('current')) {
          return Weather.fromWeatherApiJson(data);
        } else {
          throw Exception('Invalid data received from server');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      debugPrint('Dio Error: ${dioError.type} - ${dioError.message}');

      switch (dioError.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('Connection timeout - Please try again');

        case DioExceptionType.badResponse:
          final statusCode = dioError.response?.statusCode;
          if (statusCode == 400) {
            final errorData = dioError.response?.data;
            final errorMessage = errorData?['error']?['message'] ?? 'City not found';
            throw Exception('City not found: $errorMessage');
          } else if (statusCode == 401) {
            throw Exception('API key issue - Check settings');
          } else if (statusCode == 403) {
            throw Exception('API quota exceeded');
          } else {
            throw Exception('Server error: $statusCode');
          }

        case DioExceptionType.connectionError:
          throw Exception('Cannot connect to server - Check internet connection');

        case DioExceptionType.cancel:
          throw Exception('Request cancelled');

        default:
          throw Exception('Network error: ${dioError.message}');
      }
    } catch (e) {
      debugPrint('Error in getWeatherByCity: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      } else {
        throw Exception('Unexpected error: ${e.toString()}');
      }
    }
  }

  Future<Weather> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/current.json',
        queryParameters: {
          'key': _apiKey,
          'q': '$lat,$lon',
          'aqi': 'no',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return Weather.fromWeatherApiJson(response.data);
      } else {
        throw Exception('Failed to get weather data');
      }
    } on DioException catch (dioError) {
      throw Exception('Connection error: ${dioError.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Future<List<HourlyWeather>> getHourlyForecast(String cityName, {int days = 1}) async {
    try {
      debugPrint('Making API call for hourly forecast: $cityName');

      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': cityName,
          'days': days,
          'aqi': 'no',
          'alerts': 'no',
        },
      );

      debugPrint('Hourly forecast response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data.containsKey('forecast') && data['forecast']['forecastday'] != null) {
          final forecastDay = data['forecast']['forecastday'][0];
          final hourlyData = forecastDay['hour'] as List<dynamic>;
          
          return hourlyData
              .map((hourData) => HourlyWeather.fromWeatherApiJson(hourData))
              .toList();
        } else {
          throw Exception('Invalid forecast data received from server');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      debugPrint('Dio Error in hourly forecast: ${dioError.type} - ${dioError.message}');
      _handleDioError(dioError);
      return []; // This line will never be reached due to _handleDioError throwing
    } catch (e) {
      debugPrint('Error in getHourlyForecast: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      } else {
        throw Exception('Unexpected error: ${e.toString()}');
      }
    }
  }

  Future<List<HourlyWeather>> getHourlyForecastByCoordinates(double lat, double lon, {int days = 1}) async {
    try {
      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': '$lat,$lon',
          'days': days,
          'aqi': 'no',
          'alerts': 'no',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data.containsKey('forecast') && data['forecast']['forecastday'] != null) {
          final forecastDay = data['forecast']['forecastday'][0];
          final hourlyData = forecastDay['hour'] as List<dynamic>;
          
          return hourlyData
              .map((hourData) => HourlyWeather.fromWeatherApiJson(hourData))
              .toList();
        } else {
          throw Exception('Invalid forecast data received from server');
        }
      } else {
        throw Exception('Failed to get hourly forecast data');
      }
    } on DioException catch (dioError) {
      throw Exception('Connection error: ${dioError.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  Future<List<DailyWeather>> getWeeklyForecast(String cityName, {int days = 7}) async {
    try {
      debugPrint('Making API call for weekly forecast: $cityName');

      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': cityName,
          'days': days,
          'aqi': 'no',
          'alerts': 'no',
        },
      );

      debugPrint('Weekly forecast response status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data.containsKey('forecast') && data['forecast']['forecastday'] != null) {
          final forecastDays = data['forecast']['forecastday'] as List<dynamic>;
          
          return forecastDays
              .map((dayData) => DailyWeather.fromWeatherApiJson(dayData))
              .toList();
        } else {
          throw Exception('Invalid forecast data received from server');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      debugPrint('Dio Error in weekly forecast: ${dioError.type} - ${dioError.message}');
      _handleDioError(dioError);
      return []; // This line will never be reached due to _handleDioError throwing
    } catch (e) {
      debugPrint('Error in getWeeklyForecast: $e');
      if (e.toString().contains('Exception:')) {
        rethrow;
      } else {
        throw Exception('Unexpected error: ${e.toString()}');
      }
    }
  }

  Future<List<DailyWeather>> getWeeklyForecastByCoordinates(double lat, double lon, {int days = 7}) async {
    try {
      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': '$lat,$lon',
          'days': days,
          'aqi': 'no',
          'alerts': 'no',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data.containsKey('forecast') && data['forecast']['forecastday'] != null) {
          final forecastDays = data['forecast']['forecastday'] as List<dynamic>;
          
          return forecastDays
              .map((dayData) => DailyWeather.fromWeatherApiJson(dayData))
              .toList();
        } else {
          throw Exception('Invalid forecast data received from server');
        }
      } else {
        throw Exception('Failed to get weekly forecast data');
      }
    } on DioException catch (dioError) {
      throw Exception('Connection error: ${dioError.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  void _handleDioError(DioException dioError) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw Exception('Connection timeout - Please try again');

      case DioExceptionType.badResponse:
        final statusCode = dioError.response?.statusCode;
        if (statusCode == 400) {
          final errorData = dioError.response?.data;
          final errorMessage = errorData?['error']?['message'] ?? 'Invalid request';
          throw Exception('Request error: $errorMessage');
        } else if (statusCode == 401) {
          throw Exception('API key issue - Check settings');
        } else if (statusCode == 403) {
          throw Exception('API quota exceeded');
        } else {
          throw Exception('Server error: $statusCode');
        }

      case DioExceptionType.connectionError:
        throw Exception('Cannot connect to server - Check internet connection');

      case DioExceptionType.cancel:
        throw Exception('Request cancelled');

      default:
        throw Exception('Network error: ${dioError.message}');
    }
  }
}