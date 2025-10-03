// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:naca_app_mobile/core/app_colors.dart';
import '../../abd/model/weather_model.dart';

class ContainerWidget extends StatefulWidget {
  final String time;
  final String temperature;
  final WeatherCondition condition;
  final bool isHourly;
  
  const ContainerWidget({
    super.key,
    required this.time,
    required this.temperature,
    required this.condition,
    required this.isHourly,
  });

  @override
  State<ContainerWidget> createState() => _ContainerWidgetState();
}

class _ContainerWidgetState extends State<ContainerWidget> {
  IconData _getWeatherIcon(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return Icons.wb_sunny; // ☀️ شمس مشرقة
      case WeatherCondition.partlyCloudy:
        return Icons.wb_cloudy; // ⛅ غيوم جزئية
      case WeatherCondition.cloudy:
        return Icons.cloud; // ☁️ غيوم
      case WeatherCondition.overcast:
        return Icons.cloud_outlined; // ☁️ غيوم كثيفة
      case WeatherCondition.rain:
        return Icons.grain; // 🌧️ مطر خفيف
      case WeatherCondition.drizzle:
        return Icons.water_drop; // 💧 رذاذ
      case WeatherCondition.heavyRain:
        return Icons.thunderstorm; // ⛈️ مطر غزير
      case WeatherCondition.thunderstorm:
        return Icons.flash_on; // ⚡ عواصف رعدية
      case WeatherCondition.snow:
        return Icons.ac_unit; // ❄️ ثلج
      case WeatherCondition.blizzard:
        return Icons.severe_cold; // 🌨️ عاصفة ثلجية
      case WeatherCondition.mist:
        return Icons.foggy; // 🌫️ ضباب خفيف
      case WeatherCondition.fog:
        return Icons.cloud_circle; // 🌫️ ضباب كثيف
      case WeatherCondition.patchy:
        return Icons.cloud_queue; // ⛅ غيوم متناثرة
    }
  }

  Color _getWeatherIconColor(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.clear:
        return const Color(0xFFFFE135); // أصفر ذهبي مشرق للشمس ☀️
      case WeatherCondition.partlyCloudy:
        return const Color(0xFFFFA726); // برتقالي دافئ للشمس الجزئية ⛅
      case WeatherCondition.cloudy:
      case WeatherCondition.overcast:
        return const Color(0xFFE0E0E0); // رمادي فاتح للغيوم ☁️
      case WeatherCondition.rain:
      case WeatherCondition.drizzle:
        return const Color(0xFF42A5F5); // أزرق فاتح للمطر الخفيف 🌧️
      case WeatherCondition.heavyRain:
        return const Color(0xFF1565C0); // أزرق داكن للمطر الغزير 🌧️
      case WeatherCondition.thunderstorm:
        return const Color(0xFFAB47BC); // بنفسجي للعواصف الرعدية ⛈️
      case WeatherCondition.snow:
      case WeatherCondition.blizzard:
        return const Color(0xFFFFFFFF); // أبيض نقي للثلج ❄️
      case WeatherCondition.mist:
      case WeatherCondition.fog:
        return const Color(0xFFBDBDBD); // رمادي متوسط للضباب 🌫️
      case WeatherCondition.patchy:
        return const Color(0xFF90CAF9); // أزرق فاتح للغيوم المتناثرة ⛅
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: widget.isHourly ? 70 : 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color.fromARGB(255, 83, 81, 159).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: AppColors.paletteColor3.withOpacity(0.7),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            widget.time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _getWeatherIconColor(widget.condition).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getWeatherIcon(widget.condition),
              color: _getWeatherIconColor(widget.condition),
              size: 28,
            ),
          ),
          Text(
            widget.temperature,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}