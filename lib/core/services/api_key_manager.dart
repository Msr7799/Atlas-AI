import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ApiKeyManager {
  // الحصول على مفتاح API مع fallback للمفاتيح الافتراضية
  static Future<String> getApiKey(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = prefs.getString('${serviceName}_api_key') ?? '';
    
    // إذا كان المستخدم أدخل مفتاحه الخاص، استخدمه
    if (userKey.isNotEmpty) {
      return userKey;
    }
    
    // جرب المفتاح من .env أولاً
    String envKey = '';
    switch (serviceName) {
      case 'groq':
        envKey = AppConfig.groqApiKey;
        break;
      case 'gptgod':
        envKey = AppConfig.gptGodApiKey;
        break;
      case 'tavily':
        envKey = AppConfig.tavilyApiKey;
        break;
      default:
        break;
    }
    
    // إذا وُجد مفتاح في .env، استخدمه
    if (envKey.isNotEmpty) {
      return envKey;
    }
    
    // وإلا استخدم المفتاح الافتراضي كحل أخير
    return AppConfig.defaultApiKeys[serviceName] ?? '';
  }

  // الحصول على جميع مفاتيح API
  static Future<Map<String, String>> loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> keys = {};
    
    // قائمة الخدمات المدعومة
    final services = ['groq', 'gptgod', 'tavily', 'huggingface', 'openrouter'];
    
    for (final service in services) {
      final userKey = prefs.getString('${service}_api_key') ?? '';
      if (userKey.isNotEmpty) {
        keys[service] = userKey;
      } else {
        // جرب المفتاح من .env أولاً
        String envKey = '';
        switch (service) {
          case 'groq':
            envKey = AppConfig.groqApiKey;
            break;
          case 'gptgod':
            envKey = AppConfig.gptGodApiKey;
            break;
          case 'tavily':
            envKey = AppConfig.tavilyApiKey;
            break;
          default:
            break;
        }
        
        // استخدم مفتاح .env إذا كان متوفراً، وإلا المفتاح الافتراضي
        keys[service] = envKey.isNotEmpty ? envKey : (AppConfig.defaultApiKeys[service] ?? '');
      }
    }
    
    return keys;
  }

  // التحقق من وجود مفتاح مطلوب
  static Future<bool> hasRequiredKeys() async {
    final groqKey = await getApiKey('groq');
    return groqKey.isNotEmpty;
  }

  // التحقق من وجود أي مفاتيح (مستخدمة أو افتراضية)
  static Future<bool> hasAnyKeys() async {
    final keys = await loadApiKeys();
    return keys.values.any((key) => key.isNotEmpty);
  }

  // التحقق من استخدام مفاتيح افتراضية
  static Future<bool> isUsingDefaultKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final services = ['groq', 'gptgod', 'tavily'];
    
    for (final service in services) {
      final userKey = prefs.getString('${service}_api_key');
      if (userKey == null || userKey.isEmpty) {
        return true; // يستخدم مفتاح افتراضي
      }
    }
    return false;
  }

  // الحصول على قائمة المفاتيح المستخدمة (مخصصة أو افتراضية)
  static Future<Map<String, Map<String, dynamic>>> getKeysStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, dynamic>> status = {};
    
    final services = ['groq', 'gptgod', 'tavily', 'huggingface', 'openrouter'];
    
    for (final service in services) {
      final userKey = prefs.getString('${service}_api_key');
      final isUsingDefault = userKey == null || userKey.isEmpty;
      final currentKey = await getApiKey(service);
      
      status[service] = {
        'hasKey': currentKey.isNotEmpty,
        'isUsingDefault': isUsingDefault,
        'isRequired': service == 'groq',
        'keyPreview': currentKey.isNotEmpty 
            ? '${currentKey.substring(0, 8)}...${currentKey.substring(currentKey.length - 4)}'
            : 'غير متوفر',
      };
    }
    
    return status;
  }

  // حفظ مفتاح API للمستخدم
  static Future<void> saveApiKey(String serviceName, String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${serviceName}_api_key', apiKey.trim());
  }

  // مسح جميع مفاتيح API
  static Future<void> clearAllApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final services = ['groq', 'gptgod', 'tavily', 'huggingface', 'openrouter'];
    
    for (final service in services) {
      await prefs.remove('${service}_api_key');
    }
  }

  // مسح مفتاح API محدد
  static Future<void> clearApiKey(String keyName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${keyName}_api_key');
  }

  // الحصول على قائمة النماذج المجانية لخدمة معينة
  static List<Map<String, dynamic>> getFreeModels(String serviceName) {
    return AppConfig.freeModels[serviceName] ?? [];
  }

  // الحصول على معلومات نموذج محدد
  static Map<String, dynamic>? getModelInfo(String serviceName, String modelId) {
    final models = getFreeModels(serviceName);
    try {
      return models.firstWhere((model) => model['id'] == modelId);
    } catch (e) {
      return null;
    }
  }

  // الحصول على قائمة أسماء النماذج فقط
  static List<String> getFreeModelIds(String serviceName) {
    final models = getFreeModels(serviceName);
    return models.map((model) => model['id'] as String).toList();
  }

  // التحقق من صحة مفتاح API
  static bool isValidApiKey(String apiKey) {
    if (apiKey.isEmpty) return false;
    
    // التحقق من طول المفتاح (يختلف حسب الخدمة)
    if (apiKey.length < 20) return false;
    
    // التحقق من تنسيق المفتاح
    if (apiKey.startsWith('sk-') || 
        apiKey.startsWith('gsk_') || 
        apiKey.startsWith('tvly-') ||
        apiKey.startsWith('hf_')) {
      return true;
    }
    
    return false;
  }

  // الحصول على معلومات الخدمة
  static Map<String, Map<String, dynamic>> getServiceInfo() {
    return {
      'groq': {
        'name': 'Groq',
        'description': 'نماذج سريعة ومجانية',
        'url': 'https://console.groq.com/keys',
        'freeModels': getFreeModels('groq'),
        'isRequired': true,
      },
      'gptgod': {
        'name': 'GPTGod',
        'description': 'نموذج GPT-3.5 مجاني',
        'url': 'https://gptgod.site',
        'freeModels': getFreeModels('gptgod'),
        'isRequired': false,
      },
      'tavily': {
        'name': 'Tavily',
        'description': 'البحث على الإنترنت',
        'url': 'https://tavily.com',
        'freeModels': [],
        'isRequired': false,
      },
      'huggingface': {
        'name': 'Hugging Face',
        'description': 'نماذج مفتوحة المصدر',
        'url': 'https://huggingface.co/settings/tokens',
        'freeModels': [],
        'isRequired': false,
      },
      'openrouter': {
        'name': 'OpenRouter',
        'description': 'نماذج متعددة (GPT-4, Claude, Gemini)',
        'url': 'https://openrouter.ai/keys',
        'freeModels': [],
        'isRequired': false,
      },
    };
  }
}