import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/message_model.dart';
import '../widgets/compact_message_bubble.dart';
import '../widgets/thinking_process_widget.dart';
import '../providers/chat_selection_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../generated/l10n/app_localizations.dart';


/// عرض قائمة الرسائل في المحادثة
class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;
  final bool isKeyboardVisible;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.isKeyboardVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<ChatProvider, ChatSelectionProvider>(
      builder: (context, chatProvider, selectionProvider, child) {
        final messages = chatProvider.messages;

        if (messages.isEmpty && !chatProvider.isTyping) {
          return _buildEmptyState(context);
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.95),
              ],
            ),
          ),
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: 16,
              bottom: isKeyboardVisible ? 120 : 180,
              left: 16,
              right: 16,
            ),
            itemCount: messages.length + (chatProvider.isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              // عرض مؤشر الكتابة في النهاية
              if (index == messages.length && chatProvider.isTyping) {
                return _buildTypingIndicator(context, chatProvider);
              }

              final message = messages[index];
              final isSelected = selectionProvider.isMessageSelected(message.id);

              return _buildMessageItem(
                context,
                message,
                isSelected,
                selectionProvider,
              );
            },
          ),
        );
      },
    );
  }

  /// بناء حالة القائمة الفارغة
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            Localizations.localeOf(context).languageCode == 'ar' ? 'مرحباً بك في Atlas AI!' : 'Welcome to Atlas AI!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            Localizations.localeOf(context).languageCode == 'ar' ? 'ابدأ محادثتك الأولى' : 'Start your first conversation',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                  fontFamily: 'Amiri',
                ),
          ),
          const SizedBox(height: 32),
          _buildSuggestedPrompts(context),
        ],
      ),
    );
  }

  /// بناء الاقتراحات المبدئية
  Widget _buildSuggestedPrompts(BuildContext context) {
    final suggestions = Localizations.localeOf(context).languageCode == 'ar' ? [
      'اشرح لي كيف يعمل الذكاء الاصطناعي',
      'اكتب لي قصة قصيرة عن المستقبل',
      'ساعدني في تعلم لغة البرمجة',
      'اقترح أفكار لمشروع جديد',
    ] : [
      'Explain how artificial intelligence works',
      'Write me a short story about the future',
      'Help me learn programming language',
      'Suggest ideas for a new project',
    ];

    return Column(
      children: suggestions.map((suggestion) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 32),
          child: InkWell(
            onTap: () {
              final chatProvider = context.read<ChatProvider>();
              chatProvider.sendMessage(suggestion);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Amiri',
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// بناء عنصر الرسالة
  Widget _buildMessageItem(
    BuildContext context,
    MessageModel message,
    bool isSelected,
    ChatSelectionProvider selectionProvider,
  ) {
    return GestureDetector(
      onLongPress: () {
        if (!selectionProvider.isSelectionMode) {
          selectionProvider.enableSelectionMode();
        }
        selectionProvider.toggleMessageSelection(message.id);
      },
      onTap: () {
        if (selectionProvider.isSelectionMode) {
          selectionProvider.toggleMessageSelection(message.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              )
            : null,
        child: Stack(
          children: [
            CompactMessageBubble(
              message: message,
              isUser: message.isUser,
            ).animate(),
            // مؤشر التحديد
            if (isSelected)
              Positioned(
                top: 8,
                right: message.isUser ? 8 : null,
                left: message.isUser ? null : 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// بناء مؤشر الكتابة
  Widget _buildTypingIndicator(BuildContext context, ChatProvider chatProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // عرض عملية التفكير إذا كانت متاحة
                if (chatProvider.currentThinking != null)
                  Flexible(
                    child: ThinkingProcessWidget(
                      thinkingProcess: chatProvider.currentThinking!,
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar' ? 'AI يكتب...' : 'AI is typing...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Amiri',
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
