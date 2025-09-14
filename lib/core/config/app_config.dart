import 'package:flutter_dotenv/flutter_dotenv.dart';


class AppConfig {
  static const String appName = 'Atlas AI';
  static const String version = '1.0.0';

  // API Keys from .env file
  static String get tavilyApiKey => dotenv.env['TAVILY_API_KEY'] ?? '';
  static String get tavilyUrlApiPaired => dotenv.env['TAVILY_URL_API_PAIRED'] ?? '';
  static String get gptGodApiKey => dotenv.env['GPTGOD_API_KEY'] ?? '';
  static String get openRouterApiKey => dotenv.env['OPEN_ROUTER_API'] ?? '';
  static String get gptGodApiKey2 => dotenv.env['GPTGOD_API_KEY2'] ?? ''; // مفتاح احتياطي

  // Default API Keys (هدية مؤقتة للمستخدمين الجدد من .env)
  static Map<String, String> get defaultApiKeys => {
    'gptgod': gptGodApiKey, // مفتاح مؤقت من .env
    'tavily': tavilyApiKey, // مفتاح مؤقت من .env
    'openrouter': openRouterApiKey, // مفتاح OpenRouter من .env
  };

  // Free Models Configuration (النماذج المجانية المدعومة فقط)
  static const Map<String, List<Map<String, dynamic>>> freeModels = {
    'gptgod': [
      {
        'id': 'gpt-3.5-turbo',
        'name': 'GPT-3.5 Turbo (مجاني)',
        'description': 'نموذج OpenAI للتوليد الذكي، أداء ممتاز للنصوص والمحادثة',
        'features': ['مجاني', 'تكلفة منخفضة', 'أداء ممتاز', 'دعم API'],
        'speed': 'سريع جداً',
        'quality': 'جيد جداً',
        'context': '16K tokens',
        'provider': 'OpenAI',
        'requiresKey': true,
        'parameters': '1.8B',
        'isFree': true,
      },
      {
        'id': 'gpt-4o-mini',
        'name': 'GPT-4o Mini (مجاني)',
        'description': 'نسخة خفيفة من GPT-4o، أسرع وأقل تكلفة مع جودة عالية',
        'features': ['مجاني', 'سريع', 'نسخة خفيفة', 'جودة عالية'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز',
        'context': '128K tokens',
        'provider': 'OpenAI',
        'requiresKey': true,
        'parameters': '3B',
        'isFree': true,
      },
      {
        'id': 'gpt-4o',
        'name': 'GPT-4o (مجاني)',
        'description': 'النموذج الأكثر تطوراً في GPT-4 مع دعم متعدد الوسائط',
        'features': ['متقدم جداً', 'دعم الصور', 'دعم الصوت', 'أقصى جودة'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '128K tokens',
        'provider': 'OpenAI',
        'requiresKey': true,
        'parameters': '6B',
        'isFree': true,
        'modality': 'text + vision + audio',
      },
      {
        'id': 'gpt-4o-vision',
        'name': 'GPT-4o Vision (مجاني)',
        'description': 'نموذج متخصص في معالجة الصور والرسوم المتحركة',
        'features': ['تحليل الصور', 'معالجة بصرية', 'رسوم متحركة', 'تحليل متقدم'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '128K tokens',
        'provider': 'OpenAI',
        'requiresKey': true,
        'parameters': '6B',
        'isFree': true,
        'modality': 'text + vision',
      },
    ],
    'openrouter': [
      {
        'id': 'google/gemini-2.0-flash-exp:free',
        'name': 'Gemini 2.0 Flash Experimental (مجاني)',
        'description': 'نموذج Gemini Flash 2.0 يوفر سرعة أكبر في الاستجابة مع جودة مماثلة للنماذج الأكبر، مع تحسينات في فهم الوسائط المتعددة والبرمجة',
        'features': ['سريع جداً', 'متعدد الوسائط', 'قدرات البرمجة المحسنة', 'استدعاء الوظائف'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز جداً',
        'context': '1.05M tokens',
        'provider': 'Google',
        'requiresKey': true,
        'isFree': true,
        'tokens': '4.36B',
      },
      {
        'id': 'meta-llama/llama-3.3-70b-instruct:free',
        'name': 'Llama 3.3 70B Instruct (مجاني)',
        'description': 'نموذج Llama 3.3 متعدد اللغات مُحسّن للمحادثة متعددة اللغات، يتفوق على العديد من النماذج المفتوحة والمغلقة',
        'features': ['متعدد اللغات', 'محادثة محسنة', 'دعم 8 لغات', 'أداء عالي'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '66K tokens',
        'provider': 'Meta',
        'requiresKey': true,
        'isFree': true,
        'tokens': '3.65B',
      },
      {
        'id': 'qwen/qwen-2.5-coder-32b-instruct:free',
        'name': 'Qwen2.5 Coder 32B Instruct (مجاني)',
        'description': 'نموذج Qwen2.5-Coder المتخصص في البرمجة مع تحسينات كبيرة في توليد وتحليل وإصلاح الكود',
        'features': ['متخصص في البرمجة', 'تحليل الكود', 'إصلاح الأخطاء', 'وكلاء البرمجة'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '33K tokens',
        'provider': 'Qwen',
        'requiresKey': true,
        'isFree': true,
        'tokens': '350M',
      },
      {
        'id': 'meta-llama/llama-3.2-3b-instruct:free',
        'name': 'Llama 3.2 3B Instruct (مجاني)',
        'description': 'نموذج Llama 3.2 بـ 3 مليار معامل مُحسّن للمعالجة المتقدمة للغة الطبيعية مثل توليد الحوار والاستدلال',
        'features': ['متعدد اللغات', 'اتباع التعليمات', 'استدلال معقد', 'استخدام الأدوات'],
        'speed': 'سريع جداً',
        'quality': 'جيد جداً',
        'context': '131K tokens',
        'provider': 'Meta',
        'requiresKey': true,
        'isFree': true,
        'tokens': '98.1M',
      },
      {
        'id': 'qwen/qwen-2.5-72b-instruct:free',
        'name': 'Qwen2.5 72B Instruct (مجاني)',
        'description': 'نموذج Qwen2.5 بـ 72 مليار معامل مع تحسينات كبيرة في البرمجة والرياضيات واتباع التعليمات',
        'features': ['معرفة واسعة', 'البرمجة والرياضيات', 'اتباع التعليمات', 'دعم متعدد اللغات'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '33K tokens',
        'provider': 'Qwen',
        'requiresKey': true,
        'isFree': true,
        'tokens': '243M',
      },
      {
        'id': 'meta-llama/llama-3.1-405b-instruct:free',
        'name': 'Llama 3.1 405B Instruct (مجاني)',
        'description': 'النموذج الرائد بـ 400 مليار معامل من Meta AI مع أداء قوي مقارنة بـ GPT-4o و Claude 3.5 Sonnet',
        'features': ['أكبر نموذج مفتوح', 'أداء رائد', 'محادثة عالية الجودة', 'سياق طويل'],
        'speed': 'متوسط',
        'quality': 'ممتاز جداً',
        'context': '66K tokens',
        'provider': 'Meta',
        'requiresKey': true,
        'isFree': true,
        'tokens': '349M',
      },
      {
        'id': 'mistralai/mistral-nemo:free',
        'name': 'Mistral Nemo (مجاني)',
        'description': 'نموذج بـ 12 مليار معامل مع سياق 128k تم بناؤه بالتعاون مع NVIDIA، يدعم متعدد اللغات واستدعاء الوظائف',
        'features': ['متعدد اللغات', 'سياق طويل', 'استدعاء الوظائف', 'رخصة Apache 2.0'],
        'speed': 'سريع',
        'quality': 'ممتاز',
        'context': '131K tokens',
        'provider': 'Mistral AI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '928M',
      },
      {
        'id': 'google/gemma-2-9b:free',
        'name': 'Gemma 2 9B (مجاني)',
        'description': 'نموذج Gemma 2 بـ 9 مليار معامل متقدم ومفتوح المصدر يضع معياراً جديداً للكفاءة والأداء في فئته',
        'features': ['مفتوح المصدر', 'كفاءة عالية', 'أمان وسلامة', 'فعال التكلفة'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز',
        'context': '8K tokens',
        'provider': 'Google',
        'requiresKey': true,
        'isFree': true,
        'tokens': '47.7M',
      },
      {
        'id': 'mistralai/mistral-7b-instruct:free',
        'name': 'Mistral 7B Instruct (مجاني)',
        'description': 'نموذج عالي الأداء بـ 7.3 مليار معامل مع تحسينات للسرعة وطول السياق من Mistral',
        'features': ['أداء عالي', 'سريع', 'محسن للسياق', 'معيار الصناعة'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز',
        'context': '33K tokens',
        'provider': 'Mistral AI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '333M',
      },
      {
        'id': 'openrouter/sonoma-dusk-alpha:free',
        'name': 'Sonoma Dusk Alpha (مجاني)',
        'description': 'نموذج مجتمعي سريع وذكي للأغراض العامة مع سياق 2 مليون رمز ودعم للصور واستدعاء الأدوات المتوازي',
        'features': ['سريع وذكي', 'سياق 2M رمز', 'دعم الصور', 'استدعاء الأدوات المتوازي'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز',
        'context': '2M tokens',
        'provider': 'OpenRouter',
        'requiresKey': true,
        'isFree': true,
        'tokens': '34.1B',
      },
      {
        'id': 'openrouter/sonoma-sky-alpha:free',
        'name': 'Sonoma Sky Alpha (مجاني)',
        'description': 'نموذج مجتمعي ذكي جداً للأغراض العامة مع سياق 2 مليون رمز ودعم للصور واستدعاء الأدوات المتوازي',
        'features': ['ذكي جداً', 'سياق 2M رمز', 'دعم الصور', 'استدعاء الأدوات المتوازي'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '2M tokens',
        'provider': 'OpenRouter',
        'requiresKey': true,
        'isFree': true,
        'tokens': '41.1B',
      },
      {
        'id': 'deepseek/deepseek-v3.1:free',
        'name': 'DeepSeek V3.1 (مجاني)',
        'description': 'نموذج استدلال هجين كبير (671B معامل، 37B نشط) يدعم أوضاع التفكير وغير التفكير مع سياق يصل لـ 128K رمز',
        'features': ['استدلال هجين', 'وضع التفكير', 'استدعاء الأدوات المهيكل', 'وكلاء البرمجة'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '64K tokens',
        'provider': 'DeepSeek',
        'requiresKey': true,
        'isFree': true,
        'tokens': '143B',
      },
      {
        'id': 'openai/gpt-oss-120b:free',
        'name': 'GPT OSS 120B (مجاني)',
        'description': 'نموذج Mixture-of-Experts بـ 117B معامل من OpenAI للاستدلال العالي والاستخدام الإنتاجي مع استدعاء الوظائف الأصلي',
        'features': ['عمق استدلال قابل للتكوين', 'استدعاء الوظائف الأصلي', 'تصفح', 'مخرجات مهيكلة'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '33K tokens',
        'provider': 'OpenAI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '79.9M',
      },
      {
        'id': 'openai/gpt-oss-20b:free',
        'name': 'GPT OSS 20B (مجاني)',
        'description': 'نموذج مفتوح الوزن بـ 21B معامل من OpenAI بترخيص Apache 2.0 مُحسّن للاستنتاج منخفض زمن الاستجابة',
        'features': ['مفتوح الوزن', 'Apache 2.0', 'استنتاج سريع', 'قدرات الوكلاء'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز',
        'context': '131K tokens',
        'provider': 'OpenAI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '1.11B',
      },
      {
        'id': 'z-ai/glm-4.5-air:free',
        'name': 'GLM 4.5 Air (مجاني)',
        'description': 'المتغير الخفيف من عائلة GLM-4.5 المبني لتطبيقات الوكلاء مع أوضاع استنتاج هجينة ووضع تفكير متقدم',
        'features': ['هندسة MoE', 'وضع التفكير', 'وضع التفاعل الفوري', 'تطبيقات الوكلاء'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز',
        'context': '131K tokens',
        'provider': 'Z.AI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '27.7B',
      },
    ],
  };


  // GPTGOD API Configuration
  static const String gptGodBaseUrl = 'https://api.gptgod.online';
  static const String gptGodChatEndpoint = '/v1/chat/completions';


  // OpenRouter API Configuration
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterChatEndpoint = '/chat/completions';

  static const String defaultModel = 'llama-3.1-8b-instant';
  static const double defaultTemperature = 1.0;
  static const int defaultMaxTokens = 4096; // زيادة الحد الأقصى للتوكينز
  static const double defaultTopP = 1.0;

  // MCP Server Configuration
  static const Map<String, dynamic> mcpServers = {
    'memory': {
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-memory'],
      'env': {'MEMORY_FILE_PATH': '/home/msr/Desktop/flutter_AI_memory.json'},
    },
    'sequential-thinking': {
      'command': 'npx',
      'args': ['-y', '@modelcontextprotocol/server-sequential-thinking'],
    },
  };

  // Database Configuration
  static const String dbName = 'arabic_agent.db';
  static const int dbVersion = 1;

  // Chat Configuration
  static const int maxMessagesHistory = 200; // زيادة عدد الرسائل المحفوظة
  static const Duration typingAnimationDuration = Duration(milliseconds: 50);
  static const Duration thinkingDelay = Duration(seconds: 1);

  // File Upload Configuration
  static const List<String> allowedFileTypes = [
    // نصوص ووثائق
    'txt', 'md', 'json', 'yaml', 'yml', 'xml', 'csv',
    'pdf', 'doc', 'docx', 'rtf', 'odt',

    // صور
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg',
    'tiff', 'tif', 'ico', 'heic', 'heif',

    // صوتيات
    'mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma',

    // فيديو
    'mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv', 'webm',

    // كود وبرمجة
    'py', 'js', 'ts', 'html', 'css', 'dart', 'java',
    'cpp', 'c', 'h', 'php', 'rb', 'go', 'rs', 'swift',
    'kt', 'scala', 'sql', 'sh', 'bat', 'ps1',

    // ملفات مضغوطة
    'zip', 'rar', '7z', 'tar', 'gz', 'bz2',

    // جداول بيانات
    'xls', 'xlsx', 'ods', 'tsv',

    // عروض تقديمية
    'ppt', 'pptx', 'odp',
  ];
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB instead of 10MB

  // Theme Configuration
  static const String defaultFontFamily = 'Inter';
  static const double defaultFontSize = 14.0;
  static const double defaultLineHeight = 1.5;
}
