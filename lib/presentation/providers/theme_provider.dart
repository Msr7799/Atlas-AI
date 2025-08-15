import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _fontFamily = 'Amiri';  // جعل Amiri الخط الافتراضي
  double _fontSize = 14.0;
  FontWeight _fontWeight = FontWeight.normal; // وزن الخط الافتراضي
  Color _accentColor = const Color(0xFFC0E8C1);
  String? _customBackgroundPath; // مسار الخلفية المخصصة

  // إعدادات إضافية
  Color _primaryColor = Colors.blue;
  bool _animationsEnabled = true;
  final ImagePicker _imagePicker = ImagePicker();

  // Available Fonts
  static const List<String> availableFonts = [
    'Uthmanic',
    'Amiri',           // خط عربي كلاسيكي أنيق
    'Scheherazade_New', // خط عربي حديث متطور
    'Boutros',         // خط بطروس
  ];

  // Available Font Weights
  static const Map<String, FontWeight> availableFontWeights = {
    'ضعيف': FontWeight.w300,
    'عادي': FontWeight.normal,
    'متوسط': FontWeight.w500,
    'عريض': FontWeight.bold,
    'عريض جداً': FontWeight.w900,
  };

  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  double get fontSize => _fontSize;
  FontWeight get fontWeight => _fontWeight;
  Color get accentColor => _accentColor;
  String? get customBackgroundPath => _customBackgroundPath;

  // إعدادات إضافية
  Color get primaryColor => _primaryColor;
  bool get animationsEnabled => _animationsEnabled;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get hasCustomBackground => _customBackgroundPath != null && _customBackgroundPath!.isNotEmpty;

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

  void setFontWeight(FontWeight weight) {
    _fontWeight = weight;
    _saveThemeToPrefs();
    notifyListeners();
  }

  void setAccentColor(Color color) {
    _accentColor = color;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // دالة اختيار خلفية مخصصة
  Future<bool> pickCustomBackground() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // تقليل جودة الصورة لتوفير الذاكرة
      );
      
      if (image != null) {
        _customBackgroundPath = image.path;
        _saveThemeToPrefs();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // دالة إزالة الخلفية المخصصة
  void removeCustomBackground() {
    _customBackgroundPath = null;
    _saveThemeToPrefs();
    notifyListeners();
  }

  // دالة للحصول على File للخلفية المخصصة
  File? getCustomBackgroundFile() {
    if (_customBackgroundPath != null && _customBackgroundPath!.isNotEmpty) {
      final file = File(_customBackgroundPath!);
      if (file.existsSync()) {
        return file;
      } else {
        // إذا كان الملف غير موجود، قم بإزالة المسار المحفوظ
        removeCustomBackground();
      }
    }
    return null;
  }

  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];

    // التأكد من أن الخط المحفوظ موجود في القائمة المتاحة
    final savedFont = prefs.getString('fontFamily') ?? 'Amiri';
    _fontFamily = availableFonts.contains(savedFont) ? savedFont : 'Amiri';

    _fontSize = prefs.getDouble('fontSize') ?? 14.0;

    // تحميل وزن الخط
    final fontWeightIndex = prefs.getInt('fontWeight') ?? FontWeight.normal.index;
    _fontWeight = FontWeight.values[fontWeightIndex];

    final colorValue = prefs.getInt('accentColor');
    if (colorValue != null) {
      _accentColor = Color(colorValue);
    }
    
    // تحميل مسار الخلفية المخصصة
    _customBackgroundPath = prefs.getString('customBackgroundPath');

    // تحميل الإعدادات الإضافية
    final primaryColorValue = prefs.getInt('primaryColor');
    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }
    _animationsEnabled = prefs.getBool('animationsEnabled') ?? true;

    notifyListeners();
  }

  void _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', _themeMode.index);
    prefs.setString('fontFamily', _fontFamily);
    prefs.setDouble('fontSize', _fontSize);
    prefs.setInt('fontWeight', _fontWeight.index);
    prefs.setInt('accentColor', _accentColor.value);
    
    // حفظ مسار الخلفية المخصصة
    if (_customBackgroundPath != null) {
      prefs.setString('customBackgroundPath', _customBackgroundPath!);
    } else {
      prefs.remove('customBackgroundPath');
    }

    // حفظ الإعدادات الإضافية
    prefs.setInt('primaryColor', _primaryColor.value);
    prefs.setBool('animationsEnabled', _animationsEnabled);
  }

  // Setters للإعدادات الإضافية
  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
    _saveThemeToPrefs();
  }

  void setAnimationsEnabled(bool enabled) {
    _animationsEnabled = enabled;
    notifyListeners();
    _saveThemeToPrefs();
  }
}
