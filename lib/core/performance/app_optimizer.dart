import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'performance_optimizer.dart';
import 'image_optimizer.dart';
import 'database_optimizer.dart';
import 'network_optimizer.dart';
import 'performance_report.dart';
import '../utils/asset_optimizer.dart';

/// محسن التطبيق الشامل
class AppOptimizer {
  static bool _isInitialized = false;

  /// تهيئة جميع التحسينات
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // تحسين إعدادات النظام
      await PerformanceOptimizer.initialize();

      // تحسين قاعدة البيانات
      await DatabaseOptimizer.database;

      // تحميل مسبق للصور المهمة
      await _preloadImportantImages();

      // تحسين إعدادات التطبيق
      _optimizeAppSettings();

      _isInitialized = true;

      // تسجيل نجاح التهيئة
      PerformanceReport.addToLog('AppOptimizer: تم تهيئة التحسينات بنجاح');
    } catch (e) {
      PerformanceReport.addToLog('AppOptimizer: خطأ في التهيئة - $e');
    }
  }

  /// تحميل مسبق للصور والأصول المهمة
  static Future<void> _preloadImportantImages() async {
    // تحميل مسبق للأصول المحسنة
    await AssetOptimizer.preloadImportantAssets();

    // تحميل إضافي للصور المهمة
    const importantImages = [
      'assets/icons/app_icon1.png',
      'assets/icons/logo_.png',
    ];

    await ImageOptimizer.preloadImages(importantImages);
  }

  /// تحسين إعدادات التطبيق
  static void _optimizeAppSettings() {
    // تحسين إعدادات النظام
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // تحسين إعدادات التطبيق
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// تنظيف الموارد
  static Future<void> cleanup() async {
    try {
      // تنظيف ذاكرة الصور
      ImageOptimizer.clearImageCache();

      // تنظيف ذاكرة الأصول المحسنة
      AssetOptimizer.clearCache();

      // تنظيف ذاكرة الشبكة
      NetworkOptimizer.clearCache();

      // تنظيف قاعدة البيانات
      await DatabaseOptimizer.cleanupDatabase();

      // تنظيف الذاكرة العامة
      PerformanceOptimizer.clearMemory();

      PerformanceReport.addToLog('AppOptimizer: تم تنظيف الموارد');
    } catch (e) {
      PerformanceReport.addToLog('AppOptimizer: خطأ في التنظيف - $e');
    }
  }

  /// الحصول على تقرير شامل
  static Map<String, dynamic> getComprehensiveReport() {
    return {
      'performance': PerformanceReport.getDetailedReport(),
      'image_cache_size': ImageOptimizer.getImageCacheSize(),
      'network_cache_size': NetworkOptimizer.getCacheSize(),
      'database_stats': DatabaseOptimizer.getDatabaseStats(),
      'memory_usage': _getMemoryUsage(),
    };
  }

  /// الحصول على استخدام الذاكرة
  static Map<String, dynamic> _getMemoryUsage() {
    return {
      'image_cache': ImageOptimizer.getImageCacheSize(),
      'network_cache': NetworkOptimizer.getCacheSize(),
      'resource_cache': ResourceManager.getCacheSize(),
      'database_cache': DatabaseCache.getCacheSize(),
    };
  }

  /// تحسين الأداء أثناء التشغيل
  static void optimizeRuntime() {
    // تنظيف دوري للذاكرة
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _periodicCleanup();
    });
  }

  /// تنظيف دوري
  static void _periodicCleanup() {
    try {
      // تنظيف الذاكرة المؤقتة للصور
      if (ImageOptimizer.getImageCacheSize() > 15) {
        ImageOptimizer.clearImageCache();
      }

      // تنظيف ذاكرة الشبكة
      if (NetworkOptimizer.getCacheSize() > 30) {
        NetworkOptimizer.clearCache();
      }

      // تنظيف الذاكرة العامة
      if (ResourceManager.getCacheSize() > 40) {
        ResourceManager.clearCache();
      }

      PerformanceReport.addToLog('AppOptimizer: تم التنظيف الدوري');
    } catch (e) {
      PerformanceReport.addToLog('AppOptimizer: خطأ في التنظيف الدوري - $e');
    }
  }

  /// إغلاق التطبيق بشكل آمن
  static Future<void> safeShutdown() async {
    try {
      // حفظ البيانات المهمة
      await _saveImportantData();

      // تنظيف الموارد
      await cleanup();

      // إغلاق قاعدة البيانات
      await DatabaseOptimizer.closeDatabase();

      PerformanceReport.addToLog('AppOptimizer: تم الإغلاق الآمن');
    } catch (e) {
      PerformanceReport.addToLog('AppOptimizer: خطأ في الإغلاق الآمن - $e');
    }
  }

  /// حفظ البيانات المهمة
  static Future<void> _saveImportantData() async {
    // يمكن إضافة حفظ البيانات المهمة هنا
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

/// مدير تحسين الأداء التفاعلي
class InteractivePerformanceManager {
  static bool _isMonitoring = false;
  static Timer? _monitoringTimer;

  /// بدء مراقبة الأداء
  static void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkPerformance();
    });
  }

  /// إيقاف مراقبة الأداء
  static void stopMonitoring() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// فحص الأداء
  static void _checkPerformance() {
    final report = PerformanceReport.getDetailedReport();

    // فحص الأداء البطيء
    for (final entry in report.entries) {
      final data = entry.value as Map<String, dynamic>;
      final average = data['average_ms'] as int;

      if (average > 1000) {
        // أكثر من ثانية واحدة
        PerformanceReport.addToLog('تحذير: ${entry.key} بطيء - ${average}ms');
      }
    }

    // فحص استخدام الذاكرة
    final memoryUsage =
        AppOptimizer.getComprehensiveReport()['memory_usage']
            as Map<String, dynamic>;
    final totalCache = memoryUsage.values.reduce((a, b) => a + b);

    if (totalCache > 100) {
      PerformanceReport.addToLog(
        'تحذير: استخدام عالي للذاكرة - $totalCache عنصر',
      );
      AppOptimizer._periodicCleanup();
    }
  }

  /// الحصول على حالة المراقبة
  static bool get isMonitoring => _isMonitoring;
}

/// ويدجت لعرض معلومات الأداء
class PerformanceInfoWidget extends StatelessWidget {
  const PerformanceInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات الأداء',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'ذاكرة الصور',
              '${ImageOptimizer.getImageCacheSize()}',
            ),
            _buildInfoRow('ذاكرة الشبكة', '${NetworkOptimizer.getCacheSize()}'),
            _buildInfoRow(
              'الموارد العامة',
              '${ResourceManager.getCacheSize()}',
            ),
            _buildInfoRow(
              'مراقبة الأداء',
              InteractivePerformanceManager.isMonitoring ? 'مفعلة' : 'معطلة',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (InteractivePerformanceManager.isMonitoring) {
                        InteractivePerformanceManager.stopMonitoring();
                      } else {
                        InteractivePerformanceManager.startMonitoring();
                      }
                    },
                    child: Text(
                      InteractivePerformanceManager.isMonitoring
                          ? 'إيقاف المراقبة'
                          : 'بدء المراقبة',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      AppOptimizer.cleanup();
                    },
                    child: const Text('تنظيف الذاكرة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
