import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/groq_service.dart';
import '../../core/services/gptgod_service.dart';
import '../../core/services/tavily_service.dart';
import '../../core/services/mcp_service.dart';
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
  final ChatRepository _chatRepository = ChatRepository();
  final Uuid _uuid = const Uuid();

  // Initialize provider and load sessions
  ChatProvider() {
    _initializeProvider();
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

  String _getEnhancedSystemPrompt() {
    final mcpService = McpService();
    return mcpService.getEnhancedSystemPrompt();
  }

  // Helper method to get appropriate AI service based on selected model
  dynamic _getAIService(String model) {
    if (model == 'gpt-3.5-turbo') {
      return _gptGodService;
    } else {
      return _groqService;
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
      // Error loading sessions: $e (تم إخفاء طباعة الأخطاء)
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
        type: FileType.any, // تغيير لدعم جميع الملفات
        allowMultiple: true,
        withData: true, // للحصول على البيانات للملفات الصغيرة
      );

      if (result != null) {
        for (PlatformFile file in result.files) {
          if (file.path != null) {
            // فحص نوع الملف والحجم
            final extension = file.extension?.toLowerCase() ?? '';
            final isAllowed = _isFileTypeAllowed(extension);
            final isSizeOk = file.size <= AppConfig.maxFileSize;

            if (!isAllowed) {
              print('⚠️ نوع الملف غير مدعوم: $extension');
              continue;
            }

            if (!isSizeOk) {
              print(
                '⚠️ حجم الملف كبير جداً: ${(file.size / 1024 / 1024).toStringAsFixed(1)} MB',
              );
              continue;
            }

            final attachment = AttachmentModel(
              id: _uuid.v4(),
              name: file.name,
              type: extension,
              size: file.size,
              path: file.path!,
              uploadedAt: DateTime.now(),
            );

            _attachments.add(attachment);
            print('✅ تم رفع الملف: ${file.name} (${extension})');
          }
        }
        notifyListeners();
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
        final bytes = await file.readAsBytes();
        final base64 = base64Encode(bytes);
        return '$fileInfo\n🖼️ صورة مرفقة (${extension.toUpperCase()})\n[الصورة محولة إلى base64 للمعالجة]\nBase64: data:image/$extension;base64,$base64';
      }
      // ملفات الصوت
      else if (_isAudioFile(extension)) {
        return '$fileInfo\n🎵 ملف صوتي مرفق\n[يمكن معالجة الملفات الصوتية لكن النموذج الحالي لا يدعم تحليل الصوت مباشرة]';
      }
      // ملفات الفيديو
      else if (_isVideoFile(extension)) {
        return '$fileInfo\n🎬 ملف فيديو مرفق\n[يمكن معالجة ملفات الفيديو لكن النموذج الحالي يحتاج أدوات إضافية للتحليل]';
      }
      // ملفات مضغوطة
      else if (_isArchiveFile(extension)) {
        return '$fileInfo\n📦 ملف مضغوط\n[لا يمكن قراءة محتوى الملفات المضغوطة مباشرة]';
      }
      // ملفات أخرى
      else {
        return '$fileInfo\n❓ نوع ملف غير معروف أو غير مدعوم للقراءة المباشرة';
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

  // Send message with AI processing
  Future<void> sendMessage(
    String content, {
    SettingsProvider? settingsProvider,
  }) async {
    if (content.trim().isEmpty) return;

    // Ensure we have a current session
    if (_currentSessionId == null) {
      await createNewSession();
    }

    // Get current settings
    final selectedModel = settingsProvider?.selectedModel ?? 'gemma2-9b-it';
    final temperature = settingsProvider?.temperature ?? 1.0;
    final maxTokens = settingsProvider?.maxTokens ?? 1024;

    // Debug: Print selected model
    print('🤖 [DEBUG] استخدام النموذج: $selectedModel');
    if (_debugMode) {
      print(
        '📊 [DEBUG] الإعدادات - الحرارة: $temperature، أقصى رمز: $maxTokens',
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

    try {
      // Start thinking process if debug mode is on
      if (_debugMode) {
        await _startThinkingProcess(
          content,
          settingsProvider: settingsProvider,
        );
      }

      _isTyping = true;
      notifyListeners();

      // Check if query needs web search
      String searchContext = '';
      if (_shouldSearchWeb(content)) {
        try {
          final searchResult = await _tavilyService.search(
            query: content,
            maxResults: 3,
            includeAnswer: true,
          );

          searchContext = 'معلومات من البحث على الويب:\n';
          if (searchResult.answer != null) {
            searchContext += 'الإجابة المباشرة: ${searchResult.answer}\n\n';
          }

          for (final result in searchResult.results) {
            searchContext +=
                '• ${result.title}\n${result.content.substring(0, result.content.length > 200 ? 200 : result.content.length)}...\nالمصدر: ${result.url}\n\n';
          }

          searchContext += '---\n\n';
        } catch (e) {
          print('Search error: $e');
          searchContext =
              'تعذر البحث في الويب. سنقوم بالإجابة بناءً على المعرفة المتاحة.\n\n';
        }
      }

      // Prepare attached files content with enhanced support
      List<String>? attachedFilesContent;
      if (_attachments.isNotEmpty) {
        attachedFilesContent = [];
        for (final attachment in _attachments) {
          try {
            final attachmentInfo = await _processAttachment(attachment);
            if (attachmentInfo.isNotEmpty) {
              attachedFilesContent.add(attachmentInfo);
            }
          } catch (e) {
            print('Error processing file ${attachment.name}: $e');
            attachedFilesContent.add(
              'خطأ في قراءة الملف: ${attachment.name} (${attachment.type})',
            );
          }
        }
      }

      // Add search context to attached files if available
      if (searchContext.isNotEmpty) {
        attachedFilesContent ??= [];
        attachedFilesContent.add('نتائج البحث:\n$searchContext');
      }

      // Get AI response stream with enhanced system prompt
      final enhancedPrompt = _getEnhancedSystemPrompt();
      final aiService = _getAIService(selectedModel);

      // Get response stream from appropriate service
      final responseStream = await aiService.sendMessageStream(
        messages: _messages,
        model: selectedModel,
        temperature: temperature,
        maxTokens: maxTokens,
        systemPrompt: enhancedPrompt,
        attachedFiles: attachedFilesContent,
      );

      // Create assistant message
      final assistantMessage = MessageModel(
        id: _uuid.v4(),
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        thinkingProcess: _currentThinking,
      );

      _messages.add(assistantMessage);
      _isTyping = false;
      notifyListeners();

      // Stream response
      StringBuffer responseBuffer = StringBuffer();
      await for (final chunk in responseStream) {
        responseBuffer.write(chunk);

        // Update the last message with new content
        final lastIndex = _messages.length - 1;
        _messages[lastIndex] = _messages[lastIndex].copyWith(
          content: responseBuffer.toString(),
        );
        notifyListeners();
      }

      // Save the completed assistant message to database
      final completedMessage = _messages.last;
      if (_currentSessionId != null) {
        await _chatRepository.saveMessage(completedMessage, _currentSessionId!);
      }

      // Clear thinking process
      _currentThinking = null;
      _isThinking = false;
    } catch (e) {
      _isTyping = false;
      _isThinking = false;

      // Add error message
      final errorMessage = MessageModel(
        id: _uuid.v4(),
        content: 'حدث خطأ: $e',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        status: MessageStatus.failed,
      );

      _messages.add(errorMessage);

      // Save error message to database
      if (_currentSessionId != null) {
        await _chatRepository.saveMessage(errorMessage, _currentSessionId!);
      }

      notifyListeners();
    }

    // Clear attachments after sending
    _attachments.clear();
    notifyListeners();
  }

  // Determine if a query should trigger web search
  bool _shouldSearchWeb(String query) {
    final lowerQuery = query.toLowerCase();

    // Keywords that suggest current information is needed
    final searchKeywords = [
      'آخر',
      'أخبار',
      'حديث',
      'جديد',
      'الان',
      'اليوم',
      'أمس',
      'نتيجة',
      'سعر',
      'طقس',
      'أسعار',
      'مباراة',
      'مبارات',
      'ما هو',
      'من هو',
      'متى',
      'أين',
      'كيف حال',
      'latest',
      'news',
      'today',
      'now',
      'current',
      'price',
      'weather',
    ];

    return searchKeywords.any((keyword) => lowerQuery.contains(keyword));
  }

  // Start thinking process for debug mode
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
      final selectedModel = settingsProvider?.selectedModel ?? 'gemma2-9b-it';
      final aiService = _getAIService(selectedModel);

      await for (final step in aiService.generateThinkingProcess(
        query: query,
      )) {
        _currentThinking = _currentThinking!.copyWith(
          steps: [..._currentThinking!.steps, step],
        );
        notifyListeners();
      }

      _currentThinking = _currentThinking!.copyWith(
        isComplete: true,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      print('Error in thinking process: $e');
    }

    _isThinking = false;
    notifyListeners();
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

  // Clear current conversation
  void clearConversation() {
    _messages.clear();
    _attachments.clear();
    _currentThinking = null;
    notifyListeners();
  }
}
