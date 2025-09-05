import 'package:flutter_dotenv/flutter_dotenv.dart';


class AppConfig {
  static const String appName = 'Atlas AI';
  static const String version = '1.0.0';

  // API Keys from .env file
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get groqApiKey2 => dotenv.env['GROQ_API_KEY2'] ?? ''; // مفتاح احتياطي
  static String get tavilyApiKey => dotenv.env['TAVILY_API_KEY'] ?? '';
  static String get tavilyUrlApiPaired => dotenv.env['TAVILY_URL_API_PAIRED'] ?? '';
  static String get gptGodApiKey => dotenv.env['GPTGOD_API_KEY'] ?? '';
  static String get huggingFaceApiKey => dotenv.env['HUGGINGFACE_API_KEY'] ?? '';
  static String get hfToken => dotenv.env['HF_TOKEN'] ?? ''; // Hugging Face Token
  static String get openRouterApiKey => dotenv.env['OPEN_ROUTER_API'] ?? '';
  static String get gptGodApiKey2 => dotenv.env['GPTGOD_API_KEY2'] ?? ''; // مفتاح احتياطي

  // API URLs
  static const String groqApiUrl = 'https://api.groq.com/openai/v1';
  static const String groqApiUrl2 = 'https://api.groq.com/openai/v1'; // URL احتياطي
  static const String huggingFaceApiUrl = 'https://api-inference.huggingface.co'; // Hugging Face API URL

  // Default API Keys (هدية مؤقتة للمستخدمين الجدد من .env)
  static Map<String, String> get defaultApiKeys => {
    'groq': groqApiKey, // مفتاح مؤقت من .env
    'gptgod': gptGodApiKey, // مفتاح مؤقت من .env
    'tavily': tavilyApiKey, // مفتاح مؤقت من .env
    'huggingface': huggingFaceApiKey, // مفتاح مؤقت من .env
    'hf_token': hfToken, // Hugging Face Token من .env
    'openrouter': openRouterApiKey, // مفتاح OpenRouter من .env
  };

