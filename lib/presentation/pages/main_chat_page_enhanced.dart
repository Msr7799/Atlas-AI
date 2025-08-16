import '../widgets/chat_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/attachment_preview.dart';
import '../providers/settings_provider.dart';
import '../widgets/enhanced/chat_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/speech_service.dart';
import '../widgets/thinking_process_widget.dart';
import '../widgets/enhanced/chat_input_area.dart';
import '../../core/utils/performance_monitor.dart';
import '../widgets/enhanced/chat_message_list.dart';
import '../../core/services/permissions_manager.dart';
import '../widgets/enhanced/chat_welcome_screen.dart';

// Core Services

// Data Models

// Providers

// Widgets

// New Enhanced Widgets

// Pages

// Constants

/// الصفحة الرئيسية للمحادثة مع تحسينات الأداء والواجهة
class MainChatPageEnhanced extends StatefulWidget {
  const MainChatPageEnhanced({super.key});

  @override
  State<MainChatPageEnhanced> createState() => _MainChatPageEnhancedState();
}

class _MainChatPageEnhancedState extends State<MainChatPageEnhanced>
    with TickerProviderStateMixin, PerformanceMonitoringMixin {
  
  // Controllers - منظمة في مجموعة واحدة
  late final _ChatControllers _controllers;
  
  // Animation Controllers - منظمة في مجموعة واحدة
  late final _ChatAnimations _animations;
  
  // State Variables - منظمة في مجموعة واحدة
  late final _ChatState _chatState;

  // Services
  late final SpeechService _speechService;

  @override
  void initState() {
    super.initState();
    
    // تسجيل الأحداث
    if (kDebugMode) {
      print('📱 MainChatPage initialized');
      print('🎯 Starting component initialization...');
    }
    
    _initializeComponents();
    _setupInitialData();
  }

  /// تهيئة جميع المكونات الأساسية
  void _initializeComponents() {
    if (kDebugMode) {
      print('🔧 Initializing components...');
    }
    
    _controllers = _ChatControllers();
    _animations = _ChatAnimations(this);
    _chatState = _ChatState();
    _speechService = SpeechService();
    
    if (kDebugMode) {
      print('✅ Controllers initialized');
      print('✅ Animations initialized');
      print('✅ Chat state initialized');
      print('✅ Speech service initialized');
    }
    
    _controllers.initialize();
    _animations.initialize();
    
    if (kDebugMode) {
      print('🎬 All components initialized successfully');
    }
  }

  /// إعداد البيانات الأولية
  Future<void> _setupInitialData() async {
    if (kDebugMode) {
      print('📊 Setting up initial data...');
    }
    
    await Future.wait([
      _initializeSpeechService(),
      _requestInitialPermissions(),
      _loadInputHistory(),
    ]);
    
    if (kDebugMode) {
      print('✅ Initial data setup completed');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      print('🧹 Disposing MainChatPage...');
    }
    
    _controllers.dispose();
    _animations.dispose();
    
    if (kDebugMode) {
      print('✅ MainChatPage disposed successfully');
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              key: _controllers.scaffoldKey,
              appBar: ChatAppBar(
                controllers: _controllers,
                animations: _animations,
                chatState: _chatState,
              ),
              drawer: const ChatDrawer(),
              body: _buildBody(themeProvider),
            );
          },
        ),
      ),
    );
  }

  /// بناء جسم الصفحة الرئيسي
  Widget _buildBody(ThemeProvider themeProvider) {
    return Container(
      decoration: _buildBackgroundDecoration(themeProvider),
      child: Column(
        children: [
          _buildModelInfoBar(),
          _buildThinkingProcessDisplay(),
          _buildMainContent(),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// بناء خلفية الصفحة
  BoxDecoration? _buildBackgroundDecoration(ThemeProvider themeProvider) {
    if (!themeProvider.hasCustomBackground) return null;
    
    return BoxDecoration(
      image: DecorationImage(
        image: FileImage(themeProvider.getCustomBackgroundFile()!),
        fit: BoxFit.cover,
      ),
    );
  }

  /// بناء شريط معلومات النموذج
  Widget _buildModelInfoBar() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return _ModelInfoBar(
          selectedModel: settings.selectedModel,
          animations: _animations,
        );
      },
    );
  }

  /// بناء عرض عملية التفكير
  Widget _buildThinkingProcessDisplay() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (!chatProvider.isThinking || chatProvider.currentThinking == null) {
          return const SizedBox.shrink();
        }

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: ThinkingProcessWidget(
              thinkingProcess: chatProvider.currentThinking!,
            ),
          ),
        );
      },
    );
  }

  /// بناء المحتوى الرئيسي
  Widget _buildMainContent() {
    return Expanded(
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.messages.isEmpty) {
            return ChatWelcomeScreen(
              controllers: _controllers,
              animations: _animations,
            );
          }

          return ChatMessageList(
            scrollController: _controllers.scrollController,
            messages: chatProvider.messages,
          );
        },
      ),
    );
  }

  /// بناء منطقة الإدخال
  Widget _buildInputArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAttachmentsPreview(),
        ChatInputArea(
          controllers: _controllers,
          animations: _animations,
          chatState: _chatState,
          speechService: _speechService,
          onSendMessage: _sendMessage,
        ),
      ],
    );
  }

  /// بناء معاينة المرفقات
  Widget _buildAttachmentsPreview() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.attachments.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: AttachmentPreview(
            attachments: chatProvider.attachments,
            onRemove: chatProvider.removeAttachment,
          ),
        );
      },
    );
  }

  // =============== Core Methods ===============

  /// تهيئة خدمة التعرف على الصوت
  Future<void> _initializeSpeechService() async {
    if (kDebugMode) {
      print('🎤 Initializing speech service...');
    }
    
    try {
      final available = await _speechService.initialize();
      if (mounted) {
        _chatState.setSpeechEnabled(available);
        if (kDebugMode) {
          print('✅ Speech service initialized: $available');
        }
      }
    } catch (e) {
      _handleError('Speech service initialization failed', e);
      if (mounted) {
        _chatState.setSpeechEnabled(false);
        if (kDebugMode) {
          print('❌ Speech service failed: $e');
        }
      }
    }
  }

  /// طلب الأذونات المطلوبة
  Future<void> _requestInitialPermissions() async {
    if (kDebugMode) {
      print('🔐 Requesting initial permissions...');
    }
    
    try {
      final permissionsManager = PermissionsManager();
      await permissionsManager.checkAndRequestAllPermissions(context);
      if (kDebugMode) {
        print('✅ Permissions requested successfully');
      }
    } catch (e) {
      _handleError('Permissions request failed', e);
      if (kDebugMode) {
        print('❌ Permissions failed: $e');
      }
    }
  }

  /// تحميل تاريخ الرسائل
  Future<void> _loadInputHistory() async {
    if (_chatState.historyLoaded) return;

    if (kDebugMode) {
      print('📚 Loading input history...');
    }
    
    try {
      final chatProvider = context.read<ChatProvider>();
      final history = await chatProvider.getInputHistory();
      _chatState.updateMessageHistory(history);
      if (kDebugMode) {
        print('✅ Input history loaded: ${history.length} items');
      }
    } catch (e) {
      _handleError('Error loading message history', e);
      if (kDebugMode) {
        print('❌ History loading failed: $e');
      }
    }
  }

  /// إرسال رسالة
  void _sendMessage(String content, {List<XFile>? attachedImages}) async {
    if (content.trim().isEmpty) return;

    if (kDebugMode) {
      print('📤 Sending message: ${content.substring(0, content.length > 50 ? 50 : content.length)}...');
      if (attachedImages != null && attachedImages.isNotEmpty) {
        print('📎 With ${attachedImages.length} attached images');
      }
    }

    _chatState.resetHistory();

    // إضافة الصور المرفقة إلى ChatProvider قبل إرسال الرسالة
    if (attachedImages != null && attachedImages.isNotEmpty) {
      try {
        // إظهار مؤشر تحميل
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('جاري معالجة ${attachedImages.length} صورة...'),
                ],
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }

        final chatProvider = context.read<ChatProvider>();
        for (final image in attachedImages) {
          await _addImageAttachment(chatProvider, image);
        }

        // إخفاء مؤشر التحميل
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }

      } catch (e) {
        if (kDebugMode) {
          print('❌ Error processing images: $e');
        }

        // إخفاء مؤشر التحميل وإظهار رسالة خطأ
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في معالجة الصور: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return; // إيقاف الإرسال في حالة الخطأ
      }
    }

    context.read<ChatProvider>().sendMessage(
      content,
      settingsProvider: context.read<SettingsProvider>(),
    );

    _scrollToBottom();

    if (kDebugMode) {
      print('✅ Message sent successfully');
    }
  }

  /// إضافة صورة كمرفق إلى ChatProvider
  Future<void> _addImageAttachment(ChatProvider chatProvider, XFile image) async {
    try {
      if (kDebugMode) {
        print('🔄 Adding image attachment: ${image.name}');
      }

      await chatProvider.addImageAttachment(image);

      if (kDebugMode) {
        print('✅ Successfully added image attachment: ${image.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error adding image attachment: $e');
      }

      // إظهار رسالة خطأ للمستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة الصورة: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // لا نرمي الخطأ مرة أخرى لتجنب crash التطبيق
    }
  }

  /// التمرير إلى الأسفل
  void _scrollToBottom() {
    if (kDebugMode) {
      print('📜 Scrolling to bottom...');
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controllers.scrollController.hasClients) {
        _controllers.scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        if (kDebugMode) {
          print('✅ Scrolled to bottom successfully');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ Scroll controller not ready');
        }
      }
    });
  }

  /// معالجة الأخطاء
  void _handleError(String message, dynamic error) {
    if (kDebugMode) {
      print('❌ Error: $message');
      print('🔍 Details: $error');
      print('📍 Stack trace: ${StackTrace.current}');
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'موافق',
            onPressed: () {},
          ),
        ),
      );
    }
  }
}

