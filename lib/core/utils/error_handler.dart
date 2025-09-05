import 'package:flutter/foundation.dart';

/// معالج الأخطاء الموحد للتطبيق
class ErrorHandler {
  static final List<String> _errorLog = [];
  static const int _maxLogSize = 100;

  /// معالجة خطأ عام
  static void handleError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? metadata,
  }) {
    try {
      // تسجيل الخطأ محلياً
      _logError(error, stackTrace, context);

      // في وضع التطوير: طباعة تفصيلية
      if (kDebugMode) {
        _printDebugError(error, stackTrace, context, metadata);
      }

      // في الإنتاج: إرسال للتحليلات (يمكن إضافته لاحقاً)
      if (kReleaseMode) {
        _sendToCrashlytics(error, stackTrace, metadata);
      }
    } catch (e) {
      // تجنب infinite loop في حالة خطأ في معالج الأخطاء نفسه
      if (kDebugMode) {
        print('❌ [ERROR_HANDLER] خطأ في معالج الأخطاء: $e');
      }
    }
  }

  /// تسجيل خطأ محلياً
  static void _logError(dynamic error, StackTrace? stackTrace, String? context) {
    final timestamp = DateTime.now().toIso8601String();
    final contextStr = context != null ? '[$context] ' : '';
    final errorMessage = '$timestamp: $contextStr$error';

    _errorLog.add(errorMessage);

    // الاحتفاظ بآخر 100 خطأ فقط
    if (_errorLog.length > _maxLogSize) {
      _errorLog.removeAt(0);
    }
  }

  /// طباعة خطأ مفصل في وضع التطوير
  static void _printDebugError(
    dynamic error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? metadata,
  ) {
    print('┌─────────────────────────────────────────────────────────────');
    print('│ ❌ ERROR DETECTED');
    if (context != null) {
      print('│ 📍 Context: $context');
    }
    print('│ 🔍 Error: $error');
    if (metadata != null && metadata.isNotEmpty) {
      print('│ 📊 Metadata: $metadata');
    }
    if (stackTrace != null) {
      print('│ 📚 Stack Trace:');
      final stackLines = stackTrace.toString().split('\n');
      for (int i = 0; i < stackLines.length && i < 5; i++) {
        print('│   ${stackLines[i]}');
      }
      if (stackLines.length > 5) {
        print('│   ... (${stackLines.length - 5} more lines)');
      }
    }
    print('└─────────────────────────────────────────────────────────────');
  }

  /// إرسال للتحليلات (placeholder للمستقبل)
  static void _sendToCrashlytics(
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  ) {
    // TODO: إضافة Firebase Crashlytics أو أي خدمة تحليلات أخرى
    // FirebaseCrashlytics.instance.recordError(error, stackTrace, metadata: metadata);
  }

  /// الحصول على سجل الأخطاء
  static List<String> getErrorLog() {
    return List.from(_errorLog);
  }

  /// تنظيف سجل الأخطاء
  static void clearErrorLog() {
    _errorLog.clear();
  }

  /// معالجة خطأ شبكة
  static void handleNetworkError(
    dynamic error, {
    String? url,
    int? statusCode,
  }) {
    handleError(
      error,
      null,
      context: 'NETWORK',
      metadata: {
        'url': url,
        'statusCode': statusCode,
      },
    );
  }

  /// معالجة خطأ قاعدة البيانات
  static void handleDatabaseError(
    dynamic error,
    StackTrace? stackTrace, {
    String? operation,
    String? table,
  }) {
    handleError(
      error,
      stackTrace,
      context: 'DATABASE',
      metadata: {
        'operation': operation,
        'table': table,
      },
    );
  }

  /// معالجة خطأ AI
  static void handleAIError(
    dynamic error,
    StackTrace? stackTrace, {
    String? service,
    String? model,
  }) {
    handleError(
      error,
      stackTrace,
      context: 'AI_SERVICE',
      metadata: {
        'service': service,
        'model': model,
      },
    );
  }

  /// معالجة خطأ UI
  static void handleUIError(
    dynamic error,
    StackTrace? stackTrace, {
    String? widget,
    String? action,
  }) {
    handleError(
      error,
      stackTrace,
      context: 'UI',
      metadata: {
        'widget': widget,
        'action': action,
      },
    );
  }
}
