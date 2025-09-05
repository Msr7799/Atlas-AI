import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/prompt_enhancer_provider.dart';
import 'voice_input_button.dart';

/// ويدجت الإدخال المحسن للمحادثة
class ChatInputWidget extends StatefulWidget {
  final TextEditingController messageController;
  final FocusNode textFieldFocusNode;
  final Function(String) onSendMessage;
  final Function() onAttachmentTap;
  final bool isDesktop;
  final int historyIndex;
  final Function(int) onHistoryIndexChanged;

  const ChatInputWidget({
    super.key,
    required this.messageController,
    required this.textFieldFocusNode,
    required this.onSendMessage,
    required this.onAttachmentTap,
    required this.isDesktop,
    required this.historyIndex,
    required this.onHistoryIndexChanged,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _isVoiceListening = false;
  String _voiceText = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<PromptEnhancerProvider>(
      builder: (context, enhancerProvider, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: widget.textFieldFocusNode.hasFocus
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: widget.textFieldFocusNode.hasFocus
                ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // حقل النص الرئيسي
              Padding(
                padding: const EdgeInsets.only(
                  left: 60,
                  right: 100,
                  top: 12,
                  bottom: 12,
                ),
                child: widget.isDesktop
                    ? _buildDesktopTextField(enhancerProvider)
                    : _buildMobileTextField(enhancerProvider),
              ),

              // زر الصوت المحسن على اليسار
              Positioned(
                left: 8,
                top: 8,
                child: VoiceInputButton(
                  onSpeechResult: _onVoiceSpeechResult,
                  onStartListening: () {
                    setState(() {
                      _isVoiceListening = true;
                    });
                    // عرض رسالة أن التسجيل بدأ
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          Localizations.localeOf(context).languageCode == 'ar' 
                            ? '🎤 بدء التسجيل الصوتي...' 
                            : '🎤 Voice recording started...',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onStopListening: () {
                    setState(() {
                      _isVoiceListening = false;
                    });
                    // عرض رسالة أن التسجيل انتهى
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          Localizations.localeOf(context).languageCode == 'ar' 
                            ? '⏹️ توقف التسجيل الصوتي' 
                            : '⏹️ Voice recording stopped',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onDeleteRecording: () {
                    setState(() {
                      _isVoiceListening = false;
                      _voiceText = '';
                    });
                    _showDeleteMessage();
                  },
                  putTextInInput: true, // وضع النص في الـ input
                  enabled: !enhancerProvider.isEnhancing,
                  primaryColor: Theme.of(context).colorScheme.primary,
                  accentColor: Theme.of(context).colorScheme.secondary,
                ),
              ),

              // أزرار الجانب الأيمن
              Positioned(
                right: 8,
                top: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر تحسين البرومبت
                    _buildEnhanceButton(enhancerProvider),
                    const SizedBox(width: 4),
                    // زر المرفقات
                    _buildAttachmentButton(),
                    const SizedBox(width: 4),
                    // زر الإرسال
                    _buildSendButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// بناء حقل النص للسطح المكتبي
  Widget _buildDesktopTextField(PromptEnhancerProvider enhancerProvider) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter &&
              !event.isShiftPressed &&
              !event.isControlPressed &&
              !event.isAltPressed) {
            final text = widget.messageController.text.trim();
            if (text.isNotEmpty &&
                !context.read<ChatProvider>().isTyping) {
              widget.onSendMessage(text);
            }
            return;
          }
        }
      },
      child: _buildTextField(enhancerProvider),
    );
  }

  /// بناء حقل النص للهاتف المحمول
  Widget _buildMobileTextField(PromptEnhancerProvider enhancerProvider) {
    return _buildTextField(enhancerProvider);
  }

  /// بناء حقل النص الأساسي
  Widget _buildTextField(PromptEnhancerProvider enhancerProvider) {
    return TextField(
      controller: widget.messageController,
      focusNode: widget.textFieldFocusNode,
      minLines: 1,
      maxLines: widget.isDesktop ? 3 : null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 18,
            fontFamily: 'Amiri',
          ),
      enabled: !enhancerProvider.isEnhancing,
      onChanged: (value) {
        widget.onHistoryIndexChanged(-1);
      },
      decoration: _buildTextFieldDecoration(enhancerProvider),
    );
  }

  /// بناء تزيين حقل النص
  InputDecoration _buildTextFieldDecoration(
      PromptEnhancerProvider enhancerProvider) {
    return InputDecoration(
      hintText: enhancerProvider.isEnhancing
          ? (Localizations.localeOf(context).languageCode == 'ar' ? 'جاري تحسين النص...' : 'Enhancing text...')
          : (Localizations.localeOf(context).languageCode == 'ar' ? 'اكتب رسالتك هنا...' : 'Type your message here...'),
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        fontSize: 16,
        fontFamily: 'Amiri',
      ),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  /// بناء زر تحسين البرومبت
  Widget _buildEnhanceButton(PromptEnhancerProvider enhancerProvider) {
    return Container(
      decoration: enhancerProvider.isEnhancing
          ? BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: IconButton(
        icon: enhancerProvider.isEnhancing
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Icon(
                Icons.auto_fix_high,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
        onPressed: enhancerProvider.isEnhancing
            ? null
            : () => _showEnhanceDialog(enhancerProvider),
        tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'تحسين البرومبت' : 'Enhance Prompt',
      ),
    );
  }

  /// بناء زر المرفقات
  Widget _buildAttachmentButton() {
    return IconButton(
      icon: Icon(
        Icons.attach_file,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
      onPressed: widget.onAttachmentTap,
      tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'إرفاق ملف' : 'Attach File',
    );
  }

  /// بناء زر الإرسال
  Widget _buildSendButton() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.send,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          final text = widget.messageController.text.trim();
          if (text.isNotEmpty && !context.read<ChatProvider>().isTyping) {
            widget.onSendMessage(text);
          }
        },
        tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'إرسال الرسالة' : 'Send Message',
      ),
    );
  }

