import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../language_selector_widget.dart';
import '../prompt_enhancement_dialog.dart';
import '../../constants/ui_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/services/speech_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/prompt_enhancer_provider.dart';

/// منطقة الإدخال المحسنة
class ChatInputArea extends StatefulWidget {
  final dynamic controllers; // _ChatControllers
  final dynamic animations; // _ChatAnimations
  final dynamic chatState; // _ChatState
  final SpeechService speechService;
  final Function(String, {List<XFile>? attachedImages}) onSendMessage;

  const ChatInputArea({
    super.key,
    required this.controllers,
    required this.animations,
    required this.chatState,
    required this.speechService,
    required this.onSendMessage,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  List<XFile> attachedImages = [];

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // البرفيو في الأعلى
            if (attachedImages.isNotEmpty) _buildCompactAttachmentsPreview(),
            // منطقة الإدخال
            Container(
              height: screenHeight > UIConstants.mobileBreakpoint
                  ? 140.0
                  : 120.0,
              width: double.infinity,
              padding: EdgeInsets.all(
                screenWidth > UIConstants.mobileBreakpoint
                    ? 16.0
                    : 12.0,
              ),
              decoration: const BoxDecoration(
                color: Color(UIConstants.darkBackground),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: UIConstants.elevation8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.chatState.isListening) _buildVoiceWaveAnimation(),
                  _buildTextInputArea(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// بناء رسوم موجة الصوت المتحركة
  Widget _buildVoiceWaveAnimation() {
    return Container(
      height: UIConstants.voiceWaveHeight,
      margin: const EdgeInsets.only(bottom: UIConstants.spacing12),
      child: AnimatedBuilder(
        animation: widget.animations.waveAnimation,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(15, (index) {
              final baseHeight = 20.0;
              final animationValue = index % 2 == 0
                  ? widget.animations.waveAnimation.value
                  : 1 - widget.animations.waveAnimation.value;
              final height = baseHeight + (30 * (0.5 + 0.5 * animationValue));

              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.gradientStart.withOpacity(
                        UIConstants.opacityHigh,
                      ),
                      AppTheme.gradientAccent.withOpacity(
                        UIConstants.opacityMedium,
                      ),
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



  /// دالة ذكية لحساب التباين حسب الوضع الليلي/النهاري
  List<Color> _getSmartGradientColors(Color baseColor, bool isDarkMode) {
    // حساب سطوع اللون
    final luminance = baseColor.computeLuminance();

    if (isDarkMode) {
      // في الوضع الليلي: نجعل الألوان الفاتحة أغمق والألوان الغامقة أفتح
      if (luminance > 0.5) {
        // لون فاتح - نجعله أغمق
        
        return [
          Color.fromRGBO(
            (baseColor.red * 0.7).round(),
            (baseColor.green * 0.7).round(),
            (baseColor.blue * 0.7).round(),
            1.0,
          ),
          Color.fromRGBO(
            (baseColor.red * 0.5).round(),
            (baseColor.green * 0.5).round(),
            (baseColor.blue * 0.5).round(),
            1.0,
          ),
        ];
      } else {
        // لون غامق - نجعله أفتح قليلاً
        return [
          baseColor,
          Color.fromRGBO(
            (baseColor.red + (255 - baseColor.red) * 0.3).round(),
            (baseColor.green + (255 - baseColor.green) * 0.3).round(),
            (baseColor.blue + (255 - baseColor.blue) * 0.3).round(),
            1.0,
          ),
        ];
      }
    } else {
      // في الوضع النهاري: نستخدم اللون كما هو مع تدرج طبيعي
      return [
        baseColor,
        Color.fromRGBO(
          (baseColor.red * 0.8).round(),
          (baseColor.green * 0.8).round(),
          (baseColor.blue * 0.8).round(),
          1.0,
        ),
      ];
    }
  }

  /// بناء زر أداة مصغر للاستخدام في الجانب الأيمن
  Widget _buildCompactToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final gradientColors = _getSmartGradientColors(
          themeProvider.accentColor,
          isDarkMode,
        );

        return Tooltip(
          message: tooltip,
          child: Container(
            width: 28.0,
            height: 28.0,
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.3),
                  blurRadius: 4.0,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.8),
                  blurRadius: 1.0,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(8.0),
                child: Center(
                  child: Icon(
                    icon,
                    color: _getContrastColor(themeProvider.accentColor),
                    size: 14.0,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// دالة لحساب لون النص المناسب حسب خلفية اللون
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// بناء زر صوتي مصغر
  Widget _buildCompactVoiceButton() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isListening = widget.chatState.isListening;
        final speechEnabled = widget.chatState.speechEnabled;
        final isDarkMode = themeProvider.isDarkMode;
        final gradientColors = _getSmartGradientColors(
          themeProvider.accentColor,
          isDarkMode,
        );

        return Tooltip(
          message: speechEnabled
              ? (isListening
                    ? (Localizations.localeOf(context).languageCode == 'ar'
                          ? 'إيقاف التسجيل'
                          : 'Stop Recording')
                    : (Localizations.localeOf(context).languageCode == 'ar'
                          ? 'بدء التسجيل الصوتي'
                          : 'Start Voice Recording'))
              : (Localizations.localeOf(context).languageCode == 'ar'
                    ? 'الصوت غير متاح'
                    : 'Voice Not Available'),
          child: Container(
            width: 28.0,
            height: 28.0,
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isListening
                    ? [Colors.red.withOpacity(0.8), Colors.red.withOpacity(0.6)]
                    : speechEnabled
                    ? gradientColors
                    : [
                        Colors.grey.withOpacity(0.5),
                        Colors.grey.withOpacity(0.3),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: speechEnabled
                    ? (isDarkMode
                          ? Colors.white.withOpacity(0.2)
                          : Colors.black.withOpacity(0.1))
                    : Colors.grey.withOpacity(0.2),
                width: 1.0,
              ),
              boxShadow: speechEnabled
                  ? [
                      BoxShadow(
                        color: isListening
                            ? Colors.red.withOpacity(0.3)
                            : gradientColors[0].withOpacity(0.3),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: speechEnabled ? _toggleVoiceInput : null,
                borderRadius: BorderRadius.circular(8.0),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: Duration(
                      milliseconds: UIConstants.animationDuration,
                    ),
                    child: Icon(
                      isListening ? Icons.mic : Icons.mic_off,
                      key: ValueKey(isListening),
                      color: speechEnabled
                          ? (isListening
                                ? Colors.white
                                : _getContrastColor(themeProvider.accentColor))
                          : Colors.grey,
                      size: 14.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء زر مايكروفون مصغر
  Widget _buildCompactMicrophoneButton() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isListening = widget.chatState.isListening;
        final speechEnabled = widget.chatState.speechEnabled;
        final isDarkMode = themeProvider.isDarkMode;
        final gradientColors = _getSmartGradientColors(
          themeProvider.accentColor,
          isDarkMode,
        );

        return Tooltip(
          message: speechEnabled
              ? (isListening
                    ? (Localizations.localeOf(context).languageCode == 'ar'
                          ? 'إيقاف التسجيل'
                          : 'Stop Recording')
                    : (Localizations.localeOf(context).languageCode == 'ar'
                          ? 'بدء التسجيل الصوتي'
                          : 'Start Voice Recording'))
              : (Localizations.localeOf(context).languageCode == 'ar'
                    ? 'الصوت غير متاح'
                    : 'Voice Not Available'),
          child: GestureDetector(
            onTap: speechEnabled ? _toggleVoiceInput : null,
            child: Container(
              width: 28.0,
              height: 28.0,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isListening
                      ? [
                          Colors.red.withOpacity(0.9),
                          Colors.red.withOpacity(0.7),
                        ]
                      : speechEnabled
                      ? gradientColors
                      : [
                          Colors.grey.withOpacity(0.5),
                          Colors.grey.withOpacity(0.3),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: speechEnabled
                      ? (isDarkMode
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1))
                      : Colors.grey.withOpacity(0.2),
                  width: 1.0,
                ),
                boxShadow: speechEnabled
                    ? [
                        BoxShadow(
                          color: isListening
                              ? Colors.red.withOpacity(0.3)
                              : gradientColors[0].withOpacity(0.3),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isListening
                    ? Icon(Icons.stop, color: Colors.white, size: 14.0)
                    : Icon(
                        Icons.mic,
                        color: speechEnabled
                            ? _getContrastColor(themeProvider.accentColor)
                            : Colors.grey,
                        size: 14.0,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }



  /// بناء منطقة إدخال النص
  Widget _buildTextInputArea() {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(
          minHeight: UIConstants.inputMinHeight,
          maxHeight: MediaQuery.of(context).size.height * 0.30,
        ),
        child: SingleChildScrollView(child: _buildTextFieldContainer()),
      ),
    );
  }

  /// بناء حاوية حقل النص
  Widget _buildTextFieldContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widget.chatState.isListening
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: widget.chatState.isListening
                ? UIConstants.elevation8
                : UIConstants.elevation4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Consumer<PromptEnhancerProvider>(
          builder: (context, enhancerProvider, child) {
            return Column(
              children: [
                // Stack محدث لحقل الكتابة والأزرار
                Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: UIConstants.iconSize32 + UIConstants.spacing16,
                      ),
                      child: _buildKeyboardListener(enhancerProvider),
                    ),
                    // الأزرار في الجانب الأيمن
                    _buildRightSideButtons(enhancerProvider),
                    _buildSendButton(),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// بناء مستمع لوحة المفاتيح
  Widget _buildKeyboardListener(PromptEnhancerProvider enhancerProvider) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _navigateHistory(true);
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _navigateHistory(false);
          }
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: UIConstants.animationDuration),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: widget.controllers.textFieldFocusNode.hasFocus
              ? Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(UIConstants.opacityMedium),
                  width: UIConstants.strokeWidth2,
                )
              : null,
          boxShadow: widget.controllers.textFieldFocusNode.hasFocus
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(
                      UIConstants.opacityMediumHigh,
                    ),
                    blurRadius: UIConstants.elevation8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: _buildTextField(enhancerProvider),
      ),
    );
  }

  /// بناء حقل النص
  Widget _buildTextField(PromptEnhancerProvider enhancerProvider) {
    if (_isDesktop()) {
      return RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.enter &&
              !event.isShiftPressed &&
              !event.isControlPressed &&
              !event.isAltPressed) {
            final text = widget.controllers.messageController.text.trim();
            if (text.isNotEmpty && !context.read<ChatProvider>().isTyping) {
              _sendMessageWithAttachments();
            }
          }
        },
        child: _buildTextFieldWidget(
          enhancerProvider,
          maxLines: UIConstants.maxMessageLines,
        ),
      );
    } else {
      return _buildTextFieldWidget(enhancerProvider, maxLines: null);
    }
  }

  /// بناء widget حقل النص
  Widget _buildTextFieldWidget(
    PromptEnhancerProvider enhancerProvider, {
    int? maxLines,
  }) {
    return TextField(
      controller: widget.controllers.messageController,
      focusNode: widget.controllers.textFieldFocusNode,
      minLines: 1,
      maxLines: maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: UIConstants.fontSize18,
        fontFamily: 'Amiri',
      ),
      enabled: !enhancerProvider.isEnhancing,
      onChanged: (value) {
        setState(() {
          widget.chatState.setHistoryIndex(-1);
        });
      },
      decoration: _buildTextFieldDecoration(enhancerProvider),
    );
  }

  /// بناء الأزرار في الجانب الأيمن
  Widget _buildRightSideButtons(PromptEnhancerProvider enhancerProvider) {
    return Positioned(
      right: 0, // إزالة المسافة على اليمين - يبدأ من الحافة
      top: UIConstants.spacing4, // رفع الكونتينر لأعلى
      child: Container(
        padding: const EdgeInsets.all(4.0), // تصغير الكونتينر قليلاً
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر التحسين أولاً
            _buildEnhanceButtonCompact(enhancerProvider),
            const SizedBox(width: 10), // مسافة أكبر بين الأزرار
            // خط فاصل
            Container(
              width: 1,
              height: 20,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(width: 10),
            _buildCompactToolButton(
              icon: Icons.attach_file,
              tooltip: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'إرفاق ملف'
                  : 'Attach File',

              /// pick image or file
              onPressed: () => _showAttachmentOptions(context),
            ),
            const SizedBox(width: 10),
            _buildCompactToolButton(
              icon: Icons.search,
              tooltip: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'البحث في الويب'
                  : 'Web Search',
              onPressed: _showSearchDialog,
            ),
            const SizedBox(width: 10),
            _buildCompactToolButton(
              icon: Icons.language,
              tooltip: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'تغيير لغة التعرف على الصوت'
                  : 'Change Speech Recognition Language',
              onPressed: _showLanguageSelector,
            ),
            const SizedBox(width: 10),
            // خط فاصل آخر
            Container(
              width: 1,
              height: 20,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            const SizedBox(width: 10),
            _buildCompactVoiceButton(),
            const SizedBox(width: 10),
            _buildCompactMicrophoneButton(),
          ],
        ),
      ),
    );
  }

  /// بناء زر التحسين المدمج
  Widget _buildEnhanceButtonCompact(PromptEnhancerProvider enhancerProvider) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final bool isEnabled =
            widget.controllers.messageController.text.trim().isNotEmpty &&
            !enhancerProvider.isEnhancing;
        final isDarkMode = themeProvider.isDarkMode;
        final gradientColors = _getSmartGradientColors(
          themeProvider.accentColor,
          isDarkMode,
        );

        return Container(
          width: 28.0,
          height: 28.0,
          margin: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(
            gradient: enhancerProvider.isEnhancing
                ? LinearGradient(
                    colors: [
                      themeProvider.accentColor,
                      themeProvider.accentColor.withOpacity(0.7),
                    ],
                  )
                : isEnabled
                ? LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.5),
                      Colors.grey.withOpacity(0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isEnabled
                  ? (isDarkMode
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1))
                  : Colors.grey.withOpacity(0.2),
              width: 1.0,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 4.0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? _enhancePrompt : null,
              borderRadius: BorderRadius.circular(8.0),
              child: Center(
                child: enhancerProvider.isEnhancing
                    ? SizedBox(
                        width: 14.0,
                        height: 14.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getContrastColor(themeProvider.accentColor),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.auto_fix_high,
                        color: isEnabled
                            ? _getContrastColor(themeProvider.accentColor)
                            : Colors.grey,
                        size: 14.0,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء زر الإرسال
  Widget _buildSendButton() {
    return Positioned(
      left: UIConstants.spacing8,
      bottom: UIConstants.spacing8, // نقل الزر للأسفل
      child: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          final hasText = widget.controllers.messageController.text
              .trim()
              .isNotEmpty;

          return GestureDetector(
            onTap: hasText && !chatProvider.isTyping
                ? () => _sendMessageWithAttachments()
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.0, // تصغير أكثر من 28 إلى 24
              height: 24.0, // تصغير أكثر من 28 إلى 24
              decoration: BoxDecoration(
                gradient: hasText && !chatProvider.isTyping
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(
                            UIConstants.opacityHigh,
                          ),
                        ],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(UIConstants.opacityDisabled),
                          Colors.grey.withOpacity(
                            UIConstants.opacityMediumHigh,
                          ),
                        ],
                      ),
                borderRadius: BorderRadius.circular(UIConstants.borderRadius8),
                boxShadow: hasText && !chatProvider.isTyping
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary
                              .withOpacity(UIConstants.opacityMediumHigh),
                          blurRadius: UIConstants.elevation4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: chatProvider.isTyping
                    ? SizedBox(
                        width: 14,
                        height: 9,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(UIConstants.opacityHigh),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: hasText
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        size: 12.0, // تصغير أكثر من 14 إلى 12
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  // =============== Voice Input Methods ===============

  /// تبديل إدخال الصوت
  Future<void> _toggleVoiceInput() async {
    if (widget.chatState.isListening) {
      await widget.speechService.stopListening();
      widget.animations.waveController.stop();
      setState(() => widget.chatState.setListening(false));
    } else {
      if (widget.chatState.speechEnabled) {
        setState(() => widget.chatState.setListening(true));
        widget.animations.waveController.repeat(reverse: true);
        await widget.speechService.startListening(
          onResult: (result) {
            setState(() {
              widget.controllers.messageController.text = result;
            });
            if (!widget.speechService.isListening) {
              widget.animations.waveController.stop();
              setState(() => widget.chatState.setListening(false));
            }
          },
        );
      }
    }
  }




  // =============== Message Sending Methods ===============

  /// إرسال الرسالة مع المرفقات
  void _sendMessageWithAttachments() {
    final text = widget.controllers.messageController.text.trim();
    if (text.isNotEmpty || attachedImages.isNotEmpty) {
      String finalMessage = text;

      // إضافة معلومات الملفات المرفقة تلقائياً للبرومبت
      if (attachedImages.isNotEmpty) {
        final attachmentInfo = _generateAttachmentInfo();
        if (finalMessage.isNotEmpty) {
          finalMessage = '$finalMessage\n\n$attachmentInfo';
        } else {
          finalMessage = attachmentInfo;
        }
      }

      widget.onSendMessage(finalMessage, attachedImages: attachedImages);
      // مسح الصور المرفقة بعد الإرسال
      setState(() {
        attachedImages.clear();
      });
    }
  }

  /// توليد معلومات الملفات المرفقة
  String _generateAttachmentInfo() {
    if (attachedImages.isEmpty) return '';

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final List<String> fileInfos = [];

    for (int i = 0; i < attachedImages.length; i++) {
      final file = attachedImages[i];
      final fileName = file.name;
      final fileExtension = fileName.split('.').last.toLowerCase();

      String fileType;
      if (['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(fileExtension)) {
        fileType = isArabic ? 'صورة' : 'image';
      } else if (['txt', 'md'].contains(fileExtension)) {
        fileType = isArabic ? 'ملف نصي' : 'text file';
      } else if (['json', 'yaml', 'yml'].contains(fileExtension)) {
        fileType = isArabic ? 'ملف بيانات' : 'data file';
      } else if (fileExtension == 'pdf') {
        fileType = isArabic ? 'ملف PDF' : 'PDF file';
      } else {
        fileType = isArabic ? 'ملف' : 'file';
      }

      fileInfos.add(
        isArabic
            ? '${i + 1}. $fileType: $fileName'
            : '${i + 1}. $fileType: $fileName',
      );
    }

    final header = isArabic ? '📎 الملفات المرفقة:' : '📎 Attached files:';

    return '$header\n${fileInfos.join('\n')}';
  }

  // =============== Image Picking Methods ===============

  /// اختيار صورة من المعرض
  Future<void> pickImage() async {
    if (attachedImages.length >= 3) {
      // أظهر رسالة للمستخدم أن الحد الأقصى 3 صور
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'يمكنك إرفاق 3 صور كحد أقصى'
                : 'You can attach a maximum of 3 images',
          ),
        ),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // حجم الصورة
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      // تحقق من الامتداد
      final ext = image.name.split('.').last.toLowerCase();
      if (!['png', 'jpg', 'jpeg'].contains(ext)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'الملف يجب أن يكون صورة PNG أو JPG أو JPEG'
                  : 'File must be a PNG, JPG or JPEG image',
            ),
          ),
        );
        return;
      }
      // تحقق من الحجم (أقل من 5MB)
      try {
        final bytes = await image.length();
        const maxSize = 5 * 1024 * 1024; // 5MB
        if (bytes > maxSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'حجم الصورة كبير جداً. الحد الأقصى هو 5MB'
                    : 'Image size is too large. Maximum is 5MB',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        print(
          '📏 [IMAGE_PICKER] حجم الصورة: ${(bytes / 1024 / 1024).toStringAsFixed(2)} MB',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'خطأ في قراءة حجم الصورة: $e'
                  : 'Error reading image size: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      attachedImages.add(image);
      setState(() {});
    }
  }

  // =============== Helper Methods ===============

  /// تحديد ما إذا كان الجهاز كمبيوتر مكتبي
  bool _isDesktop() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  /// التنقل في التاريخ
  Future<void> _navigateHistory(bool up) async {
    // Implementation for history navigation
    // This would need to be connected to your chat state
  }

  /// عرض حوار البحث
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'البحث في الويب'
              : 'Web Search',
        ),
        content: TextField(
          decoration: InputDecoration(
            hintText: Localizations.localeOf(context).languageCode == 'ar'
                ? 'أدخل استعلام البحث...'
                : 'Enter search query...',
          ),
          onSubmitted: (query) {
            Navigator.pop(context);
            context.read<ChatProvider>().searchWeb(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'إلغاء'
                  : 'Cancel',
            ),
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
        currentLocale: widget.speechService.currentLocale,
        onLanguageChanged: (localeId, displayName) {
          setState(() {
            // تحديث الواجهة إذا لزم الأمر
          });
        },
      ),
    );
  }

  /// تحسين البرومبت
  Future<void> _enhancePrompt() async {
    final currentText = widget.controllers.messageController.text.trim();
    if (currentText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'يرجى إدخال نص أولاً لتحسينه'
                  : 'Please enter text first to enhance it',
            ),
          ),
        );
      }
      return;
    }

    try {
      final enhancerProvider = context.read<PromptEnhancerProvider>();
      final chatProvider = context.read<ChatProvider>();

      final conversationHistory = chatProvider.messages;

      final result = await enhancerProvider.enhancePrompt(
        originalPrompt: currentText,
        conversationHistory: conversationHistory,
      );

      if (result != null && mounted) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) => PromptEnhancementDialog(
            result: result,
            onUseEnhanced: (enhancedText) {
              Navigator.of(dialogContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    widget.controllers.messageController.text = enhancedText;
                  });
                }
              });
            },
            onUseOriginal: (originalText) {
              Navigator.of(dialogContext).pop();
            },
            onUseCustom: (customText) {
              Navigator.of(dialogContext).pop();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    widget.controllers.messageController.text = customText;
                  });
                }
              });
            },
          ),
        );
      } else if (enhancerProvider.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'خطأ في تحسين النص: يرجى المحاولة مرة أخرى'
                  : 'Error enhancing text: Please try again',
            ),
            action: SnackBarAction(
              label: Localizations.localeOf(context).languageCode == 'ar'
                  ? 'إعادة المحاولة'
                  : 'Retry',
              onPressed: _enhancePrompt,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar'
                  ? 'خطأ غير متوقع: $e'
                  : 'Unexpected error: $e',
            ),
          ),
        );
      }
    }
  }

  /// بناء تصميم حقل النص
  InputDecoration _buildTextFieldDecoration(
    PromptEnhancerProvider enhancerProvider,
  ) {
    return InputDecoration(
      hintText: _getHintText(enhancerProvider),
      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: enhancerProvider.isEnhancing
            ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        fontStyle: enhancerProvider.isEnhancing
            ? FontStyle.italic
            : FontStyle.normal,
        fontFamily: 'Amiri',
      ),
      filled: true,
      fillColor: enhancerProvider.isEnhancing
          ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
          : Colors.transparent,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacing16,
        vertical: UIConstants.spacing16,
      ),
    );
  }

  /// الحصول على نص التلميح
  String _getHintText(PromptEnhancerProvider enhancerProvider) {
    if (enhancerProvider.isEnhancing) {
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'جاري تحسين البرومبت باستخدام الذكاء الاصطناعي...'
          : 'Enhancing prompt using AI...';
    }
    if (widget.chatState.isListening) {
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'أستمع...'
          : 'Listening...';
    }
    if (_isDesktop()) {
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'أكتب أي شي يدور في خاطرك...'
          : 'Type anything on your mind...';
    }
    return Localizations.localeOf(context).languageCode == 'ar'
        ? 'أتحفني بأي شي يدور في خاطرك...'
        : 'Share anything on your mind...';
  }

  /// عرض خيارات الإرفاق
  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'اختر نوع الملف'
                    : 'Choose file type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    context,
                    icon: Icons.image,
                    label: Localizations.localeOf(context).languageCode == 'ar'
                        ? 'صورة'
                        : 'Image',
                    onTap: () {
                      Navigator.pop(context);
                      pickImage();
                    },
                  ),
                  _buildAttachmentOption(
                    context,
                    icon: Icons.attach_file,
                    label: Localizations.localeOf(context).languageCode == 'ar'
                        ? 'ملف'
                        : 'File',
                    onTap: () {
                      Navigator.pop(context);
                      pickFile();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  /// بناء خيار الإرفاق
  Widget _buildAttachmentOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  /// بناء معاينة مدمجة للملفات المرفقة
  Widget _buildCompactAttachmentsPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_file,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${attachedImages.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: 28,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: attachedImages.length,
                itemBuilder: (context, index) {
                  return _buildCompactAttachmentItem(attachedImages[index], index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر مرفق مدمج
  Widget _buildCompactAttachmentItem(XFile file, int index) {
    final fileName = file.name;
    final fileExtension = fileName.split('.').last.toLowerCase();
    final isImage = ['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(fileExtension);
    
    return Container(
      margin: const EdgeInsets.only(right: 4),
      child: Stack(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: isImage 
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  _getFileIcon(fileExtension),
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  attachedImages.removeAt(index);
                });
              },
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// الحصول على أيقونة الملف
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'txt':
      case 'md':
        return Icons.description;
      case 'json':
      case 'yaml':
      case 'yml':
        return Icons.data_object;
      case 'xml':
        return Icons.code;
      case 'csv':
        return Icons.table_chart;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// اختيار ملف
  Future<void> pickFile() async {
    if (attachedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'يمكنك إرفاق 5 ملفات كحد أقصى'
                : 'You can attach a maximum of 5 files',
          ),
        ),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'txt',
          'md',
          'json',
          'yaml',
          'yml',
          'xml',
          'csv',
          'pdf',
        ],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final filePath = file.path!;

        // تحقق من الحجم (أقل من 10MB)
        const maxSize = 10 * 1024 * 1024; // 10MB
        if (file.size > maxSize) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'حجم الملف كبير جداً. الحد الأقصى هو 10MB'
                    : 'File size is too large. Maximum is 10MB',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        // إضافة الملف كـ XFile للتوافق مع النظام الحالي
        final xFile = XFile(filePath, name: file.name);
        setState(() {
          attachedImages.add(xFile);
        });

      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'خطأ في اختيار الملف: $e'
                : 'Error picking file: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
