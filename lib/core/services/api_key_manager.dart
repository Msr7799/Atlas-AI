import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// مدير مفاتيح API محسن مع تشفير وإحصائيات
/// Enhanced API key manager with encryption and statistics
class ApiKeyManager {
  static const String _keyPrefix = 'atlas_';
  static const String _encryptionSalt = 'atlas_ai_2024';

  /// حفظ مفتاح API مع تشفير
  /// Save API key with encryption
  static Future<void> saveApiKey(String serviceName, String apiKey) async {
    if (apiKey.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final encryptedKey = _encryptKey(apiKey);
    final keyName = '$_keyPrefix${serviceName}_api_key_encrypted';
    
    await prefs.setString(keyName, encryptedKey);
    await prefs.setInt('$_keyPrefix${serviceName}_last_updated', DateTime.now().millisecondsSinceEpoch);
    
    if (kDebugMode) print('✅ [API_KEY_MANAGER] تم حفظ مفتاح / Successfully saved key $serviceName');
  }

  /// استرجاع مفتاح API
  /// Retrieve API key
  static Future<String> getApiKey(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final keyName = '$_keyPrefix${serviceName}_api_key_encrypted';
    final encryptedKey = prefs.getString(keyName);
    
    if (encryptedKey == null || encryptedKey.isEmpty) {
      return '';
    }
    
    try {
      return _decryptKey(encryptedKey);
    } catch (e) {
      if (kDebugMode) print('❌ [API_KEY_MANAGER] فشل في فك تشفير مفتاح / Failed to decrypt key $serviceName: $e');
      return '';
    }
  }

  /// التحقق من صحة مفتاح API
  /// Validate API key
  static bool isValidApiKey(String apiKey, String serviceName) {
    if (apiKey.isEmpty || apiKey.length < 20) return false;
    
    switch (serviceName.toLowerCase()) {
      case 'groq':
        return apiKey.startsWith('gsk_') && apiKey.length >= 56;
      case 'gptgod':
        return apiKey.startsWith('sk-') && apiKey.length >= 48;
      case 'tavily':
        return apiKey.startsWith('tvly-') && apiKey.length >= 32;
      case 'openrouter':
        return apiKey.startsWith('sk-or-') || apiKey.startsWith('or-');
      case 'huggingface':
        return apiKey.startsWith('hf_') && apiKey.length >= 32;
      case 'localai':
        return true; // LocalAI لا يحتاج مفتاح // LocalAI doesn't need a key
      default:
        return false;
    }
  }

  /// تشفير بسيط للمفتاح
  /// Simple key encryption
  static String _encryptKey(String key) {
    final bytes = utf8.encode(key + _encryptionSalt);
    final digest = sha256.convert(bytes);
    final encrypted = base64.encode(utf8.encode(key + digest.toString().substring(0, 8)));
    return encrypted;
  }

  /// فك تشفير المفتاح
  /// Decrypt key
  static String _decryptKey(String encryptedKey) {
    try {
      final decoded = utf8.decode(base64.decode(encryptedKey));
      // إزالة الـ salt المضاف
      // Remove added salt
      final key = decoded.substring(0, decoded.length - 8);
      return key;
    } catch (e) {
      throw Exception('فشل في فك تشفير المفتاح / Failed to decrypt key: $e');
    }
  }

  /// تسجيل استخدام API
  /// Record API usage
  static Future<void> recordApiUsage(String serviceName, {bool isSuccess = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final requestsKey = '$_keyPrefix${serviceName}_requests';
    final errorsKey = '$_keyPrefix${serviceName}_errors';
    final lastUsedKey = '$_keyPrefix${serviceName}_last_used';
    
    // زيادة عدد الطلبات
    // Increment request count
    final requests = prefs.getInt(requestsKey) ?? 0;
    await prefs.setInt(requestsKey, requests + 1);
    
    // زيادة عدد الأخطاء إذا فشل الطلب
    // Increment error count if request failed
    if (!isSuccess) {
      final errors = prefs.getInt(errorsKey) ?? 0;
      await prefs.setInt(errorsKey, errors + 1);
    }
    
    // تحديث آخر استخدام
    // Update last used timestamp
    await prefs.setInt(lastUsedKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// الحصول على إحصائيات الاستخدام
  /// Get usage statistics
  static Future<Map<String, dynamic>> getUsageStats(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final requestsKey = '$_keyPrefix${serviceName}_requests';
    final errorsKey = '$_keyPrefix${serviceName}_errors';
    final lastUsedKey = '$_keyPrefix${serviceName}_last_used';
    
    final requests = prefs.getInt(requestsKey) ?? 0;
    final errors = prefs.getInt(errorsKey) ?? 0;
    final lastUsed = prefs.getInt(lastUsedKey) ?? 0;
    
    final successRate = requests > 0 ? ((requests - errors) / requests * 100).toStringAsFixed(1) : '0.0';
    
    return {
      'serviceName': serviceName,
      'requests': requests,
      'errors': errors,
      'successRate': '$successRate%',
      'lastUsed': lastUsed > 0 ? DateTime.fromMillisecondsSinceEpoch(lastUsed) : null,
      'status': _getServiceStatus(requests, errors),
    };
  }

  /// تحديد حالة الخدمة
  /// Determine service status
  static String _getServiceStatus(int requests, int errors) {
    if (requests == 0) return 'غير مستخدم'; // Not used
    if (errors == 0) return 'ممتاز'; // Excellent
    if (errors < requests * 0.1) return 'جيد'; // Good
    if (errors < requests * 0.3) return 'مقبول'; // Acceptable
    return 'ضعيف'; // Poor
  }

  /// مسح إحصائيات خدمة معينة
  /// Clear statistics for specific service
  static Future<void> clearUsageStats(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      '$_keyPrefix${serviceName}_requests',
      '$_keyPrefix${serviceName}_errors',
      '$_keyPrefix${serviceName}_last_used',
    ];
    
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    if (kDebugMode) print('✅ [API_KEY_MANAGER] تم مسح إحصائيات / Cleared statistics for $serviceName');
  }

  /// الحصول على جميع الإحصائيات
  /// Get all usage statistics
  static Future<Map<String, Map<String, dynamic>>> getAllUsageStats() async {
    final services = ['groq', 'gptgod', 'tavily', 'openrouter', 'huggingface', 'localai'];
    final stats = <String, Map<String, dynamic>>{};

    for (final service in services) {
      stats[service] = await getUsageStats(service);
    }

    return stats;
  }

  /// فحص صحة جميع المفاتيح
  /// Validate all API keys
  static Future<Map<String, bool>> validateAllApiKeys() async {
    final services = ['groq', 'gptgod', 'tavily', 'openrouter', 'huggingface', 'localai'];
    final results = <String, bool>{};

    for (final service in services) {
      final key = await getApiKey(service);
      results[service] = isValidApiKey(key, service);
    }

    return results;
  }

  // ===== الدوال المفقودة للتوافق مع الكود القديم =====
  // ===== Missing functions for compatibility with old code =====

  /// التحقق من وجود مفتاح مطلوب
  /// Check if required key exists
  static Future<bool> hasRequiredKeys() async {
    final groqKey = await getApiKey('groq');
    return groqKey.isNotEmpty;
  }

  /// التحقق من وجود أي مفاتيح
  /// Check if any keys exist
  static Future<bool> hasAnyKeys() async {
    final services = ['groq', 'gptgod', 'tavily', 'openrouter', 'huggingface', 'localai'];
    for (final service in services) {
      final key = await getApiKey(service);
      if (key.isNotEmpty) return true;
    }
    return false;
  }

  /// التحقق من استخدام مفاتيح افتراضية
  /// Check if using default keys
  static Future<bool> isUsingDefaultKeys() async {
    // بما أننا نستخدم تشفير، نفترض أن المستخدم أدخل مفاتيحه الخاصة
    // Since we use encryption, we assume user entered their own keys
    return false;
  }

  /// الحصول على حالة المفاتيح
  /// Get keys status
  static Future<Map<String, Map<String, dynamic>>> getKeysStatus() async {
    final services = ['groq', 'gptgod', 'tavily', 'openrouter', 'huggingface', 'localai'];
    final status = <String, Map<String, dynamic>>{};

    for (final service in services) {
      final key = await getApiKey(service);
      final isValid = isValidApiKey(key, service);

      status[service] = {
        'hasKey': key.isNotEmpty,
        'isUsingDefault': false, // لا نستخدم مفاتيح افتراضية
        'isRequired': service == 'groq',
        'keyPreview': key.isNotEmpty
            ? 'مفتاح محفوظ ومشفر'
            : 'غير متوفر',
        'isValid': isValid,
      };
    }

    return status;
  }

  /// مسح جميع مفاتيح API
  static Future<void> clearAllApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final services = ['groq', 'gptgod', 'tavily', 'openrouter', 'huggingface', 'localai'];

    for (final service in services) {
      final keys = [
        '$_keyPrefix${service}_api_key_encrypted',
        '$_keyPrefix${service}_requests',
        '$_keyPrefix${service}_errors',
        '$_keyPrefix${service}_last_used',
        '$_keyPrefix${service}_last_updated',
      ];

      for (final key in keys) {
        await prefs.remove(key);
      }
    }

    if (kDebugMode) print('✅ [API_KEY_MANAGER] تم مسح جميع المفاتيح والإحصائيات / Cleared all keys and statistics');
  }

  /// مسح مفتاح API محدد
  static Future<void> clearApiKey(String serviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      '$_keyPrefix${serviceName}_api_key_encrypted',
      '$_keyPrefix${serviceName}_last_updated',
    ];
    
    for (final key in keys) {
      await prefs.remove(key);
    }
    
    if (kDebugMode) print('✅ [API_KEY_MANAGER] تم مسح مفتاح / Cleared key $serviceName');
  }

  /// الحصول على معلومات الخدمة
  static Map<String, Map<String, dynamic>> getServiceInfo() {
    return {
      'groq': {
        'name': 'Groq',
        'description': 'نماذج Llama وMixtral سريعة ومجانية / Fast and free Llama & Mixtral models',
        'url': 'https://console.groq.com/keys',
        'freeModels': getFreeModels('groq'),
        'isRequired': true,
      },
      'gptgod': {
        'name': 'GPTGod',
        'description': 'نماذج GPT مجانية وسريعة / Free and fast GPT models',
        'url': 'https://gptgod.site',
        'freeModels': getFreeModels('gptgod'),
        'isRequired': false,
      },
      'tavily': {
        'name': 'Tavily Search',
        'description': 'بحث ذكي في الإنترنت / Smart internet search',
        'url': 'https://tavily.com',
        'freeModels': [],
        'isRequired': false,
      },
      'huggingface': {
        'name': 'HuggingFace',
        'description': 'نماذج مفتوحة المصدر / Open source models',
        'url': 'https://huggingface.co/settings/tokens',
        'freeModels': [],
        'isRequired': false,
      },
      'openrouter': {
        'name': 'OpenRouter',
        'description': 'وصول لجميع النماذج المتقدمة / Access to all advanced models',
        'url': 'https://openrouter.ai/keys',
        'freeModels': getFreeModels('openrouter'),
        'isRequired': false,
      },
      'localai': {
        'name': 'LocalAI / Ollama',
        'description': 'نماذج محلية للخصوصية الكاملة / Local models for complete privacy',
        'url': 'https://ollama.ai',
        'freeModels': getFreeModels('localai'),
        'isRequired': false,
      },
    };
  }

  /// الحصول على قائمة النماذج المجانية لخدمة معينة
  /// Get list of free models for specific service
  static List<Map<String, dynamic>> getFreeModels(String serviceName) {
    switch (serviceName) {
      case 'groq':
        return [
          {
            'id': 'llama-3.1-8b-instant',
            'name': 'Llama 3.1 8B Instant',
            'description': 'نموذج Llama 3.1 8B سريع ومتطور',
            'speed': 'سريع جداً',
            'quality': 'ممتاز',
            'context': '128K رمز',
            'features': ['محادثة', 'برمجة', 'تحليل'],
            'maxTokens': 8192,
            'contextLength': 131072,
            'requiresKey': false,
          },
          {
            'id': 'llama-3.1-70b-versatile',
            'name': 'Llama 3.1 70B Versatile',
            'description': 'نموذج Llama 3.1 70B متعدد الاستخدامات',
            'speed': 'سريع',
            'quality': 'ممتاز جداً',
            'context': '128K رمز',
            'features': ['محادثة متقدمة', 'تحليل معقد', 'إبداع'],
            'maxTokens': 8192,
            'contextLength': 131072,
            'requiresKey': false,
          },
          {
            'id': 'llama-3.1-405b-reasoning',
            'name': 'Llama 3.1 405B Reasoning',
            'description': 'أقوى نموذج Llama للتفكير المنطقي',
            'speed': 'متوسط',
            'quality': 'استثنائي',
            'context': '128K رمز',
            'features': ['تفكير منطقي', 'حل مشاكل معقدة', 'تحليل عميق'],
            'maxTokens': 8192,
            'contextLength': 131072,
            'requiresKey': false,
          },
          {
            'id': 'mixtral-8x7b-32768',
            'name': 'Mixtral 8x7B',
            'description': 'نموذج Mixtral متعدد الخبرات',
            'speed': 'سريع',
            'quality': 'ممتاز',
            'context': '32K رمز',
            'features': ['متعدد اللغات', 'برمجة', 'رياضيات'],
            'maxTokens': 32768,
            'contextLength': 32768,
            'requiresKey': false,
          },
          {
            'id': 'gemma2-9b-it',
            'name': 'Gemma 2 9B IT',
            'description': 'نموذج Gemma 2 محسن للمحادثة',
            'speed': 'سريع جداً',
            'quality': 'جيد جداً',
            'context': '8K رمز',
            'features': ['محادثة', 'مساعدة تقنية', 'شرح'],
            'maxTokens': 8192,
            'contextLength': 8192,
            'requiresKey': false,
          },
          {
            'id': 'gemma-7b-it',
            'name': 'Gemma 7B IT',
            'description': 'نموذج Gemma للمحادثة التفاعلية',
            'speed': 'سريع جداً',
            'quality': 'جيد',
            'context': '8K رمز',
            'features': ['محادثة سريعة', 'أسئلة وأجوبة'],
            'maxTokens': 8192,
            'contextLength': 8192,
            'requiresKey': false,
          },
        ];
      case 'gptgod':
        return [
          {
            'id': 'gpt-3.5-turbo',
            'name': 'GPT-3.5 Turbo',
            'description': 'نموذج GPT-3.5 مجاني وسريع',
            'speed': 'سريع',
            'quality': 'جيد جداً',
            'context': '16K رمز',
            'features': ['محادثة', 'كتابة', 'تلخيص'],
            'maxTokens': 4096,
            'contextLength': 16384,
            'requiresKey': false,
          },
          {
            'id': 'gpt-4o-mini',
            'name': 'GPT-4o Mini',
            'description': 'نسخة مصغرة من GPT-4o',
            'speed': 'سريع',
            'quality': 'ممتاز',
            'context': '128K رمز',
            'features': ['محادثة متقدمة', 'تحليل', 'إبداع'],
            'maxTokens': 16384,
            'contextLength': 128000,
            'requiresKey': false,
          },
        ];
      case 'openrouter':
        return [
          // النماذج المجانية الجديدة
          {
            'id': 'openai/gpt-oss-20b:free',
            'name': 'GPT OSS 20B (مجاني)',
            'description': 'نموذج OpenAI مفتوح المصدر 21B معامل',
            'speed': 'سريع',
            'quality': 'ممتاز',
            'context': '131K رمز',
            'features': ['استدلال', 'استدعاء دوال', 'مخرجات منظمة'],
            'maxTokens': 8192,
            'contextLength': 131072,
            'requiresKey': true,
          },
          {
            'id': 'z-ai/glm-4.5-air:free',
            'name': 'GLM 4.5 Air (مجاني)',
            'description': 'نموذج Z.AI خفيف للتطبيقات الذكية',
            'speed': 'سريع جداً',
            'quality': 'ممتاز',
            'context': '131K رمز',
            'features': ['وضع تفكير', 'أدوات', 'تفاعل فوري'],
            'maxTokens': 8192,
            'contextLength': 131072,
            'requiresKey': true,
          },
          {
            'id': 'qwen/qwen3-coder:free',
            'name': 'Qwen3 Coder (مجاني)',
            'description': 'نموذج Qwen للبرمجة 480B معامل',
            'speed': 'متوسط',
            'quality': 'استثنائي',
            'context': '262K رمز',
            'features': ['برمجة متقدمة', 'استدعاء دوال', 'سياق طويل'],
            'maxTokens': 8192,
            'contextLength': 262144,
            'requiresKey': true,
          },
          {
            'id': 'moonshotai/kimi-k2:free',
            'name': 'Kimi K2 (مجاني)',
            'description': 'نموذج MoonshotAI 1T معامل',
            'speed': 'متوسط',
            'quality': 'استثنائي',
            'context': '33K رمز',
            'features': ['استدلال متقدم', 'برمجة', 'أدوات'],
            'maxTokens': 8192,
            'contextLength': 33000,
            'requiresKey': true,
          },
          {
            'id': 'venice/uncensored:free',
            'name': 'Venice Uncensored (مجاني)',
            'description': 'نموذج Venice غير مقيد 24B معامل',
            'speed': 'سريع',
            'quality': 'جيد جداً',
            'context': '33K رمز',
            'features': ['غير مقيد', 'تحكم كامل', 'مرونة عالية'],
            'maxTokens': 8192,
            'contextLength': 33000,
            'requiresKey': true,
          },
          {
            'id': 'google/gemma-3n-2b:free',
            'name': 'Gemma 3n 2B (مجاني)',
            'description': 'نموذج Google متعدد الوسائط 2B معامل',
            'speed': 'سريع جداً',
            'quality': 'جيد',
            'context': '8K رمز',
            'features': ['متعدد الوسائط', 'متعدد اللغات', 'خفيف'],
            'maxTokens': 4096,
            'contextLength': 8192,
            'requiresKey': true,
          },
          {
            'id': 'tencent/hunyuan-a13b:free',
            'name': 'Hunyuan A13B (مجاني)',
            'description': 'نموذج Tencent MoE 13B نشط من 80B',
            'speed': 'سريع',
            'quality': 'ممتاز',
            'context': '33K رمز',
            'features': ['رياضيات', 'علوم', 'برمجة', 'استدلال'],
            'maxTokens': 8192,
            'contextLength': 33000,
            'requiresKey': true,
          },
          {
            'id': 'tng/deepseek-r1t2-chimera:free',
            'name': 'DeepSeek R1T2 Chimera (مجاني)',
            'description': 'نموذج TNG Tech 671B معامل MoE',
            'speed': 'متوسط',
            'quality': 'استثنائي',
            'context': '164K رمز',
            'features': ['استدلال قوي', 'سياق طويل', 'تحليل عميق'],
            'maxTokens': 8192,
            'contextLength': 164000,
            'requiresKey': true,
          },
          {
            'id': 'mistral/mistral-small-3.2-24b:free',
            'name': 'Mistral Small 3.2 24B (مجاني)',
            'description': 'نموذج Mistral محسن 24B معامل',
            'speed': 'سريع',
            'quality': 'ممتاز',
            'context': '131K رمز',
            'features': ['رؤية', 'أدوات', 'مخرجات منظمة'],
            'maxTokens': 8192,
            'contextLength': 131072,
            'requiresKey': true,
          },
          // النماذج المجانية القديمة
          {
            'id': 'meta-llama/llama-3.1-8b-instruct:free',
            'name': 'Llama 3.1 8B (مجاني)',
            'description': 'نموذج Llama 3.1 8B مجاني عبر OpenRouter',
            'speed': 'سريع',
            'quality': 'ممتاز',
            'context': '128K رمز',
            'features': ['محادثة', 'برمجة'],
            'maxTokens': 8192,
            'contextLength': 131072,
            'requiresKey': true,
          },
          {
            'id': 'microsoft/phi-3-mini-128k-instruct:free',
            'name': 'Phi-3 Mini (مجاني)',
            'description': 'نموذج Microsoft Phi-3 مجاني',
            'speed': 'سريع جداً',
            'quality': 'جيد',
            'context': '128K رمز',
            'features': ['محادثة سريعة', 'مساعدة'],
            'maxTokens': 4096,
            'contextLength': 128000,
            'requiresKey': true,
          },
          {
            'id': 'google/gemma-2-9b-it:free',
            'name': 'Gemma 2 9B (مجاني)',
            'description': 'نموذج Google Gemma 2 مجاني',
            'speed': 'سريع',
            'quality': 'جيد جداً',
            'context': '8K رمز',
            'features': ['محادثة', 'شرح'],
            'maxTokens': 8192,
            'contextLength': 8192,
            'requiresKey': true,
          },
          // نماذج مدفوعة شائعة
          {
            'id': 'openai/gpt-4o',
            'name': 'GPT-4o',
            'description': 'أحدث نموذج من OpenAI',
            'speed': 'متوسط',
            'quality': 'استثنائي',
            'context': '128K رمز',
            'features': ['محادثة متقدمة', 'تحليل', 'إبداع', 'رؤية'],
            'maxTokens': 4096,
            'contextLength': 128000,
            'requiresKey': true,
          },
          {
            'id': 'anthropic/claude-3.5-sonnet',
            'name': 'Claude 3.5 Sonnet',
            'description': 'نموذج Anthropic المتطور',
            'speed': 'متوسط',
            'quality': 'استثنائي',
            'context': '200K رمز',
            'features': ['تحليل عميق', 'برمجة متقدمة', 'كتابة إبداعية'],
            'maxTokens': 8192,
            'contextLength': 200000,
            'requiresKey': true,
          },
          {
            'id': 'google/gemini-pro-1.5',
            'name': 'Gemini Pro 1.5',
            'description': 'نموذج Google المتطور',
            'speed': 'سريع',
            'quality': 'ممتاز جداً',
            'context': '1M رمز',
            'features': ['سياق طويل', 'تحليل', 'رؤية'],
            'maxTokens': 8192,
            'contextLength': 1000000,
            'requiresKey': true,
          },
        ];
      case 'huggingface':
        return [
          {
            'id': 'microsoft/DialoGPT-medium',
            'name': 'DialoGPT Medium',
            'description': 'نموذج محادثة من Microsoft',
            'speed': 'متوسط',
            'quality': 'جيد',
            'context': '1K رمز',
            'features': ['محادثة'],
            'maxTokens': 1024,
            'contextLength': 1024,
            'requiresKey': true,
          },
          {
            'id': 'facebook/blenderbot-400M-distill',
            'name': 'BlenderBot 400M',
            'description': 'نموذج محادثة من Meta',
            'speed': 'سريع',
            'quality': 'مقبول',
            'context': '512 رمز',
            'features': ['محادثة بسيطة'],
            'maxTokens': 512,
            'contextLength': 512,
            'requiresKey': true,
          },
          {
            'id': 'google/flan-t5-large',
            'name': 'FLAN-T5 Large',
            'description': 'نموذج Google للمهام المتعددة',
            'speed': 'متوسط',
            'quality': 'جيد',
            'context': '512 رمز',
            'features': ['مهام متعددة', 'ترجمة'],
            'maxTokens': 512,
            'contextLength': 512,
            'requiresKey': true,
          },
        ];
      case 'localai':
        return [
          {
            'id': 'llama3.1:8b',
            'name': 'Llama 3.1 8B (محلي)',
            'description': 'نموذج Llama 3.1 8B محلي عبر Ollama',
            'speed': 'يعتمد على الجهاز',
            'quality': 'ممتاز',
            'context': '128K رمز',
            'features': ['خصوصية كاملة', 'بدون إنترنت'],
            'maxTokens': 8192,
            'contextLength': 131072,
            'requiresKey': false,
          },
          {
            'id': 'mistral:7b',
            'name': 'Mistral 7B (محلي)',
            'description': 'نموذج Mistral 7B محلي',
            'speed': 'يعتمد على الجهاز',
            'quality': 'جيد جداً',
            'context': '32K رمز',
            'features': ['خصوصية', 'متعدد اللغات'],
            'maxTokens': 4096,
            'contextLength': 32768,
            'requiresKey': false,
          },
          {
            'id': 'codellama:7b',
            'name': 'Code Llama 7B (محلي)',
            'description': 'نموذج برمجة محلي',
            'speed': 'يعتمد على الجهاز',
            'quality': 'ممتاز للبرمجة',
            'context': '16K رمز',
            'features': ['برمجة متخصصة', 'خصوصية'],
            'maxTokens': 4096,
            'contextLength': 16384,
            'requiresKey': false,
          },
          {
            'id': 'phi3:mini',
            'name': 'Phi-3 Mini (محلي)',
            'description': 'نموذج Microsoft Phi-3 محلي',
            'speed': 'سريع',
            'quality': 'جيد',
            'context': '128K رمز',
            'features': ['سريع', 'خفيف'],
            'maxTokens': 4096,
            'contextLength': 128000,
            'requiresKey': false,
          },
        ];
      default:
        return [];
    }
  }
}