  /// معالج النتائج الصوتية
  void _onVoiceSpeechResult(String result) {
    if (result.isNotEmpty) {
      setState(() {
        _voiceText = result;
        // إضافة النص للـ controller بدلاً من الإرسال المباشر
        final currentText = widget.messageController.text;
        if (currentText.isNotEmpty && !currentText.endsWith(' ')) {
          widget.messageController.text = '$currentText $result';
        } else {
          widget.messageController.text = currentText + result;
        }
        // وضع المؤشر في النهاية
        widget.messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.messageController.text.length),
        );
      });
      
      // إظهار رسالة تأكيد
      _showVoiceAddedMessage();
    }
  }

  /// إظهار رسالة تم إضافة النص الصوتي
  void _showVoiceAddedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar' 
            ? '✅ تم إضافة النص الصوتي' 
            : '✅ Voice text added',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// إظهار رسالة تم حذف التسجيل
  void _showDeleteMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar' 
            ? '🗑️ تم إلغاء التسجيل الصوتي' 
            : '🗑️ Voice recording cancelled',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// إظهار حوار تحسين البرومبت
  void _showEnhanceDialog(PromptEnhancerProvider enhancerProvider) {
    final currentText = widget.messageController.text.trim();
    if (currentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar' 
              ? '⚠️ يرجى كتابة نص لتحسينه' 
              : '⚠️ Please enter text to enhance',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // بدء عملية التحسين
    enhancerProvider.enhancePrompt(
      originalPrompt: currentText,
      conversationHistory: [],
    ).then((result) {
      if (result != null && result.enhancedPrompt.isNotEmpty && result.enhancedPrompt != currentText) {
        widget.messageController.text = result.enhancedPrompt;
        widget.messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: result.enhancedPrompt.length),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Localizations.localeOf(context).languageCode == 'ar' 
                ? '✅ تم تحسين النص بنجاح' 
                : '✅ Text enhanced successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar' 
              ? '❌ فشل في تحسين النص' 
              : '❌ Failed to enhance text',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
}