// =============== Helper Classes ===============

/// كلاس لإدارة جميع الـ Controllers
class _ChatControllers {
  late final TextEditingController messageController;
  late final ScrollController scrollController;
  late final FocusNode textFieldFocusNode;
  late final GlobalKey<ScaffoldState> scaffoldKey;

  void initialize() {
    if (kDebugMode) {
      print('🎮 Initializing chat controllers...');
    }
    
    messageController = TextEditingController();
    scrollController = ScrollController();
    textFieldFocusNode = FocusNode();
    scaffoldKey = GlobalKey<ScaffoldState>();
    
    if (kDebugMode) {
      print('✅ Chat controllers initialized successfully');
    }
  }

  void dispose() {
    if (kDebugMode) {
      print('🧹 Disposing chat controllers...');
    }
    
    messageController.dispose();
    scrollController.dispose();
    textFieldFocusNode.dispose();
    
    if (kDebugMode) {
      print('✅ Chat controllers disposed successfully');
    }
  }
}

/// كلاس لإدارة جميع الرسوم المتحركة
class _ChatAnimations {
  final TickerProviderStateMixin _vsync;
  
  late final AnimationController fadeController;
  late final AnimationController slideController;
  late final AnimationController glowController;
  late final AnimationController waveController;
  
  late final Animation<double> fadeAnimation;
  late final Animation<Offset> slideAnimation;
  late final Animation<double> waveAnimation;

