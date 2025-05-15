import 'package:flutter/material.dart';
import 'theme.dart'; // Import the theme file

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme =>
      _isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

  void toggleTheme(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
