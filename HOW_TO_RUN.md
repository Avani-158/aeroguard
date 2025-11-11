# How to Run the IoT Air Quality Monitor App

## Step 1: Install Flutter

### For Windows:

1. **Download Flutter SDK**
   - Go to https://flutter.dev/docs/get-started/install/windows
   - Download the latest Flutter SDK (ZIP file)
   - Extract to a location like `C:\src\flutter` (avoid spaces in path)

2. **Add Flutter to PATH**
   - Open "Environment Variables" in Windows
   - Add `C:\src\flutter\bin` to your PATH
   - Restart your terminal/PowerShell

3. **Verify Installation**
   ```bash
   flutter --version
   flutter doctor
   ```

4. **Install Additional Tools** (if needed)
   - Android Studio (for Android development)
   - VS Code or Android Studio (as IDE)
   - Chrome (for web testing)

### For Mac:

1. **Download Flutter SDK**
   ```bash
   cd ~/development
   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.x.x-stable.zip
   unzip flutter_macos_arm64_3.x.x-stable.zip
   ```

2. **Add to PATH**
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

3. **Verify Installation**
   ```bash
   flutter --version
   flutter doctor
   ```

### For Linux:

1. **Download Flutter SDK**
   ```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.x.x-stable.tar.xz
   tar xf flutter_linux_3.x.x-stable.tar.xz
   ```

2. **Add to PATH**
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Step 2: Install Dependencies

Navigate to your project directory and install Flutter packages:

```bash
cd "D:\iot air purifier"
flutter pub get
```

This will download all required packages listed in `pubspec.yaml`.

## Step 3: Set Up Firebase (Required)

Before running the app, you **must** set up Firebase:

1. **Create Firebase Project**
   - Go to https://console.firebase.google.com/
   - Create a new project

2. **Add Android App**
   - In Firebase Console, add Android app
   - Package name: `com.example.iot_air_purifier` (or customize)
   - Download `google-services.json`
   - Place it in: `android/app/google-services.json`

3. **Add iOS App** (if developing for iOS)
   - Add iOS app in Firebase Console
   - Download `GoogleService-Info.plist`
   - Place it in: `ios/Runner/GoogleService-Info.plist`

4. **Enable Services**
   - Authentication → Enable Email/Password and Google Sign-In
   - Realtime Database → Create database
   - Cloud Messaging → Enable FCM

**See `FIREBASE_SETUP.md` for detailed instructions.**

## Step 4: Check Available Devices

List available devices/emulators:

```bash
flutter devices
```

You should see:
- Connected physical devices
- Available emulators
- Chrome (for web)

## Step 5: Run the App

### Option A: Run on Android Emulator

1. **Start Android Studio**
2. **Open AVD Manager** (Tools → Device Manager)
3. **Create/Start an emulator**
4. **Run the app:**
   ```bash
   flutter run
   ```

### Option B: Run on Physical Device

**For Android:**
1. Enable Developer Options on your phone
2. Enable USB Debugging
3. Connect phone via USB
4. Run:
   ```bash
   flutter run
   ```

**For iOS (Mac only):**
1. Connect iPhone via USB
2. Trust the computer on your iPhone
3. Run:
   ```bash
   flutter run -d ios
   ```

### Option C: Run on Web (for testing)

```bash
flutter run -d chrome
```

Note: Web support is experimental and some Firebase features may not work.

## Step 6: Build for Release

### Android APK:
```bash
flutter build apk
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store):
```bash
flutter build appbundle
```

### iOS (Mac only):
```bash
flutter build ios
```

## Troubleshooting

### "Flutter command not found"
- Make sure Flutter is added to PATH
- Restart your terminal
- Verify with: `flutter --version`

### "No devices found"
- For Android: Start an emulator or connect a device
- For iOS: Connect an iPhone or start iOS Simulator
- Check with: `flutter devices`

### "Firebase not initialized" error
- Make sure Firebase configuration files are in place
- Verify `Firebase.initializeApp()` is called in `main.dart`
- Check Firebase setup in `FIREBASE_SETUP.md`

### "Package not found" errors
```bash
flutter clean
flutter pub get
flutter run
```

### Build errors
```bash
# Clean build
flutter clean

# Get dependencies again
flutter pub get

# Try running again
flutter run
```

### Android build errors
- Make sure Android SDK is installed
- Check `android/local.properties` has correct SDK path
- Run `flutter doctor` to check Android setup

### iOS build errors (Mac only)
- Make sure Xcode is installed
- Run: `sudo xcode-select --switch /Applications/Xcode.app`
- Run: `flutter doctor` to check iOS setup

## Quick Test Without ESP32

You can test the app by manually adding data to Firebase:

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

## Development Tips

- **Hot Reload**: Press `r` in terminal while app is running
- **Hot Restart**: Press `R` in terminal
- **Quit**: Press `q` in terminal
- **View Logs**: Check terminal output or use `flutter logs`

## Next Steps

1. ✅ Install Flutter
2. ✅ Run `flutter pub get`
3. ✅ Set up Firebase
4. ✅ Run `flutter run`
5. ✅ Connect ESP32 device
6. ✅ Configure device ID if different from `ESP32_001`

For more details, see:
- `FIREBASE_SETUP.md` - Firebase configuration
- `QUICK_START.md` - Quick start guide
- `README.md` - Project overview

