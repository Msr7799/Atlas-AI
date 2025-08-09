import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../data/models/message_model.dart';
import '../utils/logger.dart';

/// خدمة الذكاء الاصطناعي المحلية (LocalAI)
///
/// هذه الخدمة توفر واجهة للتفاعل مع نماذج الذكاء الاصطناعي المحلية
/// المستضافة على جهاز المستخدم أو في الشبكة المحلية.
/// يمكن استخدامها كاحتياط في حالة فشل الخدمات السحابية.
class LocalAIService {
  static const String _baseUrl = 'http://localhost:8080';
  static const String _completionEndpoint = '/api/chat';

  // Singleton نمط التصميم
  static final LocalAIService _instance = LocalAIService._internal();
  factory LocalAIService() => _instance;
  LocalAIService._internal();

  /// المتغيرات الأساسية
  bool _isInitialized = false;
  bool _isLocalServerRunning = false;
  String? _modelsDirectoryPath;
  String? _activeModel;

  /// معلومات حول النماذج المتاحة محلياً
  final Map<String, Map<String, dynamic>> _availableModels = {};

  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // التحقق من وجود النماذج المحلية
      await _checkLocalModels();

      // التحقق من حالة الخادم المحلي
      await _checkLocalServer();

      _isInitialized = true;
      LogHelper.success('[LOCAL_AI] تم تهيئة خدمة الذكاء الاصطناعي المحلية');
    } catch (e) {
      LogHelper.error(
        '[LOCAL_AI] فشل في تهيئة خدمة الذكاء الاصطناعي المحلية: $e',
      );
    }
  }

  /// التحقق من النماذج المتاحة محلياً
  Future<void> _checkLocalModels() async {
    try {
      // الحصول على دليل المستندات
      final appDocDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory(path.join(appDocDir.path, 'ai_models'));

      // إنشاء الدليل إذا لم يكن موجوداً
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      _modelsDirectoryPath = modelsDir.path;

      // قراءة النماذج المتاحة
      final modelFiles = await modelsDir
          .list()
          .where(
            (entity) =>
                entity is File &&
                (entity.path.endsWith('.bin') ||
                    entity.path.endsWith('.gguf') ||
                    entity.path.endsWith('.onnx')),
          )
          .toList();

      // تسجيل النماذج المتاحة
      for (var modelFile in modelFiles) {
        final fileName = path.basename(modelFile.path);
        final fileSize = await File(modelFile.path).length();

        _availableModels[fileName] = {
          'path': modelFile.path,
          'size': fileSize,
          'type': _getModelType(fileName),
        };
      }

      LogHelper.info(
        '[LOCAL_AI] تم العثور على ${_availableModels.length} نموذج محلي',
      );
    } catch (e) {
      LogHelper.error('[LOCAL_AI] فشل في التحقق من النماذج المحلية: $e');
    }
  }

  /// التحقق من حالة الخادم المحلي
  Future<bool> _checkLocalServer() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/health'))
          .timeout(const Duration(seconds: 2));

      _isLocalServerRunning = response.statusCode == 200;

      if (_isLocalServerRunning) {
        // الحصول على النموذج النشط حالياً
        final modelResponse = await http
            .get(Uri.parse('$_baseUrl/api/models'))
            .timeout(const Duration(seconds: 2));

        if (modelResponse.statusCode == 200) {
          final modelData = json.decode(modelResponse.body);
          if (modelData['active_model'] != null) {
            _activeModel = modelData['active_model'];
            LogHelper.info('[LOCAL_AI] النموذج النشط: $_activeModel');
          }
        }

        LogHelper.success('[LOCAL_AI] الخادم المحلي يعمل');
      } else {
        LogHelper.warning('[LOCAL_AI] الخادم المحلي غير نشط');
      }

      return _isLocalServerRunning;
    } catch (e) {
      LogHelper.error('[LOCAL_AI] فشل في الاتصال بالخادم المحلي: $e');
      _isLocalServerRunning = false;
      return false;
    }
  }

  /// تحديد نوع النموذج بناءً على اسم الملف
  String _getModelType(String fileName) {
    if (fileName.contains('llama')) return 'llama';
    if (fileName.contains('mistral')) return 'mistral';
    if (fileName.contains('falcon')) return 'falcon';
    if (fileName.contains('gpt')) return 'gpt';
    if (fileName.contains('bert')) return 'bert';
    return 'unknown';
  }

  /// إرسال رسالة إلى نموذج الذكاء الاصطناعي المحلي
  Future<String> sendMessage({
    required List<MessageModel> messages,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2048,
    List<String>? attachedFilesContent,
  }) async {
    try {
      if (!_isLocalServerRunning) {
        // محاولة إعادة التحقق من الخادم
        final serverRunning = await _checkLocalServer();
        if (!serverRunning) {
          throw Exception('الخادم المحلي غير متاح');
        }
      }

      // تحضير الرسائل للطلب
      final formattedMessages = messages.map((message) {
        return {
          'role': message.role.toString().split('.').last,
          'content': message.content,
        };
      }).toList();

      // إضافة الـ system prompt إذا كان موجوداً
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        formattedMessages.insert(0, {
          'role': 'system',
          'content': systemPrompt,
        });
      }

      // إضافة محتوى الملفات المرفقة إذا كانت موجودة
      if (attachedFilesContent != null && attachedFilesContent.isNotEmpty) {
        final userMessages = formattedMessages
            .where((msg) => msg['role'] == 'user')
            .toList();
        if (userMessages.isNotEmpty) {
          final lastUserMessage = userMessages.last;
          lastUserMessage['content'] =
              '${lastUserMessage['content']}\n\n--- الملفات المرفقة ---\n${attachedFilesContent.join('\n\n')}';
        }
      }

      // إعداد طلب HTTP
      final requestBody = json.encode({
        'messages': formattedMessages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': false,
      });

      LogHelper.debug('[LOCAL_AI] إرسال طلب للنموذج المحلي');

      // إرسال الطلب
      final response = await http
          .post(
            Uri.parse('$_baseUrl$_completionEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(minutes: 2));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['choices'] != null &&
            responseData['choices'].isNotEmpty &&
            responseData['choices'][0]['message'] != null) {
          final content = responseData['choices'][0]['message']['content'];
          LogHelper.success('[LOCAL_AI] تم استلام الرد بنجاح');
          return content;
        } else {
          throw Exception('تنسيق الاستجابة غير صحيح');
        }
      } else {
        throw Exception('فشل الطلب: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      LogHelper.error('[LOCAL_AI] فشل في إرسال الرسالة: $e');
      throw Exception('فشل في الحصول على استجابة من النموذج المحلي: $e');
    }
  }

  /// إرسال رسالة إلى نموذج الذكاء الاصطناعي المحلي وإرجاع النتيجة كـ Stream
  Stream<String> sendMessageStream({
    required List<MessageModel> messages,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2048,
    List<String>? attachedFilesContent,
  }) async* {
    try {
      if (!_isLocalServerRunning) {
        // محاولة إعادة التحقق من الخادم
        final serverRunning = await _checkLocalServer();
        if (!serverRunning) {
          throw Exception('الخادم المحلي غير متاح');
        }
      }

      // تحضير الرسائل للطلب
      final formattedMessages = messages.map((message) {
        return {
          'role': message.role.toString().split('.').last,
          'content': message.content,
        };
      }).toList();

      // إضافة الـ system prompt إذا كان موجوداً
      if (systemPrompt != null && systemPrompt.isNotEmpty) {
        formattedMessages.insert(0, {
          'role': 'system',
          'content': systemPrompt,
        });
      }

      // إضافة محتوى الملفات المرفقة إذا كانت موجودة
      if (attachedFilesContent != null && attachedFilesContent.isNotEmpty) {
        final userMessages = formattedMessages
            .where((msg) => msg['role'] == 'user')
            .toList();
        if (userMessages.isNotEmpty) {
          final lastUserMessage = userMessages.last;
          lastUserMessage['content'] =
              '${lastUserMessage['content']}\n\n--- الملفات المرفقة ---\n${attachedFilesContent.join('\n\n')}';
        }
      }

      // إعداد طلب HTTP
      final requestBody = json.encode({
        'messages': formattedMessages,
        'temperature': temperature,
        'max_tokens': maxTokens,
        'stream': true,
      });

      LogHelper.debug('[LOCAL_AI] إرسال طلب stream للنموذج المحلي');

      // إرسال الطلب
      final request =
          http.Request('POST', Uri.parse('$_baseUrl$_completionEndpoint'))
            ..headers['Content-Type'] = 'application/json'
            ..body = requestBody;

      final streamedResponse = await http.Client().send(request);

      if (streamedResponse.statusCode == 200) {
        final stream = streamedResponse.stream.transform(utf8.decoder);

        await for (final chunk in stream) {
          // التعامل مع كل قطعة من البيانات
          if (chunk.startsWith('data: ')) {
            final jsonData = chunk.substring(6).trim();
            if (jsonData == '[DONE]') break;

            try {
              final parsedData = json.decode(jsonData);
              if (parsedData['choices'] != null &&
                  parsedData['choices'].isNotEmpty &&
                  parsedData['choices'][0]['delta'] != null &&
                  parsedData['choices'][0]['delta']['content'] != null) {
                yield parsedData['choices'][0]['delta']['content'];
              }
            } catch (e) {
              LogHelper.error('[LOCAL_AI] فشل في تحليل قطعة البيانات: $e');
            }
          }
        }

        LogHelper.success('[LOCAL_AI] اكتمل stream بنجاح');
      } else {
        final errorBody = await streamedResponse.stream
            .transform(utf8.decoder)
            .join();
        throw Exception(
          'فشل الطلب: ${streamedResponse.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      LogHelper.error('[LOCAL_AI] فشل في إرسال الرسالة كـ stream: $e');
      yield 'عذراً، حدث خطأ في الاتصال بالنموذج المحلي. الرجاء التأكد من تشغيل الخادم المحلي والمحاولة مرة أخرى.';
    }
  }

  /// الحصول على النماذج المتاحة محلياً
  Map<String, Map<String, dynamic>> getAvailableModels() {
    if (_modelsDirectoryPath != null) {
      LogHelper.info('[LOCAL_AI] مسار النماذج: $_modelsDirectoryPath');
    }
    return _availableModels;
  }

  /// التحقق من حالة الخدمة
  bool get isLocalServerRunning => _isLocalServerRunning;

  /// الحصول على النموذج النشط حالياً
  String? get activeModel => _activeModel;

  /// تنظيف الموارد عند الانتهاء
  void dispose() {
    // تنظيف الموارد إذا لزم الأمر
    LogHelper.info('[LOCAL_AI] تم تنظيف موارد خدمة الذكاء الاصطناعي المحلية');
  }
}
