# Firebase Setup - Step by Step Guide

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com/
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `iot-air-quality-monitor` (or any name you prefer)
4. Click **"Continue"**
5. **Disable Google Analytics** (optional, you can enable later)
6. Click **"Create project"**
7. Wait for project creation (takes ~30 seconds)
8. Click **"Continue"**

## Step 2: Add Android App

1. In Firebase Console, click the **Android icon** (or "Add app" → Android)
2. **Android package name:** `com.example.iot_air_purifier`
   - This must match your Flutter app's package name
3. **App nickname (optional):** `IoT Air Quality Monitor`
4. **Debug signing certificate SHA-1 (optional):** Leave blank for now
5. Click **"Register app"**
6. **Download `google-services.json`**
   - Click the download button
   - Save the file
7. **Place the file:**
   - Copy `google-services.json` to: `android/app/google-services.json`
   - Create the `android/app` folder if it doesn't exist
8. Click **"Next"** (skip the next steps for now)
9. Click **"Continue to console"**

## Step 3: Add iOS App (Optional - for iOS development)

1. Click the **iOS icon** (or "Add app" → iOS)
2. **iOS bundle ID:** `com.example.iotAirPurifier`
3. **App nickname:** `IoT Air Quality Monitor iOS`
4. Click **"Register app"**
5. **Download `GoogleService-Info.plist`**
6. **Place the file:**
   - Copy to: `ios/Runner/GoogleService-Info.plist`
7. Click **"Continue to console"**

## Step 4: Enable Authentication

1. In Firebase Console, go to **"Authentication"** (left sidebar)
2. Click **"Get started"**
3. Go to **"Sign-in method"** tab
4. **Enable Email/Password:**
   - Click on "Email/Password"
   - Toggle "Enable" to ON
   - Click "Save"
5. **Enable Google Sign-In (Optional):**
   - Click on "Google"
   - Toggle "Enable" to ON
   - Enter support email
   - Click "Save"

## Step 5: Create Realtime Database

1. In Firebase Console, go to **"Realtime Database"** (left sidebar)
2. Click **"Create Database"**
3. **Choose location:** Select closest to your region
4. **Security rules:** Choose **"Start in test mode"** (for development)
   - ⚠️ **Important:** Change to production rules later!
5. Click **"Enable"**
6. **Copy the database URL** (looks like: `https://your-project.firebaseio.com`)

## Step 6: Enable Cloud Messaging (FCM)

1. In Firebase Console, go to **"Cloud Messaging"** (left sidebar)
2. No additional setup needed for basic use
3. For iOS (if using): You'll need to upload APNs certificate later

## Step 7: Update Android Configuration

1. **Edit `android/build.gradle`:**
   - Add to `dependencies` section:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
       // ... other dependencies
   }
   ```

2. **Edit `android/app/build.gradle`:**
   - Add at the bottom of the file:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## Step 8: Update Flutter Code (if needed)

The code should already be set up, but verify:
- `lib/main.dart` has `Firebase.initializeApp()`
- Firebase services are properly imported

## Step 9: Test the Setup

1. Run: `flutter pub get`
2. Run: `flutter run -d chrome` (or your device)
3. Try to sign up/login
4. Check Firebase Console → Authentication → Users (should see your user)

## Step 10: Database Rules (Important for Production)

Go to Realtime Database → Rules and update:

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

## Troubleshooting

- **"Firebase not initialized"**: Make sure `google-services.json` is in `android/app/`
- **"Permission denied"**: Check database rules and authentication
- **Build errors**: Run `flutter clean` then `flutter pub get`

