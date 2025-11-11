# How to Run the App

## 🚀 Quick Command

```powershell
cd "D:\iot air purifier"
$env:PATH += ";D:\flutter_windows_3.35.7-stable\flutter\bin"
flutter run -d chrome
```

## 📋 Step by Step

1. **Open PowerShell**
2. **Navigate to project:**
   ```powershell
   cd "D:\iot air purifier"
   ```

3. **Add Flutter to PATH (if not already added permanently):**
   ```powershell
   $env:PATH += ";D:\flutter_windows_3.35.7-stable\flutter\bin"
   ```

4. **Run the app:**
   ```powershell
   flutter run -d chrome
   ```

## ⏱️ What to Expect

- **First time:** Takes 1-3 minutes to compile
- **Subsequent runs:** Faster (30-60 seconds)
- **Chrome opens automatically** when ready
- **Or look for URL** in terminal like: `http://localhost:xxxxx`

## 🔄 Alternative: Run Web Dashboard

If you want to run the simple HTML dashboard instead:

1. **Navigate to web_dashboard folder:**
   ```powershell
   cd "D:\iot air purifier\web_dashboard"
   ```

2. **Use any web server:**
   ```powershell
   # Option 1: Python
   python -m http.server 8000
   
   # Option 2: Node.js
   npx http-server -p 8000
   
   # Option 3: PHP
   php -S localhost:8000
   ```

3. **Open in browser:**
   ```
   http://localhost:8000
   ```

## 🐛 Troubleshooting

### "flutter is not recognized"
**Fix:**
```powershell
$env:PATH += ";D:\flutter_windows_3.35.7-stable\flutter\bin"
```

### App doesn't open
- Wait 1-2 minutes for compilation
- Check terminal for URL
- Look for errors in terminal

### Firebase errors
- Make sure web app is added in Firebase Console
- Check `android/app/google-services.json` exists

## ✅ Quick All-in-One Command

```powershell
$env:PATH += ";D:\flutter_windows_3.35.7-stable\flutter\bin"; cd "D:\iot air purifier"; flutter run -d chrome
```


