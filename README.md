# IoT Air Quality & Fire Safety Monitoring App

A cross-platform Flutter mobile app for monitoring air quality, fire safety, and environmental conditions from ESP32 IoT devices.

## Features

- 🔐 User Authentication (Email/Password + Google Sign-In)
- 📊 Real-time Dashboard with AQI, Temperature, Humidity, Noise, Dust
- 🔥 Fire/Smoke Detection Alerts
- 💧 Water Sprinkler Control
- 🔊 Buzzer Alarm Control
- 📈 Data Visualization (Charts for AQI, Temperature, Humidity, Noise)
- 🔔 Push Notifications (Firebase Cloud Messaging)
- ⚙️ Settings & Threshold Configuration
- 🎮 Gamification (Air Score, Daily Streaks)

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Realtime Database, Firestore, Authentication, Cloud Messaging)
- **State Management**: Provider
- **Charts**: FL Chart

## Setup Instructions

### 1. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable Authentication (Email/Password and Google Sign-In)
3. Create a Realtime Database (or Firestore)
4. Enable Cloud Messaging
5. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
6. Place them in:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
flutter run
```

## Data Structure

The ESP32 device should send data to Firebase Realtime Database in this format:

```json
{
  "devices": {
    "ESP32_001": {
      "aqi": 95,
      "temperature": 28.3,
      "humidity": 65,
      "pm2_5": 35,
      "pm10": 45,
      "noise": 60,
      "smoke": false,
      "fire": false,
      "sprinkler": "off",
      "buzzer": "off",
      "timestamp": "2025-09-19T12:30:00Z",
      "online": true
    }
  }
}
```

## ESP32 Integration

Your ESP32 should send data via HTTP POST or MQTT to Firebase. Example HTTP endpoint:

```
POST https://YOUR_PROJECT.firebaseio.com/devices/ESP32_001.json?auth=YOUR_AUTH_TOKEN
```

## Project Structure

```
lib/
├── main.dart
├── models/
│   ├── device_data.dart
│   ├── user_settings.dart
│   └── alert.dart
├── services/
│   ├── firebase_service.dart
│   ├── auth_service.dart
│   └── notification_service.dart
├── providers/
│   ├── device_provider.dart
│   ├── auth_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── login_screen.dart
│   ├── dashboard_screen.dart
│   ├── control_panel_screen.dart
│   ├── charts_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── aqi_indicator.dart
    ├── sensor_card.dart
    ├── control_button.dart
    └── chart_widget.dart
```

## License

MIT

