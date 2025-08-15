import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'api_key_manager.dart';
import 'base_api_service.dart';
import 'package:uuid/uuid.dart';
import '../config/app_config.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';

// في بداية الملف، يحتاج استيراد إضافي لـ ApiKeyManager
class GroqService extends BaseApiService {
  static final GroqService _instance = GroqService._internal();
  factory GroqService() => _instance;
  GroqService._internal();

  final _uuid = Uuid();

  @override
  Future<void> initialize() async {
    if (isInitialized) return; // منع التهيئة المتكررة

    // جرب المفتاح الأساسي أولاً، ثم الاحتياطي
    String apiKey = AppConfig.groqApiKey;
    if (apiKey.isEmpty || apiKey.startsWith('gsk_انشئ_مفتاح')) {
      apiKey = AppConfig.groqApiKey2;
      // Using backup API key
    }

    // استخدام BaseApiService.initializeBase
    initializeBase(
      serviceName: 'Groq',
      baseUrl: AppConfig.groqBaseUrl,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
        'User-Agent': 'Atlas-AI/1.0',
      },
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 120),
      sendTimeout: const Duration(seconds: 45),
    );

    // إضافة معالج أخطاء مخصص لـ Groq
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (kDebugMode) print('[GROQ ERROR] ${error.type}: ${error.message}');

          // إذا كان خطأ 403، جرب تبديل المفتاح
          if (error.response?.statusCode == 403) {
            if (kDebugMode) print('[GROQ] ❌ خطأ 403 - جاري تجربة المفتاح الاحتياطي...');
            _tryFallbackKey();
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error:
                    'لا يوجد صلاحية للوصول لـ Groq. قد تكون الخدمة محظورة أو المفتاح غير صحيح.',
                type: DioExceptionType.badResponse,
              ),
            );
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  /// تجربة المفتاح الاحتياطي عند فشل المفتاح الأساسي
  void _tryFallbackKey() {
    final currentKey = currentApiKey;
    if (currentKey == AppConfig.groqApiKey &&
        AppConfig.groqApiKey2.isNotEmpty) {
      if (kDebugMode) print('[GROQ] 🔄 تبديل للمفتاح الاحتياطي...');
      updateApiKey(AppConfig.groqApiKey2);
    } else if (currentKey == AppConfig.groqApiKey2 &&
        AppConfig.groqApiKey.isNotEmpty) {
      if (kDebugMode) print('[GROQ] 🔄 تبديل للمفتاح الأساسي...');
      updateApiKey(AppConfig.groqApiKey);
    }
  }

  /// تحديث مفتاح API
  @override
  void updateApiKey(String newApiKey, {String prefix = 'Bearer'}) {
    super.updateApiKey(newApiKey, prefix: prefix);
  }

  /// تجربة المفتاح الاحتياطي إذا فشل الأول
  Future<bool> _tryAlternativeKey() async {
    try {
      final altKey = AppConfig.groqApiKey2;
      if (altKey.isNotEmpty && altKey != currentApiKey) {
        if (kDebugMode) print('[GROQ] 🔄 Trying alternative API key...');
        updateApiKey(altKey);
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('[GROQ] ❌ Failed to switch to alternative key: $e');
    }
    return false;
  }

  /// نظام Retry متقدم مع Exponential Backoff
  Future<Response> _makeRequestWithRetry(
    Future<Response> Function() request, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 2),
    bool shouldSwitchKey = true,
  }) async {
    int retryCount = 0;
    Duration delay = initialDelay;
    
    while (retryCount < maxRetries) {
      try {
        return await request();
      } catch (e) {
        retryCount++;
        if (kDebugMode) print('[GROQ] ❌ محاولة $retryCount/$maxRetries فشلت: $e');
        
        if (retryCount >= maxRetries) {
          if (kDebugMode) print('[GROQ] ❌ انتهت جميع المحاولات، فشل الطلب نهائياً');
          rethrow;
        }
        
        // تبديل المفتاح إذا كان مناسباً
        if (shouldSwitchKey && retryCount == 1) {
          await _tryAlternativeKey();
        }
        
        // انتظار مع Exponential Backoff
        if (kDebugMode) print('[GROQ] ⏳ انتظار ${delay.inSeconds} ثانية قبل المحاولة التالية...');
        await Future.delayed(delay);
        delay = Duration(seconds: delay.inSeconds * 2); // مضاعفة وقت الانتظار
      }
    }
    
    throw Exception('Max retries exceeded');
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
            errorMessage = 'طلب غير صحيح - تحقق من البيانات المرسلة';
            break;
          case 401:
            errorMessage = 'غير مصرح - تحقق من مفتاح API';
            break;
          case 403:
            errorMessage = 'محظور - قد تكون الخدمة محظورة أو المفتاح غير صحيح.';
            break;
          case 429:
            errorMessage = 'معدل الطلبات مرتفع - انتظر قليلاً';
            break;
          case 500:
            errorMessage = 'خطأ في الخادم - حاول لاحقاً';
            break;
          case 502:
            errorMessage = 'خطأ في البوابة - الخادم غير متاح';
            break;
          case 503:
            errorMessage = 'الخدمة غير متاحة - الخادم في الصيانة';
            break;
          default:
            errorMessage = 'خطأ في الخادم (كود $statusCode)';
        }
        break;
      default:
        errorMessage = 'خطأ في الشبكة: ${error.message}';
    }
    
    if (kDebugMode) print('[GROQ ERROR] $errorMessage');
    throw Exception(errorMessage);
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

      if (kDebugMode) print('[GROQ] 🚀 Sending request to Groq API...');
      if (kDebugMode) print('[GROQ] 📝 Request data: ${jsonEncode(requestData)}');

      // تسجيل الاستخدام
      await ApiKeyManager.recordApiUsage('groq', isSuccess: true);

      final response = await dio.post(
        AppConfig.groqChatEndpoint,
        data: requestData,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      return _parseStreamResponse(response.data);
    } on DioException catch (e) {
      // تسجيل الخطأ
      await ApiKeyManager.recordApiUsage('groq', isSuccess: false);
      
      if (kDebugMode) print('[GROQ DIO ERROR] Type: ${e.type}, Message: ${e.message}');
      if (kDebugMode) {
        print(
        '[GROQ DIO ERROR] Response: ${e.response?.statusCode} - ${e.response?.data}',
      );
      }

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
                if (kDebugMode) print('[GROQ] 🔄 Retrying with alternative key...');
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
      if (kDebugMode) print('[GROQ GENERAL ERROR] $e');
      throw GroqException('فشل في إرسال الرسالة لـ Groq: $e');
    }
  }

  Stream<String> _parseStreamResponse(ResponseBody responseBody) async* {
    if (kDebugMode) print('[GROQ] 📡 Response received, parsing stream...');

    await for (final Uint8List bytes in responseBody.stream) {
      if (kDebugMode) print('[GROQ] 📦 Received chunk: ${bytes.length} bytes');
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
                  if (kDebugMode) print('[GROQ] 💬 Yielding content: ${content.length} chars');
                  yield content;
                }
              }
            } catch (e) {
              if (kDebugMode) print('[GROQ PARSE ERROR] Failed to parse: $data, Error: $e');
            }
          }
        }
      } catch (e) {
        if (kDebugMode) print('[GROQ ENCODING ERROR] Failed to decode chunk: $e');
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
    bool? enableAutoFormatting, // إضافة معامل للتحكم في التنسيق
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
    
    // تطبيق التنسيق الذكي فقط إذا كان مفعلاً
    if (enableAutoFormatting ?? true) {
      return _applySmartFormatting(rawResponse);
    } else {
      return rawResponse;
    }
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

      final response = await dio.post(
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
              id: _uuid.v4(),
              stepNumber: stepNumber++,
              message: buffer.toString().trim(),
              type: 'thinking',
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
          id: _uuid.v4(),
          stepNumber: stepNumber,
          message: buffer.toString().trim(),
          type: 'thinking',
          content: buffer.toString().trim(),
          timestamp: DateTime.now(),
        );
      }
    } catch (e) {
      if (kDebugMode) print('[THINKING ERROR] $e');
      throw GroqException('Failed to generate thinking process: $e');
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
    
    // 5. إضافة رسالة ترحيب محسنة
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
    
    // كشف الكود غير المنسق وتحويله إلى code blocks
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
      
      // كشف الكود المحتمل
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
    
    // تحسين العناوين
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
    
    // تحسين الأمثلة
    result = result.replaceAllMapped(
      RegExp(r'(مثال|Example|example):\s*(.+)', multiLine: true),
      (match) => '**${match.group(1)}:**\n> ${match.group(2)}'
    );
    
    return result;
  }

  String _addWelcomeEnhancement(String content) {
    // إضافة رسالة ترحيب محسنة في بداية الردود الطويلة
    if (content.length > 200 && !content.startsWith('##') && !content.startsWith('**')) {
      return '## مرحباً! 👋\n\n$content\n\n---\n*تم تحسين هذا الرد بواسطة Atlas AI للحصول على أفضل تجربة قراءة*';
    }
    
    return content;
  }

  @override
  void dispose() {
    dio.close();
  }
}

class GroqException implements Exception {
  final String message;
  GroqException(this.message);

  @override
  String toString() => 'GroqException: $message';
}
