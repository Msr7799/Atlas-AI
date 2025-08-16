import 'dart:async';
import 'package:dio/dio.dart';
import 'api_key_manager.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// خدمة AI موحدة تدمج جميع مقدمي الخدمة
class UnifiedAIService {
  static final UnifiedAIService _instance = UnifiedAIService._internal();
  factory UnifiedAIService() => _instance;
  UnifiedAIService._internal();

  Dio? _dio;
  String _lastUsedService = '';
  String _lastUsedModel = '';

  // مفاتيح API
  String _groqApiKey = '';
  String _groqApiKey2 = '';
  String _gptgodApiKey = '';
  String _gptgodApiKey2 = '';
  String _openRouterApiKey = '';
  String _huggingfaceApiKey = '';
  String _tavilyApiKey = '';

  // Getters
  String get lastUsedService => _lastUsedService;
  String get lastUsedModel => _lastUsedModel;

  // تهيئة الخدمة
  Future<void> initialize() async {
    if (_dio != null) return; // منع التهيئة المتكررة

    // تحميل مفاتيح API من .env و ApiKeyManager
    await _loadApiKeys();

    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
      headers: {'Content-Type': 'application/json'},
    ));

    if (kDebugMode) {
      _dio!.interceptors.add(LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (obj) => debugPrint('[AI_SERVICE] $obj'),
      ));
    }

    print('✅ [UNIFIED_AI] تم تهيئة الخدمة الموحدة');
    if (kDebugMode) {
      print('🔑 [UNIFIED_AI] Keys Status:');
      print('  - Groq: ${_groqApiKey.isNotEmpty ? "✅ Available" : "❌ Missing"}');
      print('  - GPTGod: ${_gptgodApiKey.isNotEmpty ? "✅ Available" : "❌ Missing"}');
      print('  - OpenRouter: ${_openRouterApiKey.isNotEmpty ? "✅ Available" : "❌ Missing"}');
      print('  - HuggingFace: ${_huggingfaceApiKey.isNotEmpty ? "✅ Available" : "❌ Missing"}');
      print('  - Tavily: ${_tavilyApiKey.isNotEmpty ? "✅ Available" : "❌ Missing"}');
    }
  }

  // تحميل مفاتيح API
  Future<void> _loadApiKeys() async {
    try {
      // تحميل من .env أولاً
      _groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      _groqApiKey2 = dotenv.env['GROQ_API_KEY2'] ?? '';
      _gptgodApiKey = dotenv.env['GPTGOD_API_KEY'] ?? '';
      _gptgodApiKey2 = dotenv.env['GPTGOD_API_KEY2'] ?? '';
      _openRouterApiKey = dotenv.env['OPEN_ROUTER_API'] ?? '';
      _huggingfaceApiKey = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
      _tavilyApiKey = dotenv.env['TAVILY_API_KEY'] ?? '';

      // إذا لم توجد في .env، جرب ApiKeyManager
      if (_groqApiKey.isEmpty) {
        _groqApiKey = await ApiKeyManager.getApiKey('groq');
      }
      if (_gptgodApiKey.isEmpty) {
        _gptgodApiKey = await ApiKeyManager.getApiKey('gptgod');
      }
      if (_openRouterApiKey.isEmpty) {
        _openRouterApiKey = await ApiKeyManager.getApiKey('openrouter');
      }
      if (_huggingfaceApiKey.isEmpty) {
        _huggingfaceApiKey = await ApiKeyManager.getApiKey('huggingface');
      }
      if (_tavilyApiKey.isEmpty) {
        _tavilyApiKey = await ApiKeyManager.getApiKey('tavily');
      }

      if (kDebugMode) {
        print('🔑 [UNIFIED_AI] تم تحميل مفاتيح API');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UNIFIED_AI] خطأ في تحميل مفاتيح API: $e');
      }
    }
  }

  // إرسال رسالة مع اختيار أفضل خدمة تلقائياً
  Future<String> sendMessage({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    bool? enableAutoFormatting,
  }) async {
    try {
      final service = _determineService(model);
      _lastUsedService = service;
      _lastUsedModel = model;

      print('🚀 [UNIFIED_AI] استخدام خدمة: $service للنموذج: $model');

      switch (service) {
        case 'groq':
          return await _sendToGroq(
            messages: messages,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            systemPrompt: systemPrompt,
          );
        case 'openrouter':
          return await _sendToOpenRouter(
            messages: messages,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            systemPrompt: systemPrompt,
          );
        case 'gptgod':
          return await _sendToGPTGod(
            messages: messages,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            systemPrompt: systemPrompt,
          );
        case 'huggingface':
          return await _sendToHuggingFace(
            messages: messages,
            model: model,
            temperature: temperature,
            maxTokens: maxTokens,
            systemPrompt: systemPrompt,
          );
        default:
          throw Exception('خدمة غير مدعومة: $service');
      }
    } catch (e) {
      print('❌ [UNIFIED_AI] خطأ في الإرسال: $e');
      rethrow;
    }
  }

  // تحديد الخدمة المناسبة للنموذج مع التحقق من وجود المفاتيح
  String _determineService(String model) {
    // Groq models
    if ((model.startsWith('llama') || model.startsWith('mixtral') || model.startsWith('gemma')) && _groqApiKey.isNotEmpty) {
      return 'groq';
    }

    // OpenRouter models (تحتوي على /)
    if (model.contains('/') && _openRouterApiKey.isNotEmpty) {
      return 'openrouter';
    }

    // GPTGod models
    if ((model.startsWith('gpt-4.5') || model.startsWith('claude-3.5') || model.startsWith('gpt-4o') || model.startsWith('claude-3-5')) && _gptgodApiKey.isNotEmpty) {
      return 'gptgod';
    }

    // HuggingFace models
    if ((model.startsWith('meta-llama/') || model.startsWith('microsoft/') || model.startsWith('Qwen/')) && _huggingfaceApiKey.isNotEmpty) {
      return 'huggingface';
    }

    // Fallback: استخدم أول خدمة متاحة
    if (_groqApiKey.isNotEmpty) return 'groq';
    if (_gptgodApiKey.isNotEmpty) return 'gptgod';
    if (_openRouterApiKey.isNotEmpty) return 'openrouter';
    if (_huggingfaceApiKey.isNotEmpty) return 'huggingface';

    // إذا لم توجد مفاتيح، استخدم Groq كافتراضي
    return 'groq';
  }

  // إرسال إلى Groq
  Future<String> _sendToGroq({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) async {
    final apiKey = _groqApiKey.isNotEmpty ? _groqApiKey : _groqApiKey2;
    if (apiKey.isEmpty) throw Exception('مفتاح Groq غير متوفر');

    final requestMessages = <Map<String, dynamic>>[];
    
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      requestMessages.add({'role': 'system', 'content': systemPrompt});
    }

    for (final message in messages) {
      requestMessages.add({
        'role': message.role.name,
        'content': message.content,
      });
    }

    final response = await _dio!.post(
      'https://api.groq.com/openai/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      data: {
        'messages': requestMessages,
        'model': model,
        'temperature': temperature ?? 0.7,
        'max_completion_tokens': maxTokens ?? 2048,
      },
    );

    return response.data['choices'][0]['message']['content'];
  }

  // إرسال إلى OpenRouter
  Future<String> _sendToOpenRouter({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) async {
    final apiKey = _openRouterApiKey;
    if (apiKey.isEmpty) throw Exception('مفتاح OpenRouter غير متوفر');

    final requestMessages = <Map<String, dynamic>>[];
    
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      requestMessages.add({'role': 'system', 'content': systemPrompt});
    }

    for (final message in messages) {
      final content = _formatMessageForVision(message, model);
      requestMessages.add({
        'role': message.role.name,
        'content': content,
      });
    }

    final response = await _dio!.post(
      'https://openrouter.ai/api/v1/chat/completions',
      options: Options(headers: {
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://atlas-ai.app',
        'X-Title': 'Atlas AI',
      }),
      data: {
        'model': model,
        'messages': requestMessages,
        'temperature': temperature ?? 0.7,
        'max_tokens': maxTokens ?? 2048,
      },
    );

    return response.data['choices'][0]['message']['content'];
  }

  // تنسيق الرسائل للنماذج التي تدعم الرؤية
  dynamic _formatMessageForVision(MessageModel message, String model) {
    if (!_isVisionModel(model)) return message.content;

    final content = message.content;
    final imagePattern = RegExp(r'data:(image/[^;]+);base64,([A-Za-z0-9+/=]+)');
    final matches = imagePattern.allMatches(content);

    if (matches.isEmpty) return content;

    final contentParts = <Map<String, dynamic>>[];
    String textContent = content;
    
    for (final match in matches) {
      textContent = textContent.replaceAll(match.group(0)!, '');
    }
    
    textContent = textContent
        .replaceAll(RegExp(r'📁 الملف:.*?\n'), '')
        .replaceAll(RegExp(r'📏 الحجم:.*?\n'), '')
        .replaceAll(RegExp(r'🗂️ النوع:.*?\n'), '')
        .replaceAll(RegExp(r'🖼️ صورة.*?:\n'), '')
        .trim();

    if (textContent.isNotEmpty) {
      contentParts.add({'type': 'text', 'text': textContent});
    }

    for (final match in matches) {
      final mimeType = match.group(1)!;
      final base64Data = match.group(2)!;
      contentParts.add({
        'type': 'image_url',
        'image_url': {'url': 'data:$mimeType;base64,$base64Data'},
      });
    }

    return contentParts;
  }

  // تحقق من دعم النموذج للرؤية
  bool _isVisionModel(String model) {
    final visionKeywords = ['vision', 'vl', '4o', 'claude-3', 'gemini-1.5'];
    return visionKeywords.any((keyword) => model.toLowerCase().contains(keyword));
  }

  // إرسال إلى GPTGod
  Future<String> _sendToGPTGod({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) async {
    final apiKey = _gptgodApiKey.isNotEmpty ? _gptgodApiKey : _gptgodApiKey2;
    if (apiKey.isEmpty) throw Exception('مفتاح GPTGod غير متوفر');

    final requestMessages = <Map<String, dynamic>>[];
    
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      requestMessages.add({'role': 'system', 'content': systemPrompt});
    }

    for (final message in messages) {
      requestMessages.add({
        'role': message.role.name,
        'content': message.content,
      });
    }

    final response = await _dio!.post(
      'https://api.gptgod.online/v1/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      data: {
        'model': model,
        'messages': requestMessages,
        'temperature': temperature ?? 0.7,
        'max_tokens': maxTokens ?? 2048,
      },
    );

    return response.data['choices'][0]['message']['content'];
  }

  // إرسال إلى HuggingFace
  Future<String> _sendToHuggingFace({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) async {
    final apiKey = _huggingfaceApiKey;
    if (apiKey.isEmpty) throw Exception('مفتاح HuggingFace غير متوفر');

    String prompt = '';
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      prompt += '$systemPrompt\n\n';
    }

    for (final message in messages) {
      prompt += '${message.role.name}: ${message.content}\n';
    }
    prompt += 'assistant:';

    final response = await _dio!.post(
      'https://api-inference.huggingface.co/models/$model',
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      data: {
        'inputs': prompt,
        'parameters': {
          'temperature': temperature ?? 0.7,
          'max_new_tokens': maxTokens ?? 2048,
          'return_full_text': false,
        },
      },
    );

    if (response.data is List && response.data.isNotEmpty) {
      return response.data[0]['generated_text'] ?? 'لا يوجد رد';
    }
    
    return response.data['generated_text'] ?? 'لا يوجد رد';
  }



  // البحث باستخدام Tavily
  Future<String> searchWithTavily(String query) async {
    if (_tavilyApiKey.isEmpty) {
      throw Exception('مفتاح Tavily غير متوفر');
    }

    try {
      final response = await _dio!.post(
        'https://api.tavily.com/search',
        options: Options(headers: {'Authorization': 'Bearer $_tavilyApiKey'}),
        data: {
          'query': query,
          'search_depth': 'basic',
          'include_answer': true,
          'include_raw_content': false,
          'max_results': 5,
        },
      );

      if (response.data['results'] != null && response.data['results'].isNotEmpty) {
        final results = response.data['results'] as List;
        String searchResults = 'نتائج البحث:\n\n';

        for (int i = 0; i < results.length && i < 3; i++) {
          final result = results[i];
          searchResults += '${i + 1}. ${result['title']}\n';
          searchResults += '${result['content']}\n';
          searchResults += 'المصدر: ${result['url']}\n\n';
        }

        return searchResults;
      }

      return 'لم يتم العثور على نتائج للبحث: $query';
    } catch (e) {
      print('❌ [TAVILY] خطأ في البحث: $e');
      return 'حدث خطأ أثناء البحث: $e';
    }
  }

  // الحصول على النماذج المتاحة حسب الخدمة
  List<String> getAvailableModels() {
    List<String> models = [];

    if (_groqApiKey.isNotEmpty) {
      models.addAll([
        'llama-3.1-8b-instant',
        'llama-3.1-70b-versatile',
        'llama-3.2-1b-preview',
        'llama-3.2-3b-preview',
        'mixtral-8x7b-32768',
        'gemma-7b-it',
        'gemma2-9b-it',
      ]);
    }

    if (_gptgodApiKey.isNotEmpty) {
      models.addAll([
        'gpt-4o',
        'gpt-4o-mini',
        'gpt-4.5-turbo',
        'claude-3-5-sonnet-20241022',
        'claude-3-5-haiku-20241022',
        'gemini-1.5-pro',
        'gemini-1.5-flash',
      ]);
    }

    if (_openRouterApiKey.isNotEmpty) {
      models.addAll([
        'anthropic/claude-3.5-sonnet',
        'openai/gpt-4o',
        'google/gemini-pro-1.5',
        'meta-llama/llama-3.1-405b-instruct',
        'mistralai/mixtral-8x7b-instruct',
        'qwen/qwen-2.5-72b-instruct',
      ]);
    }

    if (_huggingfaceApiKey.isNotEmpty) {
      models.addAll([
        'meta-llama/Llama-2-7b-chat-hf',
        'microsoft/DialoGPT-medium',
        'Qwen/Qwen2.5-7B-Instruct',
        'google/flan-t5-large',
      ]);
    }

    return models;
  }

  // تحديث مفتاح API
  Future<void> updateApiKey(String service, String apiKey) async {
    switch (service.toLowerCase()) {
      case 'groq':
        _groqApiKey = apiKey;
        break;
      case 'gptgod':
        _gptgodApiKey = apiKey;
        break;
      case 'openrouter':
        _openRouterApiKey = apiKey;
        break;
      case 'huggingface':
        _huggingfaceApiKey = apiKey;
        break;
      case 'tavily':
        _tavilyApiKey = apiKey;
        break;
    }

    // حفظ في ApiKeyManager أيضاً
    await ApiKeyManager.saveApiKey(service, apiKey);

    if (kDebugMode) {
      print('🔑 [UNIFIED_AI] تم تحديث مفتاح $service');
    }
  }

  // تنظيف الموارد
  void dispose() {
    try {
      _dio?.close(force: true);
      _dio = null;
      
      // تنظيف المفاتيح الحساسة من الذاكرة
      _groqApiKey = '';
      _groqApiKey2 = '';
      _gptgodApiKey = '';
      _gptgodApiKey2 = '';
      _openRouterApiKey = '';
      _huggingfaceApiKey = '';
      _tavilyApiKey = '';
      
      _lastUsedService = '';
      _lastUsedModel = '';
      
      if (kDebugMode) {
        print('✅ [UNIFIED_AI] تم تنظيف الموارد بنجاح');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UNIFIED_AI] خطأ في تنظيف الموارد: $e');
      }
    }
  }
}
