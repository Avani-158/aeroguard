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

  bool get isMockMode => _useMock;

  FirebaseService() {
    try {
      // Attempt to get a database reference. On web this will throw if
      // databaseURL is missing or invalid, so catch and enable mock mode.
      _database = FirebaseDatabase.instance.ref();
      _useMock = false; // Force real mode if database is available
      print('✅ Firebase Database initialized successfully');
    } catch (e) {
      _useMock = true;
      print('❌ Realtime Database unavailable, using mock data: $e');
    }
  }

  // Add method to check if Firebase is properly configured
  bool get isFirebaseConfigured => _database != null && !_useMock;

Stream<DeviceData?> getDeviceDataStream({required String userId}) {
  print('🔍 getDeviceDataStream called for userId: $userId');
  print('📊 Using mock mode: $_useMock');

  if (_useMock) {
    print('🔄 Using mock data mode');
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

  // ✅ Read from devices → ESP32_001 instead of users
  const deviceId = 'ESP32_001';
  print('📡 Listening to Firebase path: devices/$deviceId');

  return _database!.child('devices').child(deviceId).onValue.map((event) {
    print('📨 Firebase event received');

    if (event.snapshot.value == null) {
      print('⚠️ No data found for $deviceId - snapshot is null');
      return null;
    }

    print('📦 Raw data from Firebase: ${event.snapshot.value}');

    final data = Map<String, dynamic>.from(
      event.snapshot.value as Map<dynamic, dynamic>,
    );

    final deviceData = DeviceData.fromJson(data, deviceId);

    // Log ESP32 data to console
    print('📡 ESP32 Data Received:');
    print('  - AQI: ${deviceData.aqi.toStringAsFixed(1)}');
    print('  - Temperature: ${deviceData.temperature.toStringAsFixed(1)}°C');
    print('  - Humidity: ${deviceData.humidity.toStringAsFixed(1)}%');
    print('  - PM2.5: ${deviceData.pm2_5.toStringAsFixed(1)} µg/m³');
    print('  - PM10: ${deviceData.pm10.toStringAsFixed(1)} µg/m³');
    print('  - Noise: ${deviceData.noise.toStringAsFixed(1)} dB');
    print('  - Smoke: ${deviceData.smoke}');
    print('  - Fire: ${deviceData.fire}');
    print('  - Sprinkler: ${deviceData.sprinkler}');
    print('  - Buzzer: ${deviceData.buzzer}');
    print('  - Online: ${deviceData.online}');
    print('  - Timestamp: ${deviceData.timestamp}');
    print('✅ DeviceData object created successfully');

    return deviceData;
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
  // Get historical data for charts (per-user)
Future<List<DeviceData>> getHistoricalData({
  required String userId,
  int hours = 24,
}) async {
  if (_useMock) {
    // Return generated mock data
    return _generateMockHistoricalData(hours);
  }

  try {
    final snapshot = await _database!
        .child('users')
        .child(userId)
        .child('aqHistory')
        .get();

    if (snapshot.value == null) {
      print('No AQ history for $userId, using mock data.');
      return _generateMockHistoricalData(hours);
    }

    final data = Map<String, dynamic>.from(
      snapshot.value as Map<dynamic, dynamic>,
    );

    // final cutoffTime = DateTime.now().subtract(Duration(hours: hours));
    final List<DeviceData> history = [];

    data.forEach((key, value) {
      final record = Map<String, dynamic>.from(value);
      final deviceData = DeviceData.fromJson(record, _deviceId);

      // Filter by time window
   
        history.add(deviceData);
      
    });

    history.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Show mock data if user history is empty
    if (history.isEmpty) {
      print('No recent AQ data found for $userId, showing mock history.');
      return _generateMockHistoricalData(hours);
    }

    return history;
  } catch (e) {
    print('Error loading user AQ history: $e');
    return _generateMockHistoricalData(hours);
  }
}


  // Generate mock historical data with realistic trends
  List<DeviceData> _generateMockHistoricalData(int hours) {
    final now = DateTime.now();
    final List<DeviceData> history = [];
    final rnd = Random();

    for (var i = hours - 1; i >= 0; i--) {
      // Create trends: AQI tends to increase during day, decrease at night
      final timeOfDay = DateTime.now().hour;
      final isDay = timeOfDay >= 6 && timeOfDay < 20;
      final aqiBase = isDay ? 50 : 40;
      final aqiVariation = rnd.nextDouble() * 60;

      history.add(DeviceData(
        deviceId: _deviceId,
        aqi: aqiBase + aqiVariation,
        temperature: 18 + rnd.nextDouble() * 12, // 18-30°C
        humidity: 35 + rnd.nextDouble() * 45, // 35-80%
        pm2_5: rnd.nextDouble() * 55, // 0-55
        pm10: rnd.nextDouble() * 70, // 0-70
        noise: 25 + rnd.nextDouble() * 50, // 25-75 dB
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

  Future<void> saveUserDailyProgress(
    String userId, {
    required int dailyStreak,
    required DateTime lastGoodAirDate,
  }) async {
    if (_useMock) {
      print(
        'Mock saveUserDailyProgress for $userId: streak=$dailyStreak, lastGoodAirDate=$lastGoodAirDate',
      );
      return;
    }

    await _database!
        .child('users')
        .child(userId)
        .child('progress')
        .set({
      'dailyStreak': dailyStreak,
      'lastGoodAirDate': lastGoodAirDate.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> saveUserAqSample(String userId, DeviceData data) async {
    if (_useMock) {
      print('Mock saveUserAqSample for $userId: ${data.aqi.toStringAsFixed(1)}');
      return;
    }

    final sampleRef = _database!
        .child('users')
        .child(userId)
        .child('aqHistory')
        .push();

    await sampleRef.set({
      ...data.toJson(),
      'recordedAt': DateTime.now().toIso8601String(),
    });

    // Also keep a rolling "latest" snapshot for quick reads
    await _database!
        .child('users')
        .child(userId)
        .child('latestAqData')
        .set({
      ...data.toJson(),
      'recordedAt': DateTime.now().toIso8601String(),
    });
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

