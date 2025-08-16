import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'base_api_service.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';

class OpenRouterService extends BaseApiService {
  static final OpenRouterService _instance = OpenRouterService._internal();
  factory OpenRouterService() => _instance;
  OpenRouterService._internal();

  final _uuid = Uuid();
  String _currentApiKey = '';



  void initialize() {
    if (isInitialized) return;

    // الحصول على مفتاح API من التكوين
    _currentApiKey = AppConfig.openRouterApiKey;
    
    if (_currentApiKey.isEmpty) {
      if (kDebugMode) debugPrint('[OPENROUTER] ⚠️ لا يوجد مفتاح API - سيتم تعطيل الخدمة');
      return;
    }

    // تهيئة الخدمة الأساسية
    initializeBase(
      serviceName: 'OpenRouter',
      baseUrl: 'https://openrouter.ai/api/v1',
      headers: {
        'Authorization': 'Bearer $_currentApiKey',
        'Content-Type': 'application/json',
        'User-Agent': 'Atlas-AI/1.0',
        'HTTP-Referer': 'https://atlas-ai.app', // مطلوب لـ OpenRouter
        'X-Title': 'Atlas AI - Arabic Assistant', // اختياري
      },
    );

    if (kDebugMode) debugPrint('[OPENROUTER] ✅ تم تهيئة الخدمة بنجاح');
  }

  @override
  void updateApiKey(String newApiKey, {String prefix = 'Bearer'}) {
    _currentApiKey = newApiKey;
    super.updateApiKey(newApiKey, prefix: prefix);
    if (kDebugMode) debugPrint('[OPENROUTER] 🔄 تم تحديث مفتاح API');
  }

  /// الحصول على قائمة النماذج المجانية المتاحة
  List<OpenRouterModel> getAvailableModels() {
    final models = <OpenRouterModel>[];
    
    // الحصول على النماذج المجانية من التكوين
    final freeModels = AppConfig.freeModels['openrouter'] ?? [];
    
    for (final modelConfig in freeModels) {
      models.add(OpenRouterModel(
        id: modelConfig['id'] ?? '',
        name: modelConfig['name'] ?? '',
        description: modelConfig['description'] ?? '',
        maxTokens: _parseTokens(modelConfig['context'] ?? '4K tokens'),
        contextLength: _parseTokens(modelConfig['context'] ?? '4K tokens'),
        provider: modelConfig['provider'] ?? 'Unknown',
        isFree: modelConfig['isFree'] ?? false,
        tokens: modelConfig['tokens'] ?? '',
        features: List<String>.from(modelConfig['features'] ?? []),
        speed: modelConfig['speed'] ?? 'متوسط',
        quality: modelConfig['quality'] ?? 'جيد',
      ));
    }
    
    if (kDebugMode) debugPrint('[OPENROUTER] ✅ تم تحميل ${models.length} نموذج مجاني');
    return models;
  }

  /// تحويل نص السياق إلى رقم (مثل "131K tokens" إلى 131000)
  int _parseTokens(String contextText) {
    final regex = RegExp(r'(\d+(?:\.\d+)?)([KM]?)\s*tokens?', caseSensitive: false);
    final match = regex.firstMatch(contextText);
    
    if (match != null) {
      final number = double.tryParse(match.group(1) ?? '0') ?? 0;
      final unit = match.group(2)?.toUpperCase() ?? '';
      
      switch (unit) {
        case 'K':
          return (number * 1000).round();
        case 'M':
          return (number * 1000000).round();
        default:
          return number.round();
      }
    }
    
    return 4096; // قيمة افتراضية
  }

