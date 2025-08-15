import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class TavilyService {
  static final TavilyService _instance = TavilyService._internal();
  factory TavilyService() => _instance;
  TavilyService._internal();

  late final Dio _dio;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 45),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          if (kDebugMode) print('[TAVILY API] $object');
        },
      ),
    );

    // إضافة معالج أخطاء مخصص
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (kDebugMode) print('[TAVILY ERROR] ${error.type}: ${error.message}');
          _handleError(error);
          handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  /// معالج أخطاء محسن
  void _handleError(DioException error) {
    String errorMessage = 'خطأ غير معروف';
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'انتهت مهلة الاتصال - تحقق من اتصال الإنترنت';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'انتهت مهلة الإرسال - تحقق من سرعة الإنترنت';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'انتهت مهلة الاستقبال - الخادم بطيء';
        break;
      case DioExceptionType.connectionError:
        errorMessage = 'خطأ في الاتصال - تحقق من إعدادات الشبكة';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            errorMessage = 'طلب بحث غير صحيح';
            break;
          case 401:
            errorMessage = 'مفتاح API غير صحيح';
            break;
          case 403:
            errorMessage = 'غير مصرح بالوصول لخدمة البحث';
            break;
          case 429:
            errorMessage = 'معدل البحث مرتفع - انتظر قليلاً';
            break;
          case 500:
            errorMessage = 'خطأ في خادم البحث - حاول لاحقاً';
            break;
          default:
            errorMessage = 'خطأ في خادم البحث (كود $statusCode)';
        }
        break;
      default:
        errorMessage = 'خطأ في البحث: ${error.message}';
    }
    
    if (kDebugMode) print('[TAVILY ERROR] $errorMessage');
    throw TavilyException(errorMessage);
  }

  Future<TavilySearchResult> search({
    required String query,
    int maxResults = 5,
    bool includeImages = false,
    bool includeAnswer = true,
    String searchDepth = 'basic',
  }) async {
    return await searchWithRetry(
      query: query,
      maxResults: maxResults,
      includeImages: includeImages,
      includeAnswer: includeAnswer,
      searchDepth: searchDepth,
    );
  }

  /// البحث مع إعادة المحاولة عند فشل الشبكة
  Future<TavilySearchResult> searchWithRetry({
    required String query,
    int maxResults = 5,
    bool includeImages = false,
    bool includeAnswer = true,
    String searchDepth = 'basic',
    int maxRetries = 3,
  }) async {
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (kDebugMode) print('[TAVILY] 🔍 محاولة البحث ${attempt + 1}/$maxRetries للاستعلام: $query');
        
        final requestData = {
          'api_key': AppConfig.tavilyApiKey,
          'query': query,
          'max_results': maxResults,
          'include_images': includeImages,
          'include_answer': includeAnswer,
          'search_depth': searchDepth,
        };

        final response = await _dio.post(
          'https://api.tavily.com/search',
          data: requestData,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (kDebugMode) print('[TAVILY] ✅ نجح البحث في المحاولة ${attempt + 1}');
        return TavilySearchResult.fromJson(response.data);
        
      } catch (e) {
        if (kDebugMode) print('[TAVILY] ❌ فشلت المحاولة ${attempt + 1}: $e');
        
        // إذا كانت هذه آخر محاولة، ارمي الخطأ
        if (attempt == maxRetries - 1) {
          if (kDebugMode) print('[TAVILY] 🚫 فشل البحث نهائياً بعد $maxRetries محاولات');
          throw TavilyException('Failed to search after $maxRetries attempts: $e');
        }
        
        // انتظار متزايد بين المحاولات (exponential backoff)
        final delaySeconds = (attempt + 1) * 2; // 2, 4, 6 ثواني
        if (kDebugMode) print('[TAVILY] ⏳ انتظار $delaySeconds ثانية قبل إعادة المحاولة...');
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
    
    throw TavilyException('Unexpected error in searchWithRetry');
  }

  Future<TavilyExtractResult> extract({required List<String> urls}) async {
    try {
      final requestData = {'api_key': AppConfig.tavilyApiKey, 'urls': urls};

      final response = await _dio.post(
        'https://api.tavily.com/extract',
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return TavilyExtractResult.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) print('[TAVILY EXTRACT ERROR] $e');
      throw TavilyException('Failed to extract: $e');
    }
  }

  Future<TavilyCrawlResult> crawl({
    required String url,
    int maxDepth = 1,
  }) async {
    try {
      final requestData = {
        'api_key': AppConfig.tavilyApiKey,
        'url': url,
        'max_depth': maxDepth,
      };

      final response = await _dio.post(
        'https://api.tavily.com/crawl',
        data: requestData,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      return TavilyCrawlResult.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) print('[TAVILY CRAWL ERROR] $e');
      throw TavilyException('Failed to crawl: $e');
    }
  }

  /// تحديث مفتاح API
  void updateApiKey(String newApiKey) {
    // لا حاجة لتحديث headers لأن Tavily يستخدم API key في البيانات
    // يمكن إضافة أي منطق إضافي هنا إذا لزم الأمر
  }

  void dispose() {
    if (_isInitialized) {
      try {
        _dio.close();
      } catch (e) {
        if (kDebugMode) print('[TAVILY DISPOSE ERROR] $e');
      }
    }
    _isInitialized = false;
  }
}

