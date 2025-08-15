import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/models/message_model.dart';
import '../compact_message_bubble.dart';
import '../../constants/ui_constants.dart';

/// قائمة الرسائل المحسنة
class ChatMessageList extends StatelessWidget {
  final ScrollController scrollController;
  final List<MessageModel> messages;

  const ChatMessageList({
    super.key,
    required this.scrollController,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.all(UIConstants.spacing16),
      itemCount: messages.length,
      itemBuilder: (context, index) => _buildMessageItem(index),
    );
  }

  /// بناء عنصر الرسالة
  Widget _buildMessageItem(int index) {
    final message = messages[messages.length - 1 - index];
    
    return CompactMessageBubble(
      message: message,
      isUser: message.isUser,
    ).animate()
        .fadeIn(duration: UIConstants.animationDuration.ms)
        .slideY(begin: 0.1, duration: UIConstants.animationDuration.ms);
  }
}

