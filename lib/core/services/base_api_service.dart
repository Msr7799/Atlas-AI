import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';
import '../performance/performance_manager.dart';

/// خدمة API أساسية مشتركة لجميع خدمات API
/// تحتوي على المنطق المشترك لمعالجة الأخطاء، Retry، والإعدادات
/// بالإضافة إلى منطق AI مشترك
abstract class BaseApiService {
  late final Dio _dio;
  bool _isInitialized = false;
  String _serviceName = 'Unknown';

  /// معلومات الخدمة
  String get serviceName => _serviceName;
  bool get isInitialized => _isInitialized;
  String get currentApiKey => _dio.options.headers['Authorization']?.replaceFirst('Bearer ', '') ?? '';
  
  /// الحصول على Dio instance للخدمات الفرعية
  Dio get dio => _dio;
  

  
  /// طباعة رسالة آمنة بدون كشف API keys
  void _logSecure(String message) {
    if (kDebugMode) if (kDebugMode) print('✅ [$_serviceName] $message');
  }

  /// تهيئة الخدمة الأساسية
  void initializeBase({
    required String serviceName,
    required String baseUrl,
    Map<String, String>? headers,
    Duration connectTimeout = const Duration(seconds: 45),
    Duration receiveTimeout = const Duration(seconds: 120),
    Duration sendTimeout = const Duration(seconds: 45),
  }) {
    if (_isInitialized) return;

    _serviceName = serviceName;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: headers ?? {},
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      ),
    );

    // إضافة interceptor للتسجيل (disabled in production)
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
        ),
      );
    }

    // إضافة معالج أخطاء موحد
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (kDebugMode) if (kDebugMode) print('[$_serviceName ERROR] ${error.type}: ${error.message}');
          final processedError = _processError(error);
          handler.reject(processedError);
        },
      ),
    );

    _isInitialized = true;
    if (kDebugMode) if (kDebugMode) print('✅ [$_serviceName] تم تهيئة الخدمة بنجاح');
  }

  /// معالجة الأخطاء الموحدة
  DioException _processError(DioException error) {
    String errorMessage = _getErrorMessage(error);
    
    return DioException(
      requestOptions: error.requestOptions,
      error: errorMessage,
      type: error.type,
      response: error.response,
    );
  }

  /// الحصول على رسالة خطأ مفهومة
  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال مع $_serviceName - تحقق من اتصال الإنترنت';
      
      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة الإرسال لـ $_serviceName - تحقق من سرعة الإنترنت';
      
      case DioExceptionType.receiveTimeout:
        return 'انتهت مهلة الاستقبال من $_serviceName - الخادم بطيء أو محمل بالطلبات';
      
      case DioExceptionType.connectionError:
        return 'فشل الاتصال بخادم $_serviceName - تحقق من الإنترنت وإعدادات الشبكة';
      
      case DioExceptionType.badResponse:
        return _getBadResponseMessage(error.response?.statusCode);
      
      case DioExceptionType.cancel:
        return 'تم إلغاء طلب $_serviceName';
      
      default:
        return 'خطأ غير متوقع مع $_serviceName: ${error.message}';
    }
  }

  /// الحصول على رسالة خطأ للاستجابات السيئة
  String _getBadResponseMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'طلب غير صحيح لـ $_serviceName - تحقق من البيانات المرسلة';
      case 401:
        return 'مشكلة في التوثيق مع $_serviceName - تحقق من صحة مفتاح API';
      case 403:
        return 'لا يوجد صلاحية للوصول لـ $_serviceName - قد تكون الخدمة محظورة أو المفتاح غير صحيح';
      case 429:
        return 'تم تجاوز الحد المسموح من الطلبات لـ $_serviceName - انتظر قليلاً ثم حاول مرة أخرى';
      case 500:
        return 'خطأ في خادم $_serviceName - حاول مرة أخرى لاحقاً';
      case 502:
        return 'خطأ في بوابة $_serviceName - الخادم غير متاح';
      case 503:
        return 'خدمة $_serviceName غير متاحة حالياً - حاول مرة أخرى لاحقاً';
      default:
        return 'خطأ في خادم $_serviceName (رمز: $statusCode)';
    }
  }

  /// نظام إعادة المحاولة مع Exponential Backoff
  Future<T> makeRequestWithRetry<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 2),
    bool shouldSwitchKey = false,
    VoidCallback? onSwitchKey,
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;
    
    while (retryCount < maxRetries) {
      try {
        return await request();
      } catch (e) {
        retryCount++;
        if (kDebugMode) if (kDebugMode) print('[$_serviceName] ❌ محاولة $retryCount/$maxRetries فشلت: $e');
        
        if (retryCount >= maxRetries) {
          if (kDebugMode) if (kDebugMode) print('[$_serviceName] ❌ انتهت جميع المحاولات، فشل الطلب نهائياً');
          rethrow;
        }
        
        // تبديل المفتاح إذا كان مناسباً ومتاحاً
        if (shouldSwitchKey && retryCount == 1 && onSwitchKey != null) {
          if (kDebugMode) if (kDebugMode) print('[$_serviceName] 🔄 محاولة تبديل مفتاح API...');
          onSwitchKey();
        }
        
        // انتظار مع Exponential Backoff
        if (kDebugMode) if (kDebugMode) print('[$_serviceName] ⏳ انتظار ${delay.inSeconds} ثانية قبل المحاولة التالية...');
        await Future.delayed(delay);
        delay = Duration(seconds: (delay.inSeconds * 1.5).round()); // زيادة تدريجية أكثر اعتدالاً
      }
    }
    
    throw Exception('Max retries exceeded for $_serviceName');
  }

  /// تحديث headers (مفيد لتحديث API keys)
  void updateHeaders(Map<String, String> newHeaders) {
    _dio.options.headers.addAll(newHeaders);
    if (kDebugMode) if (kDebugMode) print('✅ [$_serviceName] تم تحديث headers');
  }

  /// تحديث مفتاح API في Authorization header
  void updateApiKey(String newApiKey, {String prefix = 'Bearer'}) {
    _dio.options.headers['Authorization'] = '$prefix $newApiKey';
    _logSecure('تم تحديث مفتاح API');
  }

  /// إرسال طلب POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// إرسال طلب GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// إرسال طلب PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// إرسال طلب DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// إغلاق الاتصالات
  void dispose() {
    if (_isInitialized) {
      try {
        _dio.close();
        if (kDebugMode) if (kDebugMode) print('✅ [$_serviceName] تم إغلاق الاتصالات بنجاح');
      } catch (e) {
        if (kDebugMode) if (kDebugMode) print('⚠️ [$_serviceName] خطأ في إغلاق الاتصالات: $e');
      }
      _isInitialized = false;
    }
  }

  /// الحصول على معلومات الحالة
  Map<String, dynamic> getStatus() {
    return {
      'serviceName': _serviceName,
      'isInitialized': _isInitialized,
      'baseUrl': _dio.options.baseUrl,
      'connectTimeout': _dio.options.connectTimeout?.inSeconds,
      'receiveTimeout': _dio.options.receiveTimeout?.inSeconds,
    };
  }

  /// فحص صحة الخدمة
  Future<bool> performHealthCheck() async {
    if (!_isInitialized) return false;
    
    try {
      // محاولة طلب بسيط للتحقق من صحة الخدمة
      final response = await _dio.get('/health', 
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        )
      );
      return response.statusCode == 200;
    } catch (e) {
      // إذا لم يكن هناك endpoint للصحة، جرب endpoint آخر
      try {
        final response = await _dio.get('/', 
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          )
        );
        return response.statusCode != 404; // أي استجابة غير 404 تعني أن الخدمة تعمل
      } catch (e) {
        return false;
      }
    }
  }

  /// إعادة تهيئة الخدمة
  Future<void> reinitialize() async {
    dispose();
    _isInitialized = false;
    // يجب على الخدمات الفرعية تجاوز هذه الدالة لإعادة التهيئة
  }

  /// معالجة Stream Response مشتركة لجميع الخدمات
  Stream<String> parseStreamResponse(ResponseBody responseBody) async* {
    await for (final Uint8List bytes in responseBody.stream) {
      try {
        final chunk = utf8.decode(bytes, allowMalformed: true);
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            
            if (data == '[DONE]') return;
            if (data.isEmpty) continue;

            try {
              final json = jsonDecode(data);
              final content = json['choices']?[0]?['delta']?['content'];
              if (content != null) yield content;
            } catch (e) {
              // تجاهل أخطاء التحليل
              continue;
            }
          }
        }
      } catch (e) {
        continue; // تجاهل أخطاء الترميز
      }
    }
  }
}

