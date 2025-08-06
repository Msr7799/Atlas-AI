import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String appName = 'Arabic Agent';
  static const String version = '1.0.0';

  // API Keys from .env
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get tavilyApiKey => dotenv.env['TAVILY_API_KEY'] ?? '';
  static String get travilyUrlApiPaired =>
      dotenv.env['TRAVILY_URL_API_PAIRED'] ?? '';
  static String get gptGodApiKey =>
      dotenv.env['GPTGOD_API_KEY'] ??
      'sk-rvz7PGTel8tSYKftzhmZXEZEj4RzAcs7FZFhhhWW6zXhyysu';

  // Groq API Configuration
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String groqChatEndpoint = '/chat/completions';

  // GPTGOD API Configuration
  static const String gptGodBaseUrl = 'https://api.gptgod.online/v1';
  static const String gptGodChatEndpoint = '/chat/completions';

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
