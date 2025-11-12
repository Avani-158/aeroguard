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
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
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
}

