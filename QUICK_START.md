# Quick Start Guide

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase account
- Node.js (optional, for web dashboard)

## Installation Steps

### 1. Install Flutter

```bash
# Check Flutter installation
flutter doctor

# Install dependencies
flutter pub get
```

### 2. Set Up Firebase

Follow the detailed guide in `FIREBASE_SETUP.md` to:
- Create Firebase project
- Add Android/iOS apps
- Enable Authentication
- Set up Realtime Database
- Configure Cloud Messaging

### 3. Configure Firebase Files

- Place `google-services.json` in `android/app/`
- Place `GoogleService-Info.plist` in `ios/Runner/`

### 4. Run the App

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web (experimental)
flutter run -d chrome
```

## Testing Without ESP32

You can test the app by manually adding data to Firebase Realtime Database:

1. Go to Firebase Console → Realtime Database
2. Add this structure:

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
      "timestamp": "2025-01-19T12:30:00Z",
      "online": true
    }
  }
}
```

## App Features Overview

### Dashboard
- Real-time AQI display with color-coded indicators
- Air Score (0-100) with circular progress
- Sensor readings (Temperature, Humidity, Noise, PM2.5, PM10)
- Fire/Smoke detection status
- Daily streak counter
- Device online/offline indicator

### Control Panel
- Toggle water sprinkler ON/OFF
- Toggle buzzer alarm ON/OFF
- Acknowledge fire alarms
- View current system status

### Charts
- Historical data visualization
- Time range selection (6 hours, 24 hours, 7 days)
- Charts for AQI, Temperature, Humidity, Noise, PM2.5, PM10

### Settings
- Dark mode toggle
- Alert thresholds configuration
- Emergency contacts management
- Air quality streak display
- Account management

## Troubleshooting

### Common Issues

1. **"Firebase not initialized"**
   - Ensure `Firebase.initializeApp()` is called in `main.dart`
   - Check Firebase configuration files are in place

2. **"Permission denied"**
   - Verify database rules in Firebase Console
   - Check user is authenticated

3. **"No data showing"**
   - Verify ESP32 is sending data to Firebase
   - Check device ID matches (`ESP32_001` by default)
   - Verify database structure matches expected format

4. **Notifications not working**
   - Check FCM setup in Firebase Console
   - Verify device permissions
   - Check notification service initialization

## Next Steps

1. Connect your ESP32 device
2. Configure device ID if different from `ESP32_001`
3. Set up Firebase Cloud Functions for automated alerts
4. Customize thresholds in Settings
5. Add emergency contacts

## Support

For issues or questions:
- Check `FIREBASE_SETUP.md` for Firebase configuration
- Review `README.md` for project overview
- Check Flutter and Firebase documentation

