import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// إزالة استيراد Google Fonts
// import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

// Enhanced UI Components - استخدام الخدمات الحقيقية
import '../../core/services/speech_service.dart';

import 'package:flutter_animate/flutter_animate.dart';
// تغيير من gradient_theme إلى app_theme
import '../../core/theme/app_theme.dart';

import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/prompt_enhancer_provider.dart';
import '../providers/chat_selection_provider.dart';
import '../widgets/chat_drawer.dart';
import '../widgets/message_bubble.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/thinking_process_widget.dart';
import '../widgets/attachment_preview.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/debug_panel.dart';
import '../widgets/prompt_enhancement_dialog.dart';
import '../widgets/language_selector_widget.dart';
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
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _speechEnabled = false;

  // Enhanced Visual Effects
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInputHistory();
    _requestInitialPermissions();
    _initializeSpeechService();

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
  }

  // Initialize speech service
  Future<void> _initializeSpeechService() async {
    try {
      final available = await _speechService.initialize();
      setState(() {
        _speechEnabled = available;
      });
    } catch (e) {
      print('Speech service initialization failed: $e');
      setState(() {
        _speechEnabled = false;
      });
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
      await _speechService.stopListening();
      _waveController.stop();
      setState(() => _isListening = false);
    } else {
      if (_speechEnabled) {
        setState(() => _isListening = true);
        _waveController.repeat(reverse: true);
        await _speechService.startListening(
          onResult: (result) {
            setState(() {
              _messageController.text = result;
            });
            if (!_speechService.isListening) {
              _waveController.stop();
              setState(() => _isListening = false);
            }
          },
        );
      }
    }
  }

  void _startVoiceRecording() async {
    if (!_speechEnabled) return;
    
    setState(() => _isListening = true);
    _waveController.repeat(reverse: true);
    
    await _speechService.startListening(
      onResult: (result) {
        setState(() {
          _messageController.text = result;
        });
      },
    );
  }

  void _stopVoiceRecording() async {
    if (!_isListening) return;
    
    await _speechService.stopListening();
    _waveController.stop();
    setState(() => _isListening = false);
    
    // Auto-send if there's text
    if (_messageController.text.trim().isNotEmpty) {
      _sendMessage(_messageController.text);
    }
  }

  void _cancelVoiceRecording() async {
    if (!_isListening) return;
    
    HapticFeedback.heavyImpact();
    await _speechService.stopListening();
    _waveController.stop();
    setState(() {
      _isListening = false;
      _messageController.clear(); // Clear any recognized text
    });
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
          color: Colors.grey[800], // لون رصاصي ثابت
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.primary, // تطبيق لون الثيم على زر الهامبرغر
      ),
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Row(
            children: [
              // إزالة أيقونة التطبيق بالكامل
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
                      builder: (context, settingsProvider, child) {
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
                            _getModelDisplayName(settingsProvider.selectedModel),
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

        // Theme Toggle
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: themeProvider.toggleTheme,
              tooltip: 'تبديل المظهر',
            );
          },
        ),

        // Settings
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => _showSettingsDialog(),
          tooltip: 'الإعدادات',
        ),

        // Model Training
        IconButton(
          icon: Icon(
            Icons.model_training,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => _navigateToTraining(),
          tooltip: 'تدريب النموذج',
        ),

        // New Chat
        IconButton(
          icon: Icon(
            Icons.add_circle_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
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
          icon: Icon(
            Icons.api,
            color: Theme.of(context).colorScheme.primary,
          ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final quickActions = [
      _QuickAction(
        icon: Icons.code,
        label: 'كتابة كود',
        color: colorScheme.primary,
        prompt: 'اكتب لي كود بلغة Python لـ',
      ),
      _QuickAction(
        icon: Icons.translate,
        label: 'ترجمة',
        color: colorScheme.secondary,
        prompt: 'ترجم لي النص التالي:',
      ),
      _QuickAction(
        icon: Icons.school,
        label: 'شرح مفهوم',
        color: colorScheme.tertiary,
        prompt: 'اشرح لي مفهوم',
      ),
      _QuickAction(
        icon: Icons.analytics,
        label: 'تحليل بيانات',
        color: colorScheme.primaryContainer,
        prompt: 'حلل لي البيانات التالية:',
      ),
      _QuickAction(
        icon: Icons.psychology,
        label: 'Fine-Tuning',
        color: colorScheme.secondaryContainer,
        prompt: 'ساعدني في fine-tuning نموذج',
      ),
      _QuickAction(
        icon: Icons.bug_report,
        label: 'حل مشكلة',
        color: colorScheme.error,
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          // زيادة الارتفاع والعرض كما طلب المستخدم
          height: 180, // زيادة الارتفاع من 120 إلى 180
          width: double.infinity, // عرض كامل
          padding: const EdgeInsets.all(20), // زيادة الحشو
          decoration: BoxDecoration(
            color: Colors.grey[800], // لون رصاصي مثل الشريط العلوي
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Voice Wave Animation when listening
              if (_isListening) _buildVoiceWaveAnimation(),

              // شريط الأدوات فوق خانة الكتابة
              Container(
                margin: const EdgeInsets.only(bottom: 12), // زيادة المسافة
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر الإرفاق
                    _buildToolButton(
                      icon: Icons.attach_file,
                      tooltip: 'إرفاق ملف',
                      onPressed: () => context.read<ChatProvider>().addAttachment(),
                    ),
                    
                    // زر البحث في الويب
                    _buildToolButton(
                      icon: Icons.search,
                      tooltip: 'البحث في الويب',
                      onPressed: _showSearchDialog,
                    ),
                    
                    // زر اللغة
                    _buildToolButton(
                      icon: Icons.language,
                      tooltip: 'تغيير لغة التعرف على الصوت',
                      onPressed: _showLanguageSelector,
                    ),
                    
                    // زر المايك
                    Consumer<ChatProvider>(
                      builder: (context, chatProvider, child) {
                        return GestureDetector(
                          onLongPressStart: (details) {
                            if (_speechEnabled) {
                              HapticFeedback.mediumImpact();
                              _startVoiceRecording();
                            }
                          },
                          onLongPressEnd: (details) {
                            if (_isListening) {
                              _stopVoiceRecording();
                            }
                          },
                          onLongPressMoveUpdate: (details) {
                            if (_isListening) {
                              final RenderBox renderBox = context.findRenderObject() as RenderBox;
                              final localPosition = renderBox.globalToLocal(details.globalPosition);
                              
                              if (localPosition.dx < -50) {
                                _cancelVoiceRecording();
                              }
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _isListening ? 56 : 44,
                            height: _isListening ? 56 : 44,
                            decoration: BoxDecoration(
                              gradient: _isListening
                                  ? LinearGradient(
                                      colors: [
                                        Colors.red,
                                        Colors.red.withOpacity(0.8),
                                      ],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                        Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(_isListening ? 28 : 12),
                              boxShadow: _isListening
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.4),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Center(
                              child: chatProvider.isTyping
                                  ? SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.mic,
                                      color: Colors.white,
                                      size: _isListening ? 28 : 20,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // خانة الكتابة المحسنة مع زيادة الحجم
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.gradientStart.withOpacity(0.8),
                        AppTheme.gradientEnd.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12), // تقليل من 24
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : AppTheme.gradientStart)
                            .withOpacity(0.4),
                        blurRadius: _isListening ? 8 : 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(10), // تقليل من 22
                    ),
                    child: Consumer<PromptEnhancerProvider>(
                      builder: (context, enhancerProvider, child) {
                        return Stack(
                          children: [
                            KeyboardListener(
                              focusNode: FocusNode(),
                              onKeyEvent: (KeyEvent event) {
                                if (event is KeyDownEvent) {
                                  // Navigate message history with arrow keys
                                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                    _navigateHistory(true);
                                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                    _navigateHistory(false);
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10), // تقليل من 20
                                  border: _textFieldFocusNode.hasFocus
                                      ? Border.all(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                          width: 2,
                                        )
                                      : null,
                                  boxShadow: _textFieldFocusNode.hasFocus
                                      ? [
                                          BoxShadow(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  focusNode: _textFieldFocusNode,
                                  minLines: 2, // زيادة الحد الأدنى للأسطر
                                  maxLines: 8, // زيادة الحد الأقصى للأسطر
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16, // زيادة حجم الخط
                                  ),
                                  enabled: !enhancerProvider.isEnhancing,
                                  onChanged: (value) {
                                    setState(() {
                                      _historyIndex = -1;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: enhancerProvider.isEnhancing
                                        ? 'جاري تحسين البرومبت باستخدام الذكاء الاصطناعي...'
                                        : _isListening
                                            ? 'أستمع...'
                                            : 'اسألني أي سؤال يخطر في بالك',
                                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: enhancerProvider.isEnhancing
                                          ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                      fontStyle: enhancerProvider.isEnhancing
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                    filled: true,
                                    fillColor: enhancerProvider.isEnhancing
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                                        : Colors.transparent,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(
                                      right: 50, // مساحة لزر تحسين البروبت
                                      left: 50,  // مساحة لزر الإرسال
                                      top: 20,   // زيادة الحشو العلوي
                                      bottom: 20, // زيادة الحشو السفلي
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            // زر تحسين البروبت داخل خانة الكتابة (يمين)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                decoration: enhancerProvider.isEnhancing
                                    ? BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      )
                                    : null,
                                child: IconButton(
                                  icon: enhancerProvider.isEnhancing
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.auto_fix_high,
                                          color: _messageController.text.trim().isEmpty
                                              ? Theme.of(context).disabledColor
                                              : Theme.of(context).colorScheme.primary,
                                          size: 20,
                                        ),
                                  onPressed: (_messageController.text.trim().isEmpty || enhancerProvider.isEnhancing)
                                      ? null
                                      : () => _enhancePrompt(),
                                  tooltip: enhancerProvider.isEnhancing
                                      ? 'جاري تحسين البرومبت...'
                                      : 'تحسين البرومبت بالذكاء الاصطناعي',
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              ),
                            ),

                            // زر الإرسال داخل خانة الكتابة (يسار)
                            Positioned(
                              left: 8,
                              top: 8,
                              child: Consumer<ChatProvider>(
                                builder: (context, chatProvider, child) {
                                  final hasText = _messageController.text.trim().isNotEmpty;
                                  
                                  return GestureDetector(
                                    onTap: hasText && !chatProvider.isTyping
                                        ? () => _sendMessage(_messageController.text)
                                        : null,
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        gradient: hasText && !chatProvider.isTyping
                                            ? LinearGradient(
                                                colors: [
                                                  Theme.of(context).colorScheme.primary,
                                                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                                ],
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  Colors.grey.withOpacity(0.4),
                                                  Colors.grey.withOpacity(0.3),
                                                ],
                                              ),
                                        borderRadius: BorderRadius.circular(8), // تقليل من 20
                                        boxShadow: hasText && !chatProvider.isTyping
                                            ? [
                                                BoxShadow(
                                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: chatProvider.isTyping
                                            ? SizedBox(
                                                width: 14,
                                                height: 14,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.white.withOpacity(0.8),
                                                  ),
                                                ),
                                              )
                                            : Icon(
                                                Icons.send,
                                                color: hasText
                                                    ? Colors.white
                                                    : Colors.white.withOpacity(0.5),
                                                size: 16,
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // دالة مساعدة لبناء أزرار الأدوات
  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(12),
              splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Container(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
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

  /// اختبار دقة التعرف على الصوت
  Future<void> _testSpeechAccuracy() async {
    try {
      final results = await _speechService.testSpeechRecognitionAccuracy();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('🎤 نتائج اختبار دقة التعرف على الصوت'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTestResult('اللغات المتاحة', '${results['available_locales']} لغة'),
                  _buildTestResult('اللغات العربية', '${results['arabic_locales']} لهجة'),
                  _buildTestResult('اللغات الإنجليزية', '${results['english_locales']} لهجة'),
                  _buildTestResult('إذن الميكروفون', results['microphone_available'] ? '✅ متاح' : '❌ غير متاح'),
                  _buildTestResult('خدمة التعرف', results['speech_service_initialized'] ? '✅ مفعلة' : '❌ معطلة'),
                  _buildTestResult('خدمة النطق', results['tts_service_initialized'] ? '✅ مفعلة' : '❌ معطلة'),
                  _buildTestResult('اللغة الحالية', results['current_locale'] ?? 'غير محددة'),
                  _buildTestResult('اللغات المدعومة', '${results['supported_locales_count']} لغة'),
                  
                  if (results['error'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        '❌ خطأ: ${results['error']}',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showLanguageSelector();
                },
                child: const Text('تغيير اللغة'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختبار دقة التعرف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTestResult(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// عرض محدد اللغة
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => LanguageSelectorDialog(
        currentLocale: _speechService.currentLocale,
        onLanguageChanged: (localeId, displayName) {
          setState(() {
            // تحديث الواجهة إذا لزم الأمر
          });
        },
      ),
    );
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
