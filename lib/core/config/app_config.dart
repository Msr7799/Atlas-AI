import 'package:flutter_dotenv/flutter_dotenv.dart';


class AppConfig {
  static const String appName = 'Arabic Agent';
  static const String version = '1.0.0';

  // API Keys from .env file
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get groqApiKey2 => dotenv.env['GROQ_API_KEY2'] ?? ''; // مفتاح احتياطي
  static String get tavilyApiKey => dotenv.env['TAVILY_API_KEY'] ?? '';
  static String get tavilyUrlApiPaired => dotenv.env['TAVILY_URL_API_PAIRED'] ?? '';
  static String get gptGodApiKey => dotenv.env['GPTGOD_API_KEY'] ?? '';
  static String get huggingFaceApiKey => dotenv.env['HUGGINGFACE_API_KEY'] ?? '';

  // Default API Keys (هدية مؤقتة للمستخدمين الجدد من .env)
  static Map<String, String> get defaultApiKeys => {
    'groq': groqApiKey, // مفتاح مؤقت من .env
    'gptgod': gptGodApiKey, // مفتاح مؤقت من .env
    'tavily': tavilyApiKey, // مفتاح مؤقت من .env
    'huggingface': huggingFaceApiKey, // مفتاح مؤقت من .env
    'openrouter': '', // لا يوجد مفتاح افتراضي
  };

