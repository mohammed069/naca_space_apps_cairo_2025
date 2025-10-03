import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:naca_app_mobile/models/nasa_response_model.dart';

class AppRepo {
  static late Dio _dio;
  static String get dailyPoint =>
      'https://power.larc.nasa.gov/api/temporal/daily/point';

  static Future<double> initTest() async {
    double prob = await getProbabilityOfOneDay(
      "0101",
      "T2M_MAX",
      30.444,
      30.0444,
    );
    return prob;
  }

  static Future<double> getProbabilityOfOneDay(
    String monthDay,
    String parameter,
    double latitude,
    double longitude,
  ) async {
    await init();
    final response = await get(
      path: "/point",
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
        baseUrl: 'https://power.larc.nasa.gov/api/temporal/daily',
        connectTimeout: Duration(milliseconds: 30000),
        receiveTimeout: Duration(milliseconds: 30000),
        sendTimeout: Duration(milliseconds: 30000),
      ),
    );

    // final response = await get(
    //   path: buildWeatherDataUrl(
    //     latitude: 30.0444,
    //     longitude: 30.0444,
    //     startDate: "20010101",
    //     endDate: "20241231",
    //     parameters: [
    //       "T2M",
    //       "T2M_MIN",
    //       "T2M_MAX",
    //       "ALLSKY_SFC_SW_DWN",
    //       "RH2M",
    //       "WS2M",
    //       "PRECTOTCORR",
    //       "PS",
    //     ],
    //   ),
    //   options: Options(responseType: ResponseType.json),
    // );
    // print(
    //   "====================T2M=>${response.properties.parameter["T2M"]}====================",
    // );
    // final averages = calculateDailyAverages(
    //   response.properties.parameter["T2M"]!,
    // );
    // print("====================average=>$averages====================");

    // final averageOfOneDay = calculateOneDayAverage(
    //   response.properties.parameter["T2M"]!,
    //   "0101",
    // );
    // print(
    //   "====================averageOfOneDay=>$averageOfOneDay====================",
    // );
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
      print("================start================");
      final response = await _dio.get(
        path,
        options: options,
        queryParameters: queryParameters,
      );
      print("===============response================");
      debugPrint(response.data.toString(), wrapWidth: 1024);
      print("=================end================");
      return NasaResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Dio error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
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
}
