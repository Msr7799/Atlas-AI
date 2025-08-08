import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// إزالة استيراد Google Fonts
// import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// Enhanced UI Components - استخدام classes وهمية مؤقتاً
// import 'package:speech_to_text/speech_to_text.dart';
// import 'package:flutter_tts/flutter_tts.dart';
import '../../core/utils/speech_stub.dart';

import 'package:flutter_animate/flutter_animate.dart';
// تغيير من gradient_theme إلى app_theme
import '../../core/theme/app_theme.dart';

import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/prompt_enhancer_provider.dart';
import '../providers/chat_selection_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/thinking_process_widget.dart';
import '../widgets/attachment_preview.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/debug_panel.dart';
import '../widgets/prompt_enhancement_dialog.dart';

import 'model_training_page.dart';
import '../../core/widgets/optimized_widgets.dart';
import '../../core/utils/memory_manager.dart';
import '../../core/utils/performance_monitor.dart';
import '../../data/models/message_model.dart';
import 'api_settings_page.dart';
import '../../core/services/permissions_manager.dart';

class MainChatPage extends StatefulWidget {
  const MainChatPage({super.key});

  @override
  State<MainChatPage> createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage>
    with
        TickerProviderStateMixin,
        MemoryOptimizedMixin,
        PerformanceMonitoringMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _textFieldFocusNode = FocusNode();
  List<String> _messageHistory = [];
  int _historyIndex = -1;
  bool _historyLoaded = false;

  // Animation Controllers for Enhanced UI
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  // Enhanced UI State
  final bool _showQuickActions = false;

  // Voice Input State
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  bool _speechEnabled = false;

  // Enhanced Visual Effects
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInputHistory();
    _requestInitialPermissions();

    // تسجيل Controllers في memory manager لإدارة أفضل للذاكرة
    registerTextController('message', _messageController);
    registerScrollController('scroll', _scrollController);
    registerFocusNode('textField', _textFieldFocusNode);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Wave animation for voice input
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // تسجيل AnimationControllers في memory manager
    registerAnimationController('fade', _fadeController);
    registerAnimationController('slide', _slideController);
    registerAnimationController('glow', _glowController);
    registerAnimationController('wave', _waveController);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Start initial animations
    _fadeController.forward();
    _slideController.forward();

