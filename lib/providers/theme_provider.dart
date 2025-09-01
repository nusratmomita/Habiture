// manages light/dark mode state and remembers the choice using SharedPreferences (local storage on the device)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    loadTheme();// constructor calls loadTheme() to restore the saved theme when the app starts.
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    saveTheme();
    notifyListeners();
  }

  // Loading Theme from Storage
  /* Reads the saved theme setting from SharedPreferences.
  If nothing is saved yet, defaults to false (light mode).
  Notifies the UI once the value is loaded.*/
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // SSaving Theme to Storage
  // Stores the current theme choice (true or false) so it persists between app launches.
  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
  }
}

// This class is a state manager for app theme:

// Switches between light/dark mode.

// Persists the setting using SharedPreferences.

// Notifies UI to rebuild when the theme changes.
