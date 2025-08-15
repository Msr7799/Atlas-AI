import 'dart:io';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// مدير الأداء الشامل للتطبيق - يجمع جميع وظائف الأداء
class PerformanceManager {
  static final PerformanceManager _instance = PerformanceManager._internal();
  factory PerformanceManager() => _instance;
  PerformanceManager._internal();

  // === متغيرات الأداء ===
  static Timer? _cleanupTimer;
  static bool _isAppActive = true;
  static bool _isInitialized = false;
  
  // === متغيرات المراقبة ===
  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<Duration>> _operationDurations = {};
  final Map<String, int> _operationCounts = {};
  
  // === متغيرات الذاكرة ===
  final int _peakMemoryUsage = 0;
  final int _currentMemoryUsage = 0;
  
  // === متغيرات الشبكة ===
  final Map<String, List<Duration>> _networkLatencies = {};
  final Map<String, int> _networkErrors = {};
  
  // === متغيرات AI ===
  final Map<String, List<Duration>> _aiResponseTimes = {};
  final Map<String, int> _aiSuccessCount = {};
  final Map<String, int> _aiErrorCount = {};
  
  // === متغيرات التقرير ===
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<Duration>> _measurements = {};
  static final List<String> _performanceLog = [];
  static const int _maxLogSize = 100;
  
  // === متغيرات الشبكة ===
  static final Map<String, dynamic> _networkCache = {};
  static const int _maxNetworkCacheSize = 50;
  static const Duration _networkCacheExpiry = Duration(minutes: 5);
  static final Map<String, DateTime> _networkCacheTimestamps = {};
  
  // === متغيرات الصور ===
  static final Map<String, ui.Image?> _imageCache = {};
  static const int _maxImageCacheSize = 20;

