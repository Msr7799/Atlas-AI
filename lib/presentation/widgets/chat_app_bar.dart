import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/chat_selection_provider.dart';

/// شريط العلوي المخصص لصفحة المحادثة
class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AnimationController fadeController;
  final AnimationController slideController;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const ChatAppBar({
    super.key,
    required this.fadeController,
    required this.slideController,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1F2428),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.primary,
      ),
      title: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Atlas AI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: const Color.fromARGB(64, 68, 67, 67)
                                .withOpacity(0.3),
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Consumer<ChatSelectionProvider>(
          builder: (context, selectionProvider, child) {
            if (selectionProvider.isSelectionMode) {
              return _buildSelectionActions(context, selectionProvider);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// بناء أزرار وضع التحديد
  Widget _buildSelectionActions(
    BuildContext context,
    ChatSelectionProvider selectionProvider,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // إلغاء التحديد
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            selectionProvider.disableSelectionMode();
          },
          tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء التحديد' : 'Cancel Selection',
        ),
        // تحديد الكل / إلغاء تحديد الكل
        IconButton(
          icon: Icon(
            selectionProvider.selectedMessageIds.isEmpty
                ? Icons.select_all
                : Icons.deselect,
          ),
          onPressed: () {
            final chatProvider = context.read<ChatProvider>();
            if (selectionProvider.selectedMessageIds.isEmpty) {
              // تحديد جميع الرسائل
              for (final message in chatProvider.messages) {
                selectionProvider.selectMessage(message.id);
              }
            } else {
              // إلغاء تحديد الكل
              selectionProvider.disableSelectionMode();
            }
          },
          tooltip: selectionProvider.selectedMessageIds.isEmpty
              ? (Localizations.localeOf(context).languageCode == 'ar' ? 'تحديد الكل' : 'Select All')
              : (Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء تحديد الكل' : 'Deselect All'),
        ),
        // عرض عدد المحدد
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
