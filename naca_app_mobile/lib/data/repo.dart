import 'dart:math';
import 'package:dio/dio.dart';
import 'package:naca_app_mobile/models/nasa_response_model.dart';

class AppRepo {
  static late Dio _dio;
  static String get dailyPoint =>
      'https://power.larc.nasa.gov/api/temporal/daily/point';
  static String get hourlyPoint =>
      'https://power.larc.nasa.gov/api/temporal/hourly/point';

  static Future<Map<String, double>> getProbabilityOfHourlyData(
    String monthDay,
    String parameter,
    double latitude,
    double longitude,
  ) async {
    await init();
    final response = await get(
      path: "/hourly/point",
      options: Options(responseType: ResponseType.json),
      queryParameters: {
        'start': '20010101',
        'end': '20241231',
        'latitude': latitude,
        'longitude': longitude,
        'community': 're',
        'parameters': parameter,
        'format': 'json',
        'header': 'true',
      },
    );
    final averages = calculateHourlyAveragesForOneDay(
      response.properties.parameter[parameter]!,
      "0101",
    );
    return averages;
  }

  static Future<double> getProbabilityOfOneDay(
    String monthDay,
    String parameter,
    double latitude,
    double longitude,
  ) async {
    await init();
    final response = await get(
      path: "/daily/point",
      options: Options(responseType: ResponseType.json),
      queryParameters: {
        'start': '20010101',
        'end': '20241231',
        'latitude': latitude,
        'longitude': longitude,
        'community': 're',
        'parameters': parameter,
        'format': 'json',
        'header': 'true',
      },
    );
    final average = calculateOneDayAverage(
      response.properties.parameter[parameter]!,
      monthDay,
    );
    return average!;
  }

  static Future<double> calculateProbability(
    String monthDay,
    String parameter,
    double latitude,
    double longitude,
    double threshold,
  ) async {
    await init();
    final response = await get(
      path: "/daily/point",
      options: Options(responseType: ResponseType.json),
      queryParameters: {
        'start': '20010101',
        'end': '20241231',
        'latitude': latitude,
        'longitude': longitude,
        'community': 're',
        'parameters': parameter,
        'format': 'json',
        'header': 'true',
      },
    );
    
    final values = response.properties.parameter[parameter]!;
    List<double> dayValues = [];
    
    // Extract values for the specific month-day across all years
    values.forEach((date, value) {
      String currentMonthDay = date.substring(4, 8);
      if (currentMonthDay == monthDay) {
        dayValues.add(value);
      }
    });
    
    if (dayValues.isEmpty) {
      return 0.0;
    }
    
    // Count how many times the value exceeds the threshold
    int exceedingCount = dayValues.where((value) => value > threshold).length;
    
    // Calculate probability as percentage
    double probability = (exceedingCount / dayValues.length) * 100;
    
    return probability;
  }

