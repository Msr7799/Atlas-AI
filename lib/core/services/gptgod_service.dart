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

    final rawResponse = buffer.toString();
    // تطبيق التنسيق الذكي على الرد النهائي
    return _applySmartFormatting(rawResponse);
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

  // خوارزميات ذكية لتحسين ردود النماذج
  String _applySmartFormatting(String content) {
    String processedContent = content;
    
    // 1. تحسين القوائم والأرقام
    processedContent = _enhanceListFormatting(processedContent);
    
    // 2. تحسين عرض الكود غير المنسق
    processedContent = _enhanceCodeFormatting(processedContent);
    
    // 3. تحسين العناوين
    processedContent = _enhanceHeaderFormatting(processedContent);
    
    // 4. تحسين الأمثلة
    processedContent = _enhanceExampleFormatting(processedContent);
    
    // 5. إضافة رسالة ترحيب محسنة لـ GPT-God
    processedContent = _addWelcomeEnhancement(processedContent);
    
    return processedContent;
  }

  String _enhanceListFormatting(String content) {
    String result = content;
    
    // تحسين القوائم المرقمة
    result = result.replaceAllMapped(
      RegExp(r'^(\d+)[\.\)][\s]*(.+)$', multiLine: true),
      (match) => '${match.group(1)}. **${match.group(2)}**'
    );
    
    // تحسين القوائم النقطية
    result = result.replaceAllMapped(
      RegExp(r'^[-\*\+][\s]*(.+)$', multiLine: true),
      (match) => '- **${match.group(1)}**'
    );
    
    return result;
  }

  String _enhanceCodeFormatting(String content) {
    String result = content;
    
    final lines = result.split('\n');
    final List<String> processedLines = [];
    
    bool inCodeBlock = false;
    List<String> currentCodeLines = [];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        processedLines.add(line);
        continue;
      }
      
      if (inCodeBlock) {
        processedLines.add(line);
        continue;
      }
      
      if (_looksLikeCode(trimmedLine) && trimmedLine.isNotEmpty) {
        currentCodeLines.add(line);
      } else {
        if (currentCodeLines.isNotEmpty) {
          final codeContent = currentCodeLines.join('\n');
          final language = _detectCodeLanguage(codeContent);
          processedLines.add('```$language');
          processedLines.addAll(currentCodeLines);
          processedLines.add('```');
          currentCodeLines.clear();
        }
        processedLines.add(line);
      }
    }
    
    if (currentCodeLines.isNotEmpty) {
      final codeContent = currentCodeLines.join('\n');
      final language = _detectCodeLanguage(codeContent);
      processedLines.add('```$language');
      processedLines.addAll(currentCodeLines);
      processedLines.add('```');
    }
    
    return processedLines.join('\n');
  }

  bool _looksLikeCode(String line) {
    if (line.isEmpty) return false;
    
    final codePatterns = [
      RegExp(r'^\$\s+\w+'),
      RegExp(r'^(sudo|apt|npm|pip|git|docker|curl|wget)\s+'),
      RegExp(r'^(def|class|function|const|let|var|import|from)\s+'),
      RegExp(r'[{}()\[\];].*[{}()\[\];]'),
      RegExp(r'^\s*[a-zA-Z_]\w*\s*='),
    ];
    
    return codePatterns.any((pattern) => pattern.hasMatch(line));
  }

  String _detectCodeLanguage(String content) {
    final contentLower = content.toLowerCase();
    
    if (contentLower.contains('def ') || contentLower.contains('import ') ||
        contentLower.contains('print(')) {
      return 'python';
    }
    
    if (contentLower.contains('\$') || contentLower.contains('sudo ') ||
        contentLower.contains('apt ') || contentLower.contains('git ')) {
      return 'bash';
    }
    
    if (contentLower.contains('function ') || contentLower.contains('const ') ||
        contentLower.contains('let ')) {
      return 'javascript';
    }
    
    return 'bash';
  }

  String _enhanceHeaderFormatting(String content) {
    String result = content;
    
    result = result.replaceAllMapped(
      RegExp(r'^([^#\n]+):$', multiLine: true),
      (match) {
        final title = match.group(1)!.trim();
        if (title.length < 50 && !title.contains('.')) {
          return '## $title';
        }
        return match.group(0)!;
      }
    );
    
    return result;
  }

  String _enhanceExampleFormatting(String content) {
    String result = content;
    
    result = result.replaceAllMapped(
      RegExp(r'(مثال|Example|example):\s*(.+)', multiLine: true),
      (match) => '**${match.group(1)}:**\n> ${match.group(2)}'
    );
    
    return result;
  }

  String _addWelcomeEnhancement(String content) {
    // إضافة رسالة ترحيب خاصة بـ GPT-God
    if (content.length > 200 && !content.startsWith('##') && !content.startsWith('**')) {
      return '## 🤖 GPT-God مساعدك الذكي\n\n$content\n\n---\n*تم تحسين هذا الرد بواسطة Atlas AI مع خوارزميات ذكية لأفضل تجربة*';
    }
    
    return content;
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