  // Free Models Configuration (النماذج المجانية المدعومة فقط)
  static const Map<String, List<Map<String, dynamic>>> freeModels = {
    'groq': [
      {
        'id': 'llama-3.1-8b-instant',
        'name': 'Llama 3.1 8B Instant',
        'description': 'نموذج سريع ومتوازن للاستخدام العام',
        'features': ['سريع جداً', 'متوازن', 'مناسب للاستخدام العام'],
        'speed': 'سريع جداً',
        'quality': 'جيد',
        'context': '128K tokens',
      },
      {
        'id': 'llama-3.1-70b-versatile',
        'name': 'Llama 3.1 70B Versatile',
        'description': 'نموذج متقدم للاستخدامات المعقدة',
        'features': ['دقة عالية', 'منطق متقدم', 'مناسب للمهام المعقدة'],
        'speed': 'سريع',
        'quality': 'ممتاز',
        'context': '128K tokens',
      },
      {
        'id': 'mixtral-8x7b-32768',
        'name': 'Mixtral 8x7B',
        'description': 'نموذج متخصص في البرمجة والتحليل',
        'features': ['ممتاز في البرمجة', 'تحليل دقيق', 'منطق قوي'],
        'speed': 'سريع',
        'quality': 'ممتاز',
        'context': '32K tokens',
      },
      {
        'id': 'llama-3.3-70b-versatile',
        'name': 'Llama 3.3 70B Versatile',
        'description': 'أحدث نموذج Llama متقدم ومحسن',
        'features': ['أحدث إصدار', 'دقة فائقة', 'محسن للمهام المعقدة'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '128K tokens',
      },
    ],
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
        'id': 'openai/gpt-oss-20b',
        'name': 'GPT-OSS 20B (مجاني)',
        'description': 'نموذج مفتوح المصدر من OpenAI بـ 21B معامل، محسن للسرعة والنشر',
        'features': ['مفتوح المصدر', 'Mixture-of-Experts', 'استدعاء الوظائف', 'مخرجات منظمة'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز',
        'context': '131K tokens',
        'provider': 'OpenAI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '2.84B',
      },
      {
        'id': 'z-ai/glm-4.5-air',
        'name': 'GLM 4.5 Air (مجاني)',
        'description': 'النسخة الخفيفة من نموذج GLM الرائد، مصمم للتطبيقات المتمحورة حول الوكلاء',
        'features': ['Mixture-of-Experts', 'وضع التفكير', 'استخدام الأدوات', 'تفاعل فوري'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز جداً',
        'context': '131K tokens',
        'provider': 'Z.AI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '47.8B',
      },
      {
        'id': 'qwen/qwen3-coder-480b-a35b-instruct',
        'name': 'Qwen3 Coder (مجاني)',
        'description': 'نموذج Mixture-of-Experts لتوليد الكود، محسن لمهام الترميز الوكيلية',
        'features': ['متخصص في البرمجة', 'استدعاء الوظائف', 'استخدام الأدوات', 'سياق طويل'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '262K tokens',
        'provider': 'Qwen',
        'requiresKey': true,
        'isFree': true,
        'tokens': '52.3B',
      },
      {
        'id': 'moonshotai/kimi-k2-instruct',
        'name': 'Kimi K2 (مجاني)',
        'description': 'نموذج Mixture-of-Experts كبير من Moonshot AI بـ 1 تريليون معامل',
        'features': ['قدرات وكيلية متقدمة', 'استخدام الأدوات', 'المنطق', 'تركيب الكود'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '33K tokens',
        'provider': 'MoonshotAI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '13.3B',
      },
      {
        'id': 'cognitivecomputations/dolphin-mistral-24b-venice',
        'name': 'Venice Uncensored (مجاني)',
        'description': 'نموذج غير خاضع للرقابة، مصمم للاستخدامات المتقدمة وغير المقيدة',
        'features': ['غير خاضع للرقابة', 'تحكم المستخدم', 'سلوك شفاف', 'قابل للتوجيه'],
        'speed': 'سريع',
        'quality': 'جيد جداً',
        'context': '33K tokens',
        'provider': 'Venice.ai',
        'requiresKey': true,
        'isFree': true,
        'tokens': '853M',
      },
      {
        'id': 'google/gemma-3n-2b',
        'name': 'Gemma 3n 2B (مجاني)',
        'description': 'نموذج متعدد الوسائط من Google DeepMind، محسن للنشر منخفض الموارد',
        'features': ['متعدد الوسائط', 'MatFormer', 'أداء متعدد اللغات', 'نشر فعال'],
        'speed': 'سريع جداً',
        'quality': 'جيد',
        'context': '8K tokens',
        'provider': 'Google',
        'requiresKey': true,
        'isFree': true,
        'tokens': '63.8M',
      },
      {
        'id': 'tencent/hunyuan-a13b-instruct',
        'name': 'Hunyuan A13B (مجاني)',
        'description': 'نموذج Mixture-of-Experts من Tencent بـ 13B معامل نشط و80B إجمالي',
        'features': ['Chain-of-Thought', 'الرياضيات والعلوم', 'البرمجة', 'المنطق متعدد الأدوار'],
        'speed': 'سريع',
        'quality': 'ممتاز',
        'context': '33K tokens',
        'provider': 'Tencent',
        'requiresKey': true,
        'isFree': true,
        'tokens': '536M',
      },
      {
        'id': 'tngtech/deepseek-r1t2-chimera',
        'name': 'DeepSeek R1T2 Chimera (مجاني)',
        'description': 'نموذج الجيل الثاني من TNG Tech بـ 671B معامل، أسرع من R1 الأصلي',
        'features': ['أداء منطقي قوي', 'سياق طويل', 'سلوك think tokens', 'سرعة عالية'],
        'speed': 'سريع جداً',
        'quality': 'ممتاز جداً',
        'context': '164K tokens',
        'provider': 'TNG Tech',
        'requiresKey': true,
        'isFree': true,
        'tokens': '23.5B',
      },
      {
        'id': 'mistralai/mistral-small-3.2-24b-instruct-2506',
        'name': 'Mistral Small 3.2 24B (مجاني)',
        'description': 'نموذج محدث من Mistral محسن لاتباع التعليمات واستدعاء الوظائف',
        'features': ['اتباع التعليمات', 'تقليل التكرار', 'استدعاء الوظائف', 'مخرجات منظمة'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '131K tokens',
        'provider': 'Mistral AI',
        'requiresKey': true,
        'isFree': true,
        'tokens': '1.14B',
      },
    ],
    'huggingface': [
      {
        'id': 'microsoft/DialoGPT-medium',
        'name': 'DialoGPT Medium (HuggingFace)',
        'description': 'نموذج DialoGPT متوسط الحجم للمحادثة - متاح للاستخدام العام',
        'features': ['سريع', 'مفتوح المصدر', 'متخصص في المحادثة', 'متاح للجميع'],
        'speed': 'سريع',
        'quality': 'جيد',
        'context': '1K tokens',
        'provider': 'Microsoft',
        'requiresKey': true,
      },
      {
        'id': 'microsoft/DialoGPT-large',
        'name': 'DialoGPT Large (HuggingFace)',
        'description': 'نموذج DialoGPT كبير الحجم للمحادثة - متاح للاستخدام العام',
        'features': ['دقة عالية', 'مفتوح المصدر', 'متخصص في المحادثة', 'متاح للجميع'],
        'speed': 'متوسط',
        'quality': 'جيد جداً',
        'context': '1K tokens',
        'provider': 'Microsoft',
        'requiresKey': true,
      },
      {
        'id': 'google/flan-t5-base',
        'name': 'Flan-T5 Base (HuggingFace)',
        'description': 'نموذج Flan-T5 أساسي متعدد المهام - متاح للاستخدام العام',
        'features': ['متعدد المهام', 'مفتوح المصدر', 'متاح للجميع', 'دعم عربي'],
        'speed': 'سريع',
        'quality': 'جيد',
        'context': '2K tokens',
        'provider': 'Google',
        'requiresKey': true,
      },
      {
        'id': 'google/flan-t5-large',
        'name': 'Flan-T5 Large (HuggingFace)',
        'description': 'نموذج Flan-T5 كبير متعدد المهام - متاح للاستخدام العام',
        'features': ['متعدد المهام', 'مفتوح المصدر', 'متاح للجميع', 'دقة عالية'],
        'speed': 'متوسط',
        'quality': 'جيد جداً',
        'context': '2K tokens',
        'provider': 'Google',
        'requiresKey': true,
      },
      {
        'id': 'microsoft/DialoGPT-large',
        'name': 'DialoGPT Large (HuggingFace)',
        'description': 'نموذج DialoGPT كبير الحجم للمحادثة - متاح للاستخدام العام',
        'features': ['دقة عالية', 'مفتوح المصدر', 'متخصص في المحادثة', 'متاح للجميع'],
        'speed': 'متوسط',
        'quality': 'جيد جداً',
        'context': '1K tokens',
        'provider': 'Microsoft',
        'requiresKey': true,
      },
      {
        'id': 'black-forest-labs/FLUX.1-dev',
        'name': 'FLUX.1-dev (Text-to-Image)',
        'description': 'نموذج FLUX المتقدم لتوليد الصور من النص - جودة عالية ومتطور',
        'features': ['توليد الصور', 'جودة عالية', 'سريع', 'مفتوح المصدر'],
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': 'Text-to-Image',
        'provider': 'Black Forest Labs',
        'requiresKey': true,
        'type': 'image_generation',
        'isFree': true,
      },
      {
        'id': 'Qwen/Qwen2-VL-7B-Instruct',
        'name': 'Qwen2-VL 7B (HuggingFace)',
        'description': 'نموذج متقدم لتحليل الصور والفيديو مع دعم العربية',
        'features': ['تحليل الصور', 'دعم العربية', 'معالجة فيديو', 'OCR'],
        'modality': 'vision + text',
        'speed': 'سريع',
        'quality': 'ممتاز جداً',
        'context': '128K tokens',
        'arabic_support': true,
        'vision_support': true,
        'provider': 'Alibaba',
        'requiresKey': true,
      },
    ],
  };

  // Groq API Configuration
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqChatEndpoint = '/chat/completions';

  // GPTGOD API Configuration
  static const String gptGodBaseUrl = 'https://api.gptgod.online';
  static const String gptGodChatEndpoint = '/v1/chat/completions';

  // Hugging Face API Configuration
  static const String huggingFaceBaseUrl = 'https://api-inference.huggingface.co/models';
  static const String huggingFaceChatEndpoint = '';

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
