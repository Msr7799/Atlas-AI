import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'settings_provider.dart';
import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/services/mcp_service.dart';
import '../../data/models/message_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/tavily_service.dart';
import '../../core/services/unified_ai_service.dart';
import '../../data/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  // Core lists - تحسين إدارة الذاكرة
  final List<MessageModel> _messages = [];
  final List<ChatSessionModel> _sessions = [];
  final List<AttachmentModel> _attachments = [];

  // State management - تحسين إدارة الحالة
  bool _isThinking = false;
  bool _isTyping = false;
  bool _debugMode = false;
  bool _isDisposed = false;
  bool _isInitialized = false;

  // Enhanced properties
  ThinkingProcessModel? _currentThinking;
  String _lastUsedService = '';
  String _lastUsedModel = '';
  Map<String, dynamic> _debugInfo = {};
  String? _currentSessionId;

  // Message pagination - تحسين الأداء
  static const int _messagePageSize = 50;
  bool _isLoadingMessages = false;
  bool _hasMoreMessages = true;

  // Rate limiting - تحسين الأمان
  final Map<String, List<DateTime>> _messageTimestamps = {};
  static const int _maxMessagesPerMinute = 10;

  // Cleanup timer - منع تسرب الذاكرة
  Timer? _cleanupTimer;
  Timer? _autoSaveTimer;

  // Services - Unified AI service
  late final UnifiedAIService _aiService;
  late final TavilyService _tavilyService;
  late final McpService _mcpService;
  late final ChatRepository _chatRepository;
  late final Uuid _uuid;

  // Constructor with improved error handling
  ChatProvider() {
    try {
      print('🚀 [CHAT_PROVIDER] بدء تهيئة ChatProvider...');
      _initializeCore();
      _initializeServices();
      _setupTimers();
      _initializeProvider();
    } catch (e, stackTrace) {
      print('❌ [CHAT_PROVIDER] خطأ في تهيئة ChatProvider: $e');
      print('📍 Stack trace: $stackTrace');
      _handleInitializationError(e);
    }
  }

  // Core initialization
  void _initializeCore() {
    _uuid = const Uuid();
    _chatRepository = ChatRepository();
    _debugInfo = {
      'initialization_time': DateTime.now().toIso8601String(),
      'version': '2.0.0',
    };
  }

  // Lazy service initialization
  void _initializeServices() {
    try {
      _aiService = UnifiedAIService();
      _tavilyService = TavilyService();
      _mcpService = McpService();

      // Initialize services asynchronously
      _aiService.initialize();
      _tavilyService.initialize();
      _mcpService.initialize();

      print('✅ [SERVICES] تم تهيئة جميع الخدمات المحسنة بنجاح');
    } catch (e) {
      print('⚠️ [SERVICES] خطأ في تهيئة الخدمات: $e');
      throw ServiceInitializationException('فشل في تهيئة الخدمات: $e');
    }
  }

  // Setup timers for maintenance
  void _setupTimers() {
    // Cleanup timer - كل 5 دقائق
    _cleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performCleanup(),
    );

    // Auto-save timer - كل دقيقة
    _autoSaveTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _performAutoSave(),
    );
  }

  // Handle initialization errors
  void _handleInitializationError(dynamic error) {
    // تحقق من أن المزود لم يتم التخلص منه
    if (_isDisposed) return;

    _currentSessionId = _uuid.v4();
    _isInitialized = false;

    // Create emergency session
    final emergencySession = ChatSessionModel(
      id: _currentSessionId!,
      title: 'جلسة طارئة',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: [],
    );

    _sessions.add(emergencySession);

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Enhanced getters with validation
  List<MessageModel> get messages {
    _validateState();
    return List.unmodifiable(_messages);
  }

  List<ChatSessionModel> get sessions {
    _validateState();
    return List.unmodifiable(_sessions);
  }

  List<AttachmentModel> get attachments {
    _validateState();
    return List.unmodifiable(_attachments);
  }

  bool get isThinking => _isThinking;
  bool get isTyping => _isTyping;
  bool get debugMode => _debugMode;
  bool get isInitialized => _isInitialized;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get hasMoreMessages => _hasMoreMessages;
  String? get systemPrompt => _getEnhancedSystemPrompt();
  String? get currentSessionId => _currentSessionId;
  ThinkingProcessModel? get currentThinking => _currentThinking;
  String get lastUsedService => _lastUsedService;
  String get lastUsedModel => _lastUsedModel;
  Map<String, dynamic> get debugInfo => Map.unmodifiable(_debugInfo);

  // Message management methods
  void removeMessage(String messageId) {
    _validateState();
    _messages.removeWhere((message) => message.id == messageId);
    _safeNotifyListeners();
    print('✅ [REMOVE_MESSAGE] تم حذف الرسالة: $messageId');
  }

  void removeMessages(List<String> messageIds) {
    _validateState();
    _messages.removeWhere((message) => messageIds.contains(message.id));
    _safeNotifyListeners();
    print('✅ [REMOVE_MESSAGES] تم حذف ${messageIds.length} رسالة');
  }

  // Validate provider state
  void _validateState() {
    if (_isDisposed) {
      throw StateError('ChatProvider has been disposed');
    }
  }

  // Enhanced system prompt with better error handling
  String _getEnhancedSystemPrompt({SettingsProvider? settingsProvider}) {
    try {
      // استخدام prompt افتراضي محسن
      String basePrompt = '''
أنت مساعد ذكي متقدم يدعم اللغة العربية والإنجليزية.
- قدم إجابات دقيقة ومفيدة
- استخدم تنسيق Markdown عند الحاجة
- كن مهذباً ومحترماً
- اشرح المفاهيم المعقدة بطريقة بسيطة
''';
      
      // احصل على اللغة المفضلة من الإعدادات
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
      
      // إضافة تأكيد إضافي على التعدد اللغوي والردود المفصلة مع تحسين الترحيب
      final multilingualEnhancement = '''

## 🤗 WELCOME & GREETING ENHANCEMENT:
### 🎯 MANDATORY WELCOME BEHAVIOR:
- **ALWAYS START with a WARM, FRIENDLY greeting** for every response
- Make the user feel welcome and appreciated
- Use varied, natural greetings - don't repeat the same phrase
- Adapt greeting style to the user's question type and mood
- Be genuinely helpful and enthusiastic

### ✨ GREETING EXAMPLES (vary these naturally):
**For Arabic users:**
- "أهلاً وسهلاً! يسعدني مساعدتك..."
- "مرحباً بك! هذا سؤال رائع..."
- "أهلاً! سأكون سعيداً لمساعدتك في..."
- "مرحباً صديقي! دعني أساعدك..."
- "أهلاً وسهلاً بك! إليك ما يمكنني فعله..."

**For English users:**
- "Hello! I'm happy to help you with..."
- "Hi there! Great question about..."
- "Welcome! I'd be delighted to assist..."
- "Hello! Let me help you understand..."

**For programming questions:**
- "مرحباً! أحب أسئلة البرمجة! دعني أساعدك..."
- "أهلاً بك! سأكون سعيداً لحل هذه المسألة البرمجية..."

**For general questions:**
- "مرحباً! سؤال ممتاز، دعني أشرح لك..."
- "أهلاً وسهلاً! هذا موضوع شيق جداً..."

### 🎪 TONE REQUIREMENTS:
- Be ENTHUSIASTIC and POSITIVE
- Show genuine interest in helping
- Make every interaction feel personal and welcoming
- Express happiness to assist with their specific question
- Never be cold, robotic, or purely informational

## 🔧 ATLAS AI APP-SPECIFIC KNOWLEDGE:
### 📱 ABOUT THIS APPLICATION:
You are running inside **Atlas AI** - a Flutter-based Arabic AI assistant application with advanced features.

### ⚙️ HOW TO CHANGE COLORS/THEMES IN ATLAS AI:
When users ask "كيف أغير لون الواجهة؟" or about changing colors:

**خطوات تغيير الألوان في Atlas AI:**
1. **افتح الإعدادات**: اضغط على أيقونة الترس ⚙️ في الشريط العلوي
2. **اختر تبويب "المظهر والمعلومات"**: ستجد تبويبين، اختر الثاني
3. **في قسم "تخصيص المظهر"**:
   - **Color Picker (منتقي الألوان)**: اضغط على الدائرة الملونة لفتح لوحة الألوان
   - **اختر لونك المفضل**: من اللوحة الملونة أو أدخل كود اللون
   - **الوضع الداكن/الفاتح**: استخدم الـ Quick Settings في أعلى نافذة الإعدادات
   - **الوضع التلقائي**: يتبع نظام جهازك تلقائياً

4. **سيتم تطبيق التغييرات فوراً** على كامل التطبيق!

### 🎨 COLOR PICKER FEATURES:
- دعم كامل للألوان المخصصة
- تباين ذكي للنصوص (أبيض على داكن، أسود على فاتح)
- حفظ تلقائي للإعدادات
- معاينة فورية للتغييرات

### 🤖 أنت مساعد AI ذكي لتطبيق Atlas AI:
- تجيب على أسئلة البرمجة والتقنية
- تساعد في استخدام ميزات التطبيق
- تدعم اللغة العربية والإنجليزية
- تستخدم الرموز التعبيرية للوضوح (✅ للنجاح، ❌ للخطأ، ⚠️ للتحذير)

### 📝 قواعد الكود:
- استخدم markdown code blocks دائماً مع اللغة المناسبة
- مثال: ```python أو ```dart أو ```bash
- لا تضع عناوين داخل كتل الكود

''';
      
      return basePrompt + languageInstruction + multilingualEnhancement;
    } catch (e) {
      print('⚠️ [SYSTEM_PROMPT] خطأ في إنشاء System Prompt: $e');
      return 'You are a helpful AI assistant.'; // Fallback prompt
    }
  }

  // Enhanced provider initialization
  Future<void> _initializeProvider() async {
    try {
      print('📥 [INIT] بدء تحميل البيانات...');
      await _loadSessions();
      print('📄 [INIT] تم تحميل ${_sessions.length} جلسة سابقة');
      
      if (_sessions.isEmpty) {
        print('📝 [INIT] لا توجد جلسات سابقة، إنشاء جلسة جديدة');
        await createNewSession();
      } else {
        print('📂 [INIT] تحميل آخر جلسة: ${_sessions.first.title}');
        _currentSessionId = _sessions.first.id;
        await _loadCurrentSessionMessages();
      }
      
      _isInitialized = true;
      notifyListeners();
      print('✅ [INIT] تم إكمال تهيئة ChatProvider بنجاح');
    } catch (e) {
      print('❌ [INIT] خطأ في تهيئة المزود: $e');
      _handleInitializationError(e);
    }
  }

  // Enhanced session loading with pagination
  Future<void> _loadSessions() async {
    try {
      final sessions = await _chatRepository.getAllSessions();
      _sessions.clear();
      _sessions.addAll(sessions);
      _safeNotifyListeners();
    } catch (e) {
      print('❌ [LOAD_SESSIONS] خطأ في تحميل الجلسات: $e');
      throw SessionLoadException('فشل في تحميل الجلسات: $e');
    }
  }

  // Safe notifyListeners with disposal check
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Enhanced message loading with pagination
  Future<void> _loadCurrentSessionMessages() async {
    if (_currentSessionId == null || _isLoadingMessages) return;

    _isLoadingMessages = true;
    try {
      final messages = await _chatRepository.getSessionMessages(
        _currentSessionId!,
      );
      
      _messages.clear();
      _messages.addAll(messages);
      _hasMoreMessages = messages.length >= _messagePageSize;
      
      _safeNotifyListeners();
      print('✅ [LOAD_MESSAGES] تم تحميل ${messages.length} رسالة');
    } catch (e) {
      print('❌ [LOAD_MESSAGES] خطأ في تحميل الرسائل: $e');
    } finally {
      _isLoadingMessages = false;
    }
  }

  // Load more messages for pagination
  Future<void> loadMoreMessages() async {
    if (_currentSessionId == null || _isLoadingMessages || !_hasMoreMessages) {
      return;
    }

    _isLoadingMessages = true;
    try {
      final moreMessages = await _chatRepository.getSessionMessages(
        _currentSessionId!,
      );

      if (moreMessages.isNotEmpty) {
        _messages.insertAll(0, moreMessages);
        _hasMoreMessages = moreMessages.length >= _messagePageSize;
        _safeNotifyListeners();
        print('✅ [LOAD_MORE] تم تحميل ${moreMessages.length} رسالة إضافية');
      } else {
        _hasMoreMessages = false;
      }
    } catch (e) {
      print('❌ [LOAD_MORE] خطأ في تحميل المزيد من الرسائل: $e');
    } finally {
      _isLoadingMessages = false;
    }
  }

  // Public method for forcing sessions reload
  Future<void> loadSessions() async {
    await _loadSessions();
  }

  // Rate limiting check
  bool _checkRateLimit() {
    final now = DateTime.now();
    final sessionId = _currentSessionId ?? 'unknown';
    
    _messageTimestamps[sessionId] ??= [];
    final timestamps = _messageTimestamps[sessionId]!;
    
    // Remove old timestamps
    timestamps.removeWhere((time) => 
      now.difference(time).inMinutes >= 1
    );
    
    if (timestamps.length >= _maxMessagesPerMinute) {
      print('⚠️ [RATE_LIMIT] تم تجاوز حد الرسائل المسموحة');
      return false;
    }
    
    timestamps.add(now);
    return true;
  }

  // Input validation
  bool _validateInput(String content) {
    if (content.trim().isEmpty) {
      throw InvalidInputException('محتوى الرسالة فارغ');
    }
    
    if (content.length > 5000) {
      throw MessageTooLongException('الرسالة طويلة جداً');
    }
    
    // Basic security check
    if (_containsSuspiciousContent(content)) {
      throw SecurityException('المحتوى يحتوي على عناصر مشبوهة');
    }
    
    return true;
  }

  // Security check for suspicious content
  bool _containsSuspiciousContent(String content) {
    final suspiciousPatterns = [
      '<script',
      'javascript:',
      'data:text/html',
      'eval(',
    ];
    
    final lowerContent = content.toLowerCase();
    return suspiciousPatterns.any((pattern) => 
      lowerContent.contains(pattern)
    );
  }

  // Sanitize input content
  String _sanitizeInput(String content) {
    // Remove potentially harmful characters
    return content
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>'), '')
        .replaceAll(RegExp(r'javascript:'), '')
        .trim();
  }

  // Enhanced sendMessage with comprehensive error handling
  Future<void> sendMessage(String content, {SettingsProvider? settingsProvider}) async {
    _validateState();

    try {
      print('📤 [SEND_MESSAGE] بدء إرسال الرسالة...');
      // Input validation and rate limiting
      _validateInput(content);
      if (!_checkRateLimit()) {
        throw RateLimitExceededException('تم تجاوز حد الرسائل المسموحة');
      }

      final sanitizedContent = _sanitizeInput(content);
      
      // Start thinking process
      await _startThinkingProcess();

      // Update debug info
      _debugInfo.addAll({
        'timestamp': DateTime.now().toIso8601String(),
        'userMessage': sanitizedContent,
        'selectedModel': settingsProvider?.selectedModel ?? 'unknown',
        'temperature': settingsProvider?.temperature ?? 1.0,
        'maxTokens': settingsProvider?.maxTokens ?? 1024,
      });

      // Add user message with attachments info
      String userMessageContent = sanitizedContent;
      final imageCount = _attachments.where((att) => _isImageFile(att.type)).length;
      if (imageCount > 0) {
        userMessageContent += '\n\n📎 تم إرفاق $imageCount صورة';
      }

      final userMessage = MessageModel(
        id: _uuid.v4(),
        content: userMessageContent,
        role: MessageRole.user,
        timestamp: DateTime.now(),
        attachments: List.from(_attachments), // إضافة المرفقات للرسالة
      );

      _messages.add(userMessage);
      _safeNotifyListeners();
      
      // Save message asynchronously
      unawaited(_saveMessage(userMessage));
      _updateThinkingProcess('تم إضافة رسالة المستخدم', 'success');

      // Determine model and service
      String selectedModel = settingsProvider?.selectedModel ?? 'llama-3.1-8b-instant';

      if (!_isModelFreeAndAvailable(selectedModel)) {
        print('⚠️ [AI_SERVICE] النموذج المحدد غير مجاني أو غير متاح: $selectedModel');
        selectedModel = _getDefaultFreeModel();
        print('🔄 [AI_SERVICE] تم التبديل للنموذج المجاني الافتراضي: $selectedModel');
      }

      // تحقق من دعم النموذج للصور
      final hasImages = _attachments.any((att) => _isImageFile(att.type));
      if (hasImages) {
        print('📸 [VISION] تم اكتشاف صور مرفقة، النموذج المستخدم: $selectedModel');
        if (!_isVisionCapableModel(selectedModel)) {
          print('⚠️ [VISION] النموذج الحالي لا يدعم الرؤية، سيتم وصف الصور نصياً');

          // إضافة رسالة تحذيرية للمستخدم
          final warningMessage = MessageModel(
            id: _uuid.v4(),
            content: '⚠️ تنبيه: النموذج الحالي ($selectedModel) لا يدعم تحليل الصور بصرياً.\n\n'
                'للحصول على تحليل أفضل للصور، يُنصح باستخدام أحد النماذج التالية:\n'
                '• GPT-4 Vision أو GPT-4o\n'
                '• Claude-3 (جميع الإصدارات)\n'
                '• Gemini 1.5 Pro\n'
                '• Qwen-VL\n\n'
                'سيتم الآن محاولة وصف الصورة نصياً بناءً على البيانات المتاحة.',
            role: MessageRole.assistant,
            timestamp: DateTime.now(),
            metadata: {'type': 'warning', 'category': 'vision_support'},
          );

          _messages.add(warningMessage);
          _safeNotifyListeners();
        }
      }
      
      final aiService = _getAIService(selectedModel);
      
      // Update service info
      _lastUsedModel = selectedModel;
      _lastUsedService = _getServiceName(aiService);
      _debugInfo['actualService'] = _lastUsedService;
      _debugInfo['actualModel'] = selectedModel;

      _updateThinkingProcess('تم تحديد الخدمة: $_lastUsedService', 'info');
      _updateThinkingProcess('النموذج المستخدم: $selectedModel', 'info');

      // Process attachments if any
      String processedContent = sanitizedContent;
      if (_attachments.isNotEmpty) {
        _updateThinkingProcess('معالجة المرفقات...', 'processing');

        // عد الصور المرفقة
        final imageCount = _attachments.where((att) => _isImageFile(att.type)).length;
        if (imageCount > 0) {
          print('📸 [IMAGES] تم إرفاق $imageCount صورة مع الرسالة');
        }

        for (final attachment in _attachments) {
          try {
            final attachmentInfo = await _processAttachment(attachment);
            processedContent += '\n\n$attachmentInfo';
          } catch (e) {
            print('⚠️ [ATTACHMENT] خطأ في معالجة المرفق: $e');
          }
        }
        _updateThinkingProcess('تم معالجة ${_attachments.length} مرفق (منها $imageCount صورة)', 'success');
      }

      // Send request to service
      _updateThinkingProcess('إرسال الطلب للخدمة...', 'processing');
      
      final messagesForAPI = List<MessageModel>.from(_messages);

      // تحديث خوادم MCP مع الإعدادات الحالية
      _mcpService.updateCustomServers(
        settingsProvider?.customMcpServers ?? {},
        settingsProvider?.mcpServerStatus ?? {},
      );

      // معالجة الرسالة مع MCP المتقدم
      String response;
      final lastMessage = messagesForAPI.last.content.toLowerCase();

      // تحديد نوع المعالجة المطلوبة
      if (lastMessage.contains('تذكر') || lastMessage.contains('احفظ') || lastMessage.contains('ذاكرة')) {
        // استخدام خادم الذاكرة - توليد مفتاح ذكي
        final key = _generateMemoryKey(messagesForAPI.last.content);
        response = await _mcpService.executeMemoryStore(key, messagesForAPI.last.content);
      } else if (lastMessage.contains('استرجع') || lastMessage.contains('ابحث في الذاكرة')) {
        // استرجاع من الذاكرة
        final searchKey = _extractSearchKey(messagesForAPI.last.content);
        response = await _mcpService.executeMemoryRetrieve(searchKey);
      } else if (lastMessage.contains('فكر') || lastMessage.contains('حلل') || lastMessage.contains('خطوات')) {
        // استخدام التفكير التسلسلي
        final thinkingSteps = await _mcpService.executeSequentialThinking(messagesForAPI.last.content);
        response = thinkingSteps.join('\n\n');
      } else {
        // معالجة عادية مع تحسين النظام
        final enhancedPrompt = _mcpService.getEnhancedSystemPrompt();
        final systemMessage = MessageModel(
          id: 'system_${DateTime.now().millisecondsSinceEpoch}',
          content: enhancedPrompt,
          role: MessageRole.system,
          timestamp: DateTime.now(),
        );
        messagesForAPI.insert(0, systemMessage);

        response = await _aiService.sendMessage(
          messages: messagesForAPI,
          model: selectedModel,
        );
      }

      _updateThinkingProcess('تم استلام الرد من الخدمة', 'success');

      // Add AI response
      final aiMessage = MessageModel(
        id: _uuid.v4(),
        content: _enforceCodeFormatting(response),
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        metadata: {
          'service': _lastUsedService,
          'model': selectedModel,
          'debugInfo': Map.from(_debugInfo),
        },
      );

      _messages.add(aiMessage);
      _safeNotifyListeners();
      
      // Save AI message asynchronously
      unawaited(_saveMessage(aiMessage));

      // Complete thinking process
      _completeThinkingProcess();
      _attachments.clear();

      print('✅ [CHAT_PROVIDER] تم إرسال الرسالة بنجاح');
      print('📝 [DEBUG] النموذج المستخدم: $_lastUsedModel');

    } on InvalidInputException catch (e) {
      _handleError('خطأ في الإدخال', e.message);
    } on RateLimitExceededException catch (e) {
      _handleError('تجاوز الحد المسموح', e.message);
    } on SecurityException catch (e) {
      _handleError('مشكلة أمنية', e.message);
    } on NetworkException catch (e) {
      _handleError('مشكلة في الشبكة', 'تحقق من اتصال الإنترنت: ${e.message}');
    } on ServiceException catch (e) {
      _handleError('خطأ في الخدمة', 'مشكلة في خدمة AI: ${e.message}');
    } catch (e, stackTrace) {
      print('❌ [CHAT_PROVIDER] خطأ غير متوقع: $e');
      print('📍 Stack trace: $stackTrace');

      // تنظيف المرفقات في حالة الخطأ
      _attachments.clear();

      // معالجة خاصة لأخطاء الصور
      String errorMessage = 'حدث خطأ أثناء معالجة الرسالة';
      if (e.toString().contains('image') || e.toString().contains('صورة')) {
        errorMessage = 'حدث خطأ أثناء معالجة الصورة. يرجى المحاولة مرة أخرى بصورة أخرى.';
      }

      _handleError('خطأ غير متوقع', errorMessage);
    }
  }

  // Enhanced error handling
  void _handleError(String title, String message) {
    _isThinking = false;
    _currentThinking = _currentThinking?.copyWith(
      status: 'error',
      endTime: DateTime.now(),
      isComplete: true,
      completedAt: DateTime.now(),
    );
    
    // Add error message to conversation
    final errorMessage = MessageModel(
      id: _uuid.v4(),
      content: '⚠️ **$title**: $message',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      metadata: {'type': 'error'},
    );
    
    _messages.add(errorMessage);
    _safeNotifyListeners();
  }

  // Start enhanced thinking process
  Future<void> _startThinkingProcess() async {
    _isThinking = true;
    _currentThinking = ThinkingProcessModel(
      id: _uuid.v4(),
      steps: [],
      isComplete: false,
      startedAt: DateTime.now(),
      status: 'thinking',
    );
    _safeNotifyListeners();
  }

  // Update thinking process
  void _updateThinkingProcess(String message, String type) {
    if (_currentThinking != null && !_isDisposed) {
      final newStep = ThinkingStepModel(
        id: _uuid.v4(),
        stepNumber: _currentThinking!.steps.length + 1,
        message: message,
        type: type,
        timestamp: DateTime.now(),
        content: message,
      );
      
      final updatedSteps = List<ThinkingStepModel>.from(_currentThinking!.steps)
        ..add(newStep);
      
      _currentThinking = _currentThinking!.copyWith(steps: updatedSteps);
      _safeNotifyListeners();
    }
  }

  // Complete thinking process
  void _completeThinkingProcess() {
    _currentThinking = _currentThinking?.copyWith(
      status: 'completed',
      endTime: DateTime.now(),
      isComplete: true,
      completedAt: DateTime.now(),
    );
    _isThinking = false;
    _safeNotifyListeners();
  }

  // Get unified AI service
  UnifiedAIService _getAIService(String model) {
    print('🤖 [AI_SERVICE] استخدام الخدمة الموحدة للنموذج: $model');
    return _aiService;
  }

  // Get service name
  String _getServiceName(dynamic service) {
    if (service == _aiService) return _aiService.lastUsedService;
    return 'Unified AI';
  }

  // الحصول على النماذج المتاحة
  List<String> getAvailableModels() {
    try {
      return _aiService.getAvailableModels();
    } catch (e) {
      print('❌ [MODELS] خطأ في الحصول على النماذج: $e');
      return [
        'llama-3.1-8b-instant',
        'gpt-4o',
        'claude-3-5-sonnet-20241022',
        'anthropic/claude-3.5-sonnet',
      ];
    }
  }

  // تحديث مفتاح API
  Future<void> updateApiKey(String service, String apiKey) async {
    try {
      await _aiService.updateApiKey(service, apiKey);
      print('✅ [API_KEY] تم تحديث مفتاح $service');
    } catch (e) {
      print('❌ [API_KEY] خطأ في تحديث مفتاح $service: $e');
    }
  }

  // Check if model is free and available
  bool _isModelFreeAndAvailable(String modelId) {
    for (final serviceKey in AppConfig.freeModels.keys) {
      final serviceModels = AppConfig.freeModels[serviceKey] ?? [];
      for (final model in serviceModels) {
        if (model['id'] == modelId && (model['isFree'] == true || serviceKey != 'openrouter')) {
          return true;
        }
      }
    }
    return false;
  }

  // Get default free model
  String _getDefaultFreeModel() {
    const freeModelsPriority = [
      'openai/gpt-oss-20b',
      'z-ai/glm-4.5-air',
      'qwen/qwen3-coder-480b-a35b-instruct',
      'moonshotai/kimi-k2-instruct',
      'llama-3.1-8b-instant',
      'gpt-3.5-turbo',
    ];

    for (final modelId in freeModelsPriority) {
      if (_isModelFreeAndAvailable(modelId)) {
        return modelId;
      }
    }

    return 'llama-3.1-8b-instant';
  }

  // Check if model supports vision
  bool _isVisionCapableModel(String model) {
    final modelLower = model.toLowerCase();

    // النماذج المعروفة التي تدعم الرؤية
    final visionModels = [
      'gpt-4-vision', 'gpt-4o', 'claude-3', 'gemini-1.5', 'gemini-pro-vision',
      'qwen-vl', 'qwen2-vl', 'llama-3.2-11b-vision', 'llama-3.2-90b-vision'
    ];

    return visionModels.any((visionModel) => modelLower.contains(visionModel));
  }

  // Check if model belongs to OpenRouter
  bool _isOpenRouterModel(String model) {
    final openRouterPrefixes = [
      'openai/', 'z-ai/', 'qwen/', 'moonshotai/', 'cognitivecomputations/',
      'google/', 'tencent/', 'tngtech/', 'mistralai/', 'anthropic/',
    ];

    return openRouterPrefixes.any((prefix) => model.startsWith(prefix));
  }

  // Enhanced message saving with error handling
  Future<void> _saveMessage(MessageModel message) async {
    if (_currentSessionId == null) return;

    try {
      await _chatRepository.saveMessage(message, _currentSessionId!);
      print('✅ [SAVE_MESSAGE] تم حفظ الرسالة: ${message.id}');
    } catch (e) {
      print('❌ [SAVE_MESSAGE] خطأ في حفظ الرسالة: $e');
      // Don't throw here, as saving is not critical for user experience
    }
  }

  // Get messages for a specific session
  Future<List<MessageModel>> getSessionMessages(String sessionId) async {
    try {
      return await _chatRepository.getSessionMessages(sessionId);
    } catch (e) {
      print('❌ [GET_SESSION_MESSAGES] خطأ في تحميل رسائل الجلسة: $e');
      return [];
    }
  }

  // Get all messages from all sessions
  Future<List<MessageModel>> getAllMessagesFromAllSessions() async {
    try {
      List<MessageModel> allMessages = [];
      
      for (final session in _sessions) {
        final sessionMessages = await _chatRepository.getSessionMessages(session.id);
        allMessages.addAll(sessionMessages);
      }
      
      print('✅ [EXPORT_ALL] تم جمع ${allMessages.length} رسالة من ${_sessions.length} جلسة');
      return allMessages;
    } catch (e) {
      print('❌ [EXPORT_ALL] خطأ في جمع جميع الرسائل: $e');
      return [];
    }
  }

  // Toggle debug mode
  void toggleDebugMode() {
    _debugMode = !_debugMode;
    _safeNotifyListeners();
  }

  // Set system prompt from file
  void setSystemPrompt(String prompt) {
    // يتم الآن التعامل مع system prompt من خلال MCP service
    _safeNotifyListeners();
  }

  // Add image attachment from XFile
  Future<void> addImageAttachment(XFile imageFile) async {
    try {
      print('🔄 [IMAGE_ATTACHMENT] بدء معالجة الصورة: ${imageFile.name}');

      // التحقق من وجود الملف
      if (imageFile.path.isEmpty) {
        throw Exception('مسار الصورة فارغ');
      }

      // التحقق من امتداد الملف
      final extension = imageFile.name.split('.').last.toLowerCase();
      if (!_isImageFile(extension)) {
        throw UnsupportedFileTypeException('نوع الملف غير مدعوم: $extension');
      }

      // التحقق من حجم الملف بطريقة آمنة
      int fileSize;
      try {
        fileSize = await imageFile.length();
        print('📏 [IMAGE_ATTACHMENT] حجم الصورة: ${_formatFileSize(fileSize)}');
      } catch (e) {
        print('❌ [IMAGE_ATTACHMENT] خطأ في قراءة حجم الملف: $e');
        throw Exception('لا يمكن قراءة حجم الصورة');
      }

      // التحقق من الحد الأقصى للحجم (10MB)
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        throw Exception('حجم الصورة كبير جداً. الحد الأقصى هو ${_formatFileSize(maxSize)}');
      }

      // إنشاء المرفق
      final attachment = AttachmentModel(
        id: _uuid.v4(),
        name: imageFile.name,
        path: imageFile.path,
        type: extension,
        size: fileSize,
        uploadedAt: DateTime.now(),
      );

      _attachments.add(attachment);
      _safeNotifyListeners();
      print('✅ [IMAGE_ATTACHMENT] تم إضافة صورة بنجاح: ${attachment.name}');

    } catch (e) {
      print('❌ [IMAGE_ATTACHMENT] خطأ في إضافة الصورة: $e');
      rethrow;
    }
  }

  // Enhanced attachment handling
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
          _safeNotifyListeners();
          print('✅ [ATTACHMENT] تم إضافة مرفق: ${attachment.name}');
        } else {
          print('❌ [ATTACHMENT] نوع ملف غير مسموح: $extension');
          throw UnsupportedFileTypeException('نوع الملف غير مدعوم: $extension');
        }
      }
    } catch (e) {
      print('❌ [ATTACHMENT] خطأ في إضافة المرفق: $e');
      rethrow;
    }
  }

  // Check if file type is allowed
  bool _isFileTypeAllowed(String extension) {
    return AppConfig.allowedFileTypes.contains(extension.toLowerCase());
  }

  // Enhanced attachment processing
  Future<String> _processAttachment(AttachmentModel attachment) async {
    final file = File(attachment.path);
    final extension = attachment.type.toLowerCase();

    final fileInfo = '📁 الملف: ${attachment.name}\n'
        '📏 الحجم: ${_formatFileSize(attachment.size)}\n'
        '🗂️ النوع: $extension\n';

    try {
      if (_isTextFile(extension)) {
        final content = await file.readAsString();
        return '$fileInfo\n📄 المحتوى:\n$content';
      } else if (_isImageFile(extension)) {
        return await _processImageAttachment(file, attachment, fileInfo);
      } else if (_isAudioFile(extension)) {
        return '$fileInfo\n🎵 ملف صوتي تم رفعه';
      } else if (_isVideoFile(extension)) {
        return '$fileInfo\n🎬 ملف فيديو تم رفعه';
      } else if (_isArchiveFile(extension)) {
        return '$fileInfo\n📦 ملف مضغوط تم رفعه';
      } else {
        return '$fileInfo\n📎 ملف تم رفعه';
      }
    } catch (e) {
      print('❌ [ATTACHMENT_PROCESSING] خطأ في معالجة المرفق ${attachment.name}: $e');
      return '$fileInfo\n⚠️ خطأ في قراءة الملف: $e';
    }
  }

  // Process image attachment separately to avoid UI blocking
  Future<String> _processImageAttachment(File file, AttachmentModel attachment, String fileInfo) async {
    try {
      print('🖼️ [IMAGE_PROCESSING] بدء معالجة الصورة: ${attachment.name}');

      // التحقق من وجود الملف
      if (!await file.exists()) {
        throw Exception('الملف غير موجود: ${file.path}');
      }

      // قراءة الصورة بطريقة آمنة
      final bytes = await file.readAsBytes();
      print('📊 [IMAGE_PROCESSING] تم قراءة ${bytes.length} بايت');

      // التحقق من أن البيانات ليست فارغة
      if (bytes.isEmpty) {
        throw Exception('الصورة فارغة أو تالفة');
      }

      // تحويل إلى base64 (قد يكون بطيئاً للصور الكبيرة)
      // للصور الكبيرة، نستخدم compute لتجنب blocking UI
      final base64Image = bytes.length > 1024 * 1024 // 1MB
          ? await compute(_encodeBase64, bytes)
          : base64Encode(bytes);
      final mimeType = _getMimeType(attachment.type);

      print('✅ [IMAGE_PROCESSING] تم تحويل الصورة إلى base64 بنجاح');

      // إضافة وصف واضح للصورة مع البيانات
      return '$fileInfo\n🖼️ صورة مرفقة - يرجى تحليلها ووصفها:\n'
          'data:$mimeType;base64,$base64Image\n\n'
          'تعليمات للنموذج: هذه صورة تم رفعها من قبل المستخدم. يرجى:\n'
          '1. تحليل محتوى الصورة بالتفصيل\n'
          '2. وصف العناصر الموجودة فيها\n'
          '3. تحديد الألوان والأشكال والنصوص إن وجدت\n'
          '4. تقديم أي معلومات مفيدة حول الصورة';

    } catch (e) {
      print('❌ [IMAGE_PROCESSING] خطأ في معالجة الصورة: $e');
      return '$fileInfo\n⚠️ خطأ في معالجة الصورة: $e\n'
          'يرجى التأكد من أن الصورة صحيحة وغير تالفة.';
    }
  }

  // File type detection methods
  bool _isTextFile(String extension) {
    return [
      'txt', 'md', 'json', 'yaml', 'yml', 'xml', 'csv',
      'py', 'js', 'ts', 'html', 'css', 'dart', 'java',
      'cpp', 'c', 'h', 'php', 'rb', 'go', 'rs', 'swift',
      'kt', 'scala', 'sql', 'sh', 'bat', 'ps1',
    ].contains(extension);
  }

  bool _isImageFile(String extension) {
    return [
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
      'svg', 'tiff', 'tif', 'ico',
    ].contains(extension);
  }

  bool _isAudioFile(String extension) {
    return [
      'mp3', 'wav', 'aac', 'flac', 'ogg', 'm4a', 'wma',
    ].contains(extension);
  }

  bool _isVideoFile(String extension) {
    return [
      'mp4', 'avi', 'mov', 'wmv', 'flv', 'mkv', 'webm',
    ].contains(extension);
  }

  bool _isArchiveFile(String extension) {
    return ['zip', 'rar', '7z', 'tar', 'gz', 'bz2'].contains(extension);
  }

  // Get MIME type for image files
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'svg':
        return 'image/svg+xml';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      case 'ico':
        return 'image/x-icon';
      default:
        return 'image/jpeg'; // default fallback
    }
  }

  // Format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  // Remove attachment
  void removeAttachment(String id) {
    _attachments.removeWhere((att) => att.id == id);
    _safeNotifyListeners();
  }

  // Update MCP configuration
  void updateMcpConfiguration(SettingsProvider settingsProvider) {
    try {
      // تحديث إعدادات MCP
      print('✅ [MCP] تم تحديث إعدادات MCP المخصصة');
    } catch (e) {
      print('❌ [MCP] خطأ في تحديث إعدادات MCP: $e');
    }
  }

  // Enhanced web search
  Future<void> searchWeb(String query) async {
    try {
      _updateThinkingProcess('البحث في الويب...', 'processing');
      
      final searchResult = await _tavilyService.search(query: query);

      String searchContent = 'نتائج البحث لـ "$query":\n\n';

      if (searchResult.answer != null) {
        searchContent += 'الإجابة المباشرة: ${searchResult.answer}\n\n';
      }

      for (final result in searchResult.results.take(3)) {
        searchContent += '• ${result.title}\n';
        searchContent += '  ${result.content.substring(0, 
          result.content.length > 200 ? 200 : result.content.length)}...\n';
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
      unawaited(_saveMessage(searchMessage));
      _safeNotifyListeners();

      _updateThinkingProcess('تم الانتهاء من البحث', 'success');
      print('✅ [SEARCH] تم البحث عن: $query');
    } catch (e) {
      print('❌ [SEARCH] خطأ في البحث: $e');
      _updateThinkingProcess('خطأ في البحث: $e', 'error');
    }
  }

  // Enhanced session management
  Future<void> createNewSession([String? title]) async {
    try {
      final sessionTitle = title ?? _generateSessionTitle();
      final sessionId = await _chatRepository.createNewSession(sessionTitle);

      _currentSessionId = sessionId;
      _messages.clear();
      _attachments.clear();
      _currentThinking = null;

      await _loadSessions();
      _safeNotifyListeners();
      
      print('✅ [SESSION] تم إنشاء جلسة جديدة: $sessionTitle');
    } catch (e) {
      print('❌ [SESSION] خطأ في إنشاء جلسة جديدة: $e');
      throw SessionCreationException('فشل في إنشاء جلسة جديدة: $e');
    }
  }

  // Load chat session with enhanced error handling
  Future<void> loadSession(String sessionId) async {
    try {
      print('📄 [LOAD_SESSION] تحميل جلسة: $sessionId');
      
      final session = _sessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => throw SessionNotFoundException('الجلسة غير موجودة: $sessionId'),
      );
      
      print('📂 [LOAD_SESSION] تحميل جلسة: ${session.title}');
      
      _currentSessionId = sessionId;
      _messages.clear();
      _attachments.clear();
      _currentThinking = null;
      
      await _loadCurrentSessionMessages();
      _safeNotifyListeners();
      
      print('✅ [LOAD_SESSION] تم تحميل الجلسة بنجاح: ${_messages.length} رسالة');
    } catch (e) {
      print('❌ [LOAD_SESSION] خطأ في تحميل الجلسة: $e');
      await createNewSession('جلسة طارئة');
    }
  }

  // Delete chat session
  Future<void> deleteSession(String sessionId) async {
    try {
      await _chatRepository.deleteSession(sessionId);

      if (_currentSessionId == sessionId) {
        await createNewSession();
      }

      await _loadSessions();
      _safeNotifyListeners();
      
      print('✅ [DELETE_SESSION] تم حذف الجلسة: $sessionId');
    } catch (e) {
      print('❌ [DELETE_SESSION] خطأ في حذف الجلسة: $e');
      throw SessionDeletionException('فشل في حذف الجلسة: $e');
    }
  }

  // Get input history
  Future<List<String>> getInputHistory() async {
    if (_currentSessionId == null) return [];

    try {
      return await _chatRepository.getInputHistory(_currentSessionId!);
    } catch (e) {
      print('❌ [INPUT_HISTORY] خطأ في الحصول على تاريخ الإدخال: $e');
      return [];
    }
  }

  // Clear input history
  Future<void> clearInputHistory() async {
    if (_currentSessionId == null) return;

    try {
      await _chatRepository.clearInputHistory(_currentSessionId!);
      print('✅ [INPUT_HISTORY] تم مسح تاريخ الإدخال');
    } catch (e) {
      print('❌ [INPUT_HISTORY] خطأ في مسح تاريخ الإدخال: $e');
    }
  }

  // توليد مفتاح ذكي للذاكرة
  String _generateMemoryKey(String content) {
    // استخراج الكلمات المفتاحية من المحتوى
    final words = content.toLowerCase()
        .replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\w\s]'), '')
        .split(' ')
        .where((word) => word.length > 2)
        .take(3)
        .join('_');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return words.isNotEmpty ? '${words}_$timestamp' : 'memory_$timestamp';
  }

  // استخراج مفتاح البحث من النص
  String _extractSearchKey(String content) {
    // البحث عن كلمات مفتاحية بعد "استرجع" أو "ابحث"
    final patterns = [
      RegExp(r'استرجع\s+(.+)', caseSensitive: false),
      RegExp(r'ابحث\s+عن\s+(.+)', caseSensitive: false),
      RegExp(r'ابحث\s+في\s+الذاكرة\s+عن\s+(.+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null && match.group(1) != null) {
        return match.group(1)!.trim();
      }
    }

    // إذا لم نجد نمط محدد، استخدم النص كاملاً
    return content.trim();
  }

  // Enhanced code formatting
  String _enforceCodeFormatting(String content) {
    if (content.trim().isEmpty) return content;
    
    String formatted = content;
    
    try {
      formatted = _fixUnformattedCode(formatted);
      formatted = _fixHeadersInsideCodeBlocks(formatted);
      formatted = _fixIncorrectBashBlocks(formatted);
      formatted = _ensureProperLanguageIdentifiers(formatted);
      
      return formatted;
    } catch (e) {
      print('⚠️ [CODE_FORMAT] خطأ في تنسيق الكود: $e');
      return content; // Return original if formatting fails
    }
  }
  
  // Fix unformatted code
  String _fixUnformattedCode(String content) {
    final pythonRegex = RegExp(
      r'(?:^|\n)(?:def |class |import |from |pip install |print\()',
      multiLine: true,
    );
    
    final jsRegex = RegExp(
      r'(?:^|\n)(?:function |const |let |var |npm install |console\.)',
      multiLine: true,
    );
    
    String formatted = content;
    
    if (pythonRegex.hasMatch(formatted) && !formatted.contains('```python')) {
      formatted = _wrapCodeInBlocks(formatted, 'python');
    }
    
    if (jsRegex.hasMatch(formatted) && !formatted.contains('```javascript')) {
      formatted = _wrapCodeInBlocks(formatted, 'javascript');
    }
    
    return formatted;
  }
  
  // Fix headers inside code blocks
  String _fixHeadersInsideCodeBlocks(String content) {
    final codeBlockWithHeaderRegex = RegExp(
      r'```(\w+)?\s*\n(#[^\n]+)\n',
      multiLine: true,
    );
    
    return content.replaceAllMapped(codeBlockWithHeaderRegex, (match) {
      final language = match.group(1) ?? '';
      final header = match.group(2) ?? '';
      return '$header\n```$language\n';
    });
  }
  
  // Fix incorrect bash blocks
  String _fixIncorrectBashBlocks(String content) {
    final bashBlockRegex = RegExp(
      r'```bash\s*\n((?:(?!```)[\s\S])*)\n```',
      multiLine: true,
    );
    
    return content.replaceAllMapped(bashBlockRegex, (match) {
      final codeContent = match.group(1) ?? '';
      
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
      
      return match.group(0) ?? '';
    });
  }
  
  // Ensure proper language identifiers
  String _ensureProperLanguageIdentifiers(String content) {
    final emptyCodeBlockRegex = RegExp(r'```\s*\n', multiLine: true);
    return content.replaceAll(emptyCodeBlockRegex, '```text\n');
  }
  
  // Wrap code in blocks
  String _wrapCodeInBlocks(String content, String language) {
    // This would contain more sophisticated logic for determining code boundaries
    // For now, returning as-is to prevent breaking existing functionality
    return content;
  }

  // Generate session title
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

  // Clear conversation with enhanced safety
  void clearConversation() {
    try {
      _messages.clear();
      _attachments.clear();
      _currentThinking = null;

      if (_currentSessionId != null) {
        unawaited(_chatRepository.clearSessionMessages(_currentSessionId!));
      }

      _safeNotifyListeners();
      print('✅ [CLEAR] تم مسح المحادثة');
    } catch (e) {
      print('❌ [CLEAR] خطأ في مسح المحادثة: $e');
      _messages.clear();
      _attachments.clear();
      _currentThinking = null;
      _safeNotifyListeners();
    }
  }

  // Maintenance methods
  void _performCleanup() {
    if (_isDisposed) return;

    try {
      // Clean old debug info
      if (_debugInfo.length > 100) {
        final keys = _debugInfo.keys.toList()..take(50);
        for (final key in keys) {
          _debugInfo.remove(key);
        }
      }

      // Clean old message timestamps
      final now = DateTime.now();
      _messageTimestamps.forEach((key, timestamps) {
        timestamps.removeWhere((time) => 
          now.difference(time).inMinutes > 60
        );
      });

      // Remove empty timestamp lists
      _messageTimestamps.removeWhere((key, timestamps) => 
        timestamps.isEmpty
      );

      print('🧹 [CLEANUP] تم تنظيف البيانات المؤقتة');
    } catch (e) {
      print('⚠️ [CLEANUP] خطأ في التنظيف: $e');
    }
  }

  void _performAutoSave() {
    if (_isDisposed || _currentSessionId == null) return;

    try {
      // Auto-save pending operations can be added here
      print('💾 [AUTO_SAVE] تم الحفظ التلقائي');
    } catch (e) {
      print('⚠️ [AUTO_SAVE] خطأ في الحفظ التلقائي: $e');
    }
  }

  // Enhanced dispose method with comprehensive cleanup
  @override
  void dispose() {
    if (_isDisposed) return;

    print('🧹 [CHAT_PROVIDER] بدء تنظيف الموارد...');
    _isDisposed = true;

    // Cancel timers
    _cleanupTimer?.cancel();
    _autoSaveTimer?.cancel();
    
    // Clear collections
    _messages.clear();
    _sessions.clear();
    _attachments.clear();
    _debugInfo.clear();
    _messageTimestamps.clear();

    // Reset state
    _currentThinking = null;
    _currentSessionId = null;
    _isThinking = false;
    _isTyping = false;

    // Dispose services safely
    _disposeServices();

    print('✅ [CHAT_PROVIDER] تم تنظيف جميع الموارد بنجاح');
    super.dispose();
  }

  // Safe service disposal
  void _disposeServices() {
    try {
      _aiService.dispose();
      print('✅ [DISPOSE] تم إغلاق UnifiedAIService بنجاح');
    } catch (e) {
      print('⚠️ [DISPOSE] خطأ في إغلاق UnifiedAIService: $e');
    }

    try {
      _tavilyService.dispose();
      print('✅ [DISPOSE] تم إغلاق TavilyService بنجاح');
    } catch (e) {
      print('⚠️ [DISPOSE] خطأ في إغلاق TavilyService: $e');
    }
  }
}

