
import 'package:shared_preferences/shared_preferences.dart';

// Class to store app-wide constants and configuration
class Constants {
  // API endpoints
  static late String googleScriptUrl;
  
  // App settings
  static const String appName = 'ACTT Student Registration';
  static const String appVersion = '1.0.0';
  
  // Local storage keys
  static const String prefGoogleScriptUrl = 'google_script_url';
  static const String prefAutoSync = 'auto_sync';
  static const String prefDarkMode = 'dark_mode';
  static const String prefCurrentUser = 'current_user';
  
  // Default values
  static const String defaultGoogleScriptUrl = 'https://script.google.com/macros/s/your-script-id/exec';
  static const bool defaultAutoSync = true;
  static const bool defaultDarkMode = false;
  
  // Initialize constants from shared preferences
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Google Script URL
    googleScriptUrl = prefs.getString(prefGoogleScriptUrl) ?? defaultGoogleScriptUrl;
  }
  
  // Save Google Script URL
  static Future<void> saveGoogleScriptUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefGoogleScriptUrl, url);
    googleScriptUrl = url;
  }
  
  // Get auto-sync setting
  static Future<bool> getAutoSync() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefAutoSync) ?? defaultAutoSync;
  }
  
  // Save auto-sync setting
  static Future<void> saveAutoSync(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefAutoSync, value);
  }
  
  // Get dark mode setting
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefDarkMode) ?? defaultDarkMode;
  }
  
  // Save dark mode setting
  static Future<void> saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefDarkMode, value);
  }
  
  // Education level options
  static const List<String> educationLevels = [
    'Primary School',
    'Middle School',
    'High School',
    'College',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'Doctorate',
    'Other',
  ];
  
  // Gender options
  static const List<String> genders = [
    'Male',
    'Female',
    'Other',
  ];
  
  // Course durations in days
  static const Map<String, int> courseDurations = {
    'Short': 30,
    'Standard': 90,
    'Extended': 180,
    'Custom': 0,
  };
}