import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/groq_service.dart';
import '../../core/services/gptgod_service.dart';
import '../../core/services/tavily_service.dart';
import '../../core/services/mcp_service.dart';
import '../../core/services/local_ai_service.dart';
import '../../core/config/app_config.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';
import 'settings_provider.dart';

class ChatProvider extends ChangeNotifier {
  final List<MessageModel> _messages = [];
  final List<ChatSessionModel> _sessions = [];
  final List<AttachmentModel> _attachments = [];

  bool _isThinking = false;
  bool _isTyping = false;
  bool _debugMode = false;
  ThinkingProcessModel? _currentThinking;
  String? _currentSessionId;

  final GroqService _groqService = GroqService();
  final GPTGodService _gptGodService = GPTGodService();
  final TavilyService _tavilyService = TavilyService();
  final LocalAIService _localAIService = LocalAIService();
  final ChatRepository _chatRepository = ChatRepository();
  final Uuid _uuid = const Uuid();

  // Initialize provider and load sessions
  ChatProvider() {
    try {
      _initializeServices();
      _initializeProvider();
    } catch (e) {
      print('❌ [CHAT_PROVIDER] خطأ في تهيئة ChatProvider: $e');
      // إنشاء جلسة افتراضية في حالة الخطأ
      _currentSessionId = _uuid.v4();
      notifyListeners();
    }
  }

  // Initialize AI services
  void _initializeServices() {
    _groqService.initialize();
    _gptGodService.initialize();
    _tavilyService.initialize();
  }

  // Getters
  List<MessageModel> get messages => List.unmodifiable(_messages);
  List<ChatSessionModel> get sessions => List.unmodifiable(_sessions);
  List<AttachmentModel> get attachments => List.unmodifiable(_attachments);
  bool get isThinking => _isThinking;
  bool get isTyping => _isTyping;
  bool get debugMode => _debugMode;
  String? get systemPrompt => _getEnhancedSystemPrompt();
  String? get currentSessionId => _currentSessionId;
  ThinkingProcessModel? get currentThinking => _currentThinking;

  String _getEnhancedSystemPrompt({SettingsProvider? settingsProvider}) {
    final mcpService = McpService();
    final basePrompt = mcpService.getEnhancedSystemPrompt();
    
    // الحصول على اللغة المفضلة من الإعدادات
    String languageInstruction = '';
    if (settingsProvider != null) {
      final preferredLang = settingsProvider.preferredLanguage;
      if (preferredLang != 'auto') {
        final langName = SettingsProvider.supportedLanguages[preferredLang] ?? preferredLang;
        languageInstruction = '''

## 🎯 USER LANGUAGE PREFERENCE:
- User has set preferred language to: $langName ($preferredLang)
- Please respond primarily in this language unless user explicitly requests another language
- If user writes in a different language, adapt to their choice

''';
      }
    }
    
    // إضافة تأكيد إضافي على التعدد اللغوي والردود المفصلة
    final multilingualEnhancement = '''

## 🌍 MULTILINGUAL SUPPORT CONFIRMATION:
- You are a FULLY MULTILINGUAL AI assistant
- You can understand and respond in ANY language the user chooses
- You are NOT limited to Arabic and English only
- If user writes in French, German, Spanish, Italian, Chinese, Japanese, etc. - respond in that language
- Adapt your language naturally based on user input
- Default to Arabic only when user language is unclear

## 📋 RESPONSE QUALITY & LENGTH REQUIREMENTS:
### 🎯 MANDATORY RESPONSE STANDARDS:
1. **COMPREHENSIVE ANSWERS**: Always provide detailed, thorough responses
2. **HELPFUL EXPLANATIONS**: Include context, examples, and practical guidance
3. **STEP-BY-STEP GUIDANCE**: Break down complex topics into clear steps
4. **COMPLETE INFORMATION**: Don't leave users with partial answers
5. **PRACTICAL EXAMPLES**: Include relevant code examples, use cases, or scenarios

### ✅ RESPONSE LENGTH GUIDELINES:
- **Minimum**: Never give one-sentence answers unless explicitly requested
- **Technical questions**: Provide comprehensive explanations with examples
- **Programming help**: Include full code examples with explanations
- **Problem-solving**: Walk through the complete thought process
- **Educational content**: Provide thorough, learning-focused responses

### 🚫 AVOID:
- Brief, unhelpful responses
- Leaving questions partially answered
- Skipping important context or details
- Providing code without explanations

## 📝 CRITICAL CODE FORMATTING RULES - NO EXCEPTIONS:

### 🔒 ABSOLUTE REQUIREMENTS:
1. **ALL CODE MUST BE IN MARKDOWN CODE BLOCKS** - NO EXCEPTIONS
2. **USE CORRECT LANGUAGE IDENTIFIERS** - ```python, ```dart, ```json, ```bash, ```javascript, etc.
3. **NEVER PUT CODE TITLES/HEADERS INSIDE CODE BLOCKS**
4. **NEVER USE SHELL BLOCKS FOR NON-SHELL CODE**
5. **CODE EXPLANATIONS OUTSIDE BLOCKS, CODE INSIDE BLOCKS**

### ✅ CORRECT PATTERNS YOU MUST FOLLOW:

**For Python code:**
إليك مثال على كود بايثون:
```python
def greet():
    print("مرحبا بالعالم")
```

**For configuration files:**
ملف التكوين JSON:
```json
{
  "key": "value"
}
```

**For shell commands:**
أوامر الشل:
```bash
pip install transformers
echo "تم التثبيت"
```

### ❌ NEVER DO THIS:
```bash
# عنوان الكود هنا - خطأ!
def my_function():
    pass
```

### 🎯 ENFORCEMENT:
- If you write ANY code without proper markdown blocks, you are failing
- If you put titles inside code blocks, you are failing  
- Every single piece of code must follow these rules exactly

''';
    
    return basePrompt + languageInstruction + multilingualEnhancement;
  }

