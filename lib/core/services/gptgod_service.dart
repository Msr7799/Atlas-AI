import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../../data/models/message_model.dart';

class GPTGodService {
  static final GPTGodService _instance = GPTGodService._internal();
  factory GPTGodService() => _instance;
  GPTGodService._internal();

  late final Dio _dio;
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return; // منع التهيئة المتكررة

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.gptGodBaseUrl,
        headers: {
          'Authorization': 'Bearer ${AppConfig.gptGodApiKey}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30), // تقليل وقت الاتصال
        receiveTimeout: const Duration(seconds: 30), // تقليل وقت الاستقبال
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[GPTGOD API] $object'),
      ),
    );

    _isInitialized = true; // تأكيد التهيئة
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
        'model': model ?? 'gpt-3.5-turbo',
        'temperature': temperature ?? AppConfig.defaultTemperature,
        'max_tokens': maxTokens ?? AppConfig.defaultMaxTokens,
        'top_p': AppConfig.defaultTopP,
        'stream': true,
        'stop': null,
      };

      // إضافة الأدوات إذا كانت متوفرة
      if (tools != null && tools.isNotEmpty) {
        requestData['tools'] = tools;
        requestData['tool_choice'] = 'auto';
      }

      print('[GPTGOD] 🤖 استخدام نموذج: ${model ?? 'gpt-3.5-turbo'}');
      print('[GPTGOD] Sending request: ${jsonEncode(requestData)}');

      final response = await _dio.post(
        AppConfig.gptGodChatEndpoint,
        data: requestData,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      return _parseStreamResponse(response.data);
    } catch (e) {
      print('[GPTGOD ERROR] $e');

      // معالجة أنواع مختلفة من الأخطاء
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            throw GPTGodException(
              'انتهت مهلة الاتصال مع الخادم. تحقق من اتصالك بالإنترنت.',
            );
          case DioExceptionType.receiveTimeout:
            throw GPTGodException(
              'انتهت مهلة انتظار الاستجابة. الخادم بطيء أو محمل بالطلبات.',
            );
          case DioExceptionType.sendTimeout:
            throw GPTGodException(
              'انتهت مهلة إرسال البيانات. تحقق من سرعة الإنترنت.',
            );
          case DioExceptionType.badResponse:
            final statusCode = e.response?.statusCode;
            switch (statusCode) {
              case 400:
                throw GPTGodException(
                  'خطأ في تنسيق الطلب. تحقق من صحة البيانات المرسلة.',
                );
              case 401:
                throw GPTGodException(
                  'مشكلة في التوثيق. تحقق من صحة مفتاح API.',
                );
              case 403:
                throw GPTGodException(
                  'لا يوجد صلاحية للوصول. قد تكون الخدمة محظورة أو انتهت صلاحية الحساب.',
                );
              case 429:
                throw GPTGodException(
                  'تم تجاوز الحد المسموح من الطلبات. انتظر قليلاً ثم حاول مرة أخرى.',
                );
              case 500:
                throw GPTGodException('خطأ في الخادم. حاول مرة أخرى لاحقاً.');
              default:
                throw GPTGodException(
                  'خطأ في الخادم (رمز: $statusCode). تفاصيل: ${e.message}',
                );
            }
          case DioExceptionType.cancel:
            throw GPTGodException('تم إلغاء الطلب.');
          case DioExceptionType.connectionError:
            throw GPTGodException(
              'فشل الاتصال بالخادم. تحقق من الإنترنت وإعدادات الشبكة.',
            );
          default:
            throw GPTGodException('خطأ غير متوقع: ${e.message}');
        }
      }

      throw GPTGodException('فشل في إرسال الرسالة: $e');
    }
  }

  Stream<String> _parseStreamResponse(ResponseBody responseBody) async* {
    String buffer = '';

    await for (final Uint8List bytes in responseBody.stream) {
      try {
        // معالجة آمنة للترميز مع السماح بالأخطاء
        final chunk = utf8.decode(bytes, allowMalformed: true);
        buffer += chunk;

        // معالجة الخطوط المكتملة فقط
        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

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
              // تجاهل الأخطاء في تحليل JSON المجزأ - إنها طبيعية في Streaming
              continue;
            }
          }
        }
      } catch (e) {
        print('[GPTGOD ENCODING ERROR] Failed to decode chunk: $e');
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
        'model': 'gpt-3.5-turbo',
        'temperature': 0.7,
        'max_tokens': 2048,
        'stream': true,
      };

      final response = await _dio.post(
        AppConfig.gptGodChatEndpoint,
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
      print('[GPTGOD THINKING ERROR] $e');
      throw GPTGodException('Failed to generate thinking process: $e');
    }
  }

  void dispose() {
    _dio.close();
  }

  /// تحديث مفتاح API
  void updateApiKey(String newApiKey) {
    _dio.options.headers['Authorization'] = 'Bearer $newApiKey';
  }
}

class GPTGodException implements Exception {
  final String message;
  GPTGodException(this.message);

  @override
  String toString() => 'GPTGodException: $message';
}
