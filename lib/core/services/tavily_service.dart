import 'package:dio/dio.dart';
import '../config/app_config.dart';

class TavilyService {
  static final TavilyService _instance = TavilyService._internal();
  factory TavilyService() => _instance;
  TavilyService._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[TAVILY API] $object'),
      ),
    );
  }

  Future<TavilySearchResult> search({
    required String query,
    int maxResults = 5,
    bool includeImages = false,
    bool includeAnswer = true,
    String searchDepth = 'basic',
  }) async {
    try {
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

      return TavilySearchResult.fromJson(response.data);
    } catch (e) {
      print('[TAVILY SEARCH ERROR] $e');
      throw TavilyException('Failed to search: $e');
    }
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
      print('[TAVILY EXTRACT ERROR] $e');
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
      print('[TAVILY CRAWL ERROR] $e');
      throw TavilyException('Failed to crawl: $e');
    }
  }

  /// تحديث مفتاح API
  void updateApiKey(String newApiKey) {
    // لا حاجة لتحديث headers لأن Tavily يستخدم API key في البيانات
    // يمكن إضافة أي منطق إضافي هنا إذا لزم الأمر
  }

  void dispose() {
    _dio.close();
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
