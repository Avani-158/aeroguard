# Add Flutter to PATH Permanently

## Your Flutter Path
**Correct PATH to add:** `D:\flutter_windows_3.35.7-stable\flutter\bin`

## Steps to Add to PATH Permanently

1. **Press `Win + R`** (Windows key + R)
2. **Type:** `sysdm.cpl` and press Enter
3. **Click the "Advanced" tab**
4. **Click "Environment Variables"** button
5. **Under "User variables"** (top section), find **"Path"**
6. **Click "Edit"**
7. **Click "New"**
8. **Add this exact path:** `D:\flutter_windows_3.35.7-stable\flutter\bin`
9. **Click "OK"** on all dialogs
10. **IMPORTANT:** Close ALL PowerShell/Command Prompt windows
11. **Open a NEW PowerShell window**
12. **Test:** Type `flutter --version`

## Verify It Works

After adding to PATH and opening a new terminal:

```powershell
flutter --version
flutter doctor
```

## Current Status

✅ Flutter is installed and working
✅ Flutter version: 3.35.7
✅ Chrome is available (can run web version)
⚠️ Android Studio not installed (needed for Android development)
⚠️ Visual Studio needs C++ components (for Windows apps)

## Next Steps

### Option 1: Run on Web (Easiest - No Android Studio needed)
```powershell
cd "D:\iot air purifier"
flutter pub get
flutter run -d chrome
```

### Option 2: Install Android Studio (For Android development)
1. Download from: https://developer.android.com/studio
2. Install Android Studio
3. Open it and let it install Android SDK
4. Then you can run: `flutter run` (on Android emulator or device)

## Quick Test (Current Session Only)

For now, you can test in this PowerShell session:

```powershell
# Already added for this session
flutter --version  # Should work now

# Navigate to project
cd "D:\iot air purifier"

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome
```

