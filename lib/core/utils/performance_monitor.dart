import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// مراقب الأداء لتتبع وتحسين الأداء
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _timers = {};
  final Map<String, List<Duration>> _measurements = {};
  final Map<String, int> _operationCounts = {};

  /// بدء قياس الأداء
  void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();

    if (kDebugMode) {
      print('بدء قياس الأداء: $operation');
    }
  }

  /// إيقاف قياس الأداء
  void stopTimer(String operation) {
    final timer = _timers[operation];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsed;

      // تسجيل القياس
      _measurements.putIfAbsent(operation, () => []).add(duration);
      _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;

      if (kDebugMode) {
        print('انتهى قياس الأداء: $operation - ${duration.inMilliseconds}ms');
      }

      _timers.remove(operation);
    }
  }

  /// قياس دالة مع إرجاع النتيجة
  Future<T> measureAsync<T>(
    String operation,
    Future<T> Function() function,
  ) async {
    startTimer(operation);
    try {
      final result = await function();
      return result;
    } finally {
      stopTimer(operation);
    }
  }

  /// قياس دالة متزامنة مع إرجاع النتيجة
  T measureSync<T>(String operation, T Function() function) {
    startTimer(operation);
    try {
      final result = function();
      return result;
    } finally {
      stopTimer(operation);
    }
  }

  /// الحصول على متوسط وقت العملية
  Duration getAverageTime(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    final total = measurements.fold<Duration>(
      Duration.zero,
      (total, duration) => total + duration,
    );

    return Duration(microseconds: total.inMicroseconds ~/ measurements.length);
  }

  /// الحصول على أسرع وقت للعملية
  Duration getFastestTime(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    return measurements.reduce((a, b) => a < b ? a : b);
  }

  /// الحصول على أبطأ وقت للعملية
  Duration getSlowestTime(String operation) {
    final measurements = _measurements[operation];
    if (measurements == null || measurements.isEmpty) {
      return Duration.zero;
    }

    return measurements.reduce((a, b) => a > b ? a : b);
  }

  /// الحصول على عدد مرات تنفيذ العملية
  int getOperationCount(String operation) {
    return _operationCounts[operation] ?? 0;
  }

  /// الحصول على تقرير الأداء
  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{};

    for (final operation in _measurements.keys) {
      report[operation] = {
        'count': getOperationCount(operation),
        'average': getAverageTime(operation).inMilliseconds,
        'fastest': getFastestTime(operation).inMilliseconds,
        'slowest': getSlowestTime(operation).inMilliseconds,
      };
    }

    return report;
  }

  /// طباعة تقرير الأداء
  void printPerformanceReport() {
    if (!kDebugMode) return;

    print('\n=== تقرير الأداء ===');
    final report = getPerformanceReport();

    for (final entry in report.entries) {
      final data = entry.value as Map<String, dynamic>;
      print('${entry.key}:');
      print('  عدد المرات: ${data['count']}');
      print('  المتوسط: ${data['average']}ms');
      print('  الأسرع: ${data['fastest']}ms');
      print('  الأبطأ: ${data['slowest']}ms');
      print('');
    }
  }

  /// تنظيف البيانات
  void clear() {
    _timers.clear();
    _measurements.clear();
    _operationCounts.clear();
  }
}

/// مزيج لمراقبة الأداء في الـ widgets
mixin PerformanceMonitoringMixin {
  final PerformanceMonitor _monitor = PerformanceMonitor();

  /// قياس بناء الـ widget
  Widget measureWidgetBuild(String operation, Widget Function() builder) {
    return _monitor.measureSync(operation, builder);
  }

  /// قياس العمليات غير المتزامنة
  Future<T> measureAsyncOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) {
    return _monitor.measureAsync(operationName, operation);
  }

  /// الحصول على مراقب الأداء
  PerformanceMonitor get performanceMonitor => _monitor;
}
