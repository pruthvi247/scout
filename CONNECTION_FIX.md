# 🔧 Quick Fix: Connection Refused Error

## You're seeing this error because:

The app is trying to connect to `localhost:8000` but your device/emulator can't reach it.

## ✅ Quick Solution

### Option 1: Update API URL (Recommended)

**Edit this file:** `lib/core/config/app_config.dart`

**Find this line:**

```dart
static const String current = androidEmulator;
```

**Make sure it matches your setup:**

#### Running on Android Emulator? ✅

```dart
static const String current = androidEmulator;  // Uses http://10.0.2.2:8000
```

#### Running on iOS Simulator?

```dart
static const String current = iosSimulator;  // Uses http://localhost:8000
```

#### Running on Physical Device?

1. **Find your computer's IP address:**

   ```bash
   # On macOS/Linux
   ifconfig | grep "inet "

   # On Windows
   ipconfig
   ```

   Look for something like `192.168.1.100` or `10.0.0.50`

2. **Update the IP in `app_config.dart`:**

   ```dart
   static const String physicalDevice = 'http://YOUR_IP_HERE:8000';  // e.g., 'http://192.168.1.100:8000'
   static const String current = physicalDevice;
   ```

3. **Make sure your phone and computer are on the SAME WiFi network!**

### Option 2: Verify Backend is Running

1. **Start your backend:**

   ```bash
   cd scout-pms  # Your backend directory
   uvicorn app.main:app --reload
   ```

2. **Test in browser:**
   - Open: `http://localhost:8000/api/docs`
   - You should see FastAPI Swagger UI

### After Making Changes

1. **Hot reload** or **restart** the app:

   ```bash
   # In terminal where flutter run is running, press:
   r  # for hot reload
   R  # for hot restart
   ```

2. **Try logging in again**

## 🎯 Visual Guide

Now when you open the login screen, you'll see an **orange banner at the top** showing which API URL the app is using. This helps you verify the configuration!

Example:

```
┌─────────────────────────────────────┐
│ ℹ️ API: http://10.0.2.2:8000       │  ← This banner
├─────────────────────────────────────┤
│                                     │
│         SCOUT-PMS                   │
│   Political Management System       │
│                                     │
└─────────────────────────────────────┘
```

## 📋 Checklist

- [ ] Backend is running (`uvicorn app.main:app --reload`)
- [ ] Can access `http://localhost:8000/api/docs` in browser
- [ ] Updated `app_config.dart` with correct URL for your platform
- [ ] Restarted/hot reloaded the app
- [ ] If on physical device: phone and computer on same WiFi
- [ ] If on physical device: firewall allows port 8000

## Still stuck?

See the full guide: [NETWORK_SETUP.md](NETWORK_SETUP.md)

## Common Platform URLs

| Where you're running | What to use in app_config.dart                |
| -------------------- | --------------------------------------------- |
| Android Emulator     | `current = androidEmulator`                   |
| iOS Simulator        | `current = iosSimulator`                      |
| Physical Phone       | `current = physicalDevice` (update IP first!) |
| Production           | `current = production`                        |