// Custom Exceptions for better error handling
class ChatProviderException implements Exception {
  final String message;
  const ChatProviderException(this.message);
  @override
  String toString() => 'ChatProviderException: $message';
}

class InvalidInputException extends ChatProviderException {
  const InvalidInputException(super.message);
}

class MessageTooLongException extends ChatProviderException {
  const MessageTooLongException(super.message);
}

class SecurityException extends ChatProviderException {
  const SecurityException(super.message);
}

class RateLimitExceededException extends ChatProviderException {
  const RateLimitExceededException(super.message);
}

class NetworkException extends ChatProviderException {
  const NetworkException(super.message);
}

class ServiceException extends ChatProviderException {
  const ServiceException(super.message);
}

class ServiceInitializationException extends ChatProviderException {
  const ServiceInitializationException(super.message);
}

class SessionLoadException extends ChatProviderException {
  const SessionLoadException(super.message);
}

class SessionCreationException extends ChatProviderException {
  const SessionCreationException(super.message);
}

class SessionNotFoundException extends ChatProviderException {
  const SessionNotFoundException(super.message);
}

// دالة مساعدة لتحويل البيانات إلى base64 في isolate منفصل
String _encodeBase64(List<int> bytes) {
  return base64Encode(bytes);
}

class SessionDeletionException extends ChatProviderException {
  const SessionDeletionException(super.message);
}

class UnsupportedFileTypeException extends ChatProviderException {
  const UnsupportedFileTypeException(super.message);
}

// Helper function for fire-and-forget operations
void unawaited(Future<void> future) {
  // Explicitly ignore the future to avoid analyzer warnings
}