  static init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://power.larc.nasa.gov/api/temporal',
        connectTimeout: Duration(milliseconds: 60000), // 60 seconds
        receiveTimeout: Duration(milliseconds: 120000), // 2 minutes
        sendTimeout: Duration(milliseconds: 60000), // 60 seconds
      ),
    );
  }

  static String buildWeatherDataUrl({
    required double latitude,
    required double longitude,
    required String startDate,
    required String endDate,
    required List<String> parameters,
    String community = 're',
    String format = 'json',
  }) {
    final paramString = parameters.join(',');

    return '$dailyPoint?'
        'start=$startDate&'
        'end=$endDate&'
        'latitude=$latitude&'
        'longitude=$longitude&'
        'community=$community&'
        'parameters=$paramString&'
        'format=$format&'
        'header=true';
  }

  static Future<NasaResponse> get({
    required String path,
    required Map<String, dynamic> queryParameters,
    Options? options,
  }) async {
    try {
      print("Making API request to: $path");
      print("Query parameters: $queryParameters");
      
      final response = await _dio.get(
        path,
        options: options,
        queryParameters: queryParameters,
      );
      
      print("API request successful");
      return NasaResponse.fromJson(response.data);
    } on DioException catch (e) {
      print("Dio error occurred: ${e.message}");
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('انتهت مهلة الاتصال. يرجى التأكد من الاتصال بالإنترنت والمحاولة مرة أخرى.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('انتهت مهلة استقبال البيانات. الخادم يستغرق وقتاً أطول من المعتاد.');
      } else if (e.type == DioExceptionType.sendTimeout) {
        throw Exception('انتهت مهلة إرسال الطلب. يرجى المحاولة مرة أخرى.');
      } else {
        throw Exception('خطأ في الشبكة: ${e.message ?? "خطأ غير معروف"} يرجى التأكد من الاتصال بالإنترنت.');
      }
    } catch (e) {
      print("Unexpected error: ${e.toString()}");
      throw Exception('خطأ في معالجة بيانات الطقس: ${e.toString()}');
    }
  }

  static Map<String, double> calculateOneYearAverages(
    Map<String, double> temps,
  ) {
    Map<String, List<double>> grouped = {};

    temps.forEach((date, value) {
      String monthDay = date.substring(4, 8);
      grouped.putIfAbsent(monthDay, () => []);
      grouped[monthDay]!.add(value);
    });

    Map<String, double> averages = {};
    grouped.forEach((monthDay, values) {
      double avg = values.reduce((a, b) => a + b) / values.length;
      averages[monthDay] = avg;
    });

    return averages;
  }

  static double? calculateOneDayAverage(
    Map<String, double> temps,
    String monthDay,
  ) {
    List<double> values = [];

    temps.forEach((date, value) {
      String currentMonthDay = date.substring(4, 8);
      if (currentMonthDay == monthDay) {
        values.add(value);
      }
    });

    if (values.isEmpty) {
      return null;
    }

    double avg = values.reduce((a, b) => a + b) / values.length;
    return avg;
  }

  static Map<String, double> calculateHourlyAveragesForOneDay(
    Map<String, double> temps,
    String monthDay,
  ) {
    Map<String, List<double>> grouped = {};

    temps.forEach((dateHour, value) {
      // YYYYMMDDHH
      String currentMonthDay = dateHour.substring(4, 8);
      String hour = dateHour.substring(8, 10);

      if (currentMonthDay == monthDay) {
        grouped.putIfAbsent(hour, () => []);
        grouped[hour]!.add(value);
      }
    });

    Map<String, double> averages = {};
    grouped.forEach((hour, values) {
      double avg = values.reduce((a, b) => a + b) / values.length;
      averages[hour] = avg;
    });

    return averages;
  }

  // Statistical utility methods for advanced probability analysis
  
  static Map<String, double> calculatePercentiles(Map<String, double> values) {
    List<double> sortedValues = values.values.toList()..sort();
    if (sortedValues.isEmpty) return {};
    
    return {
      'p10': _getPercentile(sortedValues, 0.10),
      'p25': _getPercentile(sortedValues, 0.25),
      'p50': _getPercentile(sortedValues, 0.50), // median
      'p75': _getPercentile(sortedValues, 0.75),
      'p90': _getPercentile(sortedValues, 0.90),
    };
  }
  
  static double _getPercentile(List<double> sortedValues, double percentile) {
    int n = sortedValues.length;
    double index = percentile * (n - 1);
    int lowerIndex = index.floor();
    int upperIndex = index.ceil();
    
    if (lowerIndex == upperIndex) {
      return sortedValues[lowerIndex];
    } else {
      double weight = index - lowerIndex;
      return sortedValues[lowerIndex] * (1 - weight) + sortedValues[upperIndex] * weight;
    }
  }
  
  static Map<String, double> calculateConfidenceInterval(List<double> values, double confidenceLevel) {
    if (values.isEmpty) return {'lower': 0.0, 'upper': 0.0, 'mean': 0.0};
    
    // Calculate mean
    double mean = values.reduce((a, b) => a + b) / values.length;
    
    // Calculate standard deviation
    double variance = values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / values.length;
    double stdDev = sqrt(variance);
    
    // Calculate standard error
    double standardError = stdDev / sqrt(values.length.toDouble());
    
    // For 95% confidence interval, use z-score of 1.96
    double zScore = confidenceLevel == 0.95 ? 1.96 : 2.576; // 95% or 99%
    double marginOfError = zScore * standardError;
    
    return {
      'lower': mean - marginOfError,
      'upper': mean + marginOfError,
      'mean': mean,
      'stdDev': stdDev,
    };
  }
  
  static Map<String, dynamic> generateDistributionData(List<double> values) {
    if (values.isEmpty) return {};
    
    // Calculate basic statistics
    double mean = values.reduce((a, b) => a + b) / values.length;
    double variance = values.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / values.length;
    double stdDev = sqrt(variance);
    
    // Generate bell curve points
    List<Map<String, double>> bellCurvePoints = [];
    double minVal = values.reduce((a, b) => a < b ? a : b);
    double maxVal = values.reduce((a, b) => a > b ? a : b);
    double range = maxVal - minVal;
    
    for (int i = 0; i <= 100; i++) {
      double x = minVal + (range * i / 100);
      double y = _normalDistribution(x, mean, stdDev);
      bellCurvePoints.add({'x': x, 'y': y});
    }
    
    return {
      'mean': mean,
      'median': _getPercentile(values..sort(), 0.50),
      'stdDev': stdDev,
      'bellCurve': bellCurvePoints,
      'min': minVal,
      'max': maxVal,
    };
  }
  
  static double _normalDistribution(double x, double mean, double stdDev) {
    double exponent = -0.5 * pow((x - mean) / stdDev, 2);
    return exp(exponent) / (stdDev * sqrt(2 * pi));
  }
  
  static Future<Map<String, dynamic>> getAdvancedStatistics(
    String monthDay,
    String parameter,
    double latitude,
    double longitude,
  ) async {
    await init();
    final response = await get(
      path: "/daily/point",
      options: Options(responseType: ResponseType.json),
      queryParameters: {
        'start': '20010101',
        'end': '20241231',
        'latitude': latitude,
        'longitude': longitude,
        'community': 're',
        'parameters': parameter,
        'format': 'json',
        'header': 'true',
      },
    );
    
    final values = response.properties.parameter[parameter]!;
    List<double> dayValues = [];
    Map<String, List<double>> yearlyData = {};
    
    // Extract values for the specific month-day across all years
    values.forEach((date, value) {
      String currentMonthDay = date.substring(4, 8);
      if (currentMonthDay == monthDay) {
        dayValues.add(value);
        String year = date.substring(0, 4);
        yearlyData.putIfAbsent(year, () => []);
        yearlyData[year]!.add(value);
      }
    });
    
    if (dayValues.isEmpty) {
      return {
        'percentiles': {},
        'confidenceInterval': {},
        'distribution': {},
        'yearlyComparison': {},
      };
    }
    
    // Calculate all statistical measures
    Map<String, double> percentiles = calculatePercentiles({for (int i = 0; i < dayValues.length; i++) i.toString(): dayValues[i]});
    Map<String, double> confidenceInterval = calculateConfidenceInterval(dayValues, 0.95);
    Map<String, dynamic> distribution = generateDistributionData(dayValues);
    
    // Prepare yearly comparison data
    Map<String, double> yearlyAverages = {};
    yearlyData.forEach((year, values) {
      if (values.isNotEmpty) {
        yearlyAverages[year] = values.reduce((a, b) => a + b) / values.length;
      }
    });
    
    return {
      'percentiles': percentiles,
      'confidenceInterval': confidenceInterval,
      'distribution': distribution,
      'yearlyComparison': yearlyAverages,
      'allValues': dayValues,
    };
  }
}
