import 'dart:async';
import '../../data/models/message_model.dart';
import 'mcp_service.dart';
import 'unified_ai_service.dart';

/// طبقة وسطية ذكية تربط MCP مع خدمات AI
class McpAiMiddleware {
  static final McpAiMiddleware _instance = McpAiMiddleware._internal();
  factory McpAiMiddleware() => _instance;
  McpAiMiddleware._internal();

  late final McpService _mcpService;
  late final UnifiedAIService _aiService;
  bool _isInitialized = false;

  /// تهيئة الطبقة الوسطية
  Future<void> initialize() async {
    if (_isInitialized) return;

    _mcpService = McpService();
    _aiService = UnifiedAIService();
    
    _mcpService.initialize();
    await _aiService.initialize();
    
    _isInitialized = true;
    print('✅ [MCP_AI_MIDDLEWARE] تم تهيئة الطبقة الوسطية الذكية');
  }

  /// إرسال رسالة ذكي مع MCP
  Future<String> sendIntelligentMessage({
    required List<MessageModel> messages,
    required String model,
    String? systemPrompt,
    double? temperature,
    int? maxTokens,
  }) async {
    try {
      // 1. تحليل السياق والسؤال
      final context = await _analyzeContext(messages);
      print('🔍 [MCP_AI] تحليل السياق: ${context['type']}');

      // 2. تحسين السؤال باستخدام MCP
      final enhancedMessages = await _enhanceMessages(messages, context);
      
      // 3. اختيار أفضل خدمة AI
      final bestService = _selectBestService(model, context);
      print('🎯 [MCP_AI] اختيار الخدمة: $bestService');

      // 4. إرسال للخدمة المختارة
      final response = await _aiService.sendMessage(
        messages: enhancedMessages,
        model: model,
        systemPrompt: systemPrompt,
        temperature: temperature,
        maxTokens: maxTokens,
      );

      // 5. معالجة الرد باستخدام MCP
      final processedResponse = await _processResponse(response, context);

      // 6. حفظ تلقائي للمعلومات المهمة
      await _autoSaveImportantInfo(messages.last, processedResponse, context);

      return processedResponse;

    } catch (e) {
      print('❌ [MCP_AI] خطأ في الإرسال الذكي: $e');
      rethrow;
    }
  }

  /// تحليل سياق المحادثة
  Future<Map<String, dynamic>> _analyzeContext(List<MessageModel> messages) async {
    if (messages.isEmpty) return {'type': 'general', 'priority': 'normal'};

    final lastMessage = messages.last.content.toLowerCase();
    
    // تحديد نوع السؤال
    String questionType = 'general';
    String priority = 'normal';
    bool needsMemory = false;
    bool needsThinking = false;

    // تحليل نوع السؤال
    if (lastMessage.contains('برمجة') || lastMessage.contains('كود') || 
        lastMessage.contains('programming') || lastMessage.contains('code')) {
      questionType = 'programming';
      priority = 'high';
    } else if (lastMessage.contains('صورة') || lastMessage.contains('image') ||
               lastMessage.contains('تحليل') || lastMessage.contains('analyze')) {
      questionType = 'vision';
      priority = 'high';
    } else if (lastMessage.contains('احفظ') || lastMessage.contains('تذكر') ||
               lastMessage.contains('save') || lastMessage.contains('remember')) {
      needsMemory = true;
      priority = 'high';
    } else if (lastMessage.contains('فكر') || lastMessage.contains('حلل') ||
               lastMessage.contains('think') || lastMessage.contains('analyze')) {
      needsThinking = true;
      priority = 'high';
    }

    return {
      'type': questionType,
      'priority': priority,
      'needsMemory': needsMemory,
      'needsThinking': needsThinking,
      'messageLength': lastMessage.length,
      'hasImages': lastMessage.contains('data:image'),
    };
  }

