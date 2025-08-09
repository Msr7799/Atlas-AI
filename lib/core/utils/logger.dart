import 'package:flutter/foundation.dart';

/// مساعد للسجلات (Logger) لعرض رسائل مختلفة بألوان مميزة
/// يساعد في تتبع أحداث التطبيق
class LogHelper {
  /// طباعة رسالة نجاح
  static void success(String message) {
    if (kDebugMode) {
      print('✅ $message');
    }
  }

  /// طباعة رسالة خطأ
  static void error(String message) {
    if (kDebugMode) {
      print('❌ $message');
    }
  }

  /// طباعة رسالة تحذير
  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ $message');
    }
  }

  /// طباعة رسالة معلومات
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ $message');
    }
  }

  /// طباعة رسالة تصحيح
  static void debug(String message) {
    if (kDebugMode) {
      print('🔍 $message');
    }
  }
}
