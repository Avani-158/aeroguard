# Quick Run Guide - Fix Flutter PATH Issue

## 🚨 Problem: "flutter is not recognized"

This happens when Flutter is not in your PATH for the current terminal session.

## ✅ Quick Fix (Run These Commands)

Copy and paste these commands **one by one** in your PowerShell:

### Step 1: Add Flutter to PATH (for this session)
```powershell
$env:PATH += ";D:\flutter_windows_3.35.7-stable\flutter\bin"
```

### Step 2: Verify Flutter works
```powershell
flutter --version
```

### Step 3: Navigate to project and run
```powershell
cd "D:\iot air purifier"
flutter run -d chrome
```

## 🔄 All-in-One Command

Or run this single command:
```powershell
$env:PATH += ";D:\flutter_windows_3.35.7-stable\flutter\bin"; cd "D:\iot air purifier"; flutter run -d chrome
```

## 📋 Step-by-Step Instructions

1. **Open PowerShell** (or use your current terminal)
2. **Copy and paste this first:**
   ```powershell
   $env:PATH += ";D:\flutter_windows_3.35.7-stable\flutter\bin"
   ```
3. **Press Enter**
4. **Then run:**
   ```powershell
   cd "D:\iot air purifier"
   flutter run -d chrome
   ```

## ⚠️ Important Notes

- This fix is **temporary** - only works for the current terminal session
- If you close the terminal, you'll need to run the PATH command again
- For permanent fix, see below

## 🔧 Permanent Fix (Recommended)

To make Flutter work in all terminals:

1. **Press `Win + R`**
2. **Type:** `sysdm.cpl` and press Enter
3. **Click "Advanced" tab**
4. **Click "Environment Variables"**
5. **Under "User variables", find "Path"**
6. **Click "Edit"**
7. **Click "New"**
8. **Add:** `D:\flutter_windows_3.35.7-stable\flutter\bin`
9. **Click "OK" on all dialogs**
10. **Close ALL terminal windows**
11. **Open a NEW PowerShell**
12. **Test:** `flutter --version`

After this, Flutter will work in all new terminal windows!

## 🎯 Quick Test

After adding to PATH, test with:
```powershell
flutter --version
```

Should show: `Flutter 3.35.7` or similar version number.

## 💡 Alternative: Use Full Path

If you don't want to modify PATH, you can use the full path:
```powershell
& "D:\flutter_windows_3.35.7-stable\flutter\bin\flutter.bat" run -d chrome
```

But adding to PATH is much easier!


