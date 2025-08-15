import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// مراقب الأداء المتقدم للتطبيق
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, DateTime> _operationStartTimes = {};
  final Map<String, List<Duration>> _operationDurations = {};
  final Map<String, int> _operationCounts = {};

  // مؤشرات الذاكرة
  int _peakMemoryUsage = 0;
  int _currentMemoryUsage = 0;
  
  // مؤشرات الشبكة
  final Map<String, List<Duration>> _networkLatencies = {};
  final Map<String, int> _networkErrors = {};
  
  // مؤشرات AI
  final Map<String, List<Duration>> _aiResponseTimes = {};
  final Map<String, int> _aiSuccessCount = {};
  final Map<String, int> _aiErrorCount = {};

  /// بدء قياس عملية
  void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;
  }

  /// بدء قياس (للتوافق مع الكود القديم)
  void startTimer(String operationName) {
    startOperation(operationName);
  }

  /// إنهاء قياس عملية
  void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _operationDurations[operationName] ??= [];
      _operationDurations[operationName]!.add(duration);
      
      // إزالة القياسات القديمة (احتفظ بآخر 100)
      if (_operationDurations[operationName]!.length > 100) {
        _operationDurations[operationName]!.removeAt(0);
      }
      
      _operationStartTimes.remove(operationName);
    }
  }

  /// إنهاء قياس (للتوافق مع الكود القديم)
  void stopTimer(String operationName) {
    endOperation(operationName);
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

  /// تسجيل استجابة AI
  void recordAIResponse(String serviceName, Duration responseTime, bool isSuccess) {
    _aiResponseTimes[serviceName] ??= [];
    _aiResponseTimes[serviceName]!.add(responseTime);
    
    if (isSuccess) {
      _aiSuccessCount[serviceName] = (_aiSuccessCount[serviceName] ?? 0) + 1;
    } else {
      _aiErrorCount[serviceName] = (_aiErrorCount[serviceName] ?? 0) + 1;
    }
    
    // إزالة القياسات القديمة
    if (_aiResponseTimes[serviceName]!.length > 50) {
      _aiResponseTimes[serviceName]!.removeAt(0);
    }
  }

  /// تسجيل أداء قاعدة البيانات
  void recordDatabaseOperation(String operation, int recordCount, Duration duration) {
    final operationKey = 'db_$operation';
    _operationDurations[operationKey] ??= [];
    _operationDurations[operationKey]!.add(duration);
    _operationCounts[operationKey] = (_operationCounts[operationKey] ?? 0) + recordCount;

    if (kDebugMode) {
      print('🚀 [DB_PERFORMANCE] $operation: $recordCount سجل في ${duration.inMilliseconds}ms');
    }
  }

  /// تسجيل عملية تصدير
  void recordExportOperation(String type, int itemCount, Duration duration) {
    final operationKey = 'export_$type';
    _operationDurations[operationKey] ??= [];
    _operationDurations[operationKey]!.add(duration);
    _operationCounts[operationKey] = (_operationCounts[operationKey] ?? 0) + itemCount;

      if (kDebugMode) {
      print('✅ [EXPORT] $type: $itemCount عنصر في ${duration.inMilliseconds}ms');
    }
  }

  /// تسجيل تأخير الشبكة
  void recordNetworkLatency(String endpoint, Duration latency) {
    _networkLatencies[endpoint] ??= [];
    _networkLatencies[endpoint]!.add(latency);
    
    if (_networkLatencies[endpoint]!.length > 50) {
      _networkLatencies[endpoint]!.removeAt(0);
    }
  }

  /// تسجيل خطأ في الشبكة
  void recordNetworkError(String endpoint) {
    _networkErrors[endpoint] = (_networkErrors[endpoint] ?? 0) + 1;
  }

  /// تحديث معلومات الذاكرة
  void updateMemoryUsage() {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // استخدام ProcessInfo للحصول على معلومات الذاكرة
        _currentMemoryUsage = ProcessInfo.currentRss;
        if (_currentMemoryUsage > _peakMemoryUsage) {
          _peakMemoryUsage = _currentMemoryUsage;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[PERFORMANCE] خطأ في تحديث معلومات الذاكرة: $e');
      }
    }
  }

  /// الحصول على إحصائيات الأداء
  Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    // إحصائيات العمليات
    for (final entry in _operationDurations.entries) {
      final durations = entry.value;
      if (durations.isNotEmpty) {
        final totalMicroseconds = durations.fold<int>(
          0,
          (sum, duration) => sum + duration.inMicroseconds,
        );
        final avgDuration = Duration(microseconds: totalMicroseconds ~/ durations.length);
        
        stats['${entry.key}_avg'] = avgDuration.inMilliseconds;
        stats['${entry.key}_count'] = _operationCounts[entry.key] ?? 0;
        stats['${entry.key}_total'] = durations.length;
      }
    }
    
    // إحصائيات AI
    for (final entry in _aiResponseTimes.entries) {
      final serviceName = entry.key;
      final responseTimes = entry.value;
      
      if (responseTimes.isNotEmpty) {
        final totalMicroseconds = responseTimes.fold<int>(
          0,
          (sum, duration) => sum + duration.inMicroseconds,
        );
        final avgResponseTime = Duration(microseconds: totalMicroseconds ~/ responseTimes.length);
        
        stats['ai_${serviceName}_avg_response'] = avgResponseTime.inMilliseconds;
        stats['ai_${serviceName}_success_rate'] = 
          (_aiSuccessCount[serviceName] ?? 0) / 
          ((_aiSuccessCount[serviceName] ?? 0) + (_aiErrorCount[serviceName] ?? 0)) * 100;
      }
    }
    
    // إحصائيات الشبكة
    for (final entry in _networkLatencies.entries) {
      final endpoint = entry.key;
      final latencies = entry.value;
      
      if (latencies.isNotEmpty) {
        final totalMicroseconds = latencies.fold<int>(
          0,
          (sum, duration) => sum + duration.inMicroseconds,
        );
        final avgLatency = Duration(microseconds: totalMicroseconds ~/ latencies.length);
        
        stats['network_${endpoint}_avg_latency'] = avgLatency.inMilliseconds;
        stats['network_${endpoint}_errors'] = _networkErrors[endpoint] ?? 0;
      }
    }
    
    // معلومات الذاكرة
    stats['memory_current_mb'] = (_currentMemoryUsage / 1024 / 1024).round();
    stats['memory_peak_mb'] = (_peakMemoryUsage / 1024 / 1024).round();
    
    return stats;
  }

  /// طباعة تقرير الأداء
  void printPerformanceReport() {
    final stats = getPerformanceStats();
    
    print('\n📊 === تقرير الأداء ===');
    
    // إحصائيات العمليات العامة
    print('\n⚡ إحصائيات العمليات:');
    for (final entry in stats.entries) {
      if (entry.key.contains('_avg') && !entry.key.startsWith('ai_') && !entry.key.startsWith('network_') && !entry.key.startsWith('db_') && !entry.key.startsWith('export_')) {
        final operationName = entry.key.replaceAll('_avg', '');
        final count = stats['${operationName}_count'] ?? 0;
        final total = stats['${operationName}_total'] ?? 0;
        print('  $operationName: ${entry.value}ms ($count مرة، $total قياس)');
      }
    }
    
    // إحصائيات قاعدة البيانات
    print('\n💾 إحصائيات قاعدة البيانات:');
    for (final entry in stats.entries) {
      if (entry.key.startsWith('db_') && entry.key.contains('_avg')) {
        final operationName = entry.key.replaceAll('db_', '').replaceAll('_avg', '');
        final count = stats['db_${operationName}_count'] ?? 0;
        final total = stats['db_${operationName}_total'] ?? 0;
        print('  $operationName: ${entry.value}ms ($count سجل، $total عملية)');
      }
    }
    
    // إحصائيات التصدير
    print('\n📤 إحصائيات التصدير:');
    for (final entry in stats.entries) {
      if (entry.key.startsWith('export_') && entry.key.contains('_avg')) {
        final operationName = entry.key.replaceAll('export_', '').replaceAll('_avg', '');
        final count = stats['export_${operationName}_count'] ?? 0;
        final total = stats['export_${operationName}_total'] ?? 0;
        print('  $operationName: ${entry.value}ms ($count عنصر، $total عملية)');
      }
    }
    
    // إحصائيات AI
    print('\n🤖 إحصائيات AI:');
    for (final entry in stats.entries) {
      if (entry.key.contains('ai_') && entry.key.contains('_avg_response')) {
        final serviceName = entry.key.replaceAll('ai_', '').replaceAll('_avg_response', '');
        final successRate = stats['ai_${serviceName}_success_rate'] ?? 0;
        print('  $serviceName: ${entry.value}ms (معدل النجاح: ${successRate.toStringAsFixed(1)}%)');
      }
    }
    
    // إحصائيات الشبكة
    print('\n🌐 إحصائيات الشبكة:');
    for (final entry in stats.entries) {
      if (entry.key.contains('network_') && entry.key.contains('_avg_latency')) {
        final endpoint = entry.key.replaceAll('network_', '').replaceAll('_avg_latency', '');
        final errors = stats['network_${endpoint}_errors'] ?? 0;
        print('  $endpoint: ${entry.value}ms (أخطاء: $errors)');
      }
    }
    
    // معلومات الذاكرة
    print('\n💾 معلومات الذاكرة:');
    print('  الحالية: ${stats['memory_current_mb']} MB');
    print('  الذروة: ${stats['memory_peak_mb']} MB');
    
    print('\n📊 ====================\n');
  }

  /// مسح جميع الإحصائيات
  void clearStats() {
    _operationStartTimes.clear();
    _operationDurations.clear();
    _operationCounts.clear();
    _aiResponseTimes.clear();
    _aiSuccessCount.clear();
    _aiErrorCount.clear();
    _networkLatencies.clear();
    _networkErrors.clear();
    _peakMemoryUsage = 0;
    _currentMemoryUsage = 0;
    
    if (kDebugMode) {
      print('[PERFORMANCE] تم مسح جميع الإحصائيات');
    }
  }
}

/// مزيج لمراقبة الأداء في الـ widgets
mixin PerformanceMonitoringMixin {
  final PerformanceMonitor _monitor = PerformanceMonitor();

  /// قياس بناء الـ widget
  T measureWidgetBuild<T>(String operation, T Function() builder) {
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

/// Global instance
final performanceMonitor = PerformanceMonitor();