  _ChatAnimations(this._vsync);

  void initialize() {
    if (kDebugMode) {
      print('🎬 Initializing chat animations...');
    }
    
    // Animation Controllers
    fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: _vsync,
    );
    
    slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: _vsync,
    );
    
    glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: _vsync,
    )..repeat(reverse: true);

    waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: _vsync,
    );

    // Animations
    fadeAnimation = Tween<double>(
      begin: 0.0, 
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: fadeController, 
      curve: Curves.easeInOut,
    ));

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: slideController, 
      curve: Curves.elasticOut,
    ));

    waveAnimation = Tween<double>(
      begin: 0.0, 
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: waveController, 
      curve: Curves.easeInOut,
    ));

    // Start animations
    fadeController.forward();
    slideController.forward();
    
    if (kDebugMode) {
      print('✅ Chat animations initialized successfully');
    }
  }

  void dispose() {
    if (kDebugMode) {
      print('🧹 Disposing chat animations...');
    }
    
    fadeController.dispose();
    slideController.dispose();
    glowController.dispose();
    waveController.dispose();
    
    if (kDebugMode) {
      print('✅ Chat animations disposed successfully');
    }
  }
}

/// كلاس لإدارة حالة المحادثة
class _ChatState {
  final List<String> _messageHistory = [];
  int _historyIndex = -1;
  bool _historyLoaded = false;
  bool _isListening = false;
  bool _speechEnabled = false;

