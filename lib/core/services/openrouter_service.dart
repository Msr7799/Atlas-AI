import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../data/models/message_model.dart';

class OpenRouterService {
  static final OpenRouterService _instance = OpenRouterService._internal();
  factory OpenRouterService() => _instance;
  OpenRouterService._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://openrouter.ai/api/v1',
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'Atlas-AI/1.0',
        },
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 45),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[OPENROUTER API] $object'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('[OPENROUTER ERROR] Type: ${error.type}, Message: ${error.message}');
          if (error.type == DioExceptionType.connectionTimeout) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Connection timeout - check your internet connection',
                type: DioExceptionType.connectionTimeout,
              ),
            );
          } else if (error.type == DioExceptionType.connectionError) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Network connection error - check your internet connection',
                type: DioExceptionType.connectionError,
              ),
            );
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  /// تحديث مفتاح API
  void updateApiKey(String newApiKey) {
    _dio.options.headers['Authorization'] = 'Bearer $newApiKey';
  }

  /// الحصول على قائمة النماذج المتاحة
  List<OpenRouterModel> getAvailableModels() {
    return [
      OpenRouterModel(
        id: 'openai/gpt-3.5-turbo',
        name: 'GPT-3.5 Turbo',
        description: 'نموذج GPT-3.5 Turbo من OpenAI',
        maxTokens: 4096,
        contextLength: 4096,
        provider: 'OpenAI',
      ),
      OpenRouterModel(
        id: 'openai/gpt-4',
        name: 'GPT-4',
        description: 'نموذج GPT-4 من OpenAI',
        maxTokens: 8192,
        contextLength: 8192,
        provider: 'OpenAI',
      ),
      OpenRouterModel(
        id: 'openai/gpt-4-turbo',
        name: 'GPT-4 Turbo',
        description: 'نموذج GPT-4 Turbo من OpenAI',
        maxTokens: 128000,
        contextLength: 128000,
        provider: 'OpenAI',
      ),
      OpenRouterModel(
        id: 'anthropic/claude-3-haiku',
        name: 'Claude 3 Haiku',
        description: 'نموذج Claude 3 Haiku من Anthropic',
        maxTokens: 4096,
        contextLength: 4096,
        provider: 'Anthropic',
      ),
      OpenRouterModel(
        id: 'anthropic/claude-3-sonnet',
        name: 'Claude 3 Sonnet',
        description: 'نموذج Claude 3 Sonnet من Anthropic',
        maxTokens: 4096,
        contextLength: 4096,
        provider: 'Anthropic',
      ),
      OpenRouterModel(
        id: 'anthropic/claude-3-opus',
        name: 'Claude 3 Opus',
        description: 'نموذج Claude 3 Opus من Anthropic',
        maxTokens: 4096,
        contextLength: 4096,
        provider: 'Anthropic',
      ),
      OpenRouterModel(
        id: 'google/gemini-pro',
        name: 'Gemini Pro',
        description: 'نموذج Gemini Pro من Google',
        maxTokens: 8192,
        contextLength: 8192,
        provider: 'Google',
      ),
      OpenRouterModel(
        id: 'meta-llama/llama-2-13b-chat',
        name: 'Llama 2 13B Chat',
        description: 'نموذج Llama 2 13B من Meta',
        maxTokens: 4096,
        contextLength: 4096,
        provider: 'Meta',
      ),
      OpenRouterModel(
        id: 'meta-llama/llama-2-70b-chat',
        name: 'Llama 2 70B Chat',
        description: 'نموذج Llama 2 70B من Meta',
        maxTokens: 4096,
        contextLength: 4096,
        provider: 'Meta',
      ),
      OpenRouterModel(
        id: 'mistralai/mistral-7b-instruct',
        name: 'Mistral 7B Instruct',
        description: 'نموذج Mistral 7B من Mistral AI',
        maxTokens: 4096,
        contextLength: 4096,
        provider: 'Mistral AI',
      ),
      OpenRouterModel(
        id: 'mistralai/mixtral-8x7b-instruct',
        name: 'Mixtral 8x7B Instruct',
        description: 'نموذج Mixtral 8x7B من Mistral AI',
        maxTokens: 4096,
        contextLength: 4096,
        provider: 'Mistral AI',
      ),
    ];
  }

  Future<Stream<String>> sendMessageStream({
    required List<MessageModel> messages,
    required String modelId,
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
        'model': modelId,
        'messages': requestMessages,
        'temperature': temperature ?? 0.7,
        'max_tokens': maxTokens ?? 2048,
        'stream': true,
      };

      print('[OPENROUTER] Sending request to model: $modelId');
      print('[OPENROUTER] Request data: ${jsonEncode(requestData)}');

      final response = await _dio.post(
        '/chat/completions',
        data: requestData,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      return _parseStreamResponse(response.data);
    } on DioException catch (e) {
      print('[OPENROUTER DIO ERROR] Type: ${e.type}, Message: ${e.message}');
      
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
      print('[OPENROUTER GENERAL ERROR] $e');
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
              print('[OPENROUTER PARSE ERROR] Failed to parse: $data, Error: $e');
            }
          }
        }
      } catch (e) {
        print('[OPENROUTER ENCODING ERROR] Failed to decode chunk: $e');
        continue;
      }
    }
  }

  Future<String> sendMessage({
    required List<MessageModel> messages,
    required String modelId,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  }) async {
    final stream = await sendMessageStream(
      messages: messages,
      modelId: modelId,
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

  void dispose() {
    _dio.close();
  }
}

class OpenRouterModel {
  final String id;
  final String name;
  final String description;
  final int maxTokens;
  final int contextLength;
  final String provider;

  OpenRouterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.maxTokens,
    required this.contextLength,
    required this.provider,
  });

  @override
  String toString() => '$name ($provider)';
}

class OpenRouterException implements Exception {
  final String message;
  OpenRouterException(this.message);

  @override
  String toString() => 'OpenRouterException: $message';
}
