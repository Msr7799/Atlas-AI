import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _fontFamily = 'Cairo';
  double _fontSize = 14.0;
  Color _accentColor = const Color(0xFFC0E8C1);

  // Available Fonts
  static const List<String> availableFonts = [
    'Cairo',
    'Uthmanic',
    'Inter',
    'Roboto',
  ];

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  Color get accentColor => _accentColor;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setFontFamily(String family) {
    _fontFamily = family;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];

    // التأكد من أن الخط المحفوظ موجود في القائمة المتاحة
    final savedFont = prefs.getString('fontFamily') ?? 'Cairo';
    _fontFamily = availableFonts.contains(savedFont) ? savedFont : 'Cairo';

    _fontSize = prefs.getDouble('fontSize') ?? 14.0;
    final colorValue = prefs.getInt('accentColor');
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    notifyListeners();
  }

  void _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', _themeMode.index);
    prefs.setString('fontFamily', _fontFamily);
    prefs.setDouble('fontSize', _fontSize);
    prefs.setInt('accentColor', _accentColor.value);
  }
}
