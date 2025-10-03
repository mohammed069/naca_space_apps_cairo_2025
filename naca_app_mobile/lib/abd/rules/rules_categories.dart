enum RulesCategory {
  health,
  energy,
  driving,
  events,
  tips,
}

class RulesCategoryConstants {
  static const String health = 'Health';
  static const String energy = 'Energy';
  static const String driving = 'Driving';
  static const String events = 'Events';
  static const String tips = 'Tips';

  static const Map<RulesCategory, String> categoryNames = {
    RulesCategory.health: health,
    RulesCategory.energy: energy,
    RulesCategory.driving: driving,
    RulesCategory.events: events,
    RulesCategory.tips: tips,
  };

  static const Map<RulesCategory, String> categoryIcons = {
    RulesCategory.health: '🏥',
    RulesCategory.energy: '⚡',
    RulesCategory.driving: '🚗',
    RulesCategory.events: '🎉',
    RulesCategory.tips: '💡',
  };

  static const Map<RulesCategory, String> categoryColors = {
    RulesCategory.health: '#FF6B6B',
    RulesCategory.energy: '#4ECDC4',
    RulesCategory.driving: '#45B7D1',
    RulesCategory.events: '#96CEB4',
    RulesCategory.tips: '#FFEAA7',
  };
}

class WeatherWarning {
  final String message;
  final RulesCategory category;
  final int priority; // 1 = highest, 5 = lowest
  final String icon;

  const WeatherWarning({
    required this.message,
    required this.category,
    required this.priority,
    required this.icon,
  });

  @override
  String toString() {
    return '$icon $message';
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'category': category.name,
      'priority': priority,
      'icon': icon,
    };
  }

  factory WeatherWarning.fromJson(Map<String, dynamic> json) {
    return WeatherWarning(
      message: json['message'] as String,
      category: RulesCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => RulesCategory.tips,
      ),
      priority: json['priority'] as int,
      icon: json['icon'] as String,
    );
  }
}

extension RulesCategoryExtension on RulesCategory {
  String get displayName => RulesCategoryConstants.categoryNames[this] ?? 'Unknown';
  String get icon => RulesCategoryConstants.categoryIcons[this] ?? '❓';
  String get color => RulesCategoryConstants.categoryColors[this] ?? '#000000';
}