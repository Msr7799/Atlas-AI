import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

/// محسن للأصول والصور
class AssetOptimizer {
  static final AssetOptimizer _instance = AssetOptimizer._internal();
  factory AssetOptimizer() => _instance;
  AssetOptimizer._internal();

  final Map<String, dynamic> _cachedAssets = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);

  /// تحميل صورة محسنة مع التخزين المؤقت
  static Future<Uint8List?> loadOptimizedImage(String path) async {
    try {
      final instance = AssetOptimizer();

      // التحقق من التخزين المؤقت
      if (instance._isCached(path)) {
        return instance._cachedAssets[path] as Uint8List?;
      }

      // تحميل الصورة
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();

      // تخزين مؤقت
      instance._cacheAsset(path, bytes);

      if (kDebugMode) {
        print('تم تحميل الصورة: $path');
      }

      return bytes;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تحميل الصورة $path: $e');
      }
      return null;
    }
  }

  /// تحميل ملف JSON محسن
  static Future<Map<String, dynamic>?> loadOptimizedJson(String path) async {
    try {
      final instance = AssetOptimizer();

      // التحقق من التخزين المؤقت
      if (instance._isCached(path)) {
        return instance._cachedAssets[path] as Map<String, dynamic>?;
      }

      // تحميل الملف
      final data = await rootBundle.loadString(path);
      final json = jsonDecode(data) as Map<String, dynamic>;

      // تخزين مؤقت
      instance._cacheAsset(path, json);

      if (kDebugMode) {
        print('تم تحميل JSON: $path');
      }

      return json;
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تحميل JSON $path: $e');
      }
      return null;
    }
  }

  /// تحميل مسبق للأصول المهمة
  static Future<void> preloadImportantAssets() async {
    try {
      // تحميل مسبق للصور المهمة
      final importantImages = [
        OptimizedAssets.logo,
        OptimizedAssets.appIcon1,
        OptimizedAssets.atlas,
      ];

      for (final imagePath in importantImages) {
        await loadOptimizedImage(imagePath);
      }

      // تحميل مسبق لملفات البيانات المهمة
      final importantData = [
        OptimizedAssets.fineTuningData,
        OptimizedAssets.trainingData,
      ];

      for (final dataPath in importantData) {
        await loadOptimizedJson(dataPath);
      }

      if (kDebugMode) {
        print('تم التحميل المسبق للأصول المهمة');
      }
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في التحميل المسبق للأصول: $e');
      }
    }
  }

  /// تنظيف التخزين المؤقت
  static void clearCache() {
    final instance = AssetOptimizer();
    instance._cachedAssets.clear();
    instance._cacheTimestamps.clear();

    if (kDebugMode) {
      print('تم تنظيف التخزين المؤقت');
    }
  }

  /// الحصول على حجم التخزين المؤقت
  static int getCacheSize() {
    final instance = AssetOptimizer();
    return instance._cachedAssets.length;
  }

  /// التحقق من وجود أصل في التخزين المؤقت
  bool _isCached(String path) {
    if (!_cachedAssets.containsKey(path)) {
      return false;
    }

    final timestamp = _cacheTimestamps[path];
    if (timestamp == null) {
      return false;
    }

    // التحقق من انتهاء صلاحية التخزين المؤقت
    if (DateTime.now().difference(timestamp) > _cacheExpiry) {
      _cachedAssets.remove(path);
      _cacheTimestamps.remove(path);
      return false;
    }

    return true;
  }

  /// تخزين أصل في الذاكرة المؤقتة
  void _cacheAsset(String path, dynamic asset) {
    _cachedAssets[path] = asset;
    _cacheTimestamps[path] = DateTime.now();
  }
}

/// قائمة الأصول المحسنة
class OptimizedAssets {
  // الصور
  static const String appIcon1 = 'assets/icons/app_icon1.png';
  static const String appIcon2 = 'assets/icons/app_icon2.png';
  static const String appIcon3 = 'assets/icons/app_icon3.png';
  static const String appIcon4 = 'assets/icons/app_icon4.png';
  static const String logo = 'assets/icons/logo_.png';
  static const String atlas = 'assets/icons/atlas.png';
  static const String noBgIcon = 'assets/icons/no-bg-icon.png';

  // الخطوط
  static const String uthmanicFont = 'assets/fonts/uthmanic_hafs.ttf';
  static const String amiriFont = 'assets/fonts/Amiri,Scheherazade_New/Amiri/Amiri-Regular.ttf';
  static const String scheherazadeFont = 'assets/fonts/Amiri,Scheherazade_New/Scheherazade_New/ScheherazadeNew-Regular.ttf';
  static const String boutrosFont = 'assets/fonts/BoutrosNewsH1-Bold.ttf';

  // البيانات
  static const String fineTuningData =
      'assets/data/specialized_datasets/fine_Tuning.json';
  static const String trainingData =
      'assets/data/specialized_datasets/training_data.json';

  /// الحصول على قائمة جميع الأصول
  static List<String> getAllAssets() {
    return [
      appIcon1,
      appIcon2,
      appIcon3,
      appIcon4,
      logo,
      atlas,
      noBgIcon,
      uthmanicFont,
      amiriFont,
      scheherazadeFont,
      boutrosFont,
      fineTuningData,
      trainingData,
    ];
  }

  /// الحصول على قائمة الصور فقط
  static List<String> getImageAssets() {
    return [appIcon1, appIcon2, appIcon3, appIcon4, logo, atlas];
  }

  /// الحصول على قائمة الخطوط فقط
  static List<String> getFontAssets() {
    return [uthmanicFont, amiriFont, scheherazadeFont, boutrosFont];
  }

  /// الحصول على قائمة ملفات البيانات فقط
  static List<String> getDataAssets() {
    return [fineTuningData, trainingData];
  }
}
