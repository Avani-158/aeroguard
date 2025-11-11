# Flutter Installation Troubleshooting Guide

## Step 1: Verify Flutter Installation Location

First, let's find where you extracted Flutter:

1. **Open File Explorer**
2. **Navigate to D:\**
3. **Look for a folder named:**
   - `flutter` (most common)
   - `flutter_windows_xxx` (if you didn't rename it)
   - Any folder containing Flutter files

4. **Inside that folder, you should see:**
   - `bin` folder
   - `packages` folder
   - `README.md`
   - `flutter.bat` should be in the `bin` folder

## Step 2: Verify the Correct Path

The PATH should point to the `bin` folder inside Flutter. For example:

**If Flutter is at:** `D:\flutter\`
**Then PATH should be:** `D:\flutter\bin`

**If Flutter is at:** `D:\flutter_windows_3.24.0-stable\`
**Then PATH should be:** `D:\flutter_windows_3.24.0-stable\bin`

## Step 3: Add Flutter to PATH (Correct Method)

### Method 1: Using System Properties (Recommended)

1. **Press `Win + R`** to open Run dialog
2. **Type:** `sysdm.cpl` and press Enter
3. **Click "Advanced" tab**
4. **Click "Environment Variables"**
5. **Under "User variables" or "System variables", find "Path"**
6. **Click "Edit"**
7. **Click "New"**
8. **Add the path:** `D:\flutter\bin` (or wherever your flutter\bin folder is)
9. **Click "OK" on all dialogs**
10. **IMPORTANT: Close ALL PowerShell/Command Prompt windows**
11. **Open a NEW PowerShell window**
12. **Test:** `flutter --version`

### Method 2: Using PowerShell (Temporary - Only for current session)

```powershell
$env:PATH += ";D:\flutter\bin"
flutter --version
```

This only works for the current PowerShell session. Use Method 1 for permanent setup.

## Step 4: Verify Installation

After adding to PATH and opening a NEW terminal:

```powershell
# Check Flutter version
flutter --version

# Check Flutter installation
flutter doctor
```

## Step 5: Common Issues and Solutions

### Issue 1: "flutter: command not found"

**Solution:**
- Make sure you added `\bin` at the end of the path
- Close and reopen ALL terminal windows
- Verify the path exists: Check if `D:\flutter\bin\flutter.bat` exists

### Issue 2: "Flutter is not recognized"

**Solution:**
- Restart your computer (sometimes needed)
- Verify PATH in a new terminal: `echo $env:PATH`
- Make sure there are no spaces in the path (use quotes if needed)

### Issue 3: PATH added but still not working

**Solution:**
1. Check if you added it to the correct PATH variable (User vs System)
2. Make sure you didn't add it twice with different cases
3. Remove any old/incorrect Flutter paths
4. Restart computer

### Issue 4: Flutter folder has spaces in name

**Solution:**
- Avoid spaces in path: `D:\flutter` ✅
- Not recommended: `D:\My Flutter` ❌
- If you have spaces, use quotes: `"D:\My Flutter\bin"`

## Step 6: Manual Verification

Let's manually check if Flutter files exist:

```powershell
# Check if flutter.bat exists
Test-Path "D:\flutter\bin\flutter.bat"

# List Flutter bin folder contents
Get-ChildItem "D:\flutter\bin" | Select-Object Name
```

If `flutter.bat` doesn't exist, Flutter wasn't extracted correctly.

## Step 7: Re-extract Flutter (If Needed)

If Flutter files are missing:

1. **Download Flutter again:** https://docs.flutter.dev/get-started/install/windows
2. **Extract to:** `D:\flutter` (create this folder first)
3. **Make sure the structure is:**
   ```
   D:\flutter\
   ├── bin\
   │   └── flutter.bat
   ├── packages\
   ├── README.md
   └── ...
   ```
4. **Add to PATH:** `D:\flutter\bin`
5. **Restart terminal**

## Quick Test Commands

Run these in PowerShell to diagnose:

```powershell
# 1. Check if PATH contains flutter
$env:PATH -split ';' | Select-String -Pattern 'flutter'

# 2. Check if flutter.bat exists (adjust path as needed)
Test-Path "D:\flutter\bin\flutter.bat"

# 3. Try running flutter directly with full path
& "D:\flutter\bin\flutter.bat" --version

# 4. Check current directory
Get-Location
```

## Alternative: Use Flutter Without PATH

If PATH still doesn't work, you can use Flutter with full path:

```powershell
# Instead of: flutter --version
# Use: 
& "D:\flutter\bin\flutter.bat" --version

# Or create an alias:
Set-Alias flutter "D:\flutter\bin\flutter.bat"
flutter --version
```

## Still Not Working?

1. **Check Flutter installation:**
   - Where exactly did you extract the ZIP file?
   - What is the full path to the `bin` folder?

2. **Verify PATH:**
   - Open System Properties → Environment Variables
   - Check if `D:\flutter\bin` (or your path) is listed
   - Make sure there are no typos

3. **Try a different terminal:**
   - Use Command Prompt instead of PowerShell
   - Or use Git Bash
   - Or use Windows Terminal

4. **Check for antivirus blocking:**
   - Some antivirus software blocks Flutter
   - Add Flutter folder to exceptions

## Next Steps

Once `flutter --version` works:
1. Run `flutter doctor` to check what else needs to be installed
2. Install Android Studio or VS Code
3. Set up an Android emulator or connect a device
4. Then you can run: `flutter pub get` and `flutter run`

