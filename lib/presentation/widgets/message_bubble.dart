import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../data/models/message_model.dart';
import '../providers/chat_selection_provider.dart';
import 'thinking_process_widget.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeElementBuilder(this.context);

  @override
  Widget? visitElementAfter(element, preferredStyle) {
    final theme = Theme.of(context);
    final codeText = element.textContent;
    
    // تحديد لون الخلفية حسب الثيم
    Color codeBackground;
    Color codeTextColor;
    Color borderColor;
    
    if (theme.brightness == Brightness.light) {
      // النهار - خلفية سوداء
      codeBackground = const Color(0xFF1E1E1E);
      codeTextColor = const Color(0xFFE0E0E0);
      borderColor = const Color(0xFF404040);
    } else {
      // الليل - خلفية بيج
      codeBackground = const Color(0xFFF5F5DC);
      codeTextColor = const Color(0xFF2D2D2D);
      borderColor = const Color(0xFFD4C4A8);
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط علوي مع زر النسخ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: codeBackground.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'كود',
                  style: TextStyle(
                    color: codeTextColor.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.copy,
                    size: 16,
                    color: codeTextColor.withOpacity(0.7),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: codeText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الكود'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  tooltip: 'نسخ الكود',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
          // محتوى الكود
          Container(
            padding: const EdgeInsets.all(12),
            child: Directionality(
              textDirection: TextDirection.ltr, // فرض اتجاه من اليسار لليمين للكود
              child: SelectableText(
                codeText,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13,
                  color: codeTextColor,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isUser;

  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatSelectionProvider>(
      builder: (context, selectionProvider, child) {
        final isSelected = selectionProvider.selectedMessageIds.contains(
          message.id,
        );
        final isSelectionMode = selectionProvider.isSelectionMode;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection checkbox - يظهر في وضع التحديد فقط
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: GestureDetector(
                    onTap: () {
                      selectionProvider.selectMessage(message.id);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                ),

              if (!isUser) _buildAvatar(context),
              if (!isUser) const SizedBox(width: 8),

              Expanded(
                child: GestureDetector(
                  // الضغط الطويل لتفعيل وضع التحديد
                  onLongPress: () {
                    if (!isSelectionMode) {
                      selectionProvider.toggleSelectionMode();
                    }
                    selectionProvider.selectMessage(message.id);
                  },
                  // النقر العادي فقط في وضع التحديد
                  onTap: isSelectionMode
                      ? () => selectionProvider.selectMessage(message.id)
                      : null,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: !isUser
                          ? Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message content - مع دعم الاتجاه التلقائي
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Directionality(
                            textDirection: _detectTextDirection(
                              message.content,
                            ),
                            child: SelectableText.rich(
                              TextSpan(
                                children: _parseMessageContent(
                                  message.content,
                                  theme,
                                ),
                              ),
                              style: TextStyle(
                                color: isUser
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurface,
                                fontSize: 16,
                                height: 1.4,
                              ),
                              textDirection: _detectTextDirection(
                                message.content,
                              ),
                              // إعدادات النسخ والتحديد
                              enableInteractiveSelection: true,
                              showCursor: true,
                              toolbarOptions: const ToolbarOptions(
                                copy: true,
                                selectAll: true,
                                cut: false,
                                paste: false,
                              ),
                            ),
                          ),
                        ),

                        // Thinking Process - إضافة عرض عملية التفكير
                        if (!isUser && message.thinkingProcess != null)
                          ThinkingProcessWidget(
                            thinkingProcess: message.thinkingProcess!,
                            isExpanded: false, // مطوي بشكل افتراضي
                          ),

                        // Copy button
                        if (!isSelectionMode)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: isUser
                                        ? theme.colorScheme.onPrimary
                                              .withOpacity(0.7)
                                        : theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: message.content),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم نسخ النص'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  tooltip: 'نسخ النص',
                                ),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isUser
                                        ? theme.colorScheme.onPrimary
                                              .withOpacity(0.7)
                                        : theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isUser) const SizedBox(width: 8),
              if (isUser) _buildAvatar(context),
            ],
          ),
        );
      },
    );
  }

  // دالة لكشف اتجاه النص
  TextDirection _detectTextDirection(String text) {
    // Regular expression للحروف العربية
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );
    final englishRegex = RegExp(r'[a-zA-Z]');

    int arabicCount = arabicRegex.allMatches(text).length;
    int englishCount = englishRegex.allMatches(text).length;

    // إذا كانت نسبة العربية أكبر، استخدم RTL
    if (arabicCount > englishCount) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? theme.colorScheme.primary : theme.colorScheme.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSecondary,
        size: 18,
      ),
    );
  }

  List<TextSpan> _parseMessageContent(String content, ThemeData theme) {
    final List<TextSpan> spans = [];
    final RegExp codeBlockRegex = RegExp(r'```(\w+)?\n(.*?)```', dotAll: true);
    final RegExp inlineCodeRegex = RegExp(r'`([^`]+)`');
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final RegExp italicRegex = RegExp(r'\*(.*?)\*');

    String remainingContent = content;
    int currentIndex = 0;

    while (currentIndex < remainingContent.length) {
      String textToProcess = remainingContent.substring(currentIndex);

      // البحث عن كود blocks
      Match? codeBlockMatch = codeBlockRegex.firstMatch(textToProcess);
      Match? inlineCodeMatch = inlineCodeRegex.firstMatch(textToProcess);
      Match? boldMatch = boldRegex.firstMatch(textToProcess);
      Match? italicMatch = italicRegex.firstMatch(textToProcess);

      // العثور على أقرب match
      List<Match?> matches = [
        codeBlockMatch,
        inlineCodeMatch,
        boldMatch,
        italicMatch,
      ];
      matches.removeWhere((match) => match == null);

      if (matches.isEmpty) {
        // لا توجد تنسيقات أخرى - إضافة النص مع اتجاه مناسب
        final text = textToProcess;
        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: _containsArabic(text) ? 'Cairo' : null,
              height: 1.5, // تحسين المسافة بين الأسطر للنص العربي
            ),
          ),
        );
        break;
      }

      Match closestMatch = matches.reduce(
        (a, b) => a!.start < b!.start ? a : b,
      )!;

      // إضافة النص قبل التنسيق
      if (closestMatch.start > 0) {
        final text = textToProcess.substring(0, closestMatch.start);
        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: _containsArabic(text) ? 'Cairo' : null,
              height: 1.5,
            ),
          ),
        );
      }

      // إضافة النص المنسق
      if (closestMatch == codeBlockMatch) {
        final codeContent = closestMatch.group(2) ?? '';
        final language = closestMatch.group(1) ?? '';

        // تحديد لون الخلفية حسب الثيم
        Color codeBackground;
        Color codeTextColor;

        if (theme.brightness == Brightness.light) {
          // النهار - خلفية سوداء
          codeBackground = const Color(0xFF1E1E1E);
          codeTextColor = const Color(0xFFE0E0E0);
        } else {
          // الليل - خلفية بيج
          codeBackground = const Color(0xFFF5F5DC);
          codeTextColor = const Color(0xFF2D2D2D);
        }

        spans.add(
          TextSpan(
            text: codeContent,
            style: TextStyle(
              fontFamily: 'Courier',
              backgroundColor: codeBackground,
              color: codeTextColor,
              height: 1.4,
              // فرض اتجاه من اليسار لليمين للكود فقط
              locale: const Locale('en', 'US'),
            ),
          ),
        );
      } else if (closestMatch == inlineCodeMatch) {
        final codeContent = closestMatch.group(1) ?? '';

        // تحديد لون الخلفية للكود المضمن
        Color inlineCodeBackground;
        Color inlineCodeTextColor;

        if (theme.brightness == Brightness.light) {
          // النهار - خلفية سوداء فاتحة
          inlineCodeBackground = const Color(0xFF2D2D2D);
          inlineCodeTextColor = const Color(0xFFE0E0E0);
        } else {
          // الليل - خلفية بيج فاتحة
          inlineCodeBackground = const Color(0xFFEDE8D3);
          inlineCodeTextColor = const Color(0xFF2D2D2D);
        }

        spans.add(
          TextSpan(
            text: codeContent,
            style: TextStyle(
              fontFamily: 'Courier',
              backgroundColor: inlineCodeBackground,
              color: inlineCodeTextColor,
              height: 1.4,
              // فرض اتجاه من اليسار لليمين للكود المضمن
              locale: const Locale('en', 'US'),
            ),
          ),
        );
      } else if (closestMatch == boldMatch) {
        final text = closestMatch.group(1) ?? '';
        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: _containsArabic(text) ? 'Cairo' : null,
              height: 1.5,
            ),
          ),
        );
      } else if (closestMatch == italicMatch) {
        final text = closestMatch.group(1) ?? '';
        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontFamily: _containsArabic(text) ? 'Cairo' : null,
              height: 1.5,
            ),
          ),
        );
      }

      currentIndex += closestMatch.end;
    }

    return spans.isEmpty
        ? [
            TextSpan(
              text: content,
              style: TextStyle(
                fontFamily: _containsArabic(content) ? 'Cairo' : null,
                height: 1.5,
              ),
            ),
          ]
        : spans;
  }

  // دالة للتحقق من وجود نص عربي
  bool _containsArabic(String text) {
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );
    return arabicRegex.hasMatch(text);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}س';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}د';
    } else {
      return 'الآن';
    }
  }
}
