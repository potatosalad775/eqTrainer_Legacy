import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _storage = GetStorage();
  // true - dark, false - light, null(empty) - follow system
  final _isDarkModeKey = 'isDARKMODE';
  final _isDarkModeSystemKey = 'isDARKMODE_SYSTEM';

  // does Dark Mode follow system setting - if it's empty, return true
  bool _isDarkModeSystem() => _storage.read(_isDarkModeSystemKey) ?? true;
  // is Dark Mode - if it's empty, return false
  bool _isDarkMode() => _storage.read(_isDarkModeKey) ?? false;

  // Return actual ThemeMode from _loadThemeData.
  ThemeMode get theme => _isDarkModeSystem()
      // if it follows the system setting...
      ? ThemeMode.system
      // if it isn't,
      : (_isDarkMode()
        ? ThemeMode.dark
        : ThemeMode.light);

  // Return String value of current Theme Mode
  String get themeString => _isDarkModeSystem()
      ? 'DARKMODE_SYSTEM'
      : (_isDarkMode()
        ? 'DARKMODE_DARK'
        : 'DARKMODE_LIGHT');

  // Save theme data to GetStorage
  void _saveThemeData(bool isDarkModeSystem, bool isDarkMode) {
    if(isDarkModeSystem) {
      _storage.write('isDARKMODE_SYSTEM', true);
      _storage.write('isDARKMODE', false);
    } else {
      if(isDarkMode) {
        _storage.write('isDARKMODE_SYSTEM', false);
        _storage.write('isDARKMODE', true);
      } else {
        _storage.write('isDARKMODE_SYSTEM', false);
        _storage.write('isDARKMODE', false);
      }
    }
  }

  // Switch Theme and Save switched theme
  void switchTheme(ThemeMode themeMode) {
    Get.changeThemeMode(themeMode);
    if(themeMode == ThemeMode.system) {
      _saveThemeData(true, false);
    } else {
      if(themeMode == ThemeMode.light) {
        _saveThemeData(false, false);
      } else {
        _saveThemeData(false, true);
      }
    }
  }
}