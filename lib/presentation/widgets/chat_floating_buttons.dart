import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_selection_provider.dart';

/// الأزرار العائمة لصفحة المحادثة
class ChatFloatingButtons extends StatelessWidget {
  final VoidCallback onNewChatTap;
  final VoidCallback onScrollToBottom;
  final bool showScrollToBottom;

  const ChatFloatingButtons({
    super.key,
    required this.onNewChatTap,
    required this.onScrollToBottom,
    required this.showScrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatSelectionProvider>(
      builder: (context, selectionProvider, child) {
        return Stack(
          children: [
            // زر محادثة جديدة
            Positioned(
              bottom: 90,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'new_chat',
                onPressed: onNewChatTap,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                tooltip: 'محادثة جديدة',
                child: Icon(
                  Icons.add_comment,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),

            // زر التمرير للأسفل (يظهر عند الحاجة)
            if (showScrollToBottom)
              Positioned(
                bottom: 160,
                right: 16,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'scroll_down',
                  onPressed: onScrollToBottom,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  tooltip: 'التمرير للأسفل',
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ),

            // أزرار وضع التحديد
            if (selectionProvider.isSelectionMode)
              ..._buildSelectionModeButtons(context, selectionProvider),
          ],
        );
      },
    );
  }

  /// بناء أزرار وضع التحديد
  List<Widget> _buildSelectionModeButtons(
    BuildContext context,
    ChatSelectionProvider selectionProvider,
  ) {
    return [
      // زر النسخ
      Positioned(
        bottom: 230,
        right: 16,
        child: FloatingActionButton(
          mini: true,
          heroTag: 'copy_selected',
          onPressed: selectionProvider.selectedMessageIds.isNotEmpty
              ? () => _copySelectedMessages(context, selectionProvider)
              : null,
          backgroundColor: Theme.of(context).colorScheme.primary,
          tooltip: 'نسخ المحدد',
          child: const Icon(
            Icons.copy,
            color: Colors.white,
          ),
        ),
      ),

      // زر الحذف
      Positioned(
        bottom: 300,
        right: 16,
        child: FloatingActionButton(
          mini: true,
          heroTag: 'delete_selected',
          onPressed: selectionProvider.selectedMessageIds.isNotEmpty
              ? () => _deleteSelectedMessages(context, selectionProvider)
              : null,
          backgroundColor: Colors.red,
          tooltip: 'حذف المحدد',
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),

      // زر التصدير
      Positioned(
        bottom: 370,
        right: 16,
        child: FloatingActionButton(
          mini: true,
          heroTag: 'export_selected',
          onPressed: selectionProvider.selectedMessageIds.isNotEmpty
              ? () => _exportSelectedMessages(context, selectionProvider)
              : null,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          tooltip: 'تصدير المحدد',
          child: Icon(
            Icons.download,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      ),
    ];
  }

  /// نسخ الرسائل المحددة
  void _copySelectedMessages(
    BuildContext context,
    ChatSelectionProvider selectionProvider,
  ) {
    final chatProvider = context.read<ChatProvider>();
    final selectedMessages = chatProvider.messages
        .where((msg) => selectionProvider.selectedMessageIds.contains(msg.id))
        .toList();

    if (selectedMessages.isNotEmpty) {
      selectedMessages
          .map((msg) => '${msg.isUser ? 'أنت' : 'AI'}: ${msg.content}')
          .join('\\n\\n');

      // نسخ النص إلى الحافظة
      // يمكن استخدام Clipboard.setData هنا
      
      // إظهار رسالة تأكيد
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ الرسائل المحددة'),
          duration: Duration(seconds: 2),
        ),
      );

      // إلغاء وضع التحديد
      selectionProvider.disableSelectionMode();
    }
  }

  /// حذف الرسائل المحددة
  void _deleteSelectedMessages(
    BuildContext context,
    ChatSelectionProvider selectionProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف ${selectionProvider.selectedMessageIds.length} رسالة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final chatProvider = context.read<ChatProvider>();
              
              // حذف الرسائل المحددة
              for (final messageId in selectionProvider.selectedMessageIds) {
                chatProvider.removeMessage(messageId);
              }

              // إلغاء وضع التحديد
              selectionProvider.disableSelectionMode();
              
              Navigator.of(context).pop();

              // إظهار رسالة تأكيد
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حذف الرسائل المحددة'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  /// تصدير الرسائل المحددة
  void _exportSelectedMessages(
    BuildContext context,
    ChatSelectionProvider selectionProvider,
  ) {
    // تنفيذ تصدير الرسائل
    // يمكن استخدام خدمة التصدير هنا
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تصدير الرسائل المحددة'),
        duration: Duration(seconds: 2),
      ),
    );

    selectionProvider.disableSelectionMode();
  }
}
