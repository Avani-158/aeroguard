import 'dart:async';
import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import '../models/device_data.dart';

/// FirebaseService now gracefully falls back to a mock data source when the
/// Realtime Database is unavailable (e.g. web app not configured or hardware
/// not connected). This lets you continue developing UI without a physical
/// device.
class FirebaseService {
  DatabaseReference? _database;
  final String _deviceId = 'ESP32_001'; // Default device ID
  bool _useMock = false;

  FirebaseService() {
    try {
      // Attempt to get a database reference. On web this will throw if
      // databaseURL is missing or invalid, so catch and enable mock mode.
      _database = FirebaseDatabase.instance.ref();
    } catch (e) {
      _useMock = true;
      print('Realtime Database unavailable, using mock data: $e');
    }
  }

  // Get device data stream (real DB or mock)
  Stream<DeviceData?> getDeviceDataStream() {
    if (_useMock) {
      final rnd = Random();
      return Stream<DeviceData?>.periodic(const Duration(seconds: 2), (_) {
        final now = DateTime.now();
        return DeviceData(
          deviceId: _deviceId,
          aqi: 30 + rnd.nextDouble() * 100,
          temperature: 20 + rnd.nextDouble() * 10,
          humidity: 40 + rnd.nextDouble() * 30,
          pm2_5: rnd.nextDouble() * 50,
          pm10: rnd.nextDouble() * 60,
          noise: 30 + rnd.nextDouble() * 40,
          smoke: false,
          fire: false,
          sprinkler: 'off',
          buzzer: 'off',
          timestamp: now,
          online: true,
        );
      }).asBroadcastStream();
    }

    return _database!
        .child('devices')
        .child(_deviceId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return null;

      final data = Map<String, dynamic>.from(
        event.snapshot.value as Map<dynamic, dynamic>,
      );

      return DeviceData.fromJson(data, _deviceId);
    });
  }

  // Update sprinkler status
  Future<void> updateSprinkler(String status) async {
    if (_useMock) {
      print('Mock updateSprinkler: $status');
      return;
    }

    await _database!
        .child('devices')
        .child(_deviceId)
        .child('sprinkler')
        .set(status);
  }

  // Update buzzer status
  Future<void> updateBuzzer(String status) async {
    if (_useMock) {
      print('Mock updateBuzzer: $status');
      return;
    }

    await _database!
        .child('devices')
        .child(_deviceId)
        .child('buzzer')
        .set(status);
  }

  // Acknowledge fire alarm
  Future<void> acknowledgeFireAlarm() async {
    if (_useMock) {
      print('Mock acknowledgeFireAlarm');
      return;
    }

    await _database!
        .child('devices')
        .child(_deviceId)
        .child('fire')
        .set(false);
    await _database!
        .child('devices')
        .child(_deviceId)
        .child('smoke')
        .set(false);
  }

  // Get historical data for charts
  Future<List<DeviceData>> getHistoricalData({int hours = 24}) async {
    if (_useMock) {
      // Return generated historical data
      final now = DateTime.now();
      final List<DeviceData> history = [];
      final rnd = Random();
      for (var i = 0; i < hours; i++) {
        history.add(DeviceData(
          deviceId: _deviceId,
          aqi: 30 + rnd.nextDouble() * 100,
          temperature: 20 + rnd.nextDouble() * 10,
          humidity: 40 + rnd.nextDouble() * 30,
          pm2_5: rnd.nextDouble() * 50,
          pm10: rnd.nextDouble() * 60,
          noise: 30 + rnd.nextDouble() * 40,
          smoke: false,
          fire: false,
          sprinkler: 'off',
          buzzer: 'off',
          timestamp: now.subtract(Duration(hours: i)),
          online: true,
        ));
      }
      history.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return history;
    }

    try {
      final snapshot = await _database!
          .child('devices')
          .child(_deviceId)
          .child('history')
          .get();

      if (snapshot.value == null) return [];

      final data = Map<String, dynamic>.from(
        snapshot.value as Map<dynamic, dynamic>,
      );

      final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
      final List<DeviceData> history = [];

      data.forEach((key, value) {
        final deviceData = DeviceData.fromJson(
          Map<String, dynamic>.from(value),
          _deviceId,
        );
        if (deviceData.timestamp.isAfter(cutoffTime)) {
          history.add(deviceData);
        }
      });

      history.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return history;
    } catch (e) {
      return [];
    }
  }

  // Save user settings
  Future<void> saveUserSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    if (_useMock) {
      print('Mock saveUserSettings for $userId: $settings');
      return;
    }

    await _database!
        .child('users')
        .child(userId)
        .child('settings')
        .set(settings);
  }

  // Get user settings
  Future<Map<String, dynamic>?> getUserSettings(String userId) async {
    if (_useMock) return null;

    try {
      final snapshot = await _database!
          .child('users')
          .child(userId)
          .child('settings')
          .get();

      if (snapshot.value == null) return null;

      return Map<String, dynamic>.from(
        snapshot.value as Map<dynamic, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }
}

