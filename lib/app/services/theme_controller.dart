import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { dark, light, customImage }

class ThemeController extends ChangeNotifier {
  AppThemeMode _currentMode = AppThemeMode.dark;
  String? _customImagePath;

  AppThemeMode get currentMode => _currentMode;
  String? get customImagePath => _customImagePath;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt('theme_mode') ?? 0;
    _currentMode = AppThemeMode.values[modeIndex];
    _customImagePath = prefs.getString('custom_image_path');
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode, {String? imagePath}) async {
    _currentMode = mode;
    if (imagePath != null) {
      _customImagePath = imagePath;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    if (_customImagePath != null) {
      await prefs.setString('custom_image_path', _customImagePath!);
    }
    notifyListeners();
  }
}
