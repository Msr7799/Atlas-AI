import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

/// محسن الشبكة للتطبيق
class NetworkOptimizer {
  static final Map<String, dynamic> _cache = {};
  static const int _maxCacheSize = 50;
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// إعدادات HTTP محسّنة
  static final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'ArabicAgent/1.0',
  };

  /// طلب GET محسّن
  static Future<http.Response> optimizedGet(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final cacheKey = 'GET:$url';
    
    // التحقق من الذاكرة المؤقتة
    if (_isCacheValid(cacheKey)) {
      return _getCachedResponse(cacheKey);
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
      ).timeout(timeout ?? const Duration(seconds: 10));

      // حفظ في الذاكرة المؤقتة
      _cacheResponse(cacheKey, response);

      return response;
    } catch (e) {
      // إعادة المحاولة مرة واحدة
      return await _retryRequest(() => http.get(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
      ));
    }
  }

  /// طلب POST محسّن
  static Future<http.Response> optimizedPost(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is Map ? jsonEncode(body) : body,
      ).timeout(timeout ?? const Duration(seconds: 15));

      return response;
    } catch (e) {
      // إعادة المحاولة مرة واحدة
      return await _retryRequest(() => http.post(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is Map ? jsonEncode(body) : body,
      ));
    }
  }

  /// طلب PUT محسّن
  static Future<http.Response> optimizedPut(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is Map ? jsonEncode(body) : body,
      ).timeout(timeout ?? const Duration(seconds: 15));

      return response;
    } catch (e) {
      // إعادة المحاولة مرة واحدة
      return await _retryRequest(() => http.put(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is Map ? jsonEncode(body) : body,
      ));
    }
  }

  /// طلب DELETE محسّن
  static Future<http.Response> optimizedDelete(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is Map ? jsonEncode(body) : body,
      ).timeout(timeout ?? const Duration(seconds: 10));

      return response;
    } catch (e) {
      // إعادة المحاولة مرة واحدة
      return await _retryRequest(() => http.delete(
        Uri.parse(url),
        headers: {..._defaultHeaders, ...?headers},
        body: body is Map ? jsonEncode(body) : body,
      ));
    }
  }

  /// إعادة المحاولة مع تأخير
  static Future<http.Response> _retryRequest(
    Future<http.Response> Function() request,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    return await request();
  }

  /// حفظ الاستجابة في الذاكرة المؤقتة
  static void _cacheResponse(String key, http.Response response) {
    if (_cache.length >= _maxCacheSize) {
      // إزالة العنصر الأقدم
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
      _cacheTimestamps.remove(oldestKey);
    }

    _cache[key] = response;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// التحقق من صلاحية الذاكرة المؤقتة
  static bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// الحصول على استجابة من الذاكرة المؤقتة
  static http.Response _getCachedResponse(String key) {
    return _cache[key] as http.Response;
  }

  /// تنظيف الذاكرة المؤقتة
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  /// الحصول على حجم الذاكرة المؤقتة
  static int getCacheSize() {
    return _cache.length;
  }

  /// تحسين تحميل البيانات
  static Future<List<dynamic>> optimizedLoadData(
    List<String> urls, {
    Duration? timeout,
  }) async {
    final futures = urls.map((url) => optimizedGet(url, timeout: timeout));
    final responses = await Future.wait(futures);
    
    return responses.map((response) {
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    }).where((data) => data != null).toList();
  }
}

/// مدير الاتصال بالشبكة
class NetworkManager {
  static bool _isConnected = true;
  static final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  /// التحقق من الاتصال
  static bool get isConnected => _isConnected;

  /// تيار حالة الاتصال
  static Stream<bool> get connectionStream => _connectionController.stream;

  /// تحديث حالة الاتصال
  static void updateConnectionStatus(bool connected) {
    _isConnected = connected;
    _connectionController.add(connected);
  }

  /// إغلاق مدير الشبكة
  static void dispose() {
    _connectionController.close();
  }
}

/// محسن الطلبات المتزامنة
class BatchRequestOptimizer {
  static final List<Future<http.Response>> _pendingRequests = [];
  static Timer? _batchTimer;
  static const Duration _batchDelay = Duration(milliseconds: 100);

  /// إضافة طلب للدفعة
  static Future<http.Response> addToBatch(
    Future<http.Response> Function() request,
  ) async {
    final completer = Completer<http.Response>();
    
    _pendingRequests.add(request().then((response) {
      completer.complete(response);
      return response;
    }));

    // بدء معالجة الدفعة
    _startBatchProcessing();

    return completer.future;
  }

  /// بدء معالجة الدفعة
  static void _startBatchProcessing() {
    if (_batchTimer != null) return;

    _batchTimer = Timer(_batchDelay, () {
      _processBatch();
    });
  }

  /// معالجة الدفعة
  static Future<void> _processBatch() async {
    _batchTimer?.cancel();
    _batchTimer = null;

    if (_pendingRequests.isEmpty) return;

    final requests = List<Future<http.Response>>.from(_pendingRequests);
    _pendingRequests.clear();

    try {
      await Future.wait(requests);
    } catch (e) {
      // معالجة الأخطاء
    }
  }

  /// تنظيف الطلبات المعلقة
  static void clearPendingRequests() {
    _pendingRequests.clear();
    _batchTimer?.cancel();
    _batchTimer = null;
  }
} 