  // Getters
  List<String> get messageHistory => _messageHistory;
  int get historyIndex => _historyIndex;
  bool get historyLoaded => _historyLoaded;
  bool get isListening => _isListening;
  bool get speechEnabled => _speechEnabled;

  // Setters
  void setHistoryIndex(int index) {
    if (kDebugMode) {
      print('📊 Setting history index: $index');
    }
    _historyIndex = index;
  }

  String? getNextHistoryItem() {
    if (_messageHistory.isEmpty || _historyIndex >= _messageHistory.length - 1) {
      if (kDebugMode) {
        print('⚠️ No next history item available');
      }
      return null;
    }
    _historyIndex++;
    if (kDebugMode) {
      print('➡️ Next history item: ${_messageHistory[_historyIndex]}');
    }
    return _messageHistory[_historyIndex];
  }

  String? getPreviousHistoryItem() {
    if (_messageHistory.isEmpty || _historyIndex <= 0) {
      if (kDebugMode) {
        print('⚠️ No previous history item available');
      }
      return null;
    }
    _historyIndex--;
    if (kDebugMode) {
      print('⬅️ Previous history item: ${_messageHistory[_historyIndex]}');
    }
    return _messageHistory[_historyIndex];
  }

  void setListening(bool listening) {
    if (kDebugMode) {
      print('🎤 Setting listening state: $listening');
    }
    _isListening = listening;
  }
  
  void setSpeechEnabled(bool enabled) {
    if (kDebugMode) {
      print('🔊 Setting speech enabled: $enabled');
    }
    _speechEnabled = enabled;
  }

  void updateMessageHistory(List<String> history) {
    if (kDebugMode) {
      print('📚 Updating message history: ${history.length} items');
    }
    _messageHistory.clear();
    _messageHistory.addAll(history);
    _historyLoaded = true;
  }

  void resetHistory() {
    if (kDebugMode) {
      print('🔄 Resetting history');
    }
    _historyIndex = -1;
    _historyLoaded = false;
  }
}

/// شريط معلومات النموذج
class _ModelInfoBar extends StatelessWidget {
  final String selectedModel;
  final _ChatAnimations animations;

  const _ModelInfoBar({
    required this.selectedModel,
    required this.animations,
  });

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🏷️ Building model info bar for: $selectedModel');
    }
    
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(
        horizontal: 16, 
        vertical: 1,
      ),
      decoration: _buildDecoration(context),
      child: Row(
        children: [
          _buildModelIcon(context),
          const SizedBox(height: 8),
          _buildModelInfo(context),
          _buildConnectionStatus(context),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
          Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildModelIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _getProviderIcon(selectedModel),
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildModelInfo(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'النموذج النشط',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getModelDisplayName(selectedModel),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  IconData _getProviderIcon(String model) {
    if (model.contains('groq')) return Icons.flash_on;
    if (model.contains('gpt')) return Icons.psychology;
    if (model.contains('openrouter')) return Icons.route;
    return Icons.smart_toy;
  }

  String _getModelDisplayName(String model) {
    // إضافة منطق لعرض اسم النموذج بطريقة جميلة
    if (model.contains('/')) {
      return model.split('/').last;
    }
    return model;
  }
}
