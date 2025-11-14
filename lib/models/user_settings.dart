class UserSettings {
  final double aqiThreshold;
  final double smokeThreshold;
  final double temperatureThreshold;
  final String fireBrigadeContact;
  final String ownerContact;
  final String ownerEmail;
  final bool darkMode;
  final int dailyStreak;
  final DateTime lastGoodAirDate;
  final int? targetAQI;

  UserSettings({
    this.aqiThreshold = 100,
    this.smokeThreshold = 50,
    this.temperatureThreshold = 35,
    this.fireBrigadeContact = '',
    this.ownerContact = '',
    this.ownerEmail = '',
    this.darkMode = false,
    this.dailyStreak = 0,
    DateTime? lastGoodAirDate,
    this.targetAQI = 50,
  }) : lastGoodAirDate = lastGoodAirDate ?? DateTime.now();

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      aqiThreshold: json['aqiThreshold'] is num
          ? (json['aqiThreshold'] as num).toDouble()
          : 100,
      smokeThreshold: json['smokeThreshold'] is num
          ? (json['smokeThreshold'] as num).toDouble()
          : 50,
      temperatureThreshold: json['temperatureThreshold'] is num
          ? (json['temperatureThreshold'] as num).toDouble()
          : 35,
      fireBrigadeContact: json['fireBrigadeContact'] ?? '',
      ownerContact: json['ownerContact'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      darkMode: json['darkMode'] ?? false,
      dailyStreak: (json['dailyStreak'] as num?)?.toInt() ?? 0,
      lastGoodAirDate: json['lastGoodAirDate'] != null
          ? DateTime.parse(json['lastGoodAirDate'])
          : DateTime.now(),
      targetAQI: (json['targetAQI'] as num?)?.toInt() ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aqiThreshold': aqiThreshold,
      'smokeThreshold': smokeThreshold,
      'temperatureThreshold': temperatureThreshold,
      'fireBrigadeContact': fireBrigadeContact,
      'ownerContact': ownerContact,
      'ownerEmail': ownerEmail,
      'darkMode': darkMode,
      'dailyStreak': dailyStreak,
      'lastGoodAirDate': lastGoodAirDate.toIso8601String(),
      'targetAQI': targetAQI,
    };
  }

  UserSettings copyWith({
    double? aqiThreshold,
    double? smokeThreshold,
    double? temperatureThreshold,
    String? fireBrigadeContact,
    String? ownerContact,
    String? ownerEmail,
    bool? darkMode,
    int? dailyStreak,
    DateTime? lastGoodAirDate,
    int? targetAQI,
  }) {
    return UserSettings(
      aqiThreshold: aqiThreshold ?? this.aqiThreshold,
      smokeThreshold: smokeThreshold ?? this.smokeThreshold,
      temperatureThreshold: temperatureThreshold ?? this.temperatureThreshold,
      fireBrigadeContact: fireBrigadeContact ?? this.fireBrigadeContact,
      ownerContact: ownerContact ?? this.ownerContact,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      darkMode: darkMode ?? this.darkMode,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      lastGoodAirDate: lastGoodAirDate ?? this.lastGoodAirDate,
      targetAQI: targetAQI ?? this.targetAQI,
    );
  }
}

