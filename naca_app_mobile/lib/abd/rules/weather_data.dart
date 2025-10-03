class WeatherData {
  final double temperature; // T2M - Temperature at 2 meters (°C)
  final double minTemperature; // T2M_MIN - Minimum temperature (°C)
  final double maxTemperature; // T2M_MAX - Maximum temperature (°C)
  final double humidity; // RH2M - Relative humidity at 2 meters (%)
  final double windSpeed; // WS2M - Wind speed at 2 meters (m/s)
  final double solarRadiation; // ALLSKY_SFC_SW_DWN - Solar radiation (W/m²)
  final double precipitation; // PRECTOTCORR - Precipitation (mm/hr)
  final double pressure; // PS - Surface pressure (hPa)
  final double? visibility; // Visibility (m) - optional

  const WeatherData({
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.solarRadiation,
    required this.precipitation,
    required this.pressure,
    this.visibility,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['T2M'] as num).toDouble(),
      minTemperature: (json['T2M_MIN'] as num).toDouble(),
      maxTemperature: (json['T2M_MAX'] as num).toDouble(),
      humidity: (json['RH2M'] as num).toDouble(),
      windSpeed: (json['WS2M'] as num).toDouble(),
      solarRadiation: (json['ALLSKY_SFC_SW_DWN'] as num).toDouble(),
      precipitation: (json['PRECTOTCORR'] as num).toDouble(),
      pressure: (json['PS'] as num).toDouble(),
      visibility: json['visibility'] != null ? (json['visibility'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'T2M': temperature,
      'T2M_MIN': minTemperature,
      'T2M_MAX': maxTemperature,
      'RH2M': humidity,
      'WS2M': windSpeed,
      'ALLSKY_SFC_SW_DWN': solarRadiation,
      'PRECTOTCORR': precipitation,
      'PS': pressure,
      if (visibility != null) 'visibility': visibility,
    };
  }

  @override
  String toString() {
    return 'WeatherData(temperature: $temperature°C, humidity: $humidity%, windSpeed: $windSpeed m/s, precipitation: $precipitation mm/hr)';
  }

  // Helper methods for easier rule evaluation
  bool get isVeryHot => temperature > 35;
  bool get isHot => temperature > 30;
  bool get isVeryCold => temperature < 5;
  bool get isCold => temperature < 10;
  bool get isHighHumidity => humidity > 80;
  bool get isStrongWind => windSpeed > 30;
  bool get isVeryStrongWind => windSpeed > 50;
  bool get isExtremeFog => visibility != null && visibility! < 200;
  bool get isLightRain => precipitation > 5 && precipitation <= 10;
  bool get isHeavyRain => precipitation > 10;
  bool get isVeryHeavyRain => precipitation > 20;
  bool get isLowSolarRadiation => solarRadiation < 100;
  bool get isThunderstormConditions => isHeavyRain && isLowSolarRadiation;
}