class TavilySearchResult {
  final String? answer;
  final List<TavilyResult> results;
  final String query;
  final double responseTime;

  TavilySearchResult({
    this.answer,
    required this.results,
    required this.query,
    required this.responseTime,
  });

  factory TavilySearchResult.fromJson(Map<String, dynamic> json) {
    return TavilySearchResult(
      answer: json['answer'],
      results: (json['results'] as List)
          .map((r) => TavilyResult.fromJson(r))
          .toList(),
      query: json['query'],
      responseTime: (json['response_time'] as num).toDouble(),
    );
  }
}

class TavilyResult {
  final String title;
  final String url;
  final String content;
  final double score;
  final String? publishedDate;

  TavilyResult({
    required this.title,
    required this.url,
    required this.content,
    required this.score,
    this.publishedDate,
  });

  factory TavilyResult.fromJson(Map<String, dynamic> json) {
    return TavilyResult(
      title: json['title'],
      url: json['url'],
      content: json['content'],
      score: (json['score'] as num).toDouble(),
      publishedDate: json['published_date'],
    );
  }
}

class TavilyExtractResult {
  final List<TavilyExtractedContent> results;
  final bool success;

  TavilyExtractResult({required this.results, required this.success});

  factory TavilyExtractResult.fromJson(Map<String, dynamic> json) {
    return TavilyExtractResult(
      results: (json['results'] as List)
          .map((r) => TavilyExtractedContent.fromJson(r))
          .toList(),
      success: json['success'],
    );
  }
}

class TavilyExtractedContent {
  final String url;
  final String content;
  final String? title;
  final bool success;

  TavilyExtractedContent({
    required this.url,
    required this.content,
    this.title,
    required this.success,
  });

  factory TavilyExtractedContent.fromJson(Map<String, dynamic> json) {
    return TavilyExtractedContent(
      url: json['url'],
      content: json['content'],
      title: json['title'],
      success: json['success'],
    );
  }
}

class TavilyCrawlResult {
  final String url;
  final List<String> urls;
  final Map<String, String> content;
  final bool success;

  TavilyCrawlResult({
    required this.url,
    required this.urls,
    required this.content,
    required this.success,
  });

  factory TavilyCrawlResult.fromJson(Map<String, dynamic> json) {
    return TavilyCrawlResult(
      url: json['url'],
      urls: List<String>.from(json['urls']),
      content: Map<String, String>.from(json['content']),
      success: json['success'],
    );
  }
}

class TavilyException implements Exception {
  final String message;
  TavilyException(this.message);

  @override
  String toString() => 'TavilyException: $message';
}