/// خدمة AI أساسية مشتركة لجميع خدمات الذكاء الاصطناعي
/// تحتوي على المنطق المشترك لمعالجة الرسائل والتنسيق
abstract class BaseAIService {
  /// الحصول على اسم الخدمة
  String get serviceName;

  /// تهيئة الخدمة
  Future<void> initialize();

  /// إرسال رسالة والحصول على استجابة كـ Stream
  Stream<String> sendMessageStream({
    required List<MessageModel> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
    List<Map<String, dynamic>>? tools,
  });

  /// إرسال رسالة والحصول على استجابة كـ String
  Future<String> sendMessage({
    required List<MessageModel> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
    List<Map<String, dynamic>>? tools,
    bool? enableAutoFormatting, // إضافة معامل للتحكم في التنسيق
  }) async {
    final stopwatch = Stopwatch()..start();
    bool isSuccess = false;
    String response = '';
    
    try {
      final stream = sendMessageStream(
        messages: messages,
        model: model,
        temperature: temperature,
        maxTokens: maxTokens,
        systemPrompt: systemPrompt,
        attachedFiles: attachedFiles,
        tools: tools,
      );

      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk);
      }

      final rawResponse = buffer.toString();
      
      // تطبيق التنسيق الذكي فقط إذا كان مفعلاً
      if (enableAutoFormatting ?? true) {
        response = _applySmartFormatting(rawResponse);
      } else {
        response = rawResponse;
      }
      
      isSuccess = response.isNotEmpty;
      return response;
    } catch (e) {
      isSuccess = false;
      rethrow;
    } finally {
      stopwatch.stop();
      PerformanceManager.recordAIResponse(
        serviceName.toLowerCase(),
        stopwatch.elapsed,
        isSuccess,
      );
    }
  }

  /// تطبيق التنسيق الذكي على النص
  String _applySmartFormatting(String content) {
    // التنفيذ الافتراضي - يمكن للخدمات تجاوزه
    return content;
  }

  /// إغلاق الخدمة
  void dispose();
}

/// استثناء عام لخدمات API
class ApiServiceException implements Exception {
  final String serviceName;
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiServiceException({
    required this.serviceName,
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => '[$serviceName] $message${statusCode != null ? ' (Code: $statusCode)' : ''}';
}
