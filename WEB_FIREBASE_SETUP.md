# Firebase Web Setup - Quick Guide

## 🎯 The Problem

Firebase is configured for Android but not for web. You need to add a web app in Firebase Console.

## ✅ Solution: Add Web App to Firebase

### Step 1: Go to Firebase Console
1. Open: https://console.firebase.google.com/
2. Select your project: **iot-air-quality-monitor**

### Step 2: Add Web App
1. Click the **Web icon** (</>) or click **"Add app"** → **Web**
2. **App nickname:** `IoT Air Quality Monitor Web`
3. **Don't check** "Also set up Firebase Hosting" (unless you want it)
4. Click **"Register app"**

### Step 3: Get Configuration
After registering, you'll see Firebase configuration. You need these values:
- `apiKey`
- `authDomain` 
- `databaseURL`
- `projectId`
- `storageBucket`
- `messagingSenderId`
- `appId`

**OR** you can find them later:
- Firebase Console → **Project Settings** (gear icon)
- Scroll to **"Your apps"** section
- Click on your **Web app**
- You'll see the config values

### Step 4: Share Config Values
Once you have the config values, I can update the code automatically.

## 🔄 Alternative: Quick Test Without Full Config

For now, I've updated the code to try initializing with placeholder values. After you add the web app, we'll update with your actual values.

## 📋 What You Need

After adding web app in Firebase Console, get these values:
1. `apiKey` - from Firebase config
2. `projectId` - your project ID
3. `authDomain` - usually `your-project.firebaseapp.com`
4. `databaseURL` - your Realtime Database URL
5. `storageBucket` - usually `your-project.appspot.com`
6. `messagingSenderId` - from config
7. `appId` - from config

## 🚀 After Setup

Once you add the web app and share the config values, I'll update the code and the app will work!

---

**Quick Action:** Go to Firebase Console → Add Web App → Share the config values with me!


