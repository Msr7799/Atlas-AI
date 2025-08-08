import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../../data/models/message_model.dart';

// في بداية الملف، يحتاج استيراد إضافي لـ ApiKeyManager
class GroqService {
  static final GroqService _instance = GroqService._internal();
  factory GroqService() => _instance;
  GroqService._internal();

  late final Dio _dio;
  bool _isInitialized = false;
  String _currentApiKey = '';

  void initialize() {
    if (_isInitialized) return; // منع التهيئة المتكررة

    // جرب المفتاح الأساسي أولاً، ثم الاحتياطي
    String apiKey = AppConfig.groqApiKey;
    if (apiKey.isEmpty || apiKey.startsWith('gsk_انشئ_مفتاح')) {
      apiKey = AppConfig.groqApiKey2;
      print('[GROQ] 🔄 استخدام المفتاح الاحتياطي');
    }

    _currentApiKey = apiKey;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.groqBaseUrl,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'User-Agent': 'Atlas-AI/1.0',
        },
        connectTimeout: const Duration(seconds: 45), // زيادة وقت الاتصال
        receiveTimeout: const Duration(
          seconds: 120,
        ), // زيادة وقت الاستقبال لدقيقتين
        sendTimeout: const Duration(seconds: 45), // زيادة وقت الإرسال أيضاً
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[GROQ API] $object'),
      ),
    );

    // إضافة معالج أخطاء مخصص
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print('[GROQ ERROR] ${error.type}: ${error.message}');

          // إذا كان خطأ 403، جرب تبديل المفتاح
          if (error.response?.statusCode == 403) {
            print('[GROQ] ❌ خطأ 403 - جاري تجربة المفتاح الاحتياطي...');
            _tryFallbackKey();
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error:
                    'لا يوجد صلاحية للوصول لـ Groq. قد تكون الخدمة محظورة أو المفتاح غير صحيح.',
                type: DioExceptionType.badResponse,
              ),
            );
          } else if (error.type == DioExceptionType.connectionTimeout) {
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
                error:
                    'Network connection error - check your internet connection and DNS settings',
                type: DioExceptionType.connectionError,
              ),
            );
          } else {
            handler.next(error);
          }
        },
      ),
    );

    _isInitialized = true; // تأكيد التهيئة
  }

  /// تجربة المفتاح الاحتياطي عند فشل المفتاح الأساسي
  void _tryFallbackKey() {
    if (_currentApiKey == AppConfig.groqApiKey &&
        AppConfig.groqApiKey2.isNotEmpty) {
      print('[GROQ] 🔄 تبديل للمفتاح الاحتياطي...');
      _currentApiKey = AppConfig.groqApiKey2;
      _dio.options.headers['Authorization'] = 'Bearer ${AppConfig.groqApiKey2}';
    } else if (_currentApiKey == AppConfig.groqApiKey2 &&
        AppConfig.groqApiKey.isNotEmpty) {
      print('[GROQ] 🔄 تبديل للمفتاح الأساسي...');
      _currentApiKey = AppConfig.groqApiKey;
      _dio.options.headers['Authorization'] = 'Bearer ${AppConfig.groqApiKey}';
    }
  }

  /// تحديث مفتاح API
  void updateApiKey(String newApiKey) {
    _currentApiKey = newApiKey;
    _dio.options.headers['Authorization'] = 'Bearer $newApiKey';
  }

  /// تجربة المفتاح الاحتياطي إذا فشل الأول
  Future<bool> _tryAlternativeKey() async {
    try {
      final altKey = AppConfig.groqApiKey2;
      if (altKey.isNotEmpty && altKey != _currentApiKey) {
        print('[GROQ] 🔄 Trying alternative API key...');
        updateApiKey(altKey);
        return true;
      }
    } catch (e) {
      print('[GROQ] ❌ Failed to switch to alternative key: $e');
    }
    return false;
  }

  Future<Stream<String>> sendMessageStream({
    required List<MessageModel> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
    List<Map<String, dynamic>>? tools,
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
        'messages': requestMessages,
        'model': model ?? AppConfig.defaultModel,
        'temperature': temperature ?? AppConfig.defaultTemperature,
        'max_completion_tokens': maxTokens ?? AppConfig.defaultMaxTokens,
        'top_p': AppConfig.defaultTopP,
        'stream': true,
        'stop': null,
      };

      // إضافة الأدوات إذا كانت متوفرة
      if (tools != null && tools.isNotEmpty) {
        requestData['tools'] = tools;
        requestData['tool_choice'] = 'auto';
      }

      print('[GROQ] 🚀 Sending request to Groq API...');
      print('[GROQ] 📝 Request data: ${jsonEncode(requestData)}');

      final response = await _dio.post(
        AppConfig.groqChatEndpoint,
        data: requestData,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      return _parseStreamResponse(response.data);
    } on DioException catch (e) {
      print('[GROQ DIO ERROR] Type: ${e.type}, Message: ${e.message}');
      print(
        '[GROQ DIO ERROR] Response: ${e.response?.statusCode} - ${e.response?.data}',
      );

      // معالجة أنواع مختلفة من الأخطاء مع رسائل عربية واضحة
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw GroqException(
            'انتهت مهلة الاتصال مع خادم Groq. تحقق من اتصالك بالإنترنت.',
          );
        case DioExceptionType.receiveTimeout:
          throw GroqException(
            'انتهت مهلة انتظار الاستجابة من Groq. الخادم بطيء أو محمل بالطلبات.',
          );
        case DioExceptionType.sendTimeout:
          throw GroqException(
            'انتهت مهلة إرسال البيانات لـ Groq. تحقق من سرعة الإنترنت.',
          );
        case DioExceptionType.connectionError:
          throw GroqException(
            'فشل الاتصال بخادم Groq. تحقق من الإنترنت وتأكد من إمكانية الوصول لـ api.groq.com',
          );
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          switch (statusCode) {
            case 400:
              throw GroqException(
                'خطأ في تنسيق الطلب لـ Groq. تحقق من صحة البيانات المرسلة.',
              );
            case 401:
              throw GroqException(
                'مشكلة في التوثيق مع Groq. تحقق من صحة مفتاح API.',
              );
            case 403:
              // جرب المفتاح الاحتياطي
              if (await _tryAlternativeKey()) {
                print('[GROQ] 🔄 Retrying with alternative key...');
                // إعادة المحاولة مع المفتاح الجديد
                return sendMessageStream(
                  messages: messages,
                  model: model,
                  temperature: temperature,
                  maxTokens: maxTokens,
                  systemPrompt: systemPrompt,
                  attachedFiles: attachedFiles,
                  tools: tools,
                );
              }
              throw GroqException(
                'لا يوجد صلاحية للوصول لـ Groq. قد تكون الخدمة محظورة أو المفتاح غير صحيح.',
              );
            case 429:
              throw GroqException(
                'تم تجاوز الحد المسموح من الطلبات لـ Groq. انتظر قليلاً ثم حاول مرة أخرى.',
              );
            case 500:
              throw GroqException('خطأ في خادم Groq. حاول مرة أخرى لاحقاً.');
            case 503:
              throw GroqException(
                'خدمة Groq غير متاحة حالياً. حاول مرة أخرى لاحقاً.',
              );
            default:
              throw GroqException(
                'خطأ في خادم Groq (رمز: $statusCode). تفاصيل: ${e.response?.data}',
              );
          }
        case DioExceptionType.cancel:
          throw GroqException('تم إلغاء طلب Groq.');
        default:
          throw GroqException('خطأ غير متوقع مع Groq: ${e.message}');
      }
    } catch (e) {
      print('[GROQ GENERAL ERROR] $e');
      throw GroqException('فشل في إرسال الرسالة لـ Groq: $e');
    }
  }

  Stream<String> _parseStreamResponse(ResponseBody responseBody) async* {
    print('[GROQ] 📡 Response received, parsing stream...');

    await for (final Uint8List bytes in responseBody.stream) {
      print('[GROQ] 📦 Received chunk: ${bytes.length} bytes');
      try {
        // معالجة آمنة للترميز مع السماح بالأخطاء
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
                  print('[GROQ] 💬 Yielding content: ${content.length} chars');
                  yield content;
                }
              }
            } catch (e) {
              print('[GROQ PARSE ERROR] Failed to parse: $data, Error: $e');
            }
          }
        }
      } catch (e) {
        print('[GROQ ENCODING ERROR] Failed to decode chunk: $e');
        // تجاهل الأجزاء التالفة ومتابعة المعالجة
        continue;
      }
    }
  }

  Future<String> sendMessage({
    required List<MessageModel> messages,
    String? model,
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

  // Sequential Thinking Integration
  Stream<ThinkingStepModel> generateThinkingProcess({
    required String query,
    int? totalThoughts,
  }) async* {
    try {
      final requestData = {
        'messages': [
          {'role': 'user', 'content': query},
        ],
        'model': AppConfig.defaultModel,
        'temperature': 0.7,
        'max_completion_tokens': 2048,
        'stream': true,
      };

      final response = await _dio.post(
        AppConfig.groqChatEndpoint,
        data: requestData,
        options: Options(responseType: ResponseType.stream),
      );

      int stepNumber = 1;
      final buffer = StringBuffer();

      await for (final chunk in _parseStreamResponse(response.data)) {
        buffer.write(chunk);

        // Simulate thinking steps based on content
        if (chunk.contains('\n') || chunk.contains('.')) {
          if (buffer.length > 50) {
            yield ThinkingStepModel(
              stepNumber: stepNumber++,
              content: buffer.toString().trim(),
              timestamp: DateTime.now(),
            );
            buffer.clear();
          }
        }
      }

      // Final step if buffer has content
      if (buffer.isNotEmpty) {
        yield ThinkingStepModel(
          stepNumber: stepNumber,
          content: buffer.toString().trim(),
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      print('[THINKING ERROR] $e');
      throw GroqException('Failed to generate thinking process: $e');
    }
  }

  void dispose() {
    _dio.close();
  }
}

class GroqException implements Exception {
  final String message;
  GroqException(this.message);

  @override
  String toString() => 'GroqException: $message';
}
