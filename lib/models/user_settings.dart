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
  }) : lastGoodAirDate = lastGoodAirDate ?? DateTime.now();

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      aqiThreshold: (json['aqiThreshold'] ?? 100).toDouble(),
      smokeThreshold: (json['smokeThreshold'] ?? 50).toDouble(),
      temperatureThreshold: (json['temperatureThreshold'] ?? 35).toDouble(),
      fireBrigadeContact: json['fireBrigadeContact'] ?? '',
      ownerContact: json['ownerContact'] ?? '',
      ownerEmail: json['ownerEmail'] ?? '',
      darkMode: json['darkMode'] ?? false,
      dailyStreak: json['dailyStreak'] ?? 0,
      lastGoodAirDate: json['lastGoodAirDate'] != null
          ? DateTime.parse(json['lastGoodAirDate'])
          : DateTime.now(),
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
    );
  }
}

