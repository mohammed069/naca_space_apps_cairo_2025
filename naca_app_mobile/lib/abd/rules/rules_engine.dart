import 'weather_data.dart';
import 'user_profile.dart';
import 'rules_categories.dart';

class RulesEngine {
  /// Generates weather-related warnings and tips based on weather data and user profile
  /// Returns a list of categorized warnings ordered by priority
  List<WeatherWarning> getWarnings(WeatherData data, [UserProfile? profile]) {
    List<WeatherWarning> warnings = [];

    // Health-related warnings
    warnings.addAll(_getHealthWarnings(data, profile));

    // Energy-related warnings
    warnings.addAll(_getEnergyWarnings(data));

    // Driving-related warnings
    warnings.addAll(_getDrivingWarnings(data));

    // Event-related warnings
    warnings.addAll(_getEventWarnings(data, profile));

    // General tips
    warnings.addAll(_getTips(data, profile));

    // Sort by priority (1 = highest priority)
    warnings.sort((a, b) => a.priority.compareTo(b.priority));

    return warnings;
  }

  /// Get warnings categorized by category
  Map<RulesCategory, List<WeatherWarning>> getWarningsByCategory(
    WeatherData data, [
    UserProfile? profile,
  ]) {
    final warnings = getWarnings(data, profile);
    final Map<RulesCategory, List<WeatherWarning>> categorized = {};

    for (final category in RulesCategory.values) {
      categorized[category] = warnings
          .where((warning) => warning.category == category)
          .toList();
    }

    return categorized;
  }

  /// Get only high priority warnings (priority 1-2)
  List<WeatherWarning> getHighPriorityWarnings(
    WeatherData data, [
    UserProfile? profile,
  ]) {
    return getWarnings(data, profile)
        .where((warning) => warning.priority <= 2)
        .toList();
  }

  // Health-related warnings
  List<WeatherWarning> _getHealthWarnings(WeatherData data, UserProfile? profile) {
    List<WeatherWarning> warnings = [];

    // Temperature-related health warnings
    if (data.isVeryHot) {
      warnings.add(const WeatherWarning(
        message: 'High temperature, stay hydrated and avoid prolonged sun exposure.',
        category: RulesCategory.health,
        priority: 2,
        icon: '🥵',
      ));
    }

    if (data.isVeryCold) {
      warnings.add(const WeatherWarning(
        message: 'Very cold weather, wear warm clothes and protect exposed skin.',
        category: RulesCategory.health,
        priority: 2,
        icon: '❄️',
      ));
    }

    // Profile-specific health warnings
    if (profile != null) {
      // Sinus condition warnings
      if (profile.hasSinus && data.isStrongWind) {
        warnings.add(const WeatherWarning(
          message: 'High wind detected, wear a mask for sinus protection.',
          category: RulesCategory.health,
          priority: 1,
          icon: '😷',
        ));
      }

      // Asthma condition warnings
      if (profile.hasAsthma && data.isHighHumidity) {
        warnings.add(const WeatherWarning(
          message: 'High humidity detected, keep your inhaler with you.',
          category: RulesCategory.health,
          priority: 1,
          icon: '💨',
        ));
      }

      // Heart condition warnings
      if (profile.hasHeartCondition && data.isVeryHot) {
        warnings.add(const WeatherWarning(
          message: 'Extreme heat can stress the heart, stay in cool areas.',
          category: RulesCategory.health,
          priority: 1,
          icon: '❤️',
        ));
      }

      // Elderly or vulnerable group warnings
      if (profile.isVulnerable && (data.isVeryHot || data.isVeryCold)) {
        warnings.add(const WeatherWarning(
          message: 'Extreme temperatures detected, take extra precautions.',
          category: RulesCategory.health,
          priority: 1,
          icon: '👴',
        ));
      }
    }

    return warnings;
  }

  // Energy-related warnings
  List<WeatherWarning> _getEnergyWarnings(WeatherData data) {
    List<WeatherWarning> warnings = [];

    // Wind-related power warnings
    if (data.windSpeed > 50) {
      warnings.add(const WeatherWarning(
        message: 'Power outage risk due to strong winds.',
        category: RulesCategory.energy,
        priority: 2,
        icon: '⚡',
      ));
    }

    if (data.windSpeed > 60) {
      warnings.add(const WeatherWarning(
        message: 'Very strong wind, possible power outage. Charge your devices.',
        category: RulesCategory.energy,
        priority: 1,
        icon: '🔋',
      ));
    }

    // Thunderstorm energy warnings
    if (data.isThunderstormConditions) {
      warnings.add(const WeatherWarning(
        message: 'Thunderstorm alert, avoid using metallic devices and unplug electronics.',
        category: RulesCategory.energy,
        priority: 1,
        icon: '⚡',
      ));
    }

    // High temperature energy consumption warning
    if (data.isVeryHot) {
      warnings.add(const WeatherWarning(
        message: 'High temperatures may increase energy consumption for cooling.',
        category: RulesCategory.energy,
        priority: 3,
        icon: '🌡️',
      ));
    }

    return warnings;
  }

