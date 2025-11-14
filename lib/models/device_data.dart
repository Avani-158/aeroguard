import 'package:flutter/material.dart';

class DeviceData {
  final String deviceId;
  final double aqi;
  final double temperature;
  final double humidity;
  final double pm2_5;
  final double pm10;
  final double noise;
  final bool smoke;
  final bool fire;
  final String sprinkler; // "on" or "off"
  final String buzzer; // "on" or "off"
  final DateTime timestamp;
  final bool online;

  DeviceData({
    required this.deviceId,
    required this.aqi,
    required this.temperature,
    required this.humidity,
    required this.pm2_5,
    required this.pm10,
    required this.noise,
    required this.smoke,
    required this.fire,
    required this.sprinkler,
    required this.buzzer,
    required this.timestamp,
    required this.online,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json, String deviceId) {
    DateTime timestamp;
    if (json['timestamp'] != null) {
      if (json['timestamp'] is String) {
        // Handle ISO string format
        try {
          timestamp = DateTime.parse(json['timestamp']);
        } catch (e) {
          print('❌ Failed to parse timestamp string: ${json['timestamp']}');
          timestamp = DateTime.now();
        }
      } else if (json['timestamp'] is int) {
        // Handle Unix timestamp (seconds since epoch)
        // Check if it's a reasonable timestamp (not too large)
        if (json['timestamp'] > 1000000000 && json['timestamp'] < 2000000000) {
          // It's seconds since epoch
          timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'] * 1000);
        } else if (json['timestamp'] > 1000000000000 && json['timestamp'] < 2000000000000) {
          // It's milliseconds since epoch
          timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp']);
        } else {
          print('❌ Invalid timestamp value: ${json['timestamp']}');
          timestamp = DateTime.now();
        }
      } else if (json['timestamp'] is double) {
        // Handle Unix timestamp as double
        if (json['timestamp'] > 1000000000 && json['timestamp'] < 2000000000) {
          // It's seconds since epoch
          timestamp = DateTime.fromMillisecondsSinceEpoch((json['timestamp'] * 1000).toInt());
        } else if (json['timestamp'] > 1000000000000 && json['timestamp'] < 2000000000000) {
          // It's milliseconds since epoch
          timestamp = DateTime.fromMillisecondsSinceEpoch(json['timestamp'].toInt());
        } else {
          print('❌ Invalid timestamp value: ${json['timestamp']}');
          timestamp = DateTime.now();
        }
      } else {
        print('❌ Unknown timestamp type: ${json['timestamp'].runtimeType}');
        timestamp = DateTime.now();
      }
    } else {
      timestamp = DateTime.now();
    }

    return DeviceData(
      deviceId: deviceId,
      aqi: (json['aqi'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      pm2_5: (json['pm2_5'] ?? 0).toDouble(),
      pm10: (json['pm10'] ?? 0).toDouble(),
      noise: (json['noise'] ?? 0).toDouble(),
      smoke: json['smoke'] ?? false,
      fire: json['fire'] ?? false,
      sprinkler: json['sprinkler'] ?? 'off',
      buzzer: json['buzzer'] ?? 'off',
      timestamp: timestamp,
      online: json['online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi,
      'temperature': temperature,
      'humidity': humidity,
      'pm2_5': pm2_5,
      'pm10': pm10,
      'noise': noise,
      'smoke': smoke,
      'fire': fire,
      'sprinkler': sprinkler,
      'buzzer': buzzer,
      'timestamp': timestamp.toIso8601String(),
      'online': online,
    };
  }

  // Calculate Air Score (0-100) based on AQI
  int get airScore {
    if (aqi <= 50) return 100;
    if (aqi <= 100) return 80;
    if (aqi <= 150) return 60;
    if (aqi <= 200) return 40;
    if (aqi <= 300) return 20;
    return 0;
  }

  // Get AQI category
  String get aqiCategory {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color get aqiColor {
    if (aqi <= 50) return Colors.green;
  if (aqi <= 100) return const Color(0xFF26A69A);
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.deepPurple;
  }

    DeviceData copyWith({
    double? aqi,
    double? temperature,
    double? humidity,
    double? pm2_5,
    double? pm10,
    double? noise,
    bool? smoke,
    bool? fire,
    String? sprinkler,
    String? buzzer,
    DateTime? timestamp,
    bool? online,
  }) {
    return DeviceData(
      deviceId: deviceId,
      aqi: aqi ?? this.aqi,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      pm2_5: pm2_5 ?? this.pm2_5,
      pm10: pm10 ?? this.pm10,
      noise: noise ?? this.noise,
      smoke: smoke ?? this.smoke,
      fire: fire ?? this.fire,
      sprinkler: sprinkler ?? this.sprinkler,
      buzzer: buzzer ?? this.buzzer,
      timestamp: timestamp ?? this.timestamp,
      online: online ?? this.online,
    );
  }

}