  Future<Stream<String>> sendMessageStream({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  }) async {
    try {
      final requestMessages = <Map<String, dynamic>>[];

      // Add system prompt if provided
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        requestMessages.add({'role': 'system', 'content': systemPrompt});
      }

      // Add attached files content as context
      if (attachedFiles != null && attachedFiles.isNotEmpty) {
        final filesContent = attachedFiles.join('\n\n---\n\n');
        requestMessages.add({
          'role': 'system',
          'content': 'تعليمات إضافية من الملفات المرفقة:\n\n$filesContent',
        });
      }

      // Convert messages to API format
      for (final message in messages) {
        requestMessages.add({
          'role': message.role.name,
          'content': message.content,
        });
      }

      final requestData = {
        'model': model,
        'messages': requestMessages,
        'temperature': temperature ?? 0.7,
        'max_tokens': maxTokens ?? 2048,
        'stream': true,
        // إضافة request ID للتتبع والتشخيص
        'metadata': {
          'request_id': _uuid.v4(),
          'client': 'atlas-ai',
        },
      };

      if (kDebugMode) {
        debugPrint('[OPENROUTER] Sending request to model: $model');
        debugPrint('[OPENROUTER] Request data: ${jsonEncode(requestData)}');
      }

      final response = await post(
        '/chat/completions',
        data: requestData,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      return _parseStreamResponse(response.data);
    } on DioException catch (e) {
      if (kDebugMode) debugPrint('[OPENROUTER DIO ERROR] Type: ${e.type}, Message: ${e.message}');
      
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw OpenRouterException('انتهت مهلة الاتصال مع OpenRouter. تحقق من اتصالك بالإنترنت.');
        case DioExceptionType.receiveTimeout:
          throw OpenRouterException('انتهت مهلة انتظار الاستجابة من OpenRouter.');
        case DioExceptionType.sendTimeout:
          throw OpenRouterException('انتهت مهلة إرسال البيانات لـ OpenRouter.');
        case DioExceptionType.connectionError:
          throw OpenRouterException('فشل الاتصال بخادم OpenRouter.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          switch (statusCode) {
            case 400:
              throw OpenRouterException('خطأ في تنسيق الطلب لـ OpenRouter.');
            case 401:
              throw OpenRouterException('مشكلة في التوثيق مع OpenRouter. تحقق من صحة مفتاح API.');
            case 403:
              throw OpenRouterException('لا يوجد صلاحية للوصول لـ OpenRouter.');
            case 429:
              throw OpenRouterException('تم تجاوز الحد المسموح من الطلبات لـ OpenRouter.');
            case 500:
              throw OpenRouterException('خطأ في خادم OpenRouter.');
            default:
              throw OpenRouterException('خطأ في خادم OpenRouter (رمز: $statusCode).');
          }
        default:
          throw OpenRouterException('خطأ غير متوقع مع OpenRouter: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[OPENROUTER GENERAL ERROR] $e');
      throw OpenRouterException('فشل في إرسال الرسالة لـ OpenRouter: $e');
    }
  }

  Stream<String> _parseStreamResponse(ResponseBody responseBody) async* {
    await for (final Uint8List bytes in responseBody.stream) {
      try {
        final chunk = utf8.decode(bytes, allowMalformed: true);
        final lines = chunk.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();

            if (data == '[DONE]') {
              return;
            }

            if (data.isEmpty) continue;

            try {
              final json = jsonDecode(data);
              final choices = json['choices'] as List?;

              if (choices != null && choices.isNotEmpty) {
                final delta = choices[0]['delta'];
                final content = delta?['content'] as String?;

                if (content != null) {
                  yield content;
                }
              }
            } catch (e) {
              if (kDebugMode) debugPrint('[OPENROUTER PARSE ERROR] Failed to parse: $data, Error: $e');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('[OPENROUTER ENCODING ERROR] Failed to decode chunk: $e');
        continue;
      }
    }
  }

  /// دالة sendMessage الأساسية (API الجديد)
  Future<String> sendMessageWithModelId({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  }) async {
    final stream = await sendMessageStream(
      messages: messages,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
      systemPrompt: systemPrompt,
      attachedFiles: attachedFiles,
    );

    final buffer = StringBuffer();
    await for (final chunk in stream) {
      buffer.write(chunk);
    }

    return buffer.toString();
  }

  /// دالة sendMessage المتوافقة مع ChatProvider (API القديم)
  Future<String> sendMessage({
    required List<MessageModel> messages,
    required String model, // model بدلاً من model
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
    bool? enableAutoFormatting, // إضافة معامل للتحكم في التنسيق
  }) async {
    final response = await sendMessageWithModelId(
      messages: messages,
      model: model, // تمرير model كـ model
      temperature: temperature,
      maxTokens: maxTokens,
      systemPrompt: systemPrompt,
      attachedFiles: attachedFiles,
    );
    
    // تطبيق التنسيق الذكي فقط إذا كان مفعلاً
    if (enableAutoFormatting ?? true) {
      // OpenRouter لا يحتوي على _applySmartFormatting، لذا نعيد النص كما هو
      return response;
    } else {
      return response;
    }
  }

}

class OpenRouterModel {
  final String id;
  final String name;
  final String description;
  final int maxTokens;
  final int contextLength;
  final String provider;
  final bool isFree;
  final String tokens;
  final List<String> features;
  final String speed;
  final String quality;

  OpenRouterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.maxTokens,
    required this.contextLength,
    required this.provider,
    this.isFree = false,
    this.tokens = '',
    this.features = const [],
    this.speed = 'متوسط',
    this.quality = 'جيد',
  });

  @override
  String toString() => '$name ($provider)${isFree ? " - مجاني" : ""}';
  
  /// تحويل إلى Map للعرض في الواجهة
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'maxTokens': maxTokens,
      'contextLength': contextLength,
      'provider': provider,
      'isFree': isFree,
      'tokens': tokens,
      'features': features,
      'speed': speed,
      'quality': quality,
    };
  }
}

class OpenRouterException implements Exception {
  final String message;
  OpenRouterException(this.message);

  @override
  String toString() => 'OpenRouterException: $message';
}