  // Free Models Configuration
  static const Map<String, List<Map<String, dynamic>>> freeModels = {
    'groq': [
      {
        'id': 'llama3-8b-8192',
        'name': 'Llama 3.1 8B',
        'description': 'نموذج سريع ومتوازن للاستخدام العام',
        'features': ['سريع', 'متوازن', 'مناسب للاستخدام العام'],
        'speed': 'سريع جداً',
        'quality': 'جيد',
        'context': '8K tokens',
      },
      {
        'id': 'llama3-70b-8192',
        'name': 'Llama 3.1 70B',
        'description': 'نموذج متقدم للاستخدامات المعقدة',
        'features': ['دقة عالية', 'منطق متقدم', 'مناسب للمهام المعقدة'],
        'speed': 'سريع',
        'quality': 'ممتاز',
        'context': '8K tokens',
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
        'id': 'gemma2-9b-it',
        'name': 'Gemma 2 9B',
        'description': 'نموذج Google المحدث للاستخدام العام',
        'features': ['محدث', 'متوازن', 'مناسب للاستخدام العام'],
        'speed': 'سريع جداً',
        'quality': 'جيد جداً',
        'context': '8K tokens',
      },
      {
        'id': 'gemma2-27b-it',
        'name': 'Gemma 2 27B',
        'description': 'نموذج Google المتقدم للاستخدامات المعقدة',
        'features': ['دقة عالية', 'منطق متقدم', 'مناسب للمهام المعقدة'],
        'speed': 'متوسط',
        'quality': 'ممتاز',
        'context': '8K tokens',
      },
      {
        'id': 'llama3.1-8b-instant',
        'name': 'Llama 3.1 8B Instant',
        'description': 'نموذج سريع جداً للاستجابة الفورية',
        'features': ['سريع جداً', 'استجابة فورية', 'مناسب للمحادثات'],
        'speed': 'سريع جداً',
        'quality': 'جيد',
        'context': '8K tokens',
      },
      {
        'id': 'llama3.1-70b-versatile',
        'name': 'Llama 3.1 70B Versatile',
        'description': 'نموذج متعدد الاستخدامات للاستخدامات المختلفة',
        'features': ['متعدد الاستخدامات', 'دقة عالية', 'منطق متقدم'],
        'speed': 'سريع',
        'quality': 'ممتاز',
        'context': '8K tokens',
      },
      {
        'id': 'llama3.1-405b-reasoning',
        'name': 'Llama 3.1 405B Reasoning',
        'description': 'نموذج متخصص في التفكير المنطقي والتحليل',
        'features': ['تفكير منطقي متقدم', 'تحليل دقيق', 'منطق قوي'],
        'speed': 'متوسط',
        'quality': 'ممتاز جداً',
        'context': '8K tokens',
      },
      {
        'id': 'llama3.1-1b-instruct',
        'name': 'Llama 3.1 1B Instruct',
        'description': 'نموذج صغير وسريع للتعليمات البسيطة',
        'features': ['صغير وسريع', 'مناسب للتعليمات البسيطة', 'استجابة سريعة'],
        'speed': 'سريع جداً',
        'quality': 'جيد',
        'context': '8K tokens',
      },
      {
        'id': 'llama3.1-3b-instruct',
        'name': 'Llama 3.1 3B Instruct',
        'description': 'نموذج متوازن للتعليمات والمحادثات',
        'features': ['متوازن', 'مناسب للتعليمات', 'استجابة جيدة'],
        'speed': 'سريع جداً',
        'quality': 'جيد',
        'context': '8K tokens',
      },
    ],
    'gptgod': [
      {
        'id': 'gpt-3.5-turbo',
        'name': 'GPT-3.5 Turbo',
        'description': 'نموذج OpenAI المتوازن للاستخدام العام',
        'features': ['متوازن', 'مناسب للاستخدام العام', 'استجابة سريعة'],
        'speed': 'سريع',
        'quality': 'جيد جداً',
        'context': '4K tokens',
      },
      {
        'id': 'gpt-3.5-turbo-16k',
        'name': 'GPT-3.5 Turbo 16K',
        'description': 'نموذج OpenAI مع سياق أطول',
        'features': ['سياق طويل', 'متوازن', 'مناسب للمحادثات الطويلة'],
        'speed': 'سريع',
        'quality': 'جيد جداً',
        'context': '16K tokens',
      },
      {
        'id': 'gpt-4',
        'name': 'GPT-4',
        'description': 'نموذج OpenAI المتقدم للاستخدامات المعقدة',
        'features': ['دقة عالية', 'منطق متقدم', 'مناسب للمهام المعقدة'],
        'speed': 'متوسط',
        'quality': 'ممتاز',
        'context': '8K tokens',
      },
      {
        'id': 'gpt-4-turbo',
        'name': 'GPT-4 Turbo',
        'description': 'نموذج OpenAI الأحدث والأسرع',
        'features': ['أحدث إصدار', 'سريع', 'دقة عالية'],
        'speed': 'سريع',
        'quality': 'ممتاز',
        'context': '128K tokens',
      },
      {
        'id': 'gpt-4-turbo-preview',
        'name': 'GPT-4 Turbo Preview',
        'description': 'نموذج OpenAI التجريبي مع أحدث الميزات',
        'features': ['تجريبي', 'أحدث الميزات', 'دقة عالية'],
        'speed': 'متوسط',
        'quality': 'ممتاز',
        'context': '128K tokens',
      },
      {
        'id': 'gpt-4-32k',
        'name': 'GPT-4 32K',
        'description': 'نموذج OpenAI مع سياق طويل جداً',
        'features': ['سياق طويل جداً', 'دقة عالية', 'مناسب للمستندات الطويلة'],
        'speed': 'بطيء',
        'quality': 'ممتاز',
        'context': '32K tokens',
      },
      {
        'id': 'claude-3-opus',
        'name': 'Claude 3 Opus',
        'description': 'نموذج Anthropic الأكثر تقدماً',
        'features': ['الأكثر تقدماً', 'دقة عالية جداً', 'منطق متقدم'],
        'speed': 'بطيء',
        'quality': 'ممتاز جداً',
        'context': '200K tokens',
      },
      {
        'id': 'claude-3-sonnet',
        'name': 'Claude 3 Sonnet',
        'description': 'نموذج Anthropic المتوازن',
        'features': ['متوازن', 'دقة عالية', 'منطق جيد'],
        'speed': 'متوسط',
        'quality': 'ممتاز',
        'context': '200K tokens',
      },
      {
        'id': 'claude-3-haiku',
        'name': 'Claude 3 Haiku',
        'description': 'نموذج Anthropic السريع',
        'features': ['سريع', 'مناسب للاستخدام العام', 'استجابة سريعة'],
        'speed': 'سريع',
        'quality': 'جيد جداً',
        'context': '200K tokens',
      },
      {
        'id': 'gemini-pro',
        'name': 'Gemini Pro',
        'description': 'نموذج Google المتقدم',
        'features': ['متقدم', 'دقة عالية', 'منطق جيد'],
        'speed': 'متوسط',
        'quality': 'ممتاز',
        'context': '32K tokens',
      },
      {
        'id': 'gemini-pro-vision',
        'name': 'Gemini Pro Vision',
        'description': 'نموذج Google مع دعم الصور',
        'features': ['دعم الصور', 'تحليل مرئي', 'دقة عالية'],
        'speed': 'متوسط',
        'quality': 'ممتاز',
        'context': '32K tokens',
      },
      {
        'id': 'llama-2-7b-chat',
        'name': 'Llama 2 7B Chat',
        'description': 'نموذج Meta للمحادثات',
        'features': ['مناسب للمحادثات', 'سريع', 'متوازن'],
        'speed': 'سريع',
        'quality': 'جيد',
        'context': '4K tokens',
      },
      {
        'id': 'llama-2-13b-chat',
        'name': 'Llama 2 13B Chat',
        'description': 'نموذج Meta المتقدم للمحادثات',
        'features': ['متقدم للمحادثات', 'دقة عالية', 'منطق جيد'],
        'speed': 'متوسط',
        'quality': 'جيد جداً',
        'context': '4K tokens',
      },
      {
        'id': 'llama-2-70b-chat',
        'name': 'Llama 2 70B Chat',
        'description': 'نموذج Meta الأكثر تقدماً للمحادثات',
        'features': ['الأكثر تقدماً', 'دقة عالية جداً', 'منطق متقدم'],
        'speed': 'بطيء',
        'quality': 'ممتاز',
        'context': '4K tokens',
      },
      {
        'id': 'codellama-7b-instruct',
        'name': 'Code Llama 7B Instruct',
        'description': 'نموذج Meta المتخصص في البرمجة',
        'features': ['متخصص في البرمجة', 'سريع', 'مناسب للكود'],
        'speed': 'سريع',
        'quality': 'جيد',
        'context': '4K tokens',
      },
      {
        'id': 'codellama-13b-instruct',
        'name': 'Code Llama 13B Instruct',
        'description': 'نموذج Meta المتقدم للبرمجة',
        'features': ['متقدم في البرمجة', 'دقة عالية', 'منطق جيد'],
        'speed': 'متوسط',
        'quality': 'جيد جداً',
        'context': '4K tokens',
      },
      {
        'id': 'codellama-34b-instruct',
        'name': 'Code Llama 34B Instruct',
        'description': 'نموذج Meta الأكثر تقدماً للبرمجة',
        'features': [
          'الأكثر تقدماً في البرمجة',
          'دقة عالية جداً',
          'منطق متقدم',
        ],
        'speed': 'بطيء',
        'quality': 'ممتاز',
        'context': '4K tokens',
      },
    ],
  };

  // Groq API Configuration
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqChatEndpoint = '/chat/completions';

  // GPTGOD API Configuration
  static const String gptGodBaseUrl = 'https://api.gptgod.online';
  static const String gptGodChatEndpoint = '/v1/chat/completions';

  static const String defaultModel = 'gemma2-9b-it';
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
