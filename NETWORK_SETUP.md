# Network Configuration Guide

## Connection Refused Error?

If you're seeing "Connection refused" errors, the app can't reach your backend API. This guide will help you fix it.

## Quick Fix

1. **Open** `lib/core/config/app_config.dart`
2. **Change** the `current` constant based on where you're running the app:

```dart
// For Android Emulator
static const String current = androidEmulator;

// For iOS Simulator
static const String current = iosSimulator;

// For Physical Device
static const String current = physicalDevice;
```

## Detailed Setup by Platform

### 🤖 Android Emulator

**No changes needed!** The default configuration uses `http://10.0.2.2:8000`.

- `10.0.2.2` is a special alias that Android Emulator uses to refer to your host machine's `localhost`
- Your backend should be running on `http://localhost:8000` on your computer

### 🍎 iOS Simulator

**Change to iOS Simulator configuration:**

```dart
static const String current = iosSimulator;
```

- iOS Simulator can access `localhost` directly
- Your backend should be running on `http://localhost:8000`

### 📱 Physical Device (Android/iOS)

**You need your computer's local IP address:**

#### Step 1: Find Your Computer's IP

**On macOS/Linux:**

```bash
ifconfig
# or
ip addr show
```

Look for `inet` address like `192.168.1.100` or `10.0.0.50`

**On Windows:**

```bash
ipconfig
```

Look for `IPv4 Address` like `192.168.1.100`

#### Step 2: Update the Configuration

In `lib/core/config/app_config.dart`:

```dart
static const String physicalDevice = 'http://YOUR_IP:8000'; // e.g., 'http://192.168.1.100:8000'
static const String current = physicalDevice;
```

#### Step 3: Ensure Same Network

- Your phone/tablet and computer must be on the **same WiFi network**
- Check firewall settings - port 8000 must be accessible

### 🚀 Production

When deploying to production:

```dart
static const String production = 'https://your-api-domain.com';
static const String current = production;
```

## Testing the Connection

### 1. Verify Backend is Running

Open your browser and visit:

- Android Emulator: `http://10.0.2.2:8000/api/docs`
- iOS Simulator: `http://localhost:8000/api/docs`
- Physical Device: `http://YOUR_IP:8000/api/docs`

You should see the FastAPI Swagger documentation.

### 2. Test from Terminal

**From your computer:**

```bash
curl http://localhost:8000/api/auth/me
```

**From Android Emulator (using adb):**

```bash
adb shell curl http://10.0.2.2:8000/api/auth/me
```

### 3. Run the App

After updating the configuration:

```bash
flutter run
```

## Common Issues

### ❌ "Connection refused"

- **Cause**: Backend not running or wrong URL
- **Fix**:
  1. Start your backend: `uvicorn app.main:app --reload`
  2. Check you're using the correct URL for your platform

### ❌ "Connection timeout"

- **Cause**: Firewall blocking connection or wrong IP
- **Fix**:
  1. Check firewall settings
  2. Verify your IP address is correct
  3. Ensure devices are on same network

### ❌ "No route to host"

- **Cause**: Devices not on same network
- **Fix**: Connect phone and computer to same WiFi

### ❌ "Certificate verification failed" (HTTPS)

- **Cause**: Self-signed certificate
- **Fix**: For development, you can disable SSL verification (not recommended for production)

## Environment Variables (Advanced)

For production apps, consider using:

- **flutter_dotenv** package
- **--dart-define** flags during build
- **Environment-specific build flavors**

Example with dart-define:

```bash
flutter run --dart-define=API_URL=http://192.168.1.100:8000
```

Then access in code:

```dart
static const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');
```

## Quick Reference

| Platform         | URL                      | Notes                              |
| ---------------- | ------------------------ | ---------------------------------- |
| Android Emulator | `http://10.0.2.2:8000`   | Default, works out of box          |
| iOS Simulator    | `http://localhost:8000`  | Direct localhost access            |
| Physical Device  | `http://YOUR_IP:8000`    | Replace YOUR_IP with computer's IP |
| Production       | `https://api.domain.com` | Use HTTPS in production            |

## Still Not Working?

1. **Check backend logs** - Is it receiving requests?
2. **Check app logs** - What's the exact error?
3. **Test with curl** - Can you reach the API from terminal?
4. **Check network** - Are devices on same WiFi?
5. **Restart everything** - Backend, emulator, and app

## Need Help?

Check the [main documentation](../IMPLEMENTATION.md) or backend [API documentation](../../docs/API-doc.md).