  // Driving-related warnings
  List<WeatherWarning> _getDrivingWarnings(WeatherData data) {
    List<WeatherWarning> warnings = [];

    // Visibility warnings
    if (data.isExtremeFog) {
      warnings.add(const WeatherWarning(
        message: 'Fog alert: Road conditions dangerous, especially for trucks. Use fog lights.',
        category: RulesCategory.driving,
        priority: 1,
        icon: '🚚',
      ));
    }

    // Rain-related driving warnings
    if (data.isVeryHeavyRain) {
      warnings.add(const WeatherWarning(
        message: 'Heavy rain detected, reduce speed to avoid hydroplaning.',
        category: RulesCategory.driving,
        priority: 2,
        icon: '🌧️',
      ));
    }

    if (data.isHeavyRain) {
      warnings.add(const WeatherWarning(
        message: 'Rain expected, increase following distance and use headlights.',
        category: RulesCategory.driving,
        priority: 3,
        icon: '🚗',
      ));
    }

    // Wind warnings for driving
    if (data.isVeryStrongWind) {
      warnings.add(const WeatherWarning(
        message: 'Strong winds may affect vehicle stability, especially high-profile vehicles.',
        category: RulesCategory.driving,
        priority: 2,
        icon: '💨',
      ));
    }

    // Cold weather driving warnings
    if (data.isVeryCold) {
      warnings.add(const WeatherWarning(
        message: 'Freezing conditions possible, watch for ice on roads.',
        category: RulesCategory.driving,
        priority: 2,
        icon: '🧊',
      ));
    }

    return warnings;
  }

  // Event-related warnings
  List<WeatherWarning> _getEventWarnings(WeatherData data, UserProfile? profile) {
    List<WeatherWarning> warnings = [];

    if (profile?.hasOutdoorEvent == true) {
      // Hot weather event warnings
      if (data.isHot) {
        warnings.add(const WeatherWarning(
          message: 'Hot weather during outdoor event, provide water stations and shade.',
          category: RulesCategory.events,
          priority: 2,
          icon: '☀️',
        ));
      }

      // Rain event warnings
      if (data.isHeavyRain) {
        warnings.add(const WeatherWarning(
          message: 'Rain expected during outdoor event, provide tents or covered areas.',
          category: RulesCategory.events,
          priority: 1,
          icon: '🌧️',
        ));
      }

      // Wind event warnings
      if (data.isStrongWind) {
        warnings.add(const WeatherWarning(
          message: 'Strong winds expected, secure all outdoor equipment and decorations.',
          category: RulesCategory.events,
          priority: 2,
          icon: '🎪',
        ));
      }

      // Cold weather event warnings
      if (data.isCold) {
        warnings.add(const WeatherWarning(
          message: 'Cold weather expected, provide heating and warm beverages.',
          category: RulesCategory.events,
          priority: 3,
          icon: '🔥',
        ));
      }
    }

    return warnings;
  }

  // General tips
  List<WeatherWarning> _getTips(WeatherData data, UserProfile? profile) {
    List<WeatherWarning> warnings = [];

    // Hydration tips
    if (data.isHot || (data.humidity > 70 && data.temperature > 25)) {
      warnings.add(const WeatherWarning(
        message: 'Stay hydrated! Drink water regularly even if you don\'t feel thirsty.',
        category: RulesCategory.tips,
        priority: 4,
        icon: '💧',
      ));
    }

    // UV protection tips
    if (data.solarRadiation > 500) {
      warnings.add(const WeatherWarning(
        message: 'High solar radiation, use sunscreen and wear protective clothing.',
        category: RulesCategory.tips,
        priority: 4,
        icon: '🧴',
      ));
    }

    // Clothing tips
    if (data.temperature > 25 && data.humidity < 30) {
      warnings.add(const WeatherWarning(
        message: 'Dry and warm weather, perfect for outdoor activities.',
        category: RulesCategory.tips,
        priority: 5,
        icon: '👕',
      ));
    }

    // Indoor air quality tips
    if (data.isHighHumidity) {
      warnings.add(const WeatherWarning(
        message: 'High humidity may affect indoor air quality, consider using a dehumidifier.',
        category: RulesCategory.tips,
        priority: 4,
        icon: '🏠',
      ));
    }

    // Rain preparation tips
    if (data.isLightRain) {
      warnings.add(const WeatherWarning(
        message: 'Light rain expected, carry an umbrella or light raincoat.',
        category: RulesCategory.tips,
        priority: 4,
        icon: '☂️',
      ));
    }

    return warnings;
  }

  /// Get a summary of warnings count by category
  Map<RulesCategory, int> getWarningsSummary(WeatherData data, [UserProfile? profile]) {
    final warnings = getWarnings(data, profile);
    final Map<RulesCategory, int> summary = {};

    for (final category in RulesCategory.values) {
      summary[category] = warnings.where((w) => w.category == category).length;
    }

    return summary;
  }

  /// Check if there are any critical warnings (priority 1)
  bool hasCriticalWarnings(WeatherData data, [UserProfile? profile]) {
    return getWarnings(data, profile).any((warning) => warning.priority == 1);
  }

  /// Get warnings as simple string list (for backward compatibility)
  List<String> getWarningsAsStrings(WeatherData data, [UserProfile? profile]) {
    return getWarnings(data, profile).map((warning) => warning.toString()).toList();
  }
}