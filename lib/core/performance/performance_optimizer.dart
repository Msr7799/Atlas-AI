import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// محسن الأداء للتطبيق
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  /// تهيئة تحسينات الأداء
  static Future<void> initialize() async {
    // تحسين إعدادات النظام
    await _optimizeSystemSettings();
    
    // تحسين إعدادات Flutter
    _optimizeFlutterSettings();
  }

  /// تحسين إعدادات النظام
  static Future<void> _optimizeSystemSettings() async {
    // تعيين اتجاه الشاشة
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // تحسين شريط الحالة
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  /// تحسين إعدادات Flutter
  static void _optimizeFlutterSettings() {
    // تحسين إعدادات الرسم
    WidgetsFlutterBinding.ensureInitialized();
    
    // تحسين إعدادات التطبيق
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  /// تحسين حجم الصور
  static ImageProvider optimizeImage(String imagePath) {
    return AssetImage(imagePath);
  }

  /// تحسين تحميل الأصول
  static Future<void> preloadAssets(BuildContext context) async {
    // تحميل مسبق للخطوط
    await precacheImage(
      const AssetImage('assets/icons/app_icon1.png'),
      context,
    );
  }

  /// تنظيف الذاكرة
  static void clearMemory() {
    // تنظيف الذاكرة المؤقتة
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}

/// مدير الموارد المحسّن
class ResourceManager {
  static final Map<String, dynamic> _cache = {};
  static const int _maxCacheSize = 50;

  /// إضافة عنصر للذاكرة المؤقتة
  static void cacheItem(String key, dynamic value) {
    if (_cache.length >= _maxCacheSize) {
      // إزالة العنصر الأقدم
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// الحصول على عنصر من الذاكرة المؤقتة
  static dynamic getCachedItem(String key) {
    return _cache[key];
  }

  /// تنظيف الذاكرة المؤقتة
  static void clearCache() {
    _cache.clear();
  }

  /// الحصول على حجم الذاكرة المؤقتة
  static int getCacheSize() {
    return _cache.length;
  }
}

/// محسن الأداء للقوائم
class ListPerformanceOptimizer {
  /// تحسين أداء القوائم الطويلة
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      controller: controller,
      // تحسينات الأداء
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      cacheExtent: 100,
    );
  }

  /// تحسين أداء GridView
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required int crossAxisCount,
  }) {
    return GridView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      // تحسينات الأداء
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      cacheExtent: 100,
    );
  }
} 