import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';

class SettingsProvider with ChangeNotifier {
  UserSettings _settings = UserSettings();
  bool _isLoading = false;

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _settings.darkMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final savedDarkMode = prefs.getBool('darkMode') ?? false;
      final savedTargetAQI = prefs.getInt('targetAQI') ?? 50;

      // Load from Firebase if user is logged in
      // This would require AuthProvider, so we'll use SharedPreferences for now
      _settings = UserSettings(darkMode: savedDarkMode, targetAQI: savedTargetAQI);
    } catch (e) {
      // Use default settings
      _settings = UserSettings();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();

    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _settings.darkMode);

      // Save to Firebase if user is logged in
      // This would require userId from AuthProvider
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(darkMode: !_settings.darkMode);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', _settings.darkMode);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateThresholds({
    double? aqiThreshold,
    double? smokeThreshold,
    double? temperatureThreshold,
  }) async {
    _settings = _settings.copyWith(
      aqiThreshold: aqiThreshold ?? _settings.aqiThreshold,
      smokeThreshold: smokeThreshold ?? _settings.smokeThreshold,
      temperatureThreshold: temperatureThreshold ?? _settings.temperatureThreshold,
    );
    notifyListeners();
  }

  Future<void> updateContacts({
    String? fireBrigadeContact,
    String? ownerContact,
    String? ownerEmail,
  }) async {
    _settings = _settings.copyWith(
      fireBrigadeContact: fireBrigadeContact ?? _settings.fireBrigadeContact,
      ownerContact: ownerContact ?? _settings.ownerContact,
      ownerEmail: ownerEmail ?? _settings.ownerEmail,
    );
    notifyListeners();
  }

  Future<void> updateDailyStreak(int aqi) async {
    final now = DateTime.now();
    final lastDate = _settings.lastGoodAirDate;
    final isSameDay = now.year == lastDate.year &&
        now.month == lastDate.month &&
        now.day == lastDate.day;

    if (aqi <= 50 && !isSameDay) {
      // Good air quality and new day
      final newStreak = _settings.dailyStreak + 1;
      _settings = _settings.copyWith(
        dailyStreak: newStreak,
        lastGoodAirDate: now,
      );
      notifyListeners();
    } else if (aqi > 50 && !isSameDay) {
      // Bad air quality - reset streak
      _settings = _settings.copyWith(
        dailyStreak: 0,
        lastGoodAirDate: now,
      );
      notifyListeners();
    }
  }

  Future<void> updateTargetAQI(int targetAQI) async {
    _settings = _settings.copyWith(targetAQI: targetAQI);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('targetAQI', targetAQI);
    } catch (e) {
      // Handle error
    }
  }
  }