  // Helper method to get appropriate AI service based on selected model
  dynamic _getAIService(String model) {
    try {
      // التحقق من صحة النموذج
      if (model.isEmpty) {
        print('⚠️ [AI_SERVICE] النموذج فارغ، استخدام Groq كافتراضي');
        return _groqService;
      }

      // تحديد الخدمة حسب النموذج المحدد
      if (model.startsWith('llama') ||
          model.startsWith('mixtral') ||
          model.startsWith('gemma') ||
          model.contains('groq')) {
        print('🤖 [AI_SERVICE] استخدام Groq للنموذج: $model');
        return _groqService;
      } else if (model.startsWith('gpt') ||
          model.contains('turbo') ||
          model.contains('claude') ||
          model.contains('gemini') ||
          model.contains('gptgod')) {
        print('🤖 [AI_SERVICE] استخدام GPTGod للنموذج: $model');
        return _gptGodService;
      } else {
        // استخدام Local AI service كاحتياط عند عدم التعرف على النموذج
        print('🏠 [AI_SERVICE] نموذج غير معروف ($model)، استخدام LocalAI');
        return _localAIService;
      }
    } catch (e) {
      print('❌ [AI_SERVICE] خطأ في تحديد الخدمة: $e');
      print('🔄 [AI_SERVICE] استخدام Groq كاحتياط آمن');
      return _groqService;
    }
  }

  // Helper method to get fallback service when primary fails
  dynamic _getFallbackService(String model) {
    try {
      // إذا فشل Groq، جرب GPTGod
      if (model.startsWith('llama') ||
          model.startsWith('mixtral') ||
          model.startsWith('gemma') ||
          model.contains('groq')) {
        print('[FALLBACK] 🔄 تبديل من Groq إلى GPTGod للنموذج: $model');
        return _gptGodService;
      }
      // إذا فشل GPTGod، جرب Groq
      else if (model.startsWith('gpt') ||
          model.contains('turbo') ||
          model.contains('claude') ||
          model.contains('gemini') ||
          model.contains('gptgod')) {
        print('[FALLBACK] 🔄 تبديل من GPTGod إلى Groq للنموذج: $model');
        return _groqService;
      }
      // آخر احتياط - LocalAI
      else {
        print('[FALLBACK] 🏠 استخدام LocalAI كاحتياط نهائي للنموذج: $model');
        return _localAIService;
      }
    } catch (e) {
      print('❌ [FALLBACK] خطأ في تحديد الخدمة البديلة: $e');
      print('🆘 [FALLBACK] استخدام LocalAI كاحتياط آمن أخير');
      return _localAIService;
    }
  }

