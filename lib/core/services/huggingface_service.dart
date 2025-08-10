import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../data/models/message_model.dart';

class HuggingFaceService {
  static final HuggingFaceService _instance = HuggingFaceService._internal();
  factory HuggingFaceService() => _instance;
  HuggingFaceService._internal();

  late final Dio _dio;
  String _apiKey =
      ''; // Restored _apiKey field since it's used in updateApiKey method
  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return; // منع التهيئة المتكررة

    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api-inference.huggingface.co',
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
        logPrint: (object) => print('[HUGGINGFACE API] $object'),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          print(
            '[HUGGINGFACE ERROR] Type: ${error.type}, Message: ${error.message}',
          );
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
                error:
                    'Network connection error - check your internet connection',
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

  /// تحديث مفتاح API
  void updateApiKey(String newApiKey) {
    _apiKey = newApiKey;
    _dio.options.headers['Authorization'] = 'Bearer $_apiKey';
  }

  /// الحصول على مفتاح API الحالي
  String get apiKey => _apiKey;

  /// الحصول على قائمة النماذج المتاحة
  List<HuggingFaceModel> getAvailableModels() {
    return [
      HuggingFaceModel(
        id: 'meta-llama/Llama-2-7b-chat-hf',
        name: 'Llama 2 7B Chat',
        description: 'نموذج Llama 2 7B محسن للمحادثة',
        maxTokens: 4096,
        contextLength: 4096,
      ),
      HuggingFaceModel(
        id: 'meta-llama/Llama-2-13b-chat-hf',
        name: 'Llama 2 13B Chat',
        description: 'نموذج Llama 2 13B محسن للمحادثة',
        maxTokens: 4096,
        contextLength: 4096,
      ),
      HuggingFaceModel(
        id: 'microsoft/DialoGPT-medium',
        name: 'DialoGPT Medium',
        description: 'نموذج DialoGPT متوسط الحجم',
        maxTokens: 2048,
        contextLength: 2048,
      ),
      HuggingFaceModel(
        id: 'microsoft/DialoGPT-large',
        name: 'DialoGPT Large',
        description: 'نموذج DialoGPT كبير الحجم',
        maxTokens: 2048,
        contextLength: 2048,
      ),
      HuggingFaceModel(
        id: 'google/flan-t5-base',
        name: 'Flan-T5 Base',
        description: 'نموذج Flan-T5 أساسي',
        maxTokens: 2048,
        contextLength: 2048,
      ),
      HuggingFaceModel(
        id: 'google/flan-t5-large',
        name: 'Flan-T5 Large',
        description: 'نموذج Flan-T5 كبير',
        maxTokens: 2048,
        contextLength: 2048,
      ),
      HuggingFaceModel(
        id: 'tiiuae/falcon-7b-instruct',
        name: 'Falcon 7B Instruct',
        description: 'نموذج Falcon 7B تعليمي',
        maxTokens: 4096,
        contextLength: 4096,
      ),
      HuggingFaceModel(
        id: 'tiiuae/falcon-40b-instruct',
        name: 'Falcon 40B Instruct',
        description: 'نموذج Falcon 40B تعليمي',
        maxTokens: 4096,
        contextLength: 4096,
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
      // تحويل الرسائل إلى تنسيق مناسب للنموذج
      String prompt = _buildPrompt(messages, systemPrompt, attachedFiles);

      final requestData = {
        'inputs': prompt,
        'parameters': {
          'max_new_tokens': maxTokens ?? 512,
          'temperature': temperature ?? 0.7,
          'top_p': 0.9,
          'do_sample': true,
          'return_full_text': false,
        },
        'options': {'wait_for_model': true},
      };

      print('[HUGGINGFACE] Sending request to model: $modelId');
      print('[HUGGINGFACE] Request data: ${jsonEncode(requestData)}');

      final response = await _dio.post(
        '/models/$modelId',
        data: requestData,
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      return _parseStreamResponse(response.data);
    } on DioException catch (e) {
      print('[HUGGINGFACE DIO ERROR] Type: ${e.type}, Message: ${e.message}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw HuggingFaceException(
            'انتهت مهلة الاتصال مع Hugging Face. تحقق من اتصالك بالإنترنت.',
          );
        case DioExceptionType.receiveTimeout:
          throw HuggingFaceException(
            'انتهت مهلة انتظار الاستجابة من Hugging Face.',
          );
        case DioExceptionType.sendTimeout:
          throw HuggingFaceException(
            'انتهت مهلة إرسال البيانات لـ Hugging Face.',
          );
        case DioExceptionType.connectionError:
          throw HuggingFaceException('فشل الاتصال بخادم Hugging Face.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          switch (statusCode) {
            case 400:
              throw HuggingFaceException('خطأ في تنسيق الطلب لـ Hugging Face.');
            case 401:
              throw HuggingFaceException(
                'مشكلة في التوثيق مع Hugging Face. تحقق من صحة مفتاح API.',
              );
            case 403:
              throw HuggingFaceException(
                'لا يوجد صلاحية للوصول لـ Hugging Face.',
              );
            case 429:
              throw HuggingFaceException(
                'تم تجاوز الحد المسموح من الطلبات لـ Hugging Face.',
              );
            case 500:
              throw HuggingFaceException('خطأ في خادم Hugging Face.');
            default:
              throw HuggingFaceException(
                'خطأ في خادم Hugging Face (رمز: $statusCode).',
              );
          }
        default:
          throw HuggingFaceException(
            'خطأ غير متوقع مع Hugging Face: ${e.message}',
          );
      }
    } catch (e) {
      print('[HUGGINGFACE GENERAL ERROR] $e');
      throw HuggingFaceException('فشل في إرسال الرسالة لـ Hugging Face: $e');
    }
  }

  String _buildPrompt(
    List<MessageModel> messages,
    String? systemPrompt,
    List<String>? attachedFiles,
  ) {
    final buffer = StringBuffer();

    // إضافة system prompt
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      buffer.writeln('System: $systemPrompt');
      buffer.writeln();
    }

    // إضافة الملفات المرفقة
    if (attachedFiles != null && attachedFiles.isNotEmpty) {
      buffer.writeln('Context:');
      for (final file in attachedFiles) {
        buffer.writeln(file);
      }
      buffer.writeln();
    }

    // إضافة الرسائل
    for (final message in messages) {
      if (message.role == MessageRole.user) {
        buffer.writeln('User: ${message.content}');
      } else if (message.role == MessageRole.assistant) {
        buffer.writeln('Assistant: ${message.content}');
      }
    }

    buffer.writeln('Assistant:');
    return buffer.toString();
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
              final generatedText = json['generated_text'] as String?;

              if (generatedText != null) {
                yield generatedText;
              }
            } catch (e) {
              print(
                '[HUGGINGFACE PARSE ERROR] Failed to parse: $data, Error: $e',
              );
            }
          }
        }
      } catch (e) {
        print('[HUGGINGFACE ENCODING ERROR] Failed to decode chunk: $e');
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

    final rawResponse = buffer.toString();
    // تطبيق التنسيق الذكي على الرد النهائي
    return _applySmartFormatting(rawResponse);
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
    
    // 5. إضافة رسالة ترحيب محسنة لـ HuggingFace
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
    // إضافة رسالة ترحيب خاصة بـ HuggingFace
    if (content.length > 200 && !content.startsWith('##') && !content.startsWith('**')) {
      return '## 🤗 HuggingFace AI مساعدك المتطور\n\n$content\n\n---\n*تم تحسين هذا الرد بواسطة Atlas AI مع خوارزميات ذكية متقدمة*';
    }
    
    return content;
  }

  void dispose() {
    _dio.close();
  }
}

class HuggingFaceModel {
  final String id;
  final String name;
  final String description;
  final int maxTokens;
  final int contextLength;

  HuggingFaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.maxTokens,
    required this.contextLength,
  });

  @override
  String toString() => name;
}

class HuggingFaceException implements Exception {
  final String message;
  HuggingFaceException(this.message);

  @override
  String toString() => 'HuggingFaceException: $message';
}
