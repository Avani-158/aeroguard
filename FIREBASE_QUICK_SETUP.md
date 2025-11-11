# Firebase Quick Setup Guide

## ✅ What's Already Done

- ✅ Android project structure created
- ✅ Android build files configured for Firebase
- ✅ Flutter dependencies installed
- ✅ Code ready for Firebase integration

## 📋 What You Need to Do

### Step 1: Create Firebase Project

1. Go to: **https://console.firebase.google.com/**
2. Click **"Add project"** or **"Create a project"**
3. **Project name:** `iot-air-quality-monitor` (or any name)
4. Click **"Continue"**
5. **Disable Google Analytics** (optional)
6. Click **"Create project"**
7. Wait ~30 seconds, then click **"Continue"**

### Step 2: Add Android App

1. In Firebase Console, click the **Android icon** (🟢)
2. **Android package name:** `com.example.iot_air_purifier`
   - ⚠️ **IMPORTANT:** Use this exact package name!
3. **App nickname:** `IoT Air Quality Monitor` (optional)
4. **Debug signing certificate SHA-1:** Leave blank for now
5. Click **"Register app"**
6. **Download `google-services.json`**
   - Click the download button
   - Save the file to your Downloads folder
7. **Copy the file:**
   - Copy `google-services.json` from Downloads
   - Paste it into: `android/app/google-services.json`
   - ✅ Create the `android/app` folder if needed (it should already exist)
8. Click **"Next"** → **"Next"** → **"Continue to console"**

### Step 3: Enable Authentication

1. In Firebase Console, click **"Authentication"** (left sidebar)
2. Click **"Get started"** (if first time)
3. Go to **"Sign-in method"** tab
4. **Enable Email/Password:**
   - Click on **"Email/Password"**
   - Toggle **"Enable"** to **ON**
   - Click **"Save"**
5. **Enable Google Sign-In (Optional):**
   - Click on **"Google"**
   - Toggle **"Enable"** to **ON**
   - Enter your support email
   - Click **"Save"**

### Step 4: Create Realtime Database

1. In Firebase Console, click **"Realtime Database"** (left sidebar)
2. Click **"Create Database"**
3. **Choose location:** Select closest to your region (e.g., `us-central1`)
4. **Security rules:** Choose **"Start in test mode"** ⚠️
   - This allows read/write for development
   - **Change to production rules later!**
5. Click **"Enable"**
6. **Note the database URL** (looks like: `https://your-project-id.firebaseio.com`)

### Step 5: Enable Cloud Messaging (FCM)

1. In Firebase Console, click **"Cloud Messaging"** (left sidebar)
2. No additional setup needed for Android
3. The app will automatically get FCM token

### Step 6: Update Database Rules (Important!)

1. Go to **Realtime Database** → **Rules** tab
2. Replace the rules with:

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

3. Click **"Publish"**

### Step 7: Test the Setup

1. **Verify `google-services.json` is in place:**
   ```powershell
   Test-Path "android\app\google-services.json"
   ```
   Should return: `True`

2. **Run the app:**
   ```powershell
   flutter clean
   flutter pub get
   flutter run -d chrome
   ```

3. **Test sign up:**
   - Try creating an account with email/password
   - Check Firebase Console → Authentication → Users
   - You should see your new user!

## 📁 File Locations

- ✅ `android/app/google-services.json` ← **Place your downloaded file here**
- ✅ `android/app/build.gradle.kts` ← Already configured
- ✅ `android/settings.gradle.kts` ← Already configured

## 🔍 Verify Setup

After placing `google-services.json`, verify:

```powershell
# Check if file exists
Test-Path "android\app\google-services.json"

# Should return: True
```

## 🚨 Common Issues

### Issue: "google-services.json not found"
**Solution:** Make sure the file is at `android/app/google-services.json` (not `android/google-services.json`)

### Issue: "Firebase not initialized"
**Solution:** 
1. Check `google-services.json` is in correct location
2. Run `flutter clean`
3. Run `flutter pub get`
4. Try again

### Issue: "Permission denied" in database
**Solution:** 
1. Check database rules (should allow auth users)
2. Make sure you're signed in to the app
3. Verify authentication is enabled in Firebase Console

### Issue: Build errors
**Solution:**
```powershell
flutter clean
flutter pub get
flutter run
```

## ✅ Checklist

- [ ] Firebase project created
- [ ] Android app added with package: `com.example.iot_air_purifier`
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] Authentication enabled (Email/Password)
- [ ] Realtime Database created
- [ ] Database rules updated
- [ ] Cloud Messaging enabled
- [ ] App tested and working

## 🎯 Next Steps

After Firebase is set up:
1. Test the app: `flutter run -d chrome`
2. Sign up with email/password
3. Check Firebase Console to see your user
4. Connect your ESP32 device to send data

## 📞 Need Help?

- See `FIREBASE_SETUP.md` for detailed instructions
- Check Firebase Console for any errors
- Verify all files are in correct locations

