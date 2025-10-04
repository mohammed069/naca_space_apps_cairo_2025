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
}
