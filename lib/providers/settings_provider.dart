import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../services/firebase_service.dart';

class SettingsProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  UserSettings _settings = UserSettings();
  bool _isLoading = false;
  String? _userId;

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _settings.darkMode;

  SettingsProvider() {
    _loadSettings();
  }

  void updateUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final localSettings = _readFromPreferences(prefs);

      if (_userId != null && !_firebaseService.isMockMode) {
        final remoteJson = await _firebaseService.getUserSettings(_userId!);
        if (remoteJson != null) {
          _settings = UserSettings.fromJson(remoteJson);
          await _writeToPreferences(prefs, _settings);
        } else if (localSettings != null) {
          _settings = localSettings;
        } else {
          _settings = UserSettings();
        }
      } else if (localSettings != null) {
        _settings = localSettings;
      } else {
        _settings = UserSettings();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading settings: $e');
      }
      _settings = UserSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _persistSettings();
  }

  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(darkMode: !_settings.darkMode);
    notifyListeners();
    await _persistSettings();
  }

  Future<void> updateThresholds({
    double? aqiThreshold,
    double? smokeThreshold,
    double? temperatureThreshold,
  }) async {
    _settings = _settings.copyWith(
      aqiThreshold: aqiThreshold ?? _settings.aqiThreshold,
      smokeThreshold: smokeThreshold ?? _settings.smokeThreshold,
      temperatureThreshold:
          temperatureThreshold ?? _settings.temperatureThreshold,
    );
    notifyListeners();
    await _persistSettings();
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
    await _persistSettings();
  }

  Future<void> updateDailyStreak(int aqi) async {
    final now = DateTime.now();
    final lastDate = _settings.lastGoodAirDate;
    final isSameDay = now.year == lastDate.year &&
        now.month == lastDate.month &&
        now.day == lastDate.day;

    var updated = false;

    if (aqi <= 50 && !isSameDay) {
      final newStreak = _settings.dailyStreak + 1;
      _settings = _settings.copyWith(
        dailyStreak: newStreak,
        lastGoodAirDate: now,
      );
      updated = true;
    } else if (aqi > 50 && !isSameDay) {
      _settings = _settings.copyWith(
        dailyStreak: 0,
        lastGoodAirDate: now,
      );
      updated = true;
    }

    if (updated) {
      notifyListeners();
      await _persistSettings();
    }
  }

  Future<void> updateTargetAQI(int targetAQI) async {
    _settings = _settings.copyWith(targetAQI: targetAQI);
    notifyListeners();
    await _persistSettings();
  }

  UserSettings? _readFromPreferences(SharedPreferences prefs) {
    final hasSettings = prefs.getBool('hasSettings') ?? false;
    if (!hasSettings) return null;

    final lastGoodAirDateString = prefs.getString('lastGoodAirDate');
    final lastGoodAirDate =
        lastGoodAirDateString != null && lastGoodAirDateString.isNotEmpty
            ? DateTime.tryParse(lastGoodAirDateString)
            : null;

    return UserSettings(
      aqiThreshold: prefs.getDouble('aqiThreshold') ?? 100,
      smokeThreshold: prefs.getDouble('smokeThreshold') ?? 50,
      temperatureThreshold: prefs.getDouble('temperatureThreshold') ?? 35,
      fireBrigadeContact: prefs.getString('fireBrigadeContact') ?? '',
      ownerContact: prefs.getString('ownerContact') ?? '',
      ownerEmail: prefs.getString('ownerEmail') ?? '',
      darkMode: prefs.getBool('darkMode') ?? false,
      dailyStreak: prefs.getInt('dailyStreak') ?? 0,
      lastGoodAirDate: lastGoodAirDate,
      targetAQI: prefs.getInt('targetAQI') ?? 50,
    );
  }

  Future<void> _writeToPreferences(
    SharedPreferences prefs,
    UserSettings settings,
  ) async {
    await prefs.setBool('hasSettings', true);
    await prefs.setDouble('aqiThreshold', settings.aqiThreshold);
    await prefs.setDouble('smokeThreshold', settings.smokeThreshold);
    await prefs.setDouble(
      'temperatureThreshold',
      settings.temperatureThreshold,
    );
    await prefs.setString('fireBrigadeContact', settings.fireBrigadeContact);
    await prefs.setString('ownerContact', settings.ownerContact);
    await prefs.setString('ownerEmail', settings.ownerEmail);
    await prefs.setBool('darkMode', settings.darkMode);
    await prefs.setInt('dailyStreak', settings.dailyStreak);
    await prefs.setString(
      'lastGoodAirDate',
      settings.lastGoodAirDate.toIso8601String(),
    );
    if (settings.targetAQI != null) {
      await prefs.setInt('targetAQI', settings.targetAQI!);
    }
  }

  Future<void> _persistSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _writeToPreferences(prefs, _settings);

      if (_userId != null && !_firebaseService.isMockMode) {
        await _firebaseService.saveUserSettings(
          _userId!,
          _settings.toJson(),
        );
        await _firebaseService.saveUserDailyProgress(
          _userId!,
          dailyStreak: _settings.dailyStreak,
          lastGoodAirDate: _settings.lastGoodAirDate,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error persisting settings: $e');
      }
    }
  }
}

