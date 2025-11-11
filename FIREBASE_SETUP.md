# Firebase Setup Guide

This guide will help you set up Firebase for the IoT Air Quality Monitor app.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name (e.g., "iot-air-quality-monitor")
   - Enable/disable Google Analytics (optional)
   - Click "Create project"

## Step 2: Add Android App

1. In Firebase Console, click the Android icon (or "Add app")
2. Enter package name: `com.example.iot_air_purifier` (or your custom package)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Add to `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
6. Add to `android/app/build.gradle` (at the bottom):
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## Step 3: Add iOS App

1. In Firebase Console, click the iOS icon
2. Enter bundle ID: `com.example.iotAirPurifier` (or your custom bundle ID)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Right-click `Runner` folder → "Add Files to Runner"
7. Select `GoogleService-Info.plist` and check "Copy items if needed"

## Step 4: Enable Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider
3. Enable **Google** provider:
   - Add your OAuth 2.0 client IDs (from Google Cloud Console)
   - For iOS: Add your iOS bundle ID
   - For Android: Add your SHA-1 fingerprint

### Getting SHA-1 Fingerprint (Android)

```bash
# Windows
cd android
gradlew signingReport

# Mac/Linux
cd android
./gradlew signingReport
```

Look for `SHA1:` in the output and add it to Firebase Console.

## Step 5: Set Up Realtime Database

1. In Firebase Console, go to **Realtime Database**
2. Click "Create Database"
3. Choose location (closest to your users)
4. Start in **test mode** (for development) or **locked mode** (for production)
5. Copy the database URL (e.g., `https://your-project.firebaseio.com`)

### Database Rules (for production)

```json
{
  "rules": {
    "devices": {
      "$deviceId": {
        ".read": "auth != null",
        ".write": "auth != null"
      }
    },
    "users": {
      "$userId": {
        ".read": "$userId === auth.uid",
        ".write": "$userId === auth.uid"
      }
    }
  }
}
```

## Step 6: Enable Cloud Messaging (FCM)

1. In Firebase Console, go to **Cloud Messaging**
2. For Android: No additional setup needed
3. For iOS:
   - Upload your APNs Authentication Key or Certificate
   - Go to Project Settings → Cloud Messaging → iOS app configuration

## Step 7: Update Flutter Code

Update `lib/services/firebase_service.dart` with your database URL if needed:

```dart
final DatabaseReference _database = FirebaseDatabase.instanceFor(
  app: Firebase.app(),
  databaseURL: 'https://your-project.firebaseio.com',
).ref();
```

## Step 8: Test Connection

1. Run the app: `flutter run`
2. Sign up with email/password
3. Check Firebase Console → Authentication → Users (should see your user)
4. Check Realtime Database (should see data structure)

## ESP32 Integration

Your ESP32 should send data to Firebase Realtime Database. Example using HTTP:

```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
const char* firebaseURL = "https://your-project.firebaseio.com";
const char* authToken = "YOUR_FIREBASE_AUTH_TOKEN";

void setup() {
  Serial.begin(115200);
  WiFi.begin(ssid, password);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(firebaseURL + "/devices/ESP32_001.json?auth=" + authToken);
    http.addHeader("Content-Type", "application/json");
    
    StaticJsonDocument<200> doc;
    doc["aqi"] = 95;
    doc["temperature"] = 28.3;
    doc["humidity"] = 65;
    doc["pm2_5"] = 35;
    doc["pm10"] = 45;
    doc["noise"] = 60;
    doc["smoke"] = false;
    doc["fire"] = false;
    doc["sprinkler"] = "off";
    doc["buzzer"] = "off";
    doc["timestamp"] = "2025-01-19T12:30:00Z";
    doc["online"] = true;
    
    String jsonString;
    serializeJson(doc, jsonString);
    
    int httpResponseCode = http.PUT(jsonString);
    
    if (httpResponseCode > 0) {
      Serial.println("Data sent successfully");
    } else {
      Serial.println("Error sending data");
    }
    
    http.end();
  }
  
  delay(5000); // Send data every 5 seconds
}
```

## Troubleshooting

- **"FirebaseApp not initialized"**: Make sure `Firebase.initializeApp()` is called before using Firebase services
- **"Permission denied"**: Check database rules and authentication
- **Notifications not working**: Verify FCM setup and check device permissions
- **Google Sign-In not working**: Verify OAuth client IDs and SHA-1 fingerprint

## Security Notes

- Never commit `google-services.json` or `GoogleService-Info.plist` to public repositories
- Use environment variables for sensitive data
- Set up proper database rules for production
- Use Firebase App Check for additional security

