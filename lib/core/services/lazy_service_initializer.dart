import 'api_key_manager.dart';
import 'groq_service.dart';
import 'gptgod_service.dart';
import 'tavily_service.dart';
import 'huggingface_service.dart';
import 'openrouter_service.dart';

class LazyServiceInitializer {
  static final LazyServiceInitializer _instance = LazyServiceInitializer._internal();
  factory LazyServiceInitializer() => _instance;
  LazyServiceInitializer._internal();

  bool _isInitialized = false;

  /// تهيئة جميع الخدمات بالمفاتيح المناسبة
  Future<void> initializeServices() async {
    if (_isInitialized) return;

    try {
      // الحصول على المفاتيح (مستخدمة أو افتراضية)
      final groqKey = await ApiKeyManager.getApiKey('groq');
      final gptgodKey = await ApiKeyManager.getApiKey('gptgod');
      final tavilyKey = await ApiKeyManager.getApiKey('tavily');
      final huggingfaceKey = await ApiKeyManager.getApiKey('huggingface');
      final openrouterKey = await ApiKeyManager.getApiKey('openrouter');

      // تهيئة خدمة Groq
      if (groqKey.isNotEmpty) {
        final groqService = GroqService();
        groqService.initialize();
        groqService.updateApiKey(groqKey);
        final keyType = groqKey.startsWith('gsk_1234567890') ? 'fallback' : 
                       groqKey.startsWith('gsk_') ? 'real' : 'custom';
        print('[LAZY INIT] Groq service initialized with $keyType key: ${groqKey.substring(0, 12)}...');
      }

      // تهيئة خدمة GPTGod
      if (gptgodKey.isNotEmpty) {
        final gptgodService = GPTGodService();
        gptgodService.initialize();
        gptgodService.updateApiKey(gptgodKey);
        final keyType = gptgodKey.startsWith('sk-rvz7PGTel8tSYKftzhmZXEZEj4RzAcs7FZFhhhWW6zXhyysu') ? 'real' : 'custom';
        print('[LAZY INIT] GPTGod service initialized with $keyType key: ${gptgodKey.substring(0, 12)}...');
      }

      // تهيئة خدمة Tavily
      if (tavilyKey.isNotEmpty) {
        final tavilyService = TavilyService();
        tavilyService.initialize();
        tavilyService.updateApiKey(tavilyKey);
        print('[LAZY INIT] Tavily service initialized with ${tavilyKey.startsWith('tvly-dev') ? 'default' : 'custom'} key');
      }

      // تهيئة خدمة Hugging Face
      if (huggingfaceKey.isNotEmpty) {
        final huggingfaceService = HuggingFaceService();
        huggingfaceService.initialize();
        huggingfaceService.updateApiKey(huggingfaceKey);
        print('[LAZY INIT] Hugging Face service initialized');
      }

      // تهيئة خدمة OpenRouter
      if (openrouterKey.isNotEmpty) {
        final openrouterService = OpenRouterService();
        openrouterService.initialize();
        openrouterService.updateApiKey(openrouterKey);
        print('[LAZY INIT] OpenRouter service initialized');
      }

      _isInitialized = true;
      print('[LAZY INIT] All services initialized successfully');
    } catch (e) {
      print('[LAZY INIT ERROR] Failed to initialize services: $e');
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
      print('[SERVICES STATUS ERROR] $e');
    }

    return status;
  }

  /// تنظيف الموارد
  void dispose() {
    try {
      GroqService().dispose();
      GPTGodService().dispose();
      TavilyService().dispose();
      HuggingFaceService().dispose();
      OpenRouterService().dispose();
      _isInitialized = false;
      print('[LAZY INIT] All services disposed');
    } catch (e) {
      print('[LAZY INIT DISPOSE ERROR] $e');
    }
  }
} 