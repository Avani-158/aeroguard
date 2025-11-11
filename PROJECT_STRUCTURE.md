# Project Structure

## Flutter App Structure

```
lib/
├── main.dart                 # App entry point, Firebase initialization
├── models/                   # Data models
│   ├── device_data.dart      # Device sensor data model
│   └── user_settings.dart   # User settings and preferences
├── services/                 # Backend services
│   ├── auth_service.dart     # Firebase Authentication
│   ├── firebase_service.dart # Firebase Realtime Database operations
│   └── notification_service.dart # FCM push notifications
├── providers/                # State management (Provider pattern)
│   ├── auth_provider.dart    # Authentication state
│   ├── device_provider.dart  # Device data state
│   └── settings_provider.dart # Settings state
├── screens/                  # App screens
│   ├── login_screen.dart     # Login/Signup screen
│   ├── dashboard_screen.dart # Main dashboard with sensors
│   ├── control_panel_screen.dart # Manual controls
│   ├── charts_screen.dart    # Data visualization
│   └── settings_screen.dart  # App settings
└── widgets/                  # Reusable UI components
    ├── aqi_indicator.dart    # AQI display widget
    ├── sensor_card.dart      # Sensor reading card
    ├── control_button.dart   # Control button widget
    └── chart_widget.dart     # Chart visualization widget
```

## Web Dashboard Structure

```
web_dashboard/
├── index.html    # Main HTML file
├── app.js        # JavaScript logic and Firebase integration
└── README.md     # Web dashboard documentation
```

## Configuration Files

- `pubspec.yaml` - Flutter dependencies
- `analysis_options.yaml` - Linting rules
- `.gitignore` - Git ignore rules
- `README.md` - Main project documentation
- `FIREBASE_SETUP.md` - Firebase configuration guide
- `QUICK_START.md` - Quick start instructions

## Key Components

### Models

**DeviceData** (`lib/models/device_data.dart`)
- Represents sensor data from ESP32
- Calculates Air Score (0-100) based on AQI
- Provides AQI category and color coding

**UserSettings** (`lib/models/user_settings.dart`)
- Stores user preferences
- Alert thresholds
- Emergency contacts
- Daily streak tracking

### Services

**AuthService** (`lib/services/auth_service.dart`)
- Email/password authentication
- Google Sign-In
- Password reset

**FirebaseService** (`lib/services/firebase_service.dart`)
- Real-time data streaming
- Device control (sprinkler, buzzer)
- Historical data retrieval
- User settings persistence

**NotificationService** (`lib/services/notification_service.dart`)
- FCM token management
- Push notification handling
- Topic subscriptions

### Providers

**AuthProvider** (`lib/providers/auth_provider.dart`)
- Manages authentication state
- Handles login/logout
- Error handling

**DeviceProvider** (`lib/providers/device_provider.dart`)
- Real-time device data stream
- Control operations (sprinkler, buzzer)
- Historical data fetching

**SettingsProvider** (`lib/providers/settings_provider.dart`)
- Settings persistence
- Theme management
- Threshold configuration
- Daily streak tracking

### Screens

**LoginScreen** - Authentication UI
**DashboardScreen** - Main screen with real-time data
**ControlPanelScreen** - Manual device controls
**ChartsScreen** - Historical data visualization
**SettingsScreen** - App configuration

## Data Flow

1. **ESP32 → Firebase**
   - ESP32 sends sensor data via HTTP/MQTT
   - Data stored in Firebase Realtime Database
   - Structure: `devices/ESP32_001/{sensor_data}`

2. **Firebase → App**
   - App listens to Firebase Realtime Database
   - DeviceProvider updates UI in real-time
   - Charts fetch historical data on demand

3. **App → Firebase**
   - User controls (sprinkler, buzzer) update Firebase
   - ESP32 reads control commands from Firebase
   - Settings saved to Firebase/SharedPreferences

4. **Alerts**
   - Firebase Cloud Functions monitor thresholds
   - Sends FCM push notifications
   - App displays local notifications

## Firebase Database Structure

```
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
      "online": true,
      "history": {
        "timestamp1": { ... },
        "timestamp2": { ... }
      }
    }
  },
  "users": {
    "userId": {
      "settings": {
        "aqiThreshold": 100,
        "smokeThreshold": 50,
        "temperatureThreshold": 35,
        "fireBrigadeContact": "+1234567890",
        "ownerContact": "+1234567890",
        "ownerEmail": "user@example.com",
        "darkMode": false,
        "dailyStreak": 5,
        "lastGoodAirDate": "2025-01-19T00:00:00Z"
      }
    }
  }
}
```

## State Management

Uses Provider pattern for state management:
- `ChangeNotifierProvider` wraps app
- `Consumer` widgets listen to changes
- `notifyListeners()` triggers UI updates

## Theme Support

- Light and dark themes
- Material 3 design
- Theme toggle in settings
- Persisted in SharedPreferences

## Future Enhancements

- Multiple device support
- Voice assistant integration
- Location-based AQI comparison
- Social media sharing
- Email alerts
- Firebase Cloud Functions for automated alerts