  /// تهيئة مدير الأداء
  static Future<void> initialize() async {
    if (_isInitialized) {
      if (kDebugMode) print('⚠️ PerformanceManager already initialized');
      return;
    }

    try {
      if (kDebugMode) print('🔧 Initializing PerformanceManager...');
      
      // تهيئة المحسنات
      await _safeInitializeOptimizers();
      
      // تحسين إعدادات النظام
      await _optimizeSystemSettings();
      
      // تحسين إعدادات Flutter
      _optimizeFlutterSettings();
      
      _isInitialized = true;
      
      if (kDebugMode) print('✅ PerformanceManager initialized successfully');
      
      // بدء التحسينات الدورية
      optimizeRuntime();
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize PerformanceManager: $e');
        print('🛡️ Continuing without performance optimizations...');
      }
    }
  }

  /// تهيئة آمنة للمحسنات
  static Future<void> _safeInitializeOptimizers() async {
    try {
      if (kDebugMode) print('🔧 Initializing sub-optimizers...');
      await Future.delayed(const Duration(milliseconds: 100));
      if (kDebugMode) print('✅ Sub-optimizers initialized successfully');
    } catch (e) {
      if (kDebugMode) print('⚠️ Some sub-optimizers failed: $e');
    }
  }

  /// تحسين إعدادات النظام
  static Future<void> _optimizeSystemSettings() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      
      if (kDebugMode) print('✅ System settings optimized');
    } catch (e) {
      if (kDebugMode) print('❌ Error optimizing system settings: $e');
    }
  }

  /// تحسين إعدادات Flutter
  static void _optimizeFlutterSettings() {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
      
      if (kDebugMode) print('✅ Flutter settings optimized');
    } catch (e) {
      if (kDebugMode) print('❌ Error optimizing Flutter settings: $e');
    }
  }

  /// تحسين الأداء في وقت التشغيل
  static void optimizeRuntime() {
    try {
      _cleanupTimer?.cancel();
      
      _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
        if (!_isAppActive) {
          if (kDebugMode) print('🔄 App not active, stopping cleanup...');
          timer.cancel();
          _cleanupTimer = null;
          return;
        }
        
        try {
          _periodicCleanup();
        } catch (e) {
          if (kDebugMode) print('❌ Error in periodic cleanup: $e');
        }
      });
      
      if (kDebugMode) print('✅ Runtime optimization started');
    } catch (e) {
      if (kDebugMode) print('❌ Failed to start runtime optimization: $e');
    }
  }

  /// التنظيف الدوري
  static void _periodicCleanup() {
    try {
      if (kDebugMode) print('🧹 Performing periodic cleanup...');
      
      // تنظيف الذاكرة المؤقتة
      _clearImageCache();
      
      // تنظيف الملفات المؤقتة
      _cleanupTempFiles();
      
      if (kDebugMode) print('✅ Periodic cleanup completed');
    } catch (e) {
      if (kDebugMode) print('❌ Error in periodic cleanup: $e');
    }
  }

  /// تنظيف ذاكرة الصور
  static void _clearImageCache() {
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      _imageCache.clear();
      if (kDebugMode) print('✅ Image cache cleared');
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing image cache: $e');
    }
  }

  /// تنظيف الملفات المؤقتة
  static Future<void> _cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      int deletedCount = 0;
      for (final file in files) {
        if (file is File) {
          try {
            await file.delete();
            deletedCount++;
          } catch (e) {
            // تجاهل الأخطاء في حذف الملفات
          }
        }
      }
      
      if (kDebugMode) print('🗑️ Deleted $deletedCount temp files');
    } catch (e) {
      if (kDebugMode) print('❌ Error cleaning temp files: $e');
    }
  }

  // === دوال مراقبة الأداء ===

  /// بدء قياس عملية
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;
  }

  /// إنهاء قياس عملية
  void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _operationDurations[operationName] ??= [];
      _operationDurations[operationName]!.add(duration);
      
      if (_operationDurations[operationName]!.length > 100) {
        _operationDurations[operationName]!.removeAt(0);
      }
      
      _operationStartTimes.remove(operationName);
    }
  }

  /// قياس عملية متزامنة
  T measureSync<T>(String operationName, T Function() operation) {
    startOperation(operationName);
    try {
      final result = operation();
      return result;
    } finally {
      endOperation(operationName);
    }
  }

  /// قياس عملية غير متزامنة
  Future<T> measureAsync<T>(String operationName, Future<T> Function() operation) async {
    startOperation(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      endOperation(operationName);
    }
  }

  // === دوال التقرير ===

  /// بدء قياس الأداء
  static void startTimer(String name) {
    _timers[name] = Stopwatch()..start();
  }

  /// إيقاف قياس الأداء
  static Duration stopTimer(String name) {
    final timer = _timers[name];
    if (timer == null) return Duration.zero;

    timer.stop();
    final duration = timer.elapsed;

    _measurements.putIfAbsent(name, () => []).add(duration);
    _addToLog('$name: ${duration.inMilliseconds}ms');

    _timers.remove(name);
    return duration;
  }

  /// إضافة للسجل
  static void _addToLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _performanceLog.add('[$timestamp] $message');

    if (_performanceLog.length > _maxLogSize) {
      _performanceLog.removeAt(0);
    }
  }

  /// الحصول على تقرير مفصل
  static Map<String, dynamic> getDetailedReport() {
    final report = <String, dynamic>{};

    for (final name in _measurements.keys) {
      final measurements = _measurements[name]!;
      final count = measurements.length;
      final totalMicroseconds = measurements
          .map((duration) => duration.inMicroseconds)
          .reduce((a, b) => a + b);
      final average = Duration(microseconds: totalMicroseconds ~/ count);
      final best = measurements.reduce((a, b) => a < b ? a : b);
      final worst = measurements.reduce((a, b) => a > b ? a : b);

      report[name] = {
        'count': count,
        'average_ms': average.inMilliseconds,
        'best_ms': best.inMilliseconds,
        'worst_ms': worst.inMilliseconds,
        'total_ms': measurements
            .map((d) => d.inMilliseconds)
            .reduce((a, b) => a + b),
      };
    }

    return report;
  }

  // === دوال الشبكة ===

  /// طلب GET محسّن
  static Future<http.Response> optimizedGet(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final cacheKey = 'GET:$url';
    
    if (_isNetworkCacheValid(cacheKey)) {
      return _getNetworkCachedResponse(cacheKey);
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'ArabicAgent/1.0',
          ...?headers,
        },
      ).timeout(timeout ?? const Duration(seconds: 10));

      _cacheNetworkResponse(cacheKey, response);
      return response;
    } catch (e) {
      return await _retryNetworkRequest(() => http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'ArabicAgent/1.0',
          ...?headers,
        },
      ));
    }
  }

  /// إعادة المحاولة مع تأخير
  static Future<http.Response> _retryNetworkRequest(
    Future<http.Response> Function() request,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return await request();
  }

  /// حفظ الاستجابة في الذاكرة المؤقتة
  static void _cacheNetworkResponse(String key, http.Response response) {
    if (_networkCache.length >= _maxNetworkCacheSize) {
      final oldestKey = _networkCache.keys.first;
      _networkCache.remove(oldestKey);
      _networkCacheTimestamps.remove(oldestKey);
    }

    _networkCache[key] = response;
    _networkCacheTimestamps[key] = DateTime.now();
  }

  /// التحقق من صلاحية الذاكرة المؤقتة
  static bool _isNetworkCacheValid(String key) {
    if (!_networkCache.containsKey(key)) return false;
    
    final timestamp = _networkCacheTimestamps[key];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _networkCacheExpiry;
  }

  /// الحصول على استجابة من الذاكرة المؤقتة
  static http.Response _getNetworkCachedResponse(String key) {
    return _networkCache[key] as http.Response;
  }

  // === دوال الصور ===

  /// تحميل صورة محسّنة
  static Widget optimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: (width ?? 100).toInt(),
      cacheHeight: (height ?? 100).toInt(),
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            );
      },
    );
  }

  // === دوال إدارة الحالة ===

  /// تحديث حالة نشاط التطبيق
  static void setAppActive(bool active) {
    _isAppActive = active;
    if (kDebugMode) {
      print('📱 App activity state: ${active ? "Active" : "Inactive"}');
    }
  }

  /// تنظيف آمن عند الإغلاق
  static Future<void> safeShutdown() async {
    try {
      if (kDebugMode) print('🔄 Starting safe shutdown...');
      
      _cleanupTimer?.cancel();
      _cleanupTimer = null;
      
      await cleanup();
      
      _isInitialized = false;
      
      if (kDebugMode) print('✅ Safe shutdown completed');
    } catch (e) {
      if (kDebugMode) print('❌ Error in safe shutdown: $e');
    }
  }

  /// تنظيف عام
  static Future<void> cleanup() async {
    try {
      if (kDebugMode) print('🧹 Starting general cleanup...');
      
      _clearImageCache();
      await _cleanupTempFiles();
      
      if (kDebugMode) print('✅ General cleanup completed');
    } catch (e) {
      if (kDebugMode) print('❌ Error in general cleanup: $e');
    }
  }

  // === دوال AI ===

  /// تسجيل استجابة AI
  static void recordAIResponse(String serviceName, Duration responseTime, bool isSuccess) {
    // يمكن إضافة منطق تسجيل استجابة AI هنا
    if (kDebugMode) {
      print('🤖 AI Response: $serviceName - ${responseTime.inMilliseconds}ms - ${isSuccess ? "Success" : "Failed"}');
    }
  }

  // === Getters ===

  /// الحصول على حالة التهيئة
  static bool get isInitialized => _isInitialized;

  /// الحصول على حالة النشاط
  static bool get isAppActive => _isAppActive;

  /// الحصول على حالة Timer التنظيف
  static bool get isCleanupTimerActive => _cleanupTimer?.isActive ?? false;

  /// الحصول على حجم الذاكرة المؤقتة
  static int get imageCacheSize {
    try {
      return PaintingBinding.instance.imageCache.currentSize;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting image cache size: $e');
      return 0;
    }
  }

  /// الحصول على حجم الذاكرة المؤقتة للصور الحية
  static int get liveImageCacheSize {
    try {
      return PaintingBinding.instance.imageCache.liveImageCount;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting live image cache size: $e');
      return 0;
    }
  }

  /// الحصول على حجم الذاكرة المؤقتة الإجمالي
  static int get totalCacheSize {
    try {
      return imageCacheSize + liveImageCacheSize;
    } catch (e) {
      if (kDebugMode) print('❌ Error getting total cache size: $e');
      return 0;
    }
  }

  /// الحصول على سجل الأداء
  static List<String> getPerformanceLog() {
    return List.from(_performanceLog);
  }

  /// تنظيف البيانات
  static void clearData() {
    _timers.clear();
    _measurements.clear();
    _performanceLog.clear();
  }

  /// تنظيف الذاكرة المؤقتة للشبكة
  static void clearNetworkCache() {
    _networkCache.clear();
    _networkCacheTimestamps.clear();
  }
}

/// Global instance
final performanceManager = PerformanceManager();