  /// تحسين الرسائل باستخدام MCP
  Future<List<MessageModel>> _enhanceMessages(
    List<MessageModel> messages, 
    Map<String, dynamic> context
  ) async {
    final enhancedMessages = <MessageModel>[];
    
    for (final message in messages) {
      if (message.role == MessageRole.user) {
        // تحسين رسالة المستخدم
        String enhancedContent = message.content;
        
        // إضافة سياق من الذاكرة إذا لزم الأمر
        if (context['needsMemory'] == true) {
          final memoryContext = await _getRelevantMemory(message.content);
          if (memoryContext.isNotEmpty) {
            enhancedContent = '$memoryContext\n\n$enhancedContent';
          }
        }

        // إضافة تعليمات للتفكير التسلسلي
        if (context['needsThinking'] == true) {
          enhancedContent += '\n\nيرجى التفكير في هذه المسألة خطوة بخطوة وتقديم تحليل مفصل.';
        }

        enhancedMessages.add(message.copyWith(content: enhancedContent));
      } else {
        enhancedMessages.add(message);
      }
    }

    return enhancedMessages;
  }

  /// اختيار أفضل خدمة AI حسب السياق
  String _selectBestService(String model, Map<String, dynamic> context) {
    // إذا كان السؤال يحتاج رؤية، استخدم OpenRouter
    if (context['hasImages'] == true || context['type'] == 'vision') {
      return 'openrouter';
    }
    
    // إذا كان السؤال برمجة، استخدم Groq (سريع)
    if (context['type'] == 'programming') {
      return 'groq';
    }
    
    // للأسئلة العامة، استخدم GPTGod (مجاني)
    return 'gptgod';
  }

  /// معالجة الرد باستخدام MCP
  Future<String> _processResponse(String response, Map<String, dynamic> context) async {
    String processedResponse = response;

    // إذا كان الرد يحتوي على كود، حسن التنسيق
    if (context['type'] == 'programming') {
      processedResponse = _enhanceCodeFormatting(processedResponse);
    }

    // إضافة معلومات إضافية حسب السياق
    if (context['priority'] == 'high') {
      processedResponse += '\n\n💡 **ملاحظة:** تم تحسين هذا الرد باستخدام الذكاء الاصطناعي المتقدم.';
    }

    return processedResponse;
  }

  /// الحفظ التلقائي للمعلومات المهمة
  Future<void> _autoSaveImportantInfo(
    MessageModel question, 
    String response, 
    Map<String, dynamic> context
  ) async {
    // احفظ تلقائياً إذا كان السؤال مهم أو طويل
    if (context['priority'] == 'high' || 
        context['messageLength'] > 100 ||
        response.length > 500) {
      
      try {
        final key = _generateMemoryKey(question.content);
        final content = 'السؤال: ${question.content}\n\nالإجابة: $response';
        
        await _mcpService.executeMemoryStore(key, content);
        print('💾 [MCP_AI] تم الحفظ التلقائي: $key');
      } catch (e) {
        print('⚠️ [MCP_AI] فشل الحفظ التلقائي: $e');
      }
    }
  }

  /// الحصول على ذاكرة ذات صلة
  Future<String> _getRelevantMemory(String question) async {
    try {
      // استخراج كلمات مفتاحية من السؤال
      final keywords = _extractKeywords(question);
      
      // البحث في الذاكرة
      for (final keyword in keywords) {
        try {
          final memory = await _mcpService.executeMemoryRetrieve(keyword);
          if (memory.isNotEmpty) {
            return 'معلومات من الذاكرة:\n$memory\n';
          }
        } catch (e) {
          // تجاهل أخطاء البحث في الذاكرة
        }
      }
      
      return '';
    } catch (e) {
      return '';
    }
  }

  /// استخراج كلمات مفتاحية
  List<String> _extractKeywords(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\w\s]'), ' ')
        .split(' ')
        .where((word) => word.length > 3)
        .take(3)
        .toList();
  }

  /// توليد مفتاح للذاكرة
  String _generateMemoryKey(String content) {
    final words = _extractKeywords(content);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return words.isNotEmpty ? '${words.first}_$timestamp' : 'memory_$timestamp';
  }

  /// تحسين تنسيق الكود
  String _enhanceCodeFormatting(String response) {
    // إضافة تحسينات على تنسيق الكود
    String enhanced = response;
    
    // التأكد من وجود لغة في code blocks
    enhanced = enhanced.replaceAllMapped(
      RegExp(r'```\s*\n'),
      (match) => '```text\n'
    );
    
    return enhanced;
  }

  /// تنظيف الموارد
  void dispose() {
    _mcpService.dispose();
    _aiService.dispose();
    _isInitialized = false;
    print('🧹 [MCP_AI_MIDDLEWARE] تم تنظيف الموارد');
  }
}
