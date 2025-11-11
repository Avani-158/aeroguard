import 'package:flutter/foundation.dart';
import '../models/device_data.dart';
import '../services/firebase_service.dart';

class DeviceProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  DeviceData? _deviceData;
  bool _isLoading = false;
  String? _errorMessage;

  DeviceData? get deviceData => _deviceData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DeviceProvider() {
    _init();
  }

  void _init() {
    _firebaseService.getDeviceDataStream().listen(
      (data) {
        _deviceData = data;
        _checkAlerts(data);
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void _checkAlerts(DeviceData? data) {
    if (data == null) return;

    // Check for fire/smoke alerts
    if (data.fire || data.smoke) {
      // Alert will be sent via Firebase Cloud Functions
      // This is handled on the backend
    }
  }

  Future<void> toggleSprinkler() async {
    if (_deviceData == null) return;

    final newStatus = _deviceData!.sprinkler == 'on' ? 'off' : 'on';
    try {
      await _firebaseService.updateSprinkler(newStatus);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleBuzzer() async {
    if (_deviceData == null) return;

    final newStatus = _deviceData!.buzzer == 'on' ? 'off' : 'on';
    try {
      await _firebaseService.updateBuzzer(newStatus);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> acknowledgeFireAlarm() async {
    try {
      await _firebaseService.acknowledgeFireAlarm();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<List<DeviceData>> getHistoricalData({int hours = 24}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final history = await _firebaseService.getHistoricalData(hours: hours);
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
}

