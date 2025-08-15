import 'package:flutter/foundation.dart';
import 'api_key_manager.dart';
import 'unified_ai_service.dart';
import 'tavily_service.dart';

class LazyServiceInitializer {
  static final LazyServiceInitializer _instance = LazyServiceInitializer._internal();
  factory LazyServiceInitializer() => _instance;
  LazyServiceInitializer._internal();

  bool _isInitialized = false;

  /// تهيئة جميع الخدمات بالمفاتيح المناسبة
  Future<void> initializeServices() async {
    if (_isInitialized) return;

    try {
      // تهيئة الخدمة الموحدة
      final aiService = UnifiedAIService();
      await aiService.initialize();
      if (kDebugMode) print('[LAZY INIT] ✅ Unified AI service initialized');

      // تهيئة خدمة Tavily
      final tavilyKey = await ApiKeyManager.getApiKey('tavily');
      if (tavilyKey.isNotEmpty) {
        final tavilyService = TavilyService();
        tavilyService.initialize();
        tavilyService.updateApiKey(tavilyKey);
        if (kDebugMode) print('[LAZY INIT] Tavily service initialized with ${tavilyKey.startsWith('tvly-dev') ? 'default' : 'custom'} key');
      }



      _isInitialized = true;
      if (kDebugMode) print('[LAZY INIT] All services initialized successfully');
    } catch (e) {
      if (kDebugMode) print('[LAZY INIT ERROR] Failed to initialize services: $e');
      rethrow;
    }
  }

  /// إعادة تهيئة الخدمات (مفيد عند تغيير المفاتيح)
  Future<void> reinitializeServices() async {
    _isInitialized = false;
    await initializeServices();
  }

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  /// الحصول على معلومات الخدمات
  Future<Map<String, Map<String, dynamic>>> getServicesStatus() async {
    final status = <String, Map<String, dynamic>>{};
    
    try {
      final groqKey = await ApiKeyManager.getApiKey('groq');
      final gptgodKey = await ApiKeyManager.getApiKey('gptgod');
      final tavilyKey = await ApiKeyManager.getApiKey('tavily');
      final huggingfaceKey = await ApiKeyManager.getApiKey('huggingface');
      final openrouterKey = await ApiKeyManager.getApiKey('openrouter');

      status['groq'] = {
        'initialized': groqKey.isNotEmpty,
        'usingDefault': groqKey.startsWith('gsk_'),
        'keyPreview': groqKey.isNotEmpty 
            ? '${groqKey.substring(0, 8)}...${groqKey.substring(groqKey.length - 4)}'
            : 'غير متوفر',
      };

      status['gptgod'] = {
        'initialized': gptgodKey.isNotEmpty,
        'usingDefault': gptgodKey.startsWith('sk-rvz7'),
        'keyPreview': gptgodKey.isNotEmpty 
            ? '${gptgodKey.substring(0, 8)}...${gptgodKey.substring(gptgodKey.length - 4)}'
            : 'غير متوفر',
      };

      status['tavily'] = {
        'initialized': tavilyKey.isNotEmpty,
        'usingDefault': tavilyKey.startsWith('tvly-dev'),
        'keyPreview': tavilyKey.isNotEmpty 
            ? '${tavilyKey.substring(0, 8)}...${tavilyKey.substring(tavilyKey.length - 4)}'
            : 'غير متوفر',
      };

      status['huggingface'] = {
        'initialized': huggingfaceKey.isNotEmpty,
        'usingDefault': false, // لا يوجد مفتاح افتراضي لـ Hugging Face
        'keyPreview': huggingfaceKey.isNotEmpty 
            ? '${huggingfaceKey.substring(0, 8)}...${huggingfaceKey.substring(huggingfaceKey.length - 4)}'
            : 'غير متوفر',
      };

      status['openrouter'] = {
        'initialized': openrouterKey.isNotEmpty,
        'usingDefault': false, // لا يوجد مفتاح افتراضي لـ OpenRouter
        'keyPreview': openrouterKey.isNotEmpty 
            ? '${openrouterKey.substring(0, 8)}...${openrouterKey.substring(openrouterKey.length - 4)}'
            : 'غير متوفر',
      };
    } catch (e) {
      if (kDebugMode) print('[SERVICES STATUS ERROR] $e');
    }

    return status;
  }

  /// تنظيف الموارد
  void dispose() {
    try {
      UnifiedAIService().dispose();
      TavilyService().dispose();
      _isInitialized = false;
      if (kDebugMode) print('[LAZY INIT] All services disposed');
    } catch (e) {
      if (kDebugMode) print('[LAZY INIT DISPOSE ERROR] $e');
    }
  }
} 
