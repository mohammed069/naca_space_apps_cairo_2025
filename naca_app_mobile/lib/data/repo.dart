import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:naca_app_mobile/models/nasa_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRepo {
  static late Dio _dio;
  static String get dailyPoint =>
      'https://power.larc.nasa.gov/api/temporal/daily/point';

  static init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://power.larc.nasa.gov/api/temporal/daily',
        connectTimeout: Duration(milliseconds: 30000),
        receiveTimeout: Duration(milliseconds: 30000),
        sendTimeout: Duration(milliseconds: 30000),
      ),
    );

    final response = await get(
      path: buildWeatherDataUrl(
        latitude: 30.0444,
        longitude: 30.0444,
        startDate: "20200101",
        endDate: "20200103",
        parameters: [
          "T2M",
          "T2M_MIN",
          "T2M_MAX",
          "ALLSKY_SFC_SW_DWN",
          "RH2M",
          "WS2M",
          "PRECTOTCORR",
          "PS",
        ],
      ),
      options: Options(responseType: ResponseType.json),
    );
    print(
      "====================${response.properties.parameter["T2M"]}====================",
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
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      print("================start================");
      final response = await _dio.get(path, options: options);
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
}
