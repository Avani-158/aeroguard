# Fix Firebase Web Configuration

## 🔧 Quick Fix Steps

### Step 1: Add Web App in Firebase Console

1. **Go to:** https://console.firebase.google.com/
2. **Select your project:** `iot-air-quality-monitor`
3. **Click the Web icon** (</>) or "Add app" → Web
4. **Register your app:**
   - App nickname: `IoT Air Quality Monitor Web`
   - **Don't check** "Also set up Firebase Hosting" (unless you want it)
5. **Click "Register app"**
6. **Copy the Firebase configuration** - You'll see something like:
   ```javascript
   const firebaseConfig = {
     apiKey: "AIza...",
     authDomain: "your-project.firebaseapp.com",
     databaseURL: "https://your-project.firebaseio.com",
     projectId: "your-project-id",
     storageBucket: "your-project.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123456789:web:abcdef"
   };
   ```
7. **Click "Continue to console"**

### Step 2: Get Your Firebase Config Values

After adding the web app, note these values from the config:
- `apiKey`
- `authDomain`
- `databaseURL`
- `projectId`
- `storageBucket`
- `messagingSenderId`
- `appId`

You can also find them later in:
- Firebase Console → Project Settings → Your apps → Web app

### Step 3: Update the Code

I'll update the code to use these values. Just provide the config values or I can set it up to read from environment variables.

## 🚀 Alternative: Use FlutterFire CLI (Recommended)

If you have Node.js installed, we can use FlutterFire CLI to auto-configure:

```powershell
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

This will automatically:
- Detect your Firebase project
- Generate firebase_options.dart
- Configure all platforms (web, Android, iOS)

## 📝 Manual Configuration

If you prefer manual setup, I can update the code to accept Firebase config. Just share your Firebase config values from Step 1.