    // Initialize voice input
    _initializeSpeech();
  }

  // Initialize speech recognition
  void _initializeSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onStatus: (val) => print('Speech Status: $val'),
        onError: (val) => print('Speech Error: $val'),
      );
    } catch (e) {
      print('Speech initialization error: $e');
      _speechEnabled = false;
    }

    // Configure TTS with error handling
    try {
      await _flutterTts.setLanguage('ar-SA');
      await _flutterTts.setSpeechRate(0.8);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      print('TTS configuration error: $e');
      // TTS غير مدعوم على هذا النظام، يمكن المتابعة بدونه
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _glowController.dispose();
    _waveController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  // طلب الأذونات المطلوبة عند بدء التطبيق
  Future<void> _requestInitialPermissions() async {
    final permissionsManager = PermissionsManager();
    await permissionsManager.checkAndRequestAllPermissions();
  }

  // Voice Input Methods
  void _toggleVoiceInput() async {
    if (_isListening) {
      await _speechToText.stop();
      _waveController.stop();
      setState(() => _isListening = false);
    } else {
      if (_speechEnabled) {
        setState(() => _isListening = true);
        _waveController.repeat(reverse: true);
        await _speechToText.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
            });
            if (result.finalResult) {
              _waveController.stop();
              setState(() => _isListening = false);
            }
          },
          localeId: 'ar-SA',
        );
      }
    }
  }

  Widget _buildVoiceWaveAnimation() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 12),
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(15, (index) {
              final height =
                  20 +
                  (30 *
                      (0.5 +
                          0.5 *
                              (index % 2 == 0
                                  ? _waveAnimation.value
                                  : 1 - _waveAnimation.value)));
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.gradientStart.withOpacity(
                        0.8,
                      ), // تغيير من GradientTheme إلى AppTheme
                      AppTheme.gradientAccent.withOpacity(
                        0.6,
                      ), // تغيير من GradientTheme إلى AppTheme
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    ).animate().fadeIn();
  }

  void _navigateToTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ModelTrainingPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        drawer: const ChatDrawer(),
        body: Column(
          children: [
            // Debug Model Display
            // Model Info Bar - محسن وأنيق
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.8),
                        Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.4),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // أيقونة النموذج
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getProviderIcon(settings.selectedModel),
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      OptimizedWidgets.space8,
                      // معلومات النموذج
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'النموذج النشط',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getModelDisplayName(settings.selectedModel),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // حالة الاتصال
                      Container(
                        width: 8,
                        height: 8,
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
                      ),
                    ],
                  ),
                );
              },
            ),

            // Thinking Process Display
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isThinking &&
                    chatProvider.currentThinking != null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    color: Theme.of(context).colorScheme.surface,
                    child: ThinkingProcessWidget(
                      thinkingProcess: chatProvider.currentThinking!,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Messages List
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  if (chatProvider.messages.isEmpty) {
                    return _buildWelcomeScreen();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider
                          .messages[chatProvider.messages.length - 1 - index];
                      return MessageBubble(
                        message: message,
                        isUser: message.role == MessageRole.user,
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
                    },
                  );
                },
              ),
            ),

            // Attachments Preview
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.attachments.isNotEmpty) {
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
                }
                return const SizedBox.shrink();
              },
            ),

            // Quick Actions (when messages are empty)
            Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.messages.isEmpty && _showQuickActions) {
                  return _buildQuickActions();
                }
                return const SizedBox.shrink();
              },
            ),

            // Input Area
            _buildEnhancedInputArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.gradientStart.withOpacity(
                0.8,
              ), // تغيير من GradientTheme إلى AppTheme
              AppTheme.gradientEnd.withOpacity(
                0.6,
              ), // تغيير من GradientTheme إلى AppTheme
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.gradientStart.withOpacity(
                      _glowAnimation.value * 0.3,
                    ), // تغيير من GradientTheme إلى AppTheme
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Row(
            children: [
              // أيقونة التطبيق
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gradientStart.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/app_icon1.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain, // تغيير لإظهار الأيقونة بوضوح
                    errorBuilder: (context, error, stackTrace) {
                      // في حالة عدم وجود الصورة، استخدم أيقونة افتراضية
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.gradientStart,
                              AppTheme.gradientEnd,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // العنوان محسن
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'العميل العربي الذكي',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    // عرض النموذج المختار في الهيدر
                    Consumer<SettingsProvider>(
                      builder: (context, settings, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getModelDisplayName(settings.selectedModel),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Chat Selection and Export Actions
        Consumer<ChatSelectionProvider>(
          builder: (context, selectionProvider, child) {
            if (selectionProvider.isSelectionMode) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cancel Selection
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      selectionProvider.disableSelectionMode();
                    },
                    tooltip: 'إلغاء التحديد',
                  ),
                  // Select All / Deselect All
                  IconButton(
                    icon: Icon(
                      selectionProvider.selectedMessageIds.isEmpty
                          ? Icons.select_all
                          : Icons.deselect,
                    ),
                    onPressed: () {
                      final chatProvider = context.read<ChatProvider>();
                      if (selectionProvider.selectedMessageIds.isEmpty) {
                        // Select all messages
                        for (final message in chatProvider.messages) {
                          selectionProvider.selectMessage(message.id);
                        }
                      } else {
                        // Deselect all
                        selectionProvider.disableSelectionMode();
                      }
                    },
                    tooltip: selectionProvider.selectedMessageIds.isEmpty
                        ? 'تحديد الكل'
                        : 'إلغاء تحديد الكل',
                  ),
                  // Export Selected - الآن في الـ Drawer
                  // Show count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${selectionProvider.selectedMessageIds.length}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              );
            } else {
              return const SizedBox.shrink(); // التصدير متاح الآن في الـ Drawer
            }
          },
        ),

        // Debug Toggle
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return IconButton(
              icon: Icon(
                Icons.bug_report,
                color: chatProvider.debugMode
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              onPressed: () {
                chatProvider.toggleDebugMode();
                if (chatProvider.debugMode) {
                  _showDebugPanel();
                }
              },
              tooltip: 'وضع التشخيص',
            );
          },
        ),

        // Web Search
        Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            return IconButton(
              icon: Icon(
                Icons.search,
                color: settingsProvider.enableWebSearch
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).disabledColor,
              ),
              onPressed: settingsProvider.enableWebSearch
                  ? () => _showSearchDialog()
                  : null,
              tooltip: 'البحث في الويب',
            );
          },
        ),

        // Theme Toggle
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: themeProvider.toggleTheme,
              tooltip: 'تبديل المظهر',
            );
          },
        ),

        // Settings
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => _showSettingsDialog(),
          tooltip: 'الإعدادات',
        ),

        // Model Training
        IconButton(
          icon: const Icon(Icons.model_training),
          onPressed: () => _navigateToTraining(),
          tooltip: 'تدريب النموذج',
        ),

        // New Chat
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            context.read<ChatProvider>().createNewSession();
          },
          tooltip: 'محادثة جديدة',
        ),

        // API Settings - إعدادات API
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ApiSettingsPage()),
            );
          },
          icon: const Icon(Icons.api),
          tooltip: 'إعدادات API',
        ),
      ],
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ).animate().scale(duration: 1000.ms),
          const SizedBox(height: 24),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.headlineSmall!,
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'مرحباً بك في العميل العربي الذكي',
                  speed: const Duration(milliseconds: 100),
                ),
                TypewriterAnimatedText(
                  'كيف يمكنني مساعدتك اليوم؟',
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              isRepeatingAnimation: true,
              pause: const Duration(seconds: 3),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSuggestionChip('اسأل سؤالاً'),
              _buildSuggestionChip('اطلب مساعدة في البرمجة'),
              _buildSuggestionChip('ابحث في الويب'),
              _buildSuggestionChip('حلل ملف'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      side: BorderSide(color: Theme.of(context).colorScheme.outline),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      _QuickAction(
        icon: Icons.code,
        label: 'كتابة كود',
        color: const Color(0xFF6C63FF),
        prompt: 'اكتب لي كود بلغة Python لـ',
      ),
      _QuickAction(
        icon: Icons.translate,
        label: 'ترجمة',
        color: const Color(0xFF00BFA5),
        prompt: 'ترجم لي النص التالي:',
      ),
      _QuickAction(
        icon: Icons.school,
        label: 'شرح مفهوم',
        color: const Color(0xFFFF6B6B),
        prompt: 'اشرح لي مفهوم',
      ),
      _QuickAction(
        icon: Icons.analytics,
        label: 'تحليل بيانات',
        color: const Color(0xFFFFA726),
        prompt: 'حلل لي البيانات التالية:',
      ),
      _QuickAction(
        icon: Icons.psychology,
        label: 'Fine-Tuning',
        color: const Color(0xFF9C27B0),
        prompt: 'ساعدني في fine-tuning نموذج',
      ),
      _QuickAction(
        icon: Icons.bug_report,
        label: 'حل مشكلة',
        color: const Color(0xFF795548),
        prompt: 'ساعدني في حل المشكلة:',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              'إجراءات سريعة',
              style: TextStyle(
                // استخدام TextStyle بدلاً من GoogleFonts
                fontFamily: context.watch<ThemeProvider>().fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return SlideTransition(
                  position: _slideAnimation,
                  child: _buildQuickActionCard(action, index),
                ).animate(delay: (index * 100).ms).fadeIn().scale();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(_QuickAction action, int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          _messageController.text = action.prompt;
          _textFieldFocusNode.requestFocus();
        },
        child: AppTheme.gradientContainer(
          // تغيير من GradientTheme إلى AppTheme
          padding: const EdgeInsets.all(12),
          borderRadius: 16,
          colors: [
            action.color.withOpacity(0.1),
            action.color.withOpacity(0.05),
          ],
          blur: 8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(action.icon, color: action.color, size: 24),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 2000.ms,
                    color: action.color.withOpacity(0.3),
                  ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: TextStyle(
                  // استخدام TextStyle بدلاً من GoogleFonts
                  fontFamily: context.watch<ThemeProvider>().fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme
                      .gradientText, // تغيير من GradientTheme إلى AppTheme
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedInputArea() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.gradientSurface.withOpacity(
                  0.8,
                ), // تغيير من GradientTheme إلى AppTheme
                AppTheme.gradientBackground.withOpacity(
                  0.9,
                ), // تغيير من GradientTheme إلى AppTheme
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border(
              top: BorderSide(
                color: AppTheme.gradientStart.withOpacity(
                  _glowAnimation.value * 0.5,
                ), // تغيير من GradientTheme إلى AppTheme
                width: 2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.gradientStart.withOpacity(
                  _glowAnimation.value * 0.2,
                ), // تغيير من GradientTheme إلى AppTheme
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Voice Wave Animation when listening
                if (_isListening) _buildVoiceWaveAnimation(),

                // Enhanced Input Container
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.gradientStart.withOpacity(
                          0.8,
                        ), // تغيير من GradientTheme إلى AppTheme
                        AppTheme.gradientEnd.withOpacity(
                          0.6,
                        ), // تغيير من GradientTheme إلى AppTheme
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gradientStart.withOpacity(
                          _glowAnimation.value * 0.3,
                        ), // تغيير من GradientTheme إلى AppTheme
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Attachment Button
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () {
                            context.read<ChatProvider>().addAttachment();
                          },
                          tooltip: 'إرفاق ملف',
                        ),

                        // Prompt Enhancement Button
                        Consumer<PromptEnhancerProvider>(
                          builder: (context, enhancerProvider, child) {
                            return Container(
                              decoration: enhancerProvider.isEnhancing
                                  ? BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : null,
                              child: IconButton(
                                icon: enhancerProvider.isEnhancing
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.auto_fix_high,
                                        color:
                                            _messageController.text
                                                .trim()
                                                .isEmpty
                                            ? Theme.of(context).disabledColor
                                            : Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                      ),
                                onPressed:
                                    (_messageController.text.trim().isEmpty ||
                                        enhancerProvider.isEnhancing)
                                    ? null
                                    : () => _enhancePrompt(),
                                tooltip: enhancerProvider.isEnhancing
                                    ? 'جاري تحسين البرومبت...'
                                    : 'تحسين البرومبت بالذكاء الاصطناعي',
                              ),
                            );
                          },
                        ),

                        // Message Input Field
                        Expanded(
                          child: Consumer<PromptEnhancerProvider>(
                            builder: (context, enhancerProvider, child) {
                              return Stack(
                                children: [
                                  KeyboardListener(
                                    focusNode: FocusNode(),
                                    onKeyEvent: (KeyEvent event) {
                                      if (event is KeyDownEvent) {
                                        // Navigate message history with arrow keys
                                        if (event.logicalKey ==
                                            LogicalKeyboardKey.arrowUp) {
                                          _navigateHistory(true);
                                        } else if (event.logicalKey ==
                                            LogicalKeyboardKey.arrowDown) {
                                          _navigateHistory(false);
                                        }
                                        // Send message with Enter (not Shift+Enter)
                                        else if (event.logicalKey ==
                                                LogicalKeyboardKey.enter &&
                                            !HardwareKeyboard
                                                .instance
                                                .isShiftPressed) {
                                          if (_messageController.text
                                              .trim()
                                              .isNotEmpty) {
                                            _sendMessage(
                                              _messageController.text,
                                            );
                                          }
                                        }
                                      }
                                    },
                                    child: TextField(
                                      controller: _messageController,
                                      focusNode: _textFieldFocusNode,
                                      minLines: 1,
                                      maxLines: 8,
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      enabled: !enhancerProvider.isEnhancing,
                                      onChanged: (value) {
                                        // Reset history navigation when user types
                                        _historyIndex = -1;
                                      },
                                      onSubmitted: (value) {
                                        // Safe handling for submit action
                                        if (value.trim().isNotEmpty) {
                                          try {
                                            _sendMessage(value);
                                          } catch (e) {
                                            print('[SUBMIT ERROR] $e');
                                          }
                                        }
                                      },
                                      decoration: InputDecoration(
                                        hintText: enhancerProvider.isEnhancing
                                            ? 'جاري تحسين البرومبت باستخدام الذكاء الاصطناعي...'
                                            : _isListening
                                            ? 'أستمع...'
                                            : 'اكتب رسالتك هنا...\n\nEnter للإرسال، Shift+Enter لسطر جديد\n↑↓ للتنقل في الرسائل السابقة',
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  enhancerProvider.isEnhancing
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.7)
                                                  : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.5),
                                              fontStyle:
                                                  enhancerProvider.isEnhancing
                                                  ? FontStyle.italic
                                                  : FontStyle.normal,
                                            ),
                                        filled: true,
                                        fillColor: enhancerProvider.isEnhancing
                                            ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.05)
                                            : Colors.transparent,
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.only(
                                          right: 12,
                                          left: 40, // مساحة إضافية للسبنر
                                          top: 16,
                                          bottom: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Spinner overlay عندما يكون التحسين جارياً
                                  if (enhancerProvider.isEnhancing)
                                    Positioned(
                                      left: 12,
                                      top: 16,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),

                        // Voice Input Button
                        if (_speechEnabled)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? [Colors.red, Colors.red.shade700]
                                    : [
                                        AppTheme.gradientStart,
                                        AppTheme.gradientAccent,
                                      ], // تغيير من GradientTheme إلى AppTheme
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_isListening
                                              ? Colors.red
                                              : AppTheme.gradientStart)
                                          .withOpacity(
                                            0.4,
                                          ), // تغيير من GradientTheme إلى AppTheme
                                  blurRadius: _isListening ? 8 : 4,
                                  spreadRadius: _isListening ? 2 : 0,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _toggleVoiceInput,
                              icon: Icon(
                                _isListening ? Icons.stop : Icons.mic,
                                color: Colors.white,
                              ),
                              tooltip: _isListening
                                  ? 'إيقاف التسجيل'
                                  : 'الإدخال الصوتي',
                            ),
                          ).animate().scale(duration: 300.ms),

                        // Send Button - محسن وكلاسيكي
                        Consumer<ChatProvider>(
                          builder: (context, chatProvider, child) {
                            return Container(
                              margin: const EdgeInsets.only(left: 8),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap:
                                      chatProvider.isTyping ||
                                          _messageController.text.trim().isEmpty
                                      ? null
                                      : () => _sendMessage(
                                          _messageController.text,
                                        ),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient:
                                          (chatProvider.isTyping ||
                                              _messageController.text
                                                  .trim()
                                                  .isEmpty)
                                          ? LinearGradient(
                                              colors: [
                                                Colors.grey.withOpacity(0.3),
                                                Colors.grey.withOpacity(0.2),
                                              ],
                                            )
                                          : LinearGradient(
                                              colors: [
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.8),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow:
                                          (chatProvider.isTyping ||
                                              _messageController.text
                                                  .trim()
                                                  .isEmpty)
                                          ? null
                                          : [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                    ),
                                    child: Center(
                                      child: chatProvider.isTyping
                                          ? SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(
                                                      Colors.white.withOpacity(
                                                        0.8,
                                                      ),
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.send,
                                              color:
                                                  (_messageController.text
                                                      .trim()
                                                      .isEmpty)
                                                  ? Colors.white.withOpacity(
                                                      0.5,
                                                    )
                                                  : Colors.white,
                                              size: 20,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadMessageHistory() async {
    if (_historyLoaded) return;

    try {
      final chatProvider = context.read<ChatProvider>();
      _messageHistory = await chatProvider.getInputHistory();
      _historyLoaded = true;
    } catch (e) {
      print('Error loading message history: $e');
      _messageHistory = [];
    }
  }

  Future<void> _navigateHistory(bool up) async {
    // Load history if not loaded yet
    if (!_historyLoaded) {
      await _loadMessageHistory();
    }

    if (_messageHistory.isEmpty) return;

    if (up) {
      if (_historyIndex < _messageHistory.length - 1) {
        _historyIndex++;
        _messageController.text = _messageHistory[_historyIndex];
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
      }
    } else {
      if (_historyIndex > 0) {
        _historyIndex--;
        _messageController.text = _messageHistory[_historyIndex];
        _messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: _messageController.text.length),
        );
      } else if (_historyIndex == 0) {
        _historyIndex = -1;
        _messageController.clear();
      }
    }
  }

  void _sendMessage(String content) {
    performanceMonitor.measureSync('send_message', () {
      if (content.trim().isEmpty) return;

      // Reset history navigation
      _historyIndex = -1;
      _historyLoaded = false; // Force reload of history next time

      // Send message through ChatProvider with settings (it will handle database storage)
      context.read<ChatProvider>().sendMessage(
        content,
        settingsProvider: context.read<SettingsProvider>(),
      );
      _messageController.clear();

      // Auto scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في الويب'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'أدخل استعلام البحث...'),
          onSubmitted: (query) {
            Navigator.pop(context);
            context.read<ChatProvider>().searchWeb(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(context: context, builder: (context) => const SettingsDialog());
  }

  void _showDebugPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const DebugPanel(),
    );
  }

  // Helper methods for model display
  String _getModelDisplayName(String modelId) {
    switch (modelId) {
      case 'gemma2-9b-it':
        return 'Gemma2 9B IT';
      case 'llama-3.1-70b-versatile':
        return 'Llama 3.1 70B';
      case 'mixtral-8x7b-32768':
        return 'Mixtral 8x7B';
      case 'gpt-3.5-turbo':
        return 'GPT-3.5 Mini Turbo';
      default:
        return modelId;
    }
  }

  IconData _getProviderIcon(String modelId) {
    if (modelId == 'gpt-3.5-turbo') {
      return Icons.psychology; // أيقونة مختلفة لـ GPT
    } else {
      return Icons.memory; // أيقونة Groq
    }
  }

  // Load input history method (was called in initState)
  Future<void> _loadInputHistory() async {
    if (_historyLoaded) return;

    try {
      final chatProvider = context.read<ChatProvider>();
      _messageHistory = await chatProvider.getInputHistory();
      _historyLoaded = true;
    } catch (e) {
      print('Error loading input history: $e');
      _messageHistory = [];
    }
  }

  void _enhancePrompt() async {
    final currentText = _messageController.text.trim();
    if (currentText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى إدخال نص أولاً لتحسينه')),
        );
      }
      return;
    }

    try {
      final enhancerProvider = context.read<PromptEnhancerProvider>();
      final chatProvider = context.read<ChatProvider>();

      // جمع تاريخ المحادثة
      final conversationHistory = chatProvider.messages;

      // استدعاء خدمة التحسين
      final result = await enhancerProvider.enhancePrompt(
        originalPrompt: currentText,
        conversationHistory: conversationHistory,
      );

      if (result != null && mounted) {
        // عرض حوار التحسين
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => PromptEnhancementDialog(
            result: result,
            onUseEnhanced: (enhancedText) {
              // إغلاق الحوار أولاً
              Navigator.of(dialogContext).pop();
              // ثم تحديث النص إذا كان Widget ما زال موجوداً
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _messageController.text = enhancedText;
                  });
                }
              });
            },
            onUseOriginal: (originalText) {
              // إغلاق الحوار فقط - النص الأصلي موجود بالفعل
              Navigator.of(dialogContext).pop();
            },
            onUseCustom: (customText) {
              // إغلاق الحوار أولاً
              Navigator.of(dialogContext).pop();
              // ثم تحديث النص إذا كان Widget ما زال موجوداً
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _messageController.text = customText;
                  });
                }
              });
            },
          ),
        );
      } else if (enhancerProvider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تحسين النص: يرجى المحاولة مرة أخرى'),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              onPressed: () => _enhancePrompt(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ غير متوقع: $e')));
      }
    }
  }
}

// Helper class for Quick Actions
class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String prompt;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.prompt,
  });
}
