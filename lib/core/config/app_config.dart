/// Environment configuration for the app
class AppConfig {
  // API Base URLs for different environments

  /// Android Emulator - maps to host machine's localhost
  /// 10.0.2.2 is a special alias that Android Emulator uses to access the host machine
  static const String androidEmulator = 'http://10.0.2.2:8000';

  /// iOS Simulator - can use localhost
  static const String iosSimulator = 'http://localhost:8000';

  /// Physical Device - replace with your computer's local IP
  /// To find your IP:
  /// - macOS/Linux: Run `ifconfig` or `ip addr show`
  /// - Windows: Run `ipconfig`
  /// Look for IPv4 address (e.g., 192.168.1.x or 10.0.0.x)
  static const String physicalDevice = 'http://192.168.1.5:8000';

  /// Production API URL
  static const String production = 'https://api.scoutpms.com';

  /// USB Debugging (adb reverse) - works with phone connected via USB
  static const String usbDebug = 'http://localhost:8000';

  // Current environment - CHANGE THIS based on your setup
  static const String current = physicalDevice;

  /// Helper to get appropriate base URL
  static String getBaseUrl() {
    return current;
  }
}
