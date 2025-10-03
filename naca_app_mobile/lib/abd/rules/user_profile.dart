class UserProfile {
  final bool hasSinus;
  final bool hasAsthma;
  final bool hasHeartCondition;
  final bool isPregnant;
  final bool isElderly;
  final bool hasOutdoorEvent;

  const UserProfile({
    this.hasSinus = false,
    this.hasAsthma = false,
    this.hasHeartCondition = false,
    this.isPregnant = false,
    this.isElderly = false,
    this.hasOutdoorEvent = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      hasSinus: json['hasSinus'] as bool? ?? false,
      hasAsthma: json['hasAsthma'] as bool? ?? false,
      hasHeartCondition: json['hasHeartCondition'] as bool? ?? false,
      isPregnant: json['isPregnant'] as bool? ?? false,
      isElderly: json['isElderly'] as bool? ?? false,
      hasOutdoorEvent: json['hasOutdoorEvent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasSinus': hasSinus,
      'hasAsthma': hasAsthma,
      'hasHeartCondition': hasHeartCondition,
      'isPregnant': isPregnant,
      'isElderly': isElderly,
      'hasOutdoorEvent': hasOutdoorEvent,
    };
  }

  @override
  String toString() {
    List<String> conditions = [];
    if (hasSinus) conditions.add('Sinus');
    if (hasAsthma) conditions.add('Asthma');
    if (hasHeartCondition) conditions.add('Heart Condition');
    if (isPregnant) conditions.add('Pregnant');
    if (isElderly) conditions.add('Elderly');
    if (hasOutdoorEvent) conditions.add('Outdoor Event');
    
    return 'UserProfile(${conditions.isEmpty ? 'No special conditions' : conditions.join(', ')})';
  }

  // Helper methods for easier rule evaluation
  bool get hasRespiratoryCondition => hasSinus || hasAsthma;
  bool get isVulnerable => hasHeartCondition || isPregnant || isElderly;
  bool get needsSpecialCare => hasRespiratoryCondition || isVulnerable;

  UserProfile copyWith({
    bool? hasSinus,
    bool? hasAsthma,
    bool? hasHeartCondition,
    bool? isPregnant,
    bool? isElderly,
    bool? hasOutdoorEvent,
  }) {
    return UserProfile(
      hasSinus: hasSinus ?? this.hasSinus,
      hasAsthma: hasAsthma ?? this.hasAsthma,
      hasHeartCondition: hasHeartCondition ?? this.hasHeartCondition,
      isPregnant: isPregnant ?? this.isPregnant,
      isElderly: isElderly ?? this.isElderly,
      hasOutdoorEvent: hasOutdoorEvent ?? this.hasOutdoorEvent,
    );
  }
}