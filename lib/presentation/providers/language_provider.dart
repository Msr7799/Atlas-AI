import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('ar'); // Default to Arabic
  
  Locale get currentLocale => _currentLocale;
  
  // Available locales
  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabic
    Locale('en'), // English
  ];
  
  LanguageProvider() {
    _loadLanguage();
  }
  
  // Load saved language from SharedPreferences
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ar';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }
  
  // Change language and save to SharedPreferences
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;
    
    _currentLocale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }
  
  // Get language display name
  String getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return locale.languageCode;
    }
  }
  
  // Check if current language is RTL
  bool get isRTL => _currentLocale.languageCode == 'ar';
}
