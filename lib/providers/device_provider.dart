import 'package:flutter/foundation.dart';
import '../models/device_data.dart';
import '../services/firebase_service.dart';

class DeviceProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  FirebaseService get firebaseService => _firebaseService;
  DeviceData? _deviceData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userId;
  DateTime? _lastSampleUpload;

  DeviceData? get deviceData => _deviceData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DeviceProvider();

  // --- Called manually after login or user setup ---
  void initStream() {
    if (_userId == null) return;

    print('🔄 DeviceProvider: Initializing stream for user $_userId');
    print('🔧 Firebase configured: ${_firebaseService.isFirebaseConfigured}');

    _firebaseService.getDeviceDataStream(userId: _userId!).listen(
      (data) {
        print('📥 DeviceProvider: Received data: $data');
        _deviceData = data;
        _checkAlerts(data);
        _persistUserSample(data);
        notifyListeners();
      },
      onError: (error) {
        print('❌ DeviceProvider: Stream error: $error');
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void updateUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    if (_userId == null) {
      _lastSampleUpload = null;
    } else {
      initStream(); // reconnect stream for this user
    }
  }

  void _checkAlerts(DeviceData? data) {
    if (data == null) return;
    if (data.fire || data.smoke) {
      // Alerts handled by backend (Firebase Functions)
    }
  }

  // 🔥 Sprinkler toggle (no userId needed)
  Future<void> toggleSprinkler() async {
    if (_deviceData == null) return;
    final newStatus = _deviceData!.sprinkler == 'on' ? 'off' : 'on';
    try {
      await _firebaseService.updateSprinkler(newStatus);
      _deviceData = _deviceData!.copyWith(sprinkler: newStatus);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 🔔 Buzzer toggle (no userId needed)
  Future<void> toggleBuzzer() async {
    if (_deviceData == null) return;
    final newStatus = _deviceData!.buzzer == 'on' ? 'off' : 'on';
    try {
      await _firebaseService.updateBuzzer(newStatus);
      _deviceData = _deviceData!.copyWith(buzzer: newStatus);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 🚨 Fire alarm reset (no userId needed)
  Future<void> acknowledgeFireAlarm() async {
    try {
      await _firebaseService.acknowledgeFireAlarm();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // 📊 History (per-user)
  Future<List<DeviceData>> getHistoricalData({int hours = 24}) async {
    if (_userId == null) return [];
    _isLoading = true;
    notifyListeners();

    try {
      final history =
          await _firebaseService.getHistoricalData(userId: _userId!, hours: hours);
      _isLoading = false;
      notifyListeners();
      return history;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  // 💾 Save sampled data to Firebase
  Future<void> _persistUserSample(DeviceData? data) async {
    if (data == null || _userId == null) return;
    if (_firebaseService.isMockMode) return;

    final now = DateTime.now();
    if (_lastSampleUpload != null &&
        now.difference(_lastSampleUpload!) < const Duration(minutes: 1)) {
      return;
    }

    try {
      await _firebaseService.saveUserAqSample(_userId!, data);
      _lastSampleUpload = now;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user AQ sample: $e');
      }
    }
  }
}
