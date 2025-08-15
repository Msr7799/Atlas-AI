import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// أدوات التطبيق الشاملة - تجمع جميع الوظائف المساعدة
class AppUtils {
  // === منع إنشاء instance ===
  AppUtils._();

  // === متغيرات الأصول ===
  static final Map<String, dynamic> _cachedAssets = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 30);

  // === متغيرات الذاكرة ===
  static final Map<String, dynamic> _resources = {};
  static final Map<String, VoidCallback> _disposers = {};

  // === متغيرات الشبكة ===
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // === دوال الأصول ===

  /// تحميل صورة محسنة مع التخزين المؤقت
  static Future<Uint8List?> loadOptimizedImage(String path) async {
    try {
      // التحقق من التخزين المؤقت
      if (_isAssetCached(path)) {
        return _cachedAssets[path] as Uint8List?;
      }

      // تحميل الصورة
      final data = await rootBundle.load(path);
      final bytes = data.buffer.asUint8List();

      // تخزين مؤقت
      _cacheAsset(path, bytes);

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
      // التحقق من التخزين المؤقت
      if (_isAssetCached(path)) {
        return _cachedAssets[path] as Map<String, dynamic>?;
      }

      // تحميل الملف
      final data = await rootBundle.loadString(path);
      final json = jsonDecode(data) as Map<String, dynamic>;

      // تخزين مؤقت
      _cacheAsset(path, json);

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
        'assets/icons/app_icon1.png',
        'assets/icons/atlas.png',
        'assets/icons/ball_ani.gif',
        'assets/icons/main_gif.gif',
        'assets/icons/neon_chat_icon.gif',
        'assets/icons/neon_chat_icon2.gif',
        'assets/icons/no-bg-icon.png',
        'assets/icons/no-bg-icon1.png',
        'assets/icons/ATLAS_icon2.png',
      ];

      for (final imagePath in importantImages) {
        await loadOptimizedImage(imagePath);
      }

      // تحميل مسبق لملفات البيانات المهمة
      final importantData = [
        'assets/data/specialized_datasets/fine_Tuning.json',
        'assets/data/specialized_datasets/training_data.json',
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
  static void clearAssetCache() {
    _cachedAssets.clear();
    _cacheTimestamps.clear();

    if (kDebugMode) {
      print('تم تنظيف التخزين المؤقت');
    }
  }

  /// الحصول على حجم التخزين المؤقت
  static int getAssetCacheSize() {
    return _cachedAssets.length;
  }

  /// التحقق من وجود أصل في التخزين المؤقت
  static bool _isAssetCached(String path) {
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
  static void _cacheAsset(String path, dynamic asset) {
    _cachedAssets[path] = asset;
    _cacheTimestamps[path] = DateTime.now();
  }

  // === دوال الذاكرة ===

  /// تسجيل مورد مع دالة إغلاق
  static void registerResource(String key, dynamic resource, VoidCallback? disposer) {
    _resources[key] = resource;
    if (disposer != null) {
      _disposers[key] = disposer;
    }
    
    if (kDebugMode) {
      print('تم تسجيل المورد: $key');
    }
  }

  /// الحصول على مورد
  static T? getResource<T>(String key) {
    final resource = _resources[key];
    if (resource is T) {
      return resource;
    }
    return null;
  }

  /// إزالة مورد
  static void removeResource(String key) {
    final disposer = _disposers[key];
    if (disposer != null) {
      disposer();
      _disposers.remove(key);
    }
    
    _resources.remove(key);
    
    if (kDebugMode) {
      print('تم إزالة المورد: $key');
    }
  }

  /// إزالة جميع الموارد
  static void clearAllResources() {
    for (final key in _disposers.keys) {
      _disposers[key]?.call();
    }
    
    _resources.clear();
    _disposers.clear();
    
    if (kDebugMode) {
      print('تم إزالة جميع الموارد');
    }
  }

  /// الحصول على قائمة الموارد
  static List<String> getResourceKeys() {
    return _resources.keys.toList();
  }

  /// التحقق من وجود مورد
  static bool hasResource(String key) {
    return _resources.containsKey(key);
  }

  /// الحصول على عدد الموارد
  static int getResourceCount() {
    return _resources.length;
  }

  // === دوال الشبكة ===

  /// فحص الاتصال بالإنترنت العام
  static Future<bool> hasInternetConnection() async {
    try {
      final response = await _dio.get('https://www.google.com');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('[NETWORK] Internet connection check failed: $e');
      }
      return false;
    }
  }

  /// فحص DNS
  static Future<bool> testDNSResolution(String hostname) async {
    try {
      await InternetAddress.lookup(hostname);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('[NETWORK] DNS resolution failed for $hostname: $e');
      }
      return false;
    }
  }

  /// فحص شامل للشبكة
  static Future<Map<String, dynamic>> runFullNetworkDiagnostics() async {
    if (kDebugMode) {
      print('[NETWORK] Running full network diagnostics...');
    }

    final hasInternet = await hasInternetConnection();
    final groqDNS = await testDNSResolution('api.groq.com');
    final tavilyDNS = await testDNSResolution('api.tavily.com');

    return {
      'hasInternetConnection': hasInternet,
      'groqDNSResolved': groqDNS,
      'tavilyDNSResolved': tavilyDNS,
    };
  }

  /// طباعة تقرير مفصل
  static void printNetworkDiagnosticsReport(Map<String, dynamic> diagnostics) {
    if (!kDebugMode) return;
    
    print('\n═══════════════════════════════════════');
    print('🌐 ATLAS AI - NETWORK DIAGNOSTICS REPORT');
    print('═══════════════════════════════════════');

    print(
      '🌐 Internet Connection: ${diagnostics['hasInternetConnection'] ? "✅ Connected" : "❌ Failed"}',
    );
    print(
      '🔍 Groq DNS Resolution: ${diagnostics['groqDNSResolved'] ? "✅ Success" : "❌ Failed"}',
    );
    print(
      '🔍 Tavily DNS Resolution: ${diagnostics['tavilyDNSResolved'] ? "✅ Success" : "❌ Failed"}',
    );

    if (!diagnostics['hasInternetConnection']) {
      print('\n💡 RECOMMENDATIONS:');
      print('• Check your Wi-Fi or mobile data connection');
      print('• Try switching between Wi-Fi and mobile data');
      print('• Restart your network connection');
    }

    if (diagnostics['hasInternetConnection'] &&
        (!diagnostics['groqDNSResolved'] || !diagnostics['tavilyDNSResolved'])) {
      print('\n💡 DNS ISSUES DETECTED:');
      print('• Try using a different DNS server (8.8.8.8, 1.1.1.1)');
      print('• Check if your network blocks certain domains');
      print('• Try using a VPN to bypass network restrictions');
    }

    print('═══════════════════════════════════════\n');
  }

  // === دوال السجلات ===

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

  // === دوال التصميم المتجاوب ===

  // نقاط التوقف للشاشات المختلفة
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// التحقق من نوع الجهاز
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// الحصول على نوع الجهاز
  static String getDeviceType(BuildContext context) {
    if (isMobile(context)) return 'mobile';
    if (isTablet(context)) return 'tablet';
    return 'desktop';
  }

  /// الحصول على عرض متجاوب
  static double getResponsiveWidth(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على ارتفاع متجاوب
  static double getResponsiveHeight(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على حجم خط متجاوب
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على padding متجاوب
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على margin متجاوب
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile ?? EdgeInsets.zero;
    if (isTablet(context)) return tablet ?? mobile ?? EdgeInsets.zero;
    return mobile ?? EdgeInsets.zero;
  }

  /// الحصول على عدد الأعمدة للشبكة
  static int getGridColumns(
    BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }

  /// الحصول على aspect ratio متجاوب
  static double getResponsiveAspectRatio(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// بناء layout متجاوب
  static Widget buildResponsiveLayout(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على constraints متجاوبة
  static BoxConstraints getResponsiveConstraints(
    BuildContext context, {
    BoxConstraints? mobile,
    BoxConstraints? tablet,
    BoxConstraints? desktop,
  }) {
    final screenSize = MediaQuery.of(context).size;

    if (isDesktop(context)) {
      return desktop ??
          BoxConstraints(
            maxWidth: screenSize.width * 0.7,
            maxHeight: screenSize.height * 0.8,
          );
    }

    if (isTablet(context)) {
      return tablet ??
          BoxConstraints(
            maxWidth: screenSize.width * 0.8,
            maxHeight: screenSize.height * 0.85,
          );
    }

    return mobile ??
        BoxConstraints(
          maxWidth: screenSize.width * 0.95,
          maxHeight: screenSize.height * 0.9,
        );
  }

  /// الحصول على حجم متجاوب للأيقونات
  static double getResponsiveIconSize(
    BuildContext context, {
    double mobile = 24,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// الحصول على قيمة متجاوبة عامة - مفيدة لأي نوع من البيانات
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  /// التحقق من الاتجاه
  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  /// الحصول على safe area
  static EdgeInsets getSafeAreaPadding(BuildContext context) =>
      MediaQuery.of(context).padding;

  /// الحصول على نسبة العرض إلى الارتفاع للشاشة
  static double getScreenAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width / size.height;
  }
}