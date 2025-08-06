import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../data/models/message_model.dart';
import '../providers/chat_selection_provider.dart';

class CodeElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeElementBuilder(this.context);

  @override
  Widget? visitElementAfter(element, preferredStyle) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Text(
        element.textContent,
        style: TextStyle(
          fontFamily: 'Courier',
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
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
                        // Message content - يمكن تحديد النص منه
                        Padding(
                          padding: const EdgeInsets.all(16),
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
        // لا توجد تنسيقات أخرى
        spans.add(TextSpan(text: textToProcess));
        break;
      }

      Match closestMatch = matches.reduce(
        (a, b) => a!.start < b!.start ? a : b,
      )!;

      // إضافة النص قبل التنسيق
      if (closestMatch.start > 0) {
        spans.add(
          TextSpan(text: textToProcess.substring(0, closestMatch.start)),
        );
      }

      // إضافة النص المنسق
      if (closestMatch == codeBlockMatch) {
        spans.add(
          TextSpan(
            text: closestMatch.group(2) ?? '',
            style: TextStyle(
              fontFamily: 'Courier',
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      } else if (closestMatch == inlineCodeMatch) {
        spans.add(
          TextSpan(
            text: closestMatch.group(1) ?? '',
            style: TextStyle(
              fontFamily: 'Courier',
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      } else if (closestMatch == boldMatch) {
        spans.add(
          TextSpan(
            text: closestMatch.group(1) ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else if (closestMatch == italicMatch) {
        spans.add(
          TextSpan(
            text: closestMatch.group(1) ?? '',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }

      currentIndex += closestMatch.end;
    }

    return spans.isEmpty ? [TextSpan(text: content)] : spans;
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