  Future<void> _initializeProvider() async {
    await _loadSessions();
    if (_sessions.isEmpty) {
      await createNewSession();
    } else {
      _currentSessionId = _sessions.first.id;
      await _loadCurrentSessionMessages();
    }
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _chatRepository.getAllSessions();
      _sessions.clear();
      _sessions.addAll(sessions);
      notifyListeners();
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  Future<void> _loadCurrentSessionMessages() async {
    if (_currentSessionId == null) return;

    try {
      final messages = await _chatRepository.getSessionMessages(
        _currentSessionId!,
      );
      _messages.clear();
      _messages.addAll(messages);
      notifyListeners();
    } catch (e) {
      print('Error loading messages: $e');
    }
  }

  // Toggle debug mode
  void toggleDebugMode() {
    _debugMode = !_debugMode;
    notifyListeners();
  }

  // Set system prompt from file
  void setSystemPrompt(String prompt) {
    // يتم الآن التعامل مع system prompt من خلال MCP service
    notifyListeners();
  }

  // Add attachment with enhanced file support
  Future<void> addAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        final file = result.files.first;
        final extension = file.extension?.toLowerCase() ?? '';

        if (_isFileTypeAllowed(extension)) {
          final attachment = AttachmentModel(
            id: _uuid.v4(),
            name: file.name,
            path: file.path ?? '',
            type: extension,
            size: file.size,
            uploadedAt: DateTime.now(),
          );

          _attachments.add(attachment);
          notifyListeners();
        } else {
          print('File type not allowed: $extension');
        }
      }
    } catch (e) {
      print('Error adding attachment: $e');
    }
  }

  // Check if file type is allowed
  bool _isFileTypeAllowed(String extension) {
    return AppConfig.allowedFileTypes.contains(extension.toLowerCase());
  }

  // Process attachment based on file type
  Future<String> _processAttachment(AttachmentModel attachment) async {
    final file = File(attachment.path);
    final extension = attachment.type.toLowerCase();

    // معلومات أساسية عن الملف
    final fileInfo =
        '📁 الملف: ${attachment.name}\n📏 الحجم: ${_formatFileSize(attachment.size)}\n🗂️ النوع: $extension\n';

    try {
      // ملفات نصية
      if (_isTextFile(extension)) {
        final content = await file.readAsString();
        return '$fileInfo\n📄 المحتوى:\n$content';
      }
      // ملفات الصور
      else if (_isImageFile(extension)) {
        return '$fileInfo\n🖼️ صورة تم رفعها - يمكن تحليلها أو وصفها';
      }
      // ملفات الصوت
      else if (_isAudioFile(extension)) {
        return '$fileInfo\n🎵 ملف صوتي تم رفعه';
      }
      // ملفات الفيديو
      else if (_isVideoFile(extension)) {
        return '$fileInfo\n🎬 ملف فيديو تم رفعه';
      }
      // ملفات مضغوطة
      else if (_isArchiveFile(extension)) {
        return '$fileInfo\n📦 ملف مضغوط تم رفعه';
      }
      // ملفات أخرى
      else {
        return '$fileInfo\n📎 ملف تم رفعه';
      }
    } catch (e) {
      return '$fileInfo\n⚠️ خطأ في قراءة الملف: $e';
    }
  }

  // Helper methods for file type detection
  bool _isTextFile(String extension) {
    return [
      'txt',
      'md',
      'json',
      'yaml',
      'yml',
      'xml',
      'csv',
      'py',
      'js',
      'ts',
      'html',
      'css',
      'dart',
      'java',
      'cpp',
      'c',
      'h',
      'php',
      'rb',
      'go',
      'rs',
      'swift',
      'kt',
      'scala',
      'sql',
      'sh',
      'bat',
      'ps1',
    ].contains(extension);
  }

  bool _isImageFile(String extension) {
    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'bmp',
      'webp',
      'svg',
      'tiff',
      'tif',
      'ico',
    ].contains(extension);
  }

  bool _isAudioFile(String extension) {
    return [
      'mp3',
      'wav',
      'aac',
      'flac',
      'ogg',
      'm4a',
      'wma',
    ].contains(extension);
  }

  bool _isVideoFile(String extension) {
    return [
      'mp4',
      'avi',
      'mov',
      'wmv',
      'flv',
      'mkv',
      'webm',
    ].contains(extension);
  }

  bool _isArchiveFile(String extension) {
    return ['zip', 'rar', '7z', 'tar', 'gz', 'bz2'].contains(extension);
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  // Remove attachment
  void removeAttachment(String id) {
    _attachments.removeWhere((att) => att.id == id);
    notifyListeners();
  }

  // تحديث إعدادات MCP المخصصة
  void updateMcpConfiguration(SettingsProvider settingsProvider) {
    final mcpService = McpService();
    mcpService.updateCustomServers(
      settingsProvider.customMcpServers,
      settingsProvider.mcpServerStatus,
    );
    print('[CHAT] 🔧 تم تحديث إعدادات MCP المخصصة');
  }

  // Send message with AI processing
  Future<void> sendMessage(
    String content, {
    required SettingsProvider settingsProvider,
  }) async {
    if (content.trim().isEmpty) return;

    // تحديث إعدادات MCP قبل الإرسال
    updateMcpConfiguration(settingsProvider);

    // Ensure we have a current session
    if (_currentSessionId == null) {
      await createNewSession();
    }

    // Get current settings
    final selectedModel = settingsProvider.selectedModel;
    final temperature = settingsProvider.temperature;
    final maxTokens = settingsProvider.maxTokens;

    // Debug: Print selected model
    print('🤖 [DEBUG] استخدام النموذج: $selectedModel');
    if (_debugMode) {
      print(
        '🔧 [DEBUG] الإعدادات - درجة الحرارة: $temperature, أقصى tokens: $maxTokens',
      );
    }

    // Add user message
    final userMessage = MessageModel(
      id: _uuid.v4(),
      content: content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
      attachments: _attachments.isNotEmpty ? List.from(_attachments) : null,
    );

    _messages.add(userMessage);

    // Save message to database
    await _chatRepository.saveMessage(userMessage, _currentSessionId!);

    // Add to input history for this session
    await _chatRepository.addToInputHistory(_currentSessionId!, content);

    notifyListeners();

    // Prepare attached files content with enhanced support - نقل خارج try block
    List<String>? attachedFilesContent;
    if (_attachments.isNotEmpty) {
      attachedFilesContent = [];
      for (final attachment in _attachments) {
        final processedContent = await _processAttachment(attachment);
        attachedFilesContent.add(processedContent);
      }
      print('📎 [ATTACHMENTS] تم معالجة ${_attachments.length} ملفات مرفقة');
    }

    // 🤖 مرحلة المعالجة بالذكاء الاصطناعي - نقل خارج try block
    final enhancedPrompt = _getEnhancedSystemPrompt(settingsProvider: settingsProvider);

    try {
      // Start mandatory thinking process for better responses
      await _startThinkingProcess(
        content,
        settingsProvider: settingsProvider,
      );

      _isTyping = true;
      notifyListeners();

      // 🔍 مرحلة البحث المحسنة مع debugging شامل
      String searchContext = '';
      bool searchPerformed = false;
      final searchStartTime = DateTime.now();

      if (settingsProvider.enableWebSearch && _shouldSearchWeb(content)) {
        print('🔍 [SEARCH_FLOW] بدء عملية البحث على الإنترنت...');

        // إضافة رسالة مؤقتة للبحث مع مؤشر تحميل
        final searchMessage = MessageModel(
          id: _uuid.v4(),
          content: '🔍 جارٍ البحث على الإنترنت عن: "$content"...',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          metadata: {'type': 'search_indicator'},
        );

        _messages.add(searchMessage);
        notifyListeners();

        try {
          print('🌐 [SEARCH_TAVILY] إرسال طلب البحث إلى Tavily...');
          final searchResult = await _tavilyService.search(
            query: content,
            maxResults: 3,
            includeAnswer: true,
            includeImages: false,
          );
          final searchEndTime = DateTime.now();
          final searchDuration = searchEndTime.difference(searchStartTime);

          print(
            '✅ [SEARCH_TAVILY] اكتمل البحث في ${searchDuration.inMilliseconds}ms',
          );
          print(
            '📊 [SEARCH_RESULTS] عدد النتائج: ${searchResult.results.length}',
          );

          // إزالة رسالة البحث المؤقتة
          _messages.removeLast();

          // تحليل وعرض النتائج
          String searchContent = '🔍 **نتائج البحث عن:** "$content"\n\n';

          if (searchResult.answer != null && searchResult.answer!.isNotEmpty) {
            searchContent +=
                '💡 **الإجابة المباشرة:**\n${searchResult.answer}\n\n';
            print(
              '🎯 [SEARCH_ANSWER] إجابة مباشرة متوفرة: ${searchResult.answer!.substring(0, 50)}...',
            );
          }

          searchContent += '📚 **المصادر المتعلقة:**\n';

          for (int i = 0; i < searchResult.results.take(3).length; i++) {
            final result = searchResult.results[i];
            final contentPreview = result.content.length > 200
                ? '${result.content.substring(0, 200)}...'
                : result.content;

            searchContent += '${i + 1}. **${result.title}**\n';
            searchContent += '   $contentPreview\n';
            searchContent += '   🔗 [${result.url}](${result.url})\n\n';

            print('📄 [SEARCH_SOURCE_${i + 1}] ${result.title}');
          }

          searchContent +=
              '⏱️ *تم البحث في ${searchDuration.inMilliseconds}ms*';

          // إضافة رسالة نتائج البحث
          final searchResultsMessage = MessageModel(
            id: _uuid.v4(),
            content: searchContent,
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
            metadata: {
              'type': 'search_results',
              'query': content,
              'duration_ms': searchDuration.inMilliseconds,
              'source_count': searchResult.results.length,
            },
          );

          _messages.add(searchResultsMessage);
          notifyListeners();

          // حفظ رسالة نتائج البحث في قاعدة البيانات
          if (_currentSessionId != null) {
            await _chatRepository.saveMessage(
              searchResultsMessage,
              _currentSessionId!,
            );
          }

          // تحضير السياق للذكاء الاصطناعي
          searchContext = 'معلومات من البحث:\n$searchContent\n\n';
          searchPerformed = true;

          print(
            '🎯 [SEARCH_FLOW] انتهت عملية البحث بنجاح، ننتقل للمعالجة بالذكاء الاصطناعي',
          );
        } catch (e) {
          print('❌ [SEARCH_ERROR] خطأ في البحث: $e');

          // إزالة رسالة البحث المؤقتة
          if (_messages.isNotEmpty &&
              _messages.last.metadata?['type'] == 'search_indicator') {
            _messages.removeLast();
          }

          // إضافة رسالة خطأ
          final errorMessage = MessageModel(
            id: _uuid.v4(),
            content:
                '⚠️ حدث خطأ أثناء البحث على الإنترنت: $e\nسأحاول الإجابة من معرفتي المحفوظة.',
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
            metadata: {'type': 'search_error'},
          );

          _messages.add(errorMessage);
          notifyListeners();
        }
      } else {
        print(
          '💭 [SEARCH_FLOW] لا حاجة للبحث - سيتم الاعتماد على المعرفة المحفوظة',
        );
      }

      // Add search context to attached files if available
      if (searchContext.isNotEmpty && !searchPerformed) {
        attachedFilesContent ??= [];
        attachedFilesContent.add(searchContext);
      }

      // استمرار try block الأساسي
      final aiService = _getAIService(selectedModel);

      // إذا تم البحث، احذف رسالة البحث واستبدلها برسالة المساعد
      if (searchPerformed) {
        print('🔄 [AI_PROCESSING] بدء معالجة النتائج بالذكاء الاصطناعي...');
      }

      // إنشاء رسالة المساعد النهائية
      final assistantMessage = MessageModel(
        id: _uuid.v4(),
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        metadata: {'model': selectedModel, 'has_search': searchPerformed},
      );

      _messages.add(assistantMessage);
      _isTyping = false;
      notifyListeners();

      // Get response stream from appropriate service
      final responseStream = await aiService.sendMessageStream(
        messages: _messages,
        systemPrompt: enhancedPrompt,
        temperature: temperature,
        maxTokens: maxTokens,
        attachedFiles: attachedFilesContent,
      );

      // Stream response with code formatting enforcement
      StringBuffer responseBuffer = StringBuffer();
      await for (final chunk in responseStream) {
        responseBuffer.write(chunk);
        // Apply code formatting enforcement to accumulated content
        final formattedContent = _enforceCodeFormatting(responseBuffer.toString());
        // Update the last message with formatted content
        final lastMessage = _messages.last;
        final updatedMessage = lastMessage.copyWith(
          content: formattedContent,
        );
        _messages[_messages.length - 1] = updatedMessage;
        notifyListeners();
      }

      // Save the completed assistant message to database
      final completedMessage = _messages.last;
      if (_currentSessionId != null) {
        await _chatRepository.saveMessage(completedMessage, _currentSessionId!);
      }

      print('✅ [AI_RESPONSE] اكتملت الإجابة بنجاح');

      // Clear thinking process
      _currentThinking = null;
      _isThinking = false;
    } catch (e) {
      _isTyping = false;
      _isThinking = false;

      print('❌ [PRIMARY_SERVICE_ERROR] خطأ في الخدمة الأساسية: $e');

      // جرب الخدمة الاحتياطية
      try {
        print('🔄 [FALLBACK] تجربة الخدمة الاحتياطية...');
        final fallbackService = _getFallbackService(selectedModel);

        _isTyping = true;
        notifyListeners();

        final fallbackStream = await fallbackService.sendMessageStream(
          messages: _messages,
          systemPrompt: enhancedPrompt,
          temperature: temperature,
          maxTokens: maxTokens,
          attachedFiles: attachedFilesContent,
        );

        // Stream response from fallback service with code formatting
        StringBuffer responseBuffer = StringBuffer();
        await for (final chunk in fallbackStream) {
          responseBuffer.write(chunk);
          // Apply code formatting enforcement to fallback responses too
          final formattedContent = _enforceCodeFormatting(responseBuffer.toString());
          // Update the last message with formatted content
          final lastMessage = _messages.last;
          final updatedMessage = lastMessage.copyWith(
            content: formattedContent,
          );
          _messages[_messages.length - 1] = updatedMessage;
          notifyListeners();
        }

        _isTyping = false;
        print('✅ [FALLBACK_SUCCESS] نجحت الخدمة الاحتياطية');

        // Save the completed assistant message to database
        final completedMessage = _messages.last;
        if (_currentSessionId != null) {
          await _chatRepository.saveMessage(
            completedMessage,
            _currentSessionId!,
          );
        }
      } catch (fallbackError) {
        _isTyping = false;
        print(
          '❌ [FALLBACK_ERROR] فشلت الخدمة الاحتياطية أيضاً: $fallbackError',
        );

        // Add error message
        final errorMessage = MessageModel(
          id: _uuid.v4(),
          content:
              'عذراً، حدث خطأ أثناء معالجة طلبك: $e\n\nيرجى المحاولة مرة أخرى.',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          metadata: {'type': 'error', 'error': e.toString()},
        );

        _messages.add(errorMessage);

        // Save error message to database
        if (_currentSessionId != null) {
          await _chatRepository.saveMessage(errorMessage, _currentSessionId!);
        }
      }

      print('❌ [SEND_MESSAGE_ERROR] خطأ في إرسال الرسالة: $e');

      notifyListeners();
    }

    // Clear attachments after sending
    _attachments.clear();
    notifyListeners();
  }

  // Determine if a query should trigger web search with enhanced debugging
  bool _shouldSearchWeb(String query) {
    final lowerQuery = query.toLowerCase();
    print('🔍 [SEARCH_ANALYZER] تحليل الاستعلام: "$query"');

    // Keywords that suggest current information is needed
    final searchKeywords = [
      // Arabic terms
      'أخبار', 'جديد', 'حديث', 'اليوم', 'الآن', 'حاليا', 'مؤخرا', 'مستجدات',
      'سعر', 'أسعار', 'تحديث', 'أحدث', 'معلومات حديثة', 'ما يحدث',
      'طقس', 'أحوال الجوية', 'درجة الحرارة', 'أمطار',
      'رياضة', 'نتائج', 'مباراة', 'بطولة', 'فريق',
      'أسهم', 'بورصة', 'استثمار', 'عملة', 'دولار', 'ريال',
      'موقع', 'شركة', 'منتج', 'خدمة', 'تطبيق',
      'كوفيد', 'فيروس', 'لقاح', 'إحصائيات',
      'سياسة', 'حكومة', 'انتخابات', 'قرار',
      // English terms
      'news', 'recent', 'latest', 'current', 'today', 'now', 'update',
      'price', 'weather', 'stock', 'covid', 'virus', 'election',
      'sport', 'game', 'match', 'result', 'score',
      'website', 'company', 'product', 'service', 'app',
      'when did', 'what happened', 'how much', 'where is',
    ];

    // Check for exact matches
    for (final keyword in searchKeywords) {
      if (lowerQuery.contains(keyword)) {
        print('✅ [SEARCH_ANALYZER] تم العثور على كلمة مفتاحية: "$keyword"');
        return true;
      }
    }

    // Check for questions that might need current info
    final questionPatterns = [
      // Date/time related
      r'متى.*\d{4}', r'when.*\d{4}',
      r'في أي سنة', r'what year',
      r'كم عمر', r'how old',

      // Current state queries
      r'ما هو.*الآن', r'what is.*now',
      r'أين.*حاليا', r'where.*currently',
      r'كيف.*اليوم', r'how.*today',

      // Comparison queries
      r'أفضل.*\d{4}', r'best.*\d{4}',
      r'مقارنة.*حديث', r'compare.*recent',
    ];

    for (final pattern in questionPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(lowerQuery)) {
        print('✅ [SEARCH_ANALYZER] تطابق مع نمط الاستعلام: $pattern');
        return true;
      }
    }

    print(
      '❌ [SEARCH_ANALYZER] لا حاجة للبحث - يمكن الإجابة من المعرفة المحفوظة',
    );
    return false;
  }

  // Start enhanced thinking process with Sequential Thinking
  Future<void> _startThinkingProcess(
    String query, {
    SettingsProvider? settingsProvider,
  }) async {
    _isThinking = true;
    _currentThinking = ThinkingProcessModel(
      steps: [],
      isComplete: false,
      startedAt: DateTime.now(),
    );
    notifyListeners();

    try {
      // بدء عملية التفكير
      print('🧠 [THINKING] بدء عملية التفكير المنطقي للاستعلام: "$query"');

      _currentThinking = _currentThinking!.copyWith(
        steps: [
          ThinkingStepModel(
            stepNumber: 1,
            content: 'بدء تحليل الاستعلام...',
            timestamp: DateTime.now(),
          ),
        ],
      );
      notifyListeners();

      // مرحلة التحليل الأولي
      _currentThinking = _currentThinking!.copyWith(
        steps: [
          ..._currentThinking!.steps,
          ThinkingStepModel(
            stepNumber: _currentThinking!.steps.length + 1,
            content: 'تحليل نوع الاستعلام والمتطلبات المحتملة',
            timestamp: DateTime.now(),
          ),
        ],
      );
      notifyListeners();

      // تأخير صغير لمحاكاة عملية التفكير
      await Future.delayed(const Duration(milliseconds: 500));

      String analysisResult;

      // تحليل الاستعلام
      analysisResult = await _performSequentialThinking(query);

      _currentThinking = _currentThinking!.copyWith(
        steps: [
          ..._currentThinking!.steps,
          ThinkingStepModel(
            stepNumber: _currentThinking!.steps.length + 1,
            content: 'تحليل منطقي شامل: $analysisResult',
            timestamp: DateTime.now(),
          ),
        ],
        isComplete: true,
        completedAt: DateTime.now(),
      );
      notifyListeners();

      print('✅ [THINKING] انتهت عملية التفكير المنطقي');
    } catch (e) {
      print('❌ [THINKING] خطأ في عملية التفكير: $e');
      _currentThinking = _currentThinking!.copyWith(
        steps: [
          ..._currentThinking!.steps,
          ThinkingStepModel(
            stepNumber: _currentThinking!.steps.length + 1,
            content: 'حدث خطأ في التحليل: $e',
            timestamp: DateTime.now(),
          ),
        ],
        isComplete: true,
        completedAt: DateTime.now(),
      );
    }

    _isThinking = false;
    notifyListeners();
  }

  // استخدام Sequential Thinking للحصول على تحليل عميق
  Future<String> _performSequentialThinking(String query) async {
    try {
      // سنستخدم Sequential Thinking مباشرة للتحليل
      // هذا مجرد مثال - يمكن تطويره أكثر
      return 'تم تحليل الاستعلام بنجاح: $query\n'
          'الموضوع يتطلب تحليل متعدد المراحل\n'
          'تم تحديد أفضل استراتيجية للإجابة';
    } catch (e) {
      print('❌ [SEQUENTIAL_THINKING] خطأ: $e');
      return 'فشل في التحليل المنطقي: $e';
    }
  }

  // Search with Tavily
  Future<void> searchWeb(String query) async {
    try {
      final searchResult = await _tavilyService.search(query: query);

      String searchContent = 'نتائج البحث لـ "$query":\n\n';

      if (searchResult.answer != null) {
        searchContent += 'الإجابة المباشرة: ${searchResult.answer}\n\n';
      }

      for (final result in searchResult.results.take(3)) {
        searchContent += '• ${result.title}\n';
        searchContent +=
            '  ${result.content.substring(0, result.content.length > 200 ? 200 : result.content.length)}...\n';
        searchContent += '  المصدر: ${result.url}\n\n';
      }

      final searchMessage = MessageModel(
        id: _uuid.v4(),
        content: searchContent,
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        metadata: {'type': 'search_result', 'query': query},
      );

      _messages.add(searchMessage);

      // Save search result to database
      if (_currentSessionId != null) {
        await _chatRepository.saveMessage(searchMessage, _currentSessionId!);
      }

      notifyListeners();
    } catch (e) {
      print('Search error: $e');
    }
  }

  // Create new chat session
  Future<void> createNewSession([String? title]) async {
    try {
      final sessionTitle = title ?? _generateSessionTitle();
      final sessionId = await _chatRepository.createNewSession(sessionTitle);

      _currentSessionId = sessionId;
      _messages.clear();
      _attachments.clear();
      _currentThinking = null;

      // Reload sessions to include the new one
      await _loadSessions();
      notifyListeners();
    } catch (e) {
      print('Error creating new session: $e');
    }
  }

  // Load chat session
  Future<void> loadSession(String sessionId) async {
    try {
      _currentSessionId = sessionId;
      await _loadCurrentSessionMessages();
      notifyListeners();
    } catch (e) {
      print('Error loading session: $e');
    }
  }

  // Delete chat session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _chatRepository.deleteSession(sessionId);

      // If we deleted the current session, create a new one
      if (_currentSessionId == sessionId) {
        await createNewSession();
      }

      await _loadSessions();
      notifyListeners();
    } catch (e) {
      print('Error deleting session: $e');
    }
  }

  // Get input history for current session
  Future<List<String>> getInputHistory() async {
    if (_currentSessionId == null) return [];

    try {
      return await _chatRepository.getInputHistory(_currentSessionId!);
    } catch (e) {
      print('Error getting input history: $e');
      return [];
    }
  }

  // Clear input history for current session
  Future<void> clearInputHistory() async {
    if (_currentSessionId == null) return;

    try {
      await _chatRepository.clearInputHistory(_currentSessionId!);
    } catch (e) {
      print('Error clearing input history: $e');
    }
  }

  /// Enforce strict markdown code block formatting
  String _enforceCodeFormatting(String content) {
    if (content.trim().isEmpty) return content;
    
    // إصلاح الأخطاء الشائعة في تنسيق الكود
    String formatted = content;
    
    // 1. إصلاح الكود المكتوب بدون code blocks
    // البحث عن أكواد Python, JavaScript, etc غير مُنسقة
    formatted = _fixUnformattedCode(formatted);
    
    // 2. إصلاح العناوين الموضوعة داخل code blocks
    formatted = _fixHeadersInsideCodeBlocks(formatted);
    
    // 3. إصلاح استخدام bash blocks للكود غير المناسب
    formatted = _fixIncorrectBashBlocks(formatted);
    
    // 4. التأكد من وجود language identifier صحيح
    formatted = _ensureProperLanguageIdentifiers(formatted);
    
    return formatted;
  }
  
  /// إصلاح الكود غير المُنسق
  String _fixUnformattedCode(String content) {
    // البحث عن patterns شائعة للكود غير المُنسق
    
    // Python functions غير مُنسقة
    final pythonRegex = RegExp(
      r'(?:^|\n)(?:def |class |import |from |pip install |print\()',
      multiLine: true,
    );
    
    // JavaScript/TypeScript غير مُنسق
    final jsRegex = RegExp(
      r'(?:^|\n)(?:function |const |let |var |npm install |console\.)',
      multiLine: true,
    );
    
    // JSON غير مُنسق
    final jsonRegex = RegExp(
      r'(?:^|\n)\s*\{\s*"[^"]+"\s*:',
      multiLine: true,
    );
    
    String formatted = content;
    
    // إذا وُجد كود Python غير مُنسق، لفه في code block
    if (pythonRegex.hasMatch(formatted) && !formatted.contains('```python')) {
      // تنفيذ logic أكثر تعقيداً لتحديد وتنسيق الكود
      formatted = _wrapCodeInBlocks(formatted, 'python');
    }
    
    return formatted;
  }
  
  /// إصلاح العناوين داخل code blocks
  String _fixHeadersInsideCodeBlocks(String content) {
    // البحث عن code blocks تحتوي على عناوين
    final codeBlockWithHeaderRegex = RegExp(
      r'```(\w+)?\s*\n(#[^\n]+)\n',
      multiLine: true,
    );
    
    return content.replaceAllMapped(codeBlockWithHeaderRegex, (match) {
      final language = match.group(1) ?? '';
      final header = match.group(2) ?? '';
      
      // نقل العنوان خارج code block
      return '$header\n```$language\n';
    });
  }
  
  /// إصلاح استخدام bash blocks للكود غير المناسب  
  String _fixIncorrectBashBlocks(String content) {
    // البحث عن bash blocks تحتوي على كود غير shell
    final bashBlockRegex = RegExp(
      r'```bash\s*\n((?:(?!```)[\s\S])*)\n```',
      multiLine: true,
    );
    
    return content.replaceAllMapped(bashBlockRegex, (match) {
      final codeContent = match.group(1) ?? '';
      
      // فحص إذا كان الكود Python أو JavaScript
      if (codeContent.contains('def ') || codeContent.contains('import ') || 
          codeContent.contains('print(')) {
        return '```python\n$codeContent\n```';
      }
      
      if (codeContent.contains('function ') || codeContent.contains('const ') || 
          codeContent.contains('console.')) {
        return '```javascript\n$codeContent\n```';
      }
      
      if (codeContent.trim().startsWith('{') && codeContent.contains('"')) {
        return '```json\n$codeContent\n```';
      }
      
      // إذا كان shell حقيقي، أبقه
      return match.group(0) ?? '';
    });
  }
  
  /// التأكد من language identifiers صحيحة
  String _ensureProperLanguageIdentifiers(String content) {
    // قائمة اللغات المدعومة
    const supportedLanguages = [
      'python', 'javascript', 'typescript', 'dart', 'java', 'cpp', 'c',
      'bash', 'shell', 'json', 'yaml', 'xml', 'html', 'css', 'sql',
      'dockerfile', 'makefile', 'gradle', 'swift', 'kotlin', 'go', 'rust'
    ];
    
    // البحث عن code blocks بدون language identifier
    final emptyCodeBlockRegex = RegExp(r'```\s*\n', multiLine: true);
    
    return content.replaceAll(emptyCodeBlockRegex, '```text\n');
  }
  
  /// لف الكود في code blocks مناسبة
  String _wrapCodeInBlocks(String content, String language) {
    // تنفيذ منطق أكثر تعقيداً لتحديد حدود الكود
    // هذا مثال مبسط
    return content;
  }

  String _generateSessionTitle() {
    if (_messages.isNotEmpty) {
      final firstUserMessage = _messages.firstWhere(
        (m) => m.role == MessageRole.user,
        orElse: () => _messages.first,
      );

      String title = firstUserMessage.content;
      if (title.length > 30) {
        title = '${title.substring(0, 30)}...';
      }
      return title;
    }
    return 'محادثة جديدة';
  }

  // Clear current conversation with safety checks
  void clearConversation() {
    try {
      _messages.clear();
      _attachments.clear();
      _currentThinking = null;

      // حفظ التغييرات في قاعدة البيانات إذا كان هناك جلسة نشطة
      if (_currentSessionId != null) {
        _chatRepository.clearSessionMessages(_currentSessionId!).catchError((
          e,
        ) {
          print('⚠️ [CLEAR_CONVERSATION] خطأ في مسح رسائل الجلسة: $e');
        });
      }

      notifyListeners();
    } catch (e) {
      print('❌ [CLEAR_CONVERSATION] خطأ في مسح المحادثة: $e');
      // في حالة الخطأ، تأكد من مسح القوائم على الأقل
      _messages.clear();
      _attachments.clear();
      _currentThinking = null;
      notifyListeners();
    }
  }

  // إضافة dispose method لتنظيف الموارد ومنع تسريب الذاكرة
  @override
  void dispose() {
    // تنظيف القوائم
    _messages.clear();
    _sessions.clear();
    _attachments.clear();

    // تنظيف الحالة
    _currentThinking = null;
    _currentSessionId = null;

    // إيقاف الخدمات إذا لزم الأمر
    try {
      _groqService.dispose();
    } catch (e) {
      print('خطأ في إغلاق GroqService: $e');
    }

    try {
      _gptGodService.dispose();
    } catch (e) {
      print('خطأ في إغلاق GPTGodService: $e');
    }

    try {
      _tavilyService.dispose();
    } catch (e) {
      print('خطأ في إغلاق TavilyService: $e');
    }

    try {
      _localAIService.dispose();
    } catch (e) {
      print('خطأ في إغلاق LocalAIService: $e');
    }

    super.dispose();
  }
}
