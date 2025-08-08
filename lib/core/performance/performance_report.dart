import 'package:flutter/material.dart';
import 'dart:async';

/// تقرير الأداء للتطبيق
class PerformanceReport {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<Duration>> _measurements = {};
  static final List<String> _performanceLog = [];
  static const int _maxLogSize = 100;

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

    // حفظ القياس
    _measurements.putIfAbsent(name, () => []).add(duration);

    // إضافة للسجل
    _addToLog('$name: ${duration.inMilliseconds}ms');

    _timers.remove(name);
    return duration;
  }

  /// قياس الأداء مع دالة
  static Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation,
  ) async {
    startTimer(name);
    try {
      final result = await operation();
      stopTimer(name);
      return result;
    } catch (e) {
      stopTimer(name);
      rethrow;
    }
  }

  /// قياس الأداء مع دالة متزامنة
  static T measureSync<T>(String name, T Function() operation) {
    startTimer(name);
    try {
      final result = operation();
      stopTimer(name);
      return result;
    } catch (e) {
      stopTimer(name);
      rethrow;
    }
  }

  /// الحصول على متوسط الأداء
  static Duration getAverageTime(String name) {
    final measurements = _measurements[name];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    final totalMicroseconds = measurements
        .map((duration) => duration.inMicroseconds)
        .reduce((a, b) => a + b);

    return Duration(microseconds: totalMicroseconds ~/ measurements.length);
  }

  /// الحصول على أفضل وقت
  static Duration getBestTime(String name) {
    final measurements = _measurements[name];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    return measurements.reduce((a, b) => a < b ? a : b);
  }

  /// الحصول على أسوأ وقت
  static Duration getWorstTime(String name) {
    final measurements = _measurements[name];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    return measurements.reduce((a, b) => a > b ? a : b);
  }

  /// إضافة للسجل
  static void addToLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _performanceLog.add('[$timestamp] $message');

    if (_performanceLog.length > _maxLogSize) {
      _performanceLog.removeAt(0);
    }
  }

  /// إضافة للسجل (دالة خاصة)
  static void _addToLog(String message) {
    addToLog(message);
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

  /// الحصول على تقرير مفصل
  static Map<String, dynamic> getDetailedReport() {
    final report = <String, dynamic>{};

    for (final name in _measurements.keys) {
      final measurements = _measurements[name]!;
      final count = measurements.length;
      final average = getAverageTime(name);
      final best = getBestTime(name);
      final worst = getWorstTime(name);

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
}

/// مراقب استخدام الذاكرة
class MemoryMonitor {
  static final List<MemorySnapshot> _snapshots = [];
  static const int _maxSnapshots = 50;

  /// التقاط لقطة من الذاكرة
  static void takeSnapshot(String name) {
    final snapshot = MemorySnapshot(
      name: name,
      timestamp: DateTime.now(),
      // يمكن إضافة المزيد من المعلومات هنا
    );

    _snapshots.add(snapshot);

    if (_snapshots.length > _maxSnapshots) {
      _snapshots.removeAt(0);
    }
  }

  /// الحصول على اللقطات
  static List<MemorySnapshot> getSnapshots() {
    return List.from(_snapshots);
  }

  /// تنظيف اللقطات
  static void clearSnapshots() {
    _snapshots.clear();
  }
}

/// لقطة الذاكرة
class MemorySnapshot {
  final String name;
  final DateTime timestamp;

  MemorySnapshot({required this.name, required this.timestamp});

  @override
  String toString() {
    return 'MemorySnapshot(name: $name, timestamp: $timestamp)';
  }
}

/// مراقب أداء الواجهة
class UIPerformanceMonitor {
  static final Map<String, int> _frameCounts = {};
  static final Map<String, List<double>> _frameRates = {};
  static const int _maxFrameRateSamples = 100;

  /// تسجيل إطار
  static void recordFrame(String widgetName) {
    _frameCounts[widgetName] = (_frameCounts[widgetName] ?? 0) + 1;
  }

  /// تسجيل معدل الإطارات
  static void recordFrameRate(String widgetName, double fps) {
    _frameRates.putIfAbsent(widgetName, () => []).add(fps);

    final rates = _frameRates[widgetName]!;
    if (rates.length > _maxFrameRateSamples) {
      rates.removeAt(0);
    }
  }

  /// الحصول على متوسط معدل الإطارات
  static double getAverageFrameRate(String widgetName) {
    final rates = _frameRates[widgetName];
    if (rates == null || rates.isEmpty) return 0.0;

    final sum = rates.reduce((a, b) => a + b);
    return sum / rates.length;
  }

  /// الحصول على عدد الإطارات
  static int getFrameCount(String widgetName) {
    return _frameCounts[widgetName] ?? 0;
  }

  /// تنظيف البيانات
  static void clearData() {
    _frameCounts.clear();
    _frameRates.clear();
  }
}

/// ويدجت لعرض تقرير الأداء
class PerformanceReportWidget extends StatelessWidget {
  const PerformanceReportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final report = PerformanceReport.getDetailedReport();
    final log = PerformanceReport.getPerformanceLog();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الأداء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // تحديث البيانات
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              PerformanceReport.clearData();
              MemoryMonitor.clearSnapshots();
              UIPerformanceMonitor.clearData();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'قياسات الأداء',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...report.entries.map((entry) => _buildReportCard(entry)),
            const SizedBox(height: 24),
            const Text(
              'سجل الأداء',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...log.map(
              (message) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(message, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(MapEntry<String, dynamic> entry) {
    final data = entry.value as Map<String, dynamic>;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('عدد القياسات: ${data['count']}'),
            Text('المتوسط: ${data['average_ms']}ms'),
            Text('الأفضل: ${data['best_ms']}ms'),
            Text('الأسوأ: ${data['worst_ms']}ms'),
            Text('المجموع: ${data['total_ms']}ms'),
          ],
        ),
      ),
    );
  }
}
