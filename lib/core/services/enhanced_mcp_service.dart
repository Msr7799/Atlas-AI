import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../data/models/message_model.dart';
import 'unified_ai_service.dart';

/// خدمة MCP محسنة مع دعم Markdown
class EnhancedMCPService {
  static final EnhancedMCPService _instance = EnhancedMCPService._internal();
  factory EnhancedMCPService() => _instance;
  EnhancedMCPService._internal();

  final Dio _dio = Dio();
  final UnifiedAIService _aiService = UnifiedAIService();
  
  bool _isInitialized = false;
  Map<String, dynamic> _mcpServers = {};
  
  // خوادم MCP الافتراضية
  final Map<String, Map<String, dynamic>> _defaultServers = {
    'filesystem': {
      'name': 'File System',
      'description': 'إدارة الملفات والمجلدات',
      'enabled': true,
      'capabilities': ['read', 'write', 'list', 'search'],
    },
    'web_search': {
      'name': 'Web Search',
      'description': 'البحث في الإنترنت',
      'enabled': true,
      'capabilities': ['search', 'summarize'],
    },
    'code_analysis': {
      'name': 'Code Analysis',
      'description': 'تحليل وفهم الكود',
      'enabled': true,
      'capabilities': ['analyze', 'explain', 'optimize'],
    },
    'markdown_processor': {
      'name': 'Markdown Processor',
      'description': 'معالجة وتنسيق Markdown',
      'enabled': true,
      'capabilities': ['parse', 'render', 'convert'],
    },
  };

  // تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _mcpServers = Map.from(_defaultServers);
      await _aiService.initialize();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        print('✅ [MCP] تم تهيئة خدمة MCP المحسنة');
        print('🔧 [MCP] الخوادم المتاحة: ${_mcpServers.keys.join(', ')}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MCP] خطأ في تهيئة الخدمة: $e');
      }
    }
  }

  // معالجة رسالة مع دعم MCP
  Future<String> processMessage({
    required List<MessageModel> messages,
    required String model,
    bool enableWebSearch = false,
    bool enableMarkdown = true,
    Map<String, dynamic>? mcpOptions,
  }) async {
    try {
      String response = '';
      String context = '';

      // تحليل الرسالة للبحث عن طلبات خاصة
      final lastMessage = messages.last.content;
      
      // البحث في الويب إذا كان مطلوباً
      if (enableWebSearch && _shouldSearchWeb(lastMessage)) {
        context += await _performWebSearch(lastMessage);
      }

      // معالجة الملفات إذا كان مطلوباً
      if (_shouldProcessFiles(lastMessage)) {
        context += await _processFileRequest(lastMessage);
      }

      // تحليل الكود إذا كان مطلوباً
      if (_shouldAnalyzeCode(lastMessage)) {
        context += await _analyzeCode(lastMessage);
      }

      // إضافة السياق للرسائل
      if (context.isNotEmpty) {
        final contextMessage = MessageModel(
          id: 'context_${DateTime.now().millisecondsSinceEpoch}',
          content: 'معلومات إضافية:\n$context',
          role: MessageRole.system,
          timestamp: DateTime.now(),
        );
        messages.insert(messages.length - 1, contextMessage);
      }

      // إرسال للذكاء الاصطناعي
      response = await _aiService.sendMessage(
        messages: messages,
        model: model,
      );

      // معالجة Markdown إذا كان مطلوباً
      if (enableMarkdown) {
        response = _processMarkdown(response);
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MCP] خطأ في معالجة الرسالة: $e');
      }
      return 'حدث خطأ في معالجة الرسالة: $e';
    }
  }

  // تحديد ما إذا كان يجب البحث في الويب
  bool _shouldSearchWeb(String message) {
    final searchKeywords = [
      'ابحث', 'بحث', 'search', 'find', 'what is', 'ما هو', 'معلومات عن',
      'أخبرني عن', 'latest', 'news', 'أخبار', 'current', 'الحالي'
    ];
    
    return searchKeywords.any((keyword) => 
      message.toLowerCase().contains(keyword.toLowerCase()));
  }

  // تحديد ما إذا كان يجب معالجة الملفات
  bool _shouldProcessFiles(String message) {
    final fileKeywords = [
      'ملف', 'file', 'مجلد', 'folder', 'directory', 'read', 'اقرأ',
      'احفظ', 'save', 'write', 'اكتب'
    ];
    
    return fileKeywords.any((keyword) => 
      message.toLowerCase().contains(keyword.toLowerCase()));
  }

  // تحديد ما إذا كان يجب تحليل الكود
  bool _shouldAnalyzeCode(String message) {
    final codeKeywords = [
      'كود', 'code', 'برمجة', 'programming', 'function', 'دالة',
      'class', 'فئة', 'analyze', 'حلل', 'explain', 'اشرح'
    ];
    
    return codeKeywords.any((keyword) => 
      message.toLowerCase().contains(keyword.toLowerCase()));
  }

  // البحث في الويب
  Future<String> _performWebSearch(String query) async {
    try {
      return await _aiService.searchWithTavily(query);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [MCP] خطأ في البحث: $e');
      }
      return '';
    }
  }

  // معالجة طلبات الملفات
  Future<String> _processFileRequest(String request) async {
    // محاكاة معالجة الملفات
    return 'تم معالجة طلب الملف: $request\n';
  }

  // تحليل الكود
  Future<String> _analyzeCode(String code) async {
    // محاكاة تحليل الكود
    return 'تحليل الكود:\n- الكود يبدو صحيحاً\n- لا توجد أخطاء واضحة\n';
  }

  // معالجة Markdown
  String _processMarkdown(String text) {
    // تحسين تنسيق Markdown
    String processed = text;
    
    // إضافة تنسيق للعناوين
    processed = processed.replaceAllMapped(
      RegExp(r'^(#{1,6})\s*(.+)$', multiLine: true),
      (match) => '${match.group(1)} **${match.group(2)}**',
    );
    
    // تحسين تنسيق الكود
    processed = processed.replaceAllMapped(
      RegExp(r'```(\w+)?\n([\s\S]*?)\n```'),
      (match) => '\n```${match.group(1) ?? ''}\n${match.group(2)}\n```\n',
    );
    
    // تحسين تنسيق القوائم
    processed = processed.replaceAllMapped(
      RegExp(r'^(\s*[-*+])\s*(.+)$', multiLine: true),
      (match) => '${match.group(1)} **${match.group(2)}**',
    );
    
    return processed;
  }

  // الحصول على حالة الخوادم
  Map<String, dynamic> getServerStatus() {
    return Map.from(_mcpServers);
  }

  // تفعيل/إلغاء تفعيل خادم
  void toggleServer(String serverId, bool enabled) {
    if (_mcpServers.containsKey(serverId)) {
      _mcpServers[serverId]['enabled'] = enabled;
      
      if (kDebugMode) {
        print('🔧 [MCP] ${enabled ? "تفعيل" : "إلغاء تفعيل"} خادم: $serverId');
      }
    }
  }

  // إضافة خادم مخصص
  void addCustomServer(String id, Map<String, dynamic> serverConfig) {
    _mcpServers[id] = serverConfig;
    
    if (kDebugMode) {
      print('➕ [MCP] تم إضافة خادم مخصص: $id');
    }
  }

  // حذف خادم مخصص
  void removeCustomServer(String id) {
    if (!_defaultServers.containsKey(id)) {
      _mcpServers.remove(id);
      
      if (kDebugMode) {
        print('🗑️ [MCP] تم حذف خادم مخصص: $id');
      }
    }
  }

  // تنظيف الموارد
  void dispose() {
    _dio.close();
  }
}
