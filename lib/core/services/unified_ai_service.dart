import 'dart:async';
import 'package:dio/dio.dart';
import 'api_key_manager.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../config/app_config.dart';
import 'custom_models_manager.dart';

/// خدمة AI موحدة مع معالجة أخطاء محسنة وتبديل تلقائي بين الخدمات
class UnifiedAIService {
  static final UnifiedAIService _instance = UnifiedAIService._internal();
  factory UnifiedAIService() => _instance;
  UnifiedAIService._internal();

  Dio? _dio;
  String _lastUsedService = '';
  String _lastUsedModel = '';
  
  // تتبع حالة الخدمات
  final Map<String, bool> _serviceHealth = {
    'gptgod': true,
    'openrouter': true,
  };
  
  // تتبع أخطاء الخدمات لتجنب التكرار
  final Map<String, DateTime> _serviceErrors = {};

  // مفاتيح API
  String _gptgodApiKey = '';
  String _gptgodApiKey2 = '';
  String _openRouterApiKey = '';
  String _hfToken = '';
  String _tavilyApiKey = '';

  // Getters
  String get lastUsedService => _lastUsedService;
  String get lastUsedModel => _lastUsedModel;
  Map<String, bool> get serviceHealth => Map.from(_serviceHealth);

  // تهيئة الخدمة
  Future<void> initialize() async {
    if (_dio != null) return;

    await _loadApiKeys();

    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    if (kDebugMode) {
      _dio!.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (obj) => debugPrint('[AI_SERVICE] $obj'),
        ),
      );
    }

    print('✅ [UNIFIED_AI] تم تهيئة الخدمة الموحدة');
    _logServiceStatus();
  }

  Future<void> _loadApiKeys() async {
    try {
      // تحميل من .env أولاً
      _gptgodApiKey = dotenv.env['GPTGOD_API_KEY'] ?? '';
      _gptgodApiKey2 = dotenv.env['GPTGOD_API_KEY2'] ?? '';
      _openRouterApiKey = dotenv.env['OPEN_ROUTER_API'] ?? '';
      _hfToken = dotenv.env['HF_TOKEN'] ?? '';
      _tavilyApiKey = dotenv.env['TAVILY_API_KEY'] ?? '';

      // إذا لم توجد في .env، جرب ApiKeyManager
      if (_gptgodApiKey.isEmpty) {
        _gptgodApiKey = await ApiKeyManager.getApiKey('gptgod');
      }
      if (_openRouterApiKey.isEmpty) {
        _openRouterApiKey = await ApiKeyManager.getApiKey('openrouter');
      }
      if (_tavilyApiKey.isEmpty) {
        _tavilyApiKey = await ApiKeyManager.getApiKey('tavily');
      }
      if (_hfToken.isEmpty) {
        _hfToken = await ApiKeyManager.getApiKey('huggingface');
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

  void _logServiceStatus() {
    if (kDebugMode) {
      print('🔑 [UNIFIED_AI] Keys Status:');
      print('  - GPTGod: ${_gptgodApiKey.isNotEmpty ? "✅ Available" : "❌ Missing"}');
      print('  - OpenRouter: ${_openRouterApiKey.isNotEmpty ? "✅ Available" : "❌ Missing"}');
      print('  - Tavily: ${_tavilyApiKey.isNotEmpty ? "✅ Available" : "❌ Missing"}');
    }
  }

  // إرسال رسالة مع معالجة أخطاء محسنة وتبديل تلقائي
  Future<String> sendMessage({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    bool? enableAutoFormatting,
    List<String>? attachedFiles,
  }) async {
    // منع إرسال نماذج توليد الصور كطلبات محادثة
    if (_isImageGenerationModel(model)) {
      throw Exception(
        'نموذج "$model" مخصص لتوليد الصور وليس للمحادثة. استخدم generateImage() بدلاً من ذلك.'
      );
    }
    
    String? lastError;
    
    // قائمة الخدمات المرتبة حسب الأولوية للنموذج المحدد
    final servicesForModel = _getServicesForModel(model);
    
    for (final service in servicesForModel) {
      // تخطي الخدمة إذا كانت معطلة مؤقتاً
      if (!_isServiceHealthy(service)) {
        print('⚠️ [UNIFIED_AI] تخطي خدمة $service (معطلة مؤقتاً)');
        continue;
      }

      try {
        _lastUsedService = service;
        _lastUsedModel = model;

        print('🚀 [UNIFIED_AI] محاولة استخدام خدمة: $service للنموذج: $model');

        String response;
        switch (service) {
          case 'openrouter':
            response = await _sendToOpenRouter(
              messages: messages,
              model: model,
              temperature: temperature,
              maxTokens: maxTokens,
              systemPrompt: systemPrompt,
              attachedFiles: attachedFiles,
            );
            break;
          case 'gptgod':
            response = await _sendToGPTGod(
              messages: messages,
              model: model,
              temperature: temperature ?? 0.7,
              maxTokens: maxTokens ?? 1024,
              systemPrompt: systemPrompt,
              attachedFiles: attachedFiles?.cast<String>(),
            );
            break;
          case 'Custom':
            response = await _sendToCustomModel(
              messages: messages,
              model: model,
              temperature: temperature,
              maxTokens: maxTokens,
              systemPrompt: systemPrompt,
              attachedFiles: attachedFiles,
            );
            break;
          default:
            throw Exception('خدمة غير مدعومة: $service');
        }

        // إذا نجح الطلب، أعد تعيين حالة الخدمة للصحة
        _markServiceHealthy(service);
        
        print('✅ [UNIFIED_AI] نجح الإرسال عبر: $service');
        return response;

      } catch (e) {
        lastError = e.toString();
        print('❌ [UNIFIED_AI] فشل في خدمة $service: $e');
        
        // تحديد نوع الخطأ
        if (_isTemporaryError(e)) {
          _markServiceUnhealthy(service);
          print('⚠️ [UNIFIED_AI] تم تعطيل $service مؤقتاً');
        } else if (_isPermanentError(e)) {
          print('🚫 [UNIFIED_AI] خطأ دائم في $service - لا يمكن التبديل');
          // للأخطاء الدائمة (مثل مفتاح API خاطئ)، لا نجرب خدمات أخرى
          break;
        }
        
        // استمر في المحاولة مع الخدمة التالية
        continue;
      }
    }

    // إذا فشلت جميع الخدمات
    throw Exception('فشل في جميع الخدمات المتاحة. آخر خطأ: ${lastError ?? "غير معروف"}');
  }

  // تحديد الخدمات المناسبة للنموذج - نظام مرن وقابل للتوسع
  List<String> _getServicesForModel(String model) {
    print('🔍 [UNIFIED_AI] تحديد الخدمات للنموذج: $model');
    
    // أولاً: النماذج المخصصة لها الأولوية المطلقة
    final customModels = CustomModelsManager.instance.customModels;
    final customModelIndex = customModels.indexWhere((config) => config.name == model);
    
    if (customModelIndex != -1) {
      final customModel = customModels[customModelIndex];
      print('✅ [UNIFIED_AI] نموذج مخصص موجود: ${customModel.name}');
      return ['Custom']; // النماذج المخصصة تستخدم تكوينها الخاص حصرياً
    }

    // ثانياً: البحث في AppConfig عن النموذج
    final modelConfig = _findModelInAppConfig(model);
    if (modelConfig != null) {
      final services = _getServicesForModelType(modelConfig);
      print('✅ [UNIFIED_AI] نموذج معروف في AppConfig: $model -> خدمات: $services');
      return services;
    }

    // ثالثاً: ترتيب افتراضي للنماذج غير المعروفة (مرن وقابل للتعديل)
    final defaultServices = _getDefaultServiceOrder();
    print('⚠️ [UNIFIED_AI] نموذج غير معروف: $model -> خدمات افتراضية: $defaultServices');
    return defaultServices;
  }

  // ترتيب الخدمات الافتراضي - قابل للتخصيص
  List<String> _getDefaultServiceOrder() {
    return ['gptgod', 'openrouter'];
  }

  // البحث عن النموذج في AppConfig
  Map<String, dynamic>? _findModelInAppConfig(String modelId) {
    for (final serviceModels in AppConfig.freeModels.values) {
      for (final model in serviceModels) {
        if (model['id'] == modelId) {
          return model;
        }
      }
    }
    return null;
  }

  // تحديد الخدمات حسب نوع النموذج - نظام مرن بدون أسماء مُرمزة
  List<String> _getServicesForModelType(Map<String, dynamic> modelConfig) {
    final features = List<String>.from(modelConfig['features'] ?? []);
    final provider = modelConfig['provider']?.toString().toLowerCase() ?? '';
    final preferredServices = List<String>.from(modelConfig['preferredServices'] ?? []);
    
    // إذا كان النموذج يحدد خدمات مفضلة في التكوين، استخدمها
    if (preferredServices.isNotEmpty) {
      print('📋 [UNIFIED_AI] استخدام خدمات مفضلة من التكوين: $preferredServices');
      return _validateAndOrderServices(preferredServices);
    }
    
    // نظام ذكي لترتيب الخدمات حسب الميزات والمزود
    final orderedServices = <String>[];
    
    // للنماذج البصرية، أولوية للخدمات التي تدعم الرؤية
    if (features.contains('vision')) {
      orderedServices.addAll(_getVisionCapableServices());
    }
    
    // ترتيب حسب المزود بطريقة مرنة
    orderedServices.addAll(_getServicesForProvider(provider));
    
    // إضافة باقي الخدمات المتاحة
    orderedServices.addAll(_getAllAvailableServices());
    
    // إزالة التكرارات والحفاظ على الترتيب
    final uniqueServices = orderedServices.toSet().toList();
    
    print('🎯 [UNIFIED_AI] ترتيب الخدمات للمزود "$provider" والميزات $features: $uniqueServices');
    return uniqueServices;
  }

  // الحصول على خدمات قادرة على معالجة الصور
  List<String> _getVisionCapableServices() {
    return ['gptgod', 'openrouter'];
  }

  // الحصول على خدمات مناسبة للمزود
  List<String> _getServicesForProvider(String provider) {
    final providerServiceMap = {
      'openai': ['gptgod', 'openrouter'],
      'google': ['openrouter', 'gptgod'],
      'gemini': ['openrouter', 'gptgod'],
      'anthropic': ['openrouter', 'gptgod'],
      'claude': ['openrouter', 'gptgod'],
      'mistral': ['openrouter'],
    };
    
    return providerServiceMap[provider] ?? [];
  }

  // الحصول على جميع الخدمات المتاحة - نظام مرن وقابل للتطوير
  List<String> _getAllAvailableServices() {
    final standardServices = ['gptgod', 'openrouter'];
    
    // إضافة Custom إذا كان هناك نماذج مخصصة
    if (CustomModelsManager.instance.customModels.isNotEmpty) {
      return ['Custom', ...standardServices];
    }
    
    return standardServices;
  }

  // التحقق من صحة وترتيب الخدمات
  List<String> _validateAndOrderServices(List<String> services) {
    final allServices = _getAllAvailableServices();
    return services.where((service) => allServices.contains(service)).toList();
  }

  // فحص صحة الخدمة - نظام محسن
  bool _isServiceHealthy(String service) {
    // الخدمة المخصصة صحية إذا كان هناك نماذج مخصصة
    if (service == 'Custom') {
      return CustomModelsManager.instance.customModels.isNotEmpty;
    }
    
    // تحقق من وجود مفتاح API للخدمات الأخرى
    if (!_hasValidApiKey(service)) {
      print('⚠️ [UNIFIED_AI] مفتاح API غير صالح للخدمة: $service');
      return false;
    }

    // إذا كان هناك خطأ حديث، انتظر قبل المحاولة مرة أخرى
    final lastError = _serviceErrors[service];
    if (lastError != null) {
      final timeSinceError = DateTime.now().difference(lastError);
      if (timeSinceError.inMinutes < 5) { // انتظار 5 دقائق
        return false;
      }
      // إزالة الخطأ القديم
      _serviceErrors.remove(service);
    }

    return _serviceHealth[service] ?? true;
  }

  // فحص وجود مفتاح API صحيح
  bool _hasValidApiKey(String service) {
    switch (service) {
      case 'gptgod':
        return _gptgodApiKey.isNotEmpty || _gptgodApiKey2.isNotEmpty;
      case 'openrouter':
        return _openRouterApiKey.isNotEmpty;
      default:
        return false;
    }
  }

  // تحديد نوع الخطأ
  bool _isTemporaryError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('500') ||           // خطأ خادم
           errorStr.contains('502') ||           // Bad Gateway
           errorStr.contains('503') ||           // Service Unavailable
           errorStr.contains('504') ||           // Gateway Timeout
           errorStr.contains('timeout') ||       // انتهاء المهلة
           errorStr.contains('connection') ||    // مشاكل الاتصال
           errorStr.contains('network');         // مشاكل الشبكة
  }

  bool _isPermanentError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    return errorStr.contains('401') ||           // Unauthorized
           errorStr.contains('403') ||           // Forbidden
           errorStr.contains('invalid key') ||   // مفتاح خاطئ
           errorStr.contains('quota');           // تجاوز الحصة
  }

  // تعليم الخدمة كمعطلة مؤقتاً
  void _markServiceUnhealthy(String service) {
    _serviceHealth[service] = false;
    _serviceErrors[service] = DateTime.now();
    
    // إعادة تفعيل الخدمة بعد 10 دقائق
    Timer(const Duration(minutes: 10), () {
      _serviceHealth[service] = true;
      print('🔄 [UNIFIED_AI] إعادة تفعيل خدمة: $service');
    });
  }

  // تعليم الخدمة كصحية
  void _markServiceHealthy(String service) {
    _serviceHealth[service] = true;
    _serviceErrors.remove(service);
  }

  // فحص ما إذا كان النموذج مخصص لتوليد الصور
  bool _isImageGenerationModel(String model) {
    final imageModels = [
      'black-forest-labs/FLUX.1-dev',
      'black-forest-labs/flux.1-dev',
      'flux.1-dev',
      'flux-dev',
      'dall-e-2',
      'dall-e-3',
      'midjourney',
      'stable-diffusion',
    ];
    
    final lowerModel = model.toLowerCase();
    return imageModels.any((imageModel) => 
      lowerModel.contains(imageModel.toLowerCase())
    );
  }

  // فحص ما إذا كان الملف صورة
  bool _isImageFile(String file) {
    final lowerFile = file.toLowerCase();
    return lowerFile.contains('data:image/') || 
           lowerFile.endsWith('.jpg') || 
           lowerFile.endsWith('.jpeg') || 
           lowerFile.endsWith('.png') || 
           lowerFile.endsWith('.gif') || 
           lowerFile.endsWith('.webp');
  }

  // فحص ما إذا كان النموذج يدعم الرؤية
  bool _isVisionModel(String model) {
    return model.contains('vision') || 
           model.contains('gpt-4o') || 
           model.contains('claude');
  }

  // إرسال إلى GPTGod مع معالجة محسنة للأخطاء
  Future<String> _sendToGPTGod({
    required List<MessageModel> messages,
    required String model,
    double temperature = 0.7,
    int maxTokens = 1024,
    String? systemPrompt,
    List<String>? attachedFiles,
  }) async {
    final apiKey = _gptgodApiKey.isNotEmpty ? _gptgodApiKey : _gptgodApiKey2;
    if (apiKey.isEmpty) throw Exception('مفتاح GPTGod غير متوفر');

    final requestMessages = <Map<String, dynamic>>[];
    
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      requestMessages.add({'role': 'system', 'content': systemPrompt});
    }

    String actualModel = model;
    if (model == 'gpt-4o-vision') {
      actualModel = 'gpt-4o';
    } else if (model == 'gpt-4o-mini') {
      actualModel = 'gpt-4o-mini';
    }

    for (final message in messages) {
      if (_isVisionModel(model) && 
          message == messages.last && 
          message.role == MessageRole.user && 
          attachedFiles != null && 
          attachedFiles.isNotEmpty &&
          attachedFiles.any((file) => _isImageFile(file))) {
        
        final contentParts = <Map<String, dynamic>>[];
        
        if (message.content.isNotEmpty) {
          contentParts.add({
            'type': 'text',
            'text': message.content,
          });
        }
        
        for (final file in attachedFiles) {
          if (_isImageFile(file)) {
            // البيانات تأتي مُنسقة بالفعل من ChatProvider كـ data URI
            contentParts.add({
              'type': 'image_url',
              'image_url': {
                'url': file,
                'detail': 'auto',
              },
            });
          }
        }
        
        requestMessages.add({
          'role': message.role.name,
          'content': contentParts,
        });
      } else {
        requestMessages.add({
          'role': message.role.name,
          'content': message.content,
        });
      }
    }

    final requestData = {
      'model': actualModel,
      'messages': requestMessages,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'stream': false,
    };

    print('🔧 [GPT_GOD_DEBUG] تفاصيل الطلب:');
    print('  - النموذج الأصلي: $model');
    print('  - النموذج المرسل: $actualModel');
    print('  - عدد الرسائل: ${requestMessages.length}');

    try {
      final response = await _dio!.post(
        'https://api.gptgod.online/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final content = response.data['choices'][0]['message']['content'];
        return content ?? 'رد فارغ من GPTGod';
      } else {
        final errorMessage = response.data?['error']?['message'] ?? 
                           'خطأ غير معروف من GPTGod';
        throw Exception('خطأ GPTGod ${response.statusCode}: $errorMessage');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        throw Exception('خطأ خادم GPTGod مؤقت - سيتم المحاولة مع خدمة أخرى');
      }
      rethrow;
    }
  }


  // إرسال إلى OpenRouter مع دعم Vision
  Future<String> _sendToOpenRouter({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  }) async {
    if (_openRouterApiKey.isEmpty) {
      throw Exception('مفتاح OpenRouter غير متوفر');
    }

    final requestMessages = <Map<String, dynamic>>[];

    // إضافة رسالة النظام إذا وجدت
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      requestMessages.add({
        'role': 'system',
        'content': systemPrompt,
      });
    }

    // تحديد النموذج المناسب لـ OpenRouter
    String actualModel = model;
    if (model == 'gpt-4o-vision') {
      actualModel = 'openai/gpt-4o';
    } else if (model == 'gpt-4o') {
      actualModel = 'openai/gpt-4o';
    } else if (model == 'gpt-4o-mini') {
      actualModel = 'openai/gpt-4o-mini';
    } else if (model == 'Qwen2-VL-7B-Instruct') {
      actualModel = 'qwen/qwen2-vl-7b-instruct';
    }

    // إضافة الرسائل مع دعم Vision
    for (final message in messages) {
      // تطبيق تنسيق Vision للرسالة الأخيرة مع الصور
      if (_isVisionModel(model) && 
          message == messages.last && 
          message.role == MessageRole.user && 
          attachedFiles != null && 
          attachedFiles.isNotEmpty &&
          attachedFiles.any((file) => _isImageFile(file))) {
        
        final contentParts = <Map<String, dynamic>>[];
        
        // إضافة النص
        if (message.content.isNotEmpty) {
          contentParts.add({
            'type': 'text',
            'text': message.content,
          });
        }
        
        // إضافة الصور
        for (final file in attachedFiles) {
          if (_isImageFile(file)) {
            // البيانات تأتي مُنسقة بالفعل من ChatProvider كـ data URI
            contentParts.add({
              'type': 'image_url',
              'image_url': {
                'url': file,
                'detail': 'auto',
              },
            });
          }
        }
        
        requestMessages.add({
          'role': message.role.name,
          'content': contentParts,
        });
      } else {
        // تنسيق عادي للرسائل الأخرى
        requestMessages.add({
          'role': message.role.name,
          'content': message.content,
        });
      }
    }

    final requestData = {
      'model': actualModel,
      'messages': requestMessages,
      'temperature': temperature ?? 0.7,
      'max_tokens': maxTokens ?? 2048,
      'stream': false,
    };

    if (kDebugMode) {
      print('🚀 [OPENROUTER_V2] إرسال طلب للنموذج: $actualModel');
      print('📊 [OPENROUTER_V2] عدد الرسائل: ${requestMessages.length}');
      print('🖼️ [OPENROUTER_V2] يحتوي على صور: ${attachedFiles?.any((file) => _isImageFile(file)) ?? false}');
    }

    try {
      final response = await _dio!.post(
        'https://openrouter.ai/api/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_openRouterApiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://atlas-ai.app',
            'X-Title': 'Atlas AI',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && 
            responseData['choices'] != null && 
            responseData['choices'].isNotEmpty) {
          
          final content = responseData['choices'][0]['message']['content'];
          
          if (kDebugMode) {
            print('✅ [OPENROUTER_V2] تم استلام الرد بنجاح');
          }
          
          return content ?? 'رد فارغ من OpenRouter';
        } else {
          throw Exception('رد غير صالح من OpenRouter: بنية البيانات غير صحيحة');
        }
      } else {
        final errorMessage = response.data?['error']?['message'] ?? 
                           'خطأ غير معروف من OpenRouter';
        throw Exception('خطأ OpenRouter ${response.statusCode}: $errorMessage');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [OPENROUTER_V2] خطأ Dio: ${e.type}');
        print('   الرسالة: ${e.message}');
        print('   Status Code: ${e.response?.statusCode}');
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('انتهت مهلة الاتصال مع OpenRouter');
        case DioExceptionType.receiveTimeout:
          throw Exception('انتهت مهلة استقبال الرد من OpenRouter');
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            throw Exception('مفتاح OpenRouter غير صالح');
          } else if (e.response?.statusCode == 429) {
            throw Exception('تم تجاوز حد الطلبات لـ OpenRouter');
          } else if (e.response?.statusCode == 500) {
            throw Exception('خطأ خادم OpenRouter مؤقت');
          }
          throw Exception('رد خاطئ من OpenRouter: ${e.response?.statusCode}');
        case DioExceptionType.cancel:
          throw Exception('تم إلغاء الطلب');
        default:
          throw Exception('خطأ في الشبكة مع OpenRouter: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [OPENROUTER_V2] خطأ عام: $e');
      }
      rethrow;
    }
  }

  // إرسال إلى HuggingFace مع معالجة محسنة للأخطاء
  Future<String> _sendToHuggingFace({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
  }) async {
    if (_hfToken.isEmpty) {
      throw Exception('مفتاح HuggingFace غير متوفر');
    }

    // منع إرسال نماذج توليد الصور هنا
    if (_isImageGenerationModel(model)) {
      throw Exception('نموذج "$model" مخصص لتوليد الصور. استخدم generateImage() بدلاً من _sendToHuggingFace().');
    }

    // بناء النص (Prompt) للنموذج
    String prompt = _buildPromptForHuggingFace(messages, systemPrompt);

    final requestData = {
      'inputs': prompt,
      'parameters': {
        'max_new_tokens': maxTokens ?? 512,
        'temperature': temperature ?? 0.7,
        'top_p': 0.9,
        'do_sample': true,
        'return_full_text': false,
        'repetition_penalty': 1.1,
      },
      'options': {
        'wait_for_model': true,
        'use_cache': false,
      },
    };

    if (kDebugMode) {
      print('🚀 [HUGGINGFACE_V2] إرسال طلب للنموذج: $model');
      print('📊 [HUGGINGFACE_V2] طول النص: ${prompt.length} حرف');
      print('🔧 [HUGGINGFACE_V2] المعاملات: maxTokens=${maxTokens ?? 512}, temp=${temperature ?? 0.7}');
    }

    try {
      final response = await _dio!.post(
        'https://api-inference.huggingface.co/models/$model',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_hfToken',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: requestData,
      );

      if (response.statusCode == 200) {
        // HuggingFace يرجع قائمة من الاستجابات
        final responseData = response.data;
        
        if (responseData is List && responseData.isNotEmpty) {
          final firstResult = responseData[0];
          
          if (firstResult is Map<String, dynamic>) {
            final generatedText = firstResult['generated_text'] as String?;
            
            if (generatedText != null && generatedText.isNotEmpty) {
              if (kDebugMode) {
                print('✅ [HUGGINGFACE_V2] تم استلام الرد بنجاح');
                print('📝 [HUGGINGFACE_V2] طول الرد: ${generatedText.length} حرف');
              }
              
              return generatedText.trim();
            }
          }
        }
        
        // إذا لم نجد النص المولد
        throw Exception('رد فارغ أو غير صالح من HuggingFace');
        
      } else if (response.statusCode == 503) {
        // النموذج يحتاج وقت للتحميل
        throw Exception('النموذج قيد التحميل. يرجى المحاولة بعد قليل');
      } else {
        final errorMessage = response.data?['error'] ?? 
                           'خطأ غير معروف من HuggingFace';
        throw Exception('خطأ HuggingFace ${response.statusCode}: $errorMessage');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [HUGGINGFACE_V2] خطأ Dio: ${e.type}');
        print('   الرسالة: ${e.message}');
        print('   Status Code: ${e.response?.statusCode}');
        print('   Response Data: ${e.response?.data}');
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception('انتهت مهلة الاتصال مع HuggingFace');
        case DioExceptionType.receiveTimeout:
          throw Exception('انتهت مهلة استقبال الرد من HuggingFace - النموذج قد يحتاج وقت أطول');
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            throw Exception('مفتاح HuggingFace غير صالح');
          } else if (e.response?.statusCode == 429) {
            throw Exception('تم تجاوز حد الطلبات لـ HuggingFace');
          } else if (e.response?.statusCode == 503) {
            throw Exception('النموذج قيد التحميل في HuggingFace. يرجى المحاولة بعد دقيقتين');
          } else if (e.response?.statusCode == 500) {
            throw Exception('خطأ خادم HuggingFace مؤقت');
          }
          throw Exception('رد خاطئ من HuggingFace: ${e.response?.statusCode}');
        case DioExceptionType.cancel:
          throw Exception('تم إلغاء الطلب');
        default:
          throw Exception('خطأ في الشبكة مع HuggingFace: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [HUGGINGFACE_V2] خطأ عام: $e');
      }
      rethrow;
    }
  }

  // بناء النص (Prompt) لنماذج HuggingFace
  String _buildPromptForHuggingFace(List<MessageModel> messages, String? systemPrompt) {
    final buffer = StringBuffer();

    // إضافة رسالة النظام إذا وجدت
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      buffer.writeln('System: $systemPrompt');
      buffer.writeln();
    }

    // إضافة الرسائل
    for (final message in messages) {
      if (message.role == MessageRole.user) {
        buffer.writeln('Human: ${message.content}');
      } else if (message.role == MessageRole.assistant) {
        buffer.writeln('Assistant: ${message.content}');
      } else if (message.role == MessageRole.system) {
        buffer.writeln('System: ${message.content}');
      }
      buffer.writeln();
    }

    // إضافة بداية رد المساعد
    buffer.write('Assistant: ');
    
    return buffer.toString();
  }



  // الحصول على النماذج المتاحة
  List<Map<String, dynamic>> getAvailableModels() {
    final List<Map<String, dynamic>> allModels = [];
    
    AppConfig.freeModels.forEach((service, models) {
      for (final model in models) {
        allModels.add({
          ...model,
          'service': service,
          'healthy': _isServiceHealthy(service),
        });
      }
    });
    
    // إضافة النماذج المخصصة
    final customModels = CustomModelsManager.instance.customModels;
    for (final customModel in customModels) {
      allModels.add({
        'id': customModel.name,
        'name': customModel.name,
        'description': customModel.description,
        'service': 'Custom',
        'healthy': true,
        'features': ['chat', 'text'],
        'speed': 'medium',
        'quality': 'custom',
        'context': 'variable',
        'provider': 'custom',
        'isCustom': true,
        'customConfig': customModel,
      });
    }
    
    return allModels;
  }

  // تحديث مفتاح API
  Future<void> updateApiKey(String service, String apiKey) async {
    switch (service.toLowerCase()) {
      case 'gptgod':
        _gptgodApiKey = apiKey;
        break;
      case 'openrouter':
        _openRouterApiKey = apiKey;
        break;
      case 'huggingface':
        _hfToken = apiKey;
        break;
      case 'tavily':
        _tavilyApiKey = apiKey;
        break;
    }

    await ApiKeyManager.saveApiKey(service, apiKey);
    
    // إعادة تفعيل الخدمة عند تحديث المفتاح
    _markServiceHealthy(service);

    if (kDebugMode) {
      print('🔑 [UNIFIED_AI] تم تحديث مفتاح $service');
    }
  }

  // تنظيف الموارد
  void dispose() {
    try {
      _dio?.close(force: true);
      _dio = null;
      
      _gptgodApiKey = '';
      _gptgodApiKey2 = '';
      _openRouterApiKey = '';
      _hfToken = '';
      _tavilyApiKey = '';
      
      _lastUsedService = '';
      _lastUsedModel = '';
      _serviceHealth.clear();
      _serviceErrors.clear();
      
      print('🧹 [UNIFIED_AI] تم تنظيف الموارد');
    } catch (e) {
      print('⚠️ [UNIFIED_AI] خطأ في تنظيف الموارد: $e');
    }
  }

  // إرسال إلى النموذج المخصص - مرن وقابل للتطوير
  Future<String> _sendToCustomModel({
    required List<MessageModel> messages,
    required String model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  }) async {
    print('🔧 [CUSTOM_MODEL] محاولة استخدام النموذج المخصص: $model');
    
    try {
      // البحث عن النموذج المخصص
      final customModels = CustomModelsManager.instance.customModels;
      final customModel = customModels.firstWhere(
        (config) => config.name == model,
        orElse: () => throw Exception('النموذج المخصص "$model" غير موجود في القائمة'),
      );

      print('✅ [CUSTOM_MODEL] تم العثور على النموذج: ${customModel.name}');
      print('🌐 [CUSTOM_MODEL] URL: ${customModel.url}');
      print('🔑 [CUSTOM_MODEL] Headers count: ${customModel.headers.length}');

      // بناء محفوظات الرسائل للنموذج المخصص - بدون تكرار system prompt
      final conversationHistory = messages.map((msg) => {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      }).toList();

      // ملاحظة: system prompt يتم إضافته مسبقاً في chat_provider.dart لتجنب التكرار

      // استخدام CustomModelsManager للاستدعاء مع تمرير جميع المعاملات
      final response = await CustomModelsManager.instance.makeApiCall(
        customModel,
        messages.isNotEmpty ? messages.last.content : '',
        conversationHistory: conversationHistory,
        temperature: temperature,
        maxTokens: maxTokens,
        systemPrompt: systemPrompt,
        attachedFiles: attachedFiles,
      );

      if (response == null || response.trim().isEmpty) {
        throw Exception('النموذج المخصص "$model" أرجع رداً فارغاً');
      }

      print('✅ [CUSTOM_MODEL] تم الحصول على رد بنجاح من: $model');
      return response;
      
    } catch (e) {
      print('❌ [CUSTOM_MODEL] خطأ في النموذج المخصص "$model": $e');
      rethrow; // إعادة رمي الخطأ ليتم التعامل معه في الطبقة العليا
    }
  }

  // إنتاج الصور من النص باستخدام Hugging Face FLUX.1-dev
  Future<Map<String, dynamic>> generateImage({
    required String prompt,
    String model = 'black-forest-labs/FLUX.1-dev',
    Map<String, dynamic>? parameters,
  }) async {
    if (_hfToken.isEmpty) {
      throw Exception('مفتاح Hugging Face Token (HF_TOKEN) غير متوفر');
    }

    if (prompt.trim().isEmpty) {
      throw Exception('نص الوصف (Prompt) فارغ');
    }

    final requestData = {
      'inputs': prompt,
      'parameters': parameters ?? {
        'width': 1024,
        'height': 1024,
        'num_inference_steps': 20,
        'guidance_scale': 7.5,
      },
      'options': {
        'wait_for_model': true,
        'use_cache': false,
      },
    };

    if (kDebugMode) {
      print('🎨 [IMAGE_GENERATION] إنتاج صورة بالنموذج: $model');
      print('📝 [IMAGE_GENERATION] النص: $prompt');
      print('🔧 [IMAGE_GENERATION] المعاملات: ${requestData['parameters']}');
    }

    try {
      final response = await _dio!.post(
        'https://api-inference.huggingface.co/models/$model',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_hfToken',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes, // للحصول على الصورة
          validateStatus: (status) => status != null && status < 500,
        ),
        data: requestData,
      );

      if (response.statusCode == 200) {
        final imageBytes = response.data as List<int>;
        
        if (imageBytes.isNotEmpty) {
          if (kDebugMode) {
            print('✅ [IMAGE_GENERATION] تم إنتاج الصورة بنجاح');
            print('📊 [IMAGE_GENERATION] حجم الصورة: ${imageBytes.length} بايت');
          }

          return {
            'success': true,
            'data': imageBytes,
            'model': model,
            'prompt': prompt,
            'timestamp': DateTime.now().toIso8601String(),
          };
        } else {
          throw Exception('تم إنتاج صورة فارغة');
        }
      } else if (response.statusCode == 503) {
        throw Exception('النموذج قيد التحميل. يرجى المحاولة بعد قليل');
      } else {
        final errorMessage = 'خطأ في إنتاج الصورة ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [IMAGE_GENERATION] خطأ Dio: ${e.message}');
      }
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw Exception('انتهت مهلة الاتصال مع Hugging Face');
        case DioExceptionType.badResponse:
          if (e.response?.statusCode == 401) {
            throw Exception('مفتاح HF_TOKEN غير صحيح');
          } else if (e.response?.statusCode == 429) {
            throw Exception('تم تجاوز حد الطلبات لـ Hugging Face');
          } else if (e.response?.statusCode == 500) {
            throw Exception('خطأ خادم Hugging Face مؤقت');
          }
          throw Exception('رد خاطئ من Hugging Face: ${e.response?.statusCode}');
        case DioExceptionType.cancel:
          throw Exception('تم إلغاء الطلب');
        default:
          throw Exception('خطأ في الشبكة مع Hugging Face: ${e.message}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [IMAGE_GENERATION] خطأ عام: $e');
      }
      rethrow;
    }
  }

}