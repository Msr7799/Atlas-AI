import 'settings_dialog.dart';
import 'chat_export_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../../data/models/message_model.dart';
import '../providers/chat_selection_provider.dart';
import '../../generated/l10n/app_localizations.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: Image.asset(
                        'assets/icons/ATLAS_icon2.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.chat_bubble_outline,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 32,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Atlas AI',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // New Chat Button
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'محادثة جديدة' : 'New Chat'),
            onTap: () {
              context.read<ChatProvider>().createNewSession();
              Navigator.pop(context);
            },
          ),

          // Export Chat Button
          Consumer2<ChatProvider, ChatSelectionProvider>(
            builder: (context, chatProvider, selectionProvider, child) {
              return ExpansionTile(
                leading: const Icon(Icons.download),
                title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تصدير المحادثات' : 'Export Chats'),
                children: [
                  // Export Selected Messages (if in selection mode)
                  if (selectionProvider.isSelectionMode &&
                      selectionProvider.selectedMessageIds.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.check_box),
                      title: Text(
                        Localizations.localeOf(context).languageCode == 'ar' ? 'تصدير المحدد (${selectionProvider.selectedMessageIds.length})' : 'Export Selected (${selectionProvider.selectedMessageIds.length})',
                      ),
                      onTap: () {
                        _showExportDialog(
                          context,
                          chatProvider,
                          true,
                          selectionProvider,
                          selectionProvider.getSelectedMessages(chatProvider.messages),
                        );
                        Navigator.pop(context);
                      },
                    ),

                  // Export All Messages
                  ListTile(
                    leading: const Icon(Icons.download_outlined),
                    title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تصدير جميع المحادثات' : 'Export All Chats'),
                    onTap: () async {
                      final allMessages = await chatProvider.getAllMessagesFromAllSessions();
                      _showExportDialog(context, chatProvider, false, null, allMessages);
                      Navigator.pop(context);
                    },
                  ),

                  // Export Current Session
                  if (chatProvider.messages.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.file_download),
                      title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تصدير الجلسة الحالية' : 'Export Current Session'),
                      onTap: () {
                        _showCurrentSessionExportDialog(context, chatProvider);
                        Navigator.pop(context);
                      },
                    ),
                ],
              );
            },
          ),

          const Divider(),

          // Storage Note
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.storage,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'الحد الأقصى للمحادثات المحفوظة: 50 محادثة أو 100 ميجا' : 'Max saved chats: 50 conversations or 100 MB',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sessions List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                // عرض محادثة فارغة بدلاً من infinite loop خطير
                if (chatProvider.sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar' ? 'لا توجد محادثات محفوظة' : 'No saved conversations',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar' ? 'ابدأ محادثة جديدة لحفظها' : 'Start a new conversation to save it',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await chatProvider.loadSessions();
                          },
                          icon: const Icon(Icons.refresh),
                          label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة تحميل' : 'Reload'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: chatProvider.sessions.length,
                  itemBuilder: (context, index) {
                    final session = chatProvider.sessions[index];
                    return _buildSessionTile(context, session, chatProvider);
                  },
                );
              },
            ),
          ),

          const Divider(),

          // Settings and Theme Options
          ListTile(
            leading: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                );
              },
            ),
            title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تبديل المظهر' : 'Toggle Theme'),
            onTap: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),

          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'الإعدادات' : 'Settings'),
            onTap: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حول التطبيق' : 'About App'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSessionTile(
    BuildContext context,
    ChatSessionModel session,
    ChatProvider chatProvider,
  ) {
    final isCurrentSession = session.id == chatProvider.currentSessionId;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isCurrentSession 
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
          : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCurrentSession 
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            isCurrentSession ? Icons.chat_bubble : Icons.chat_bubble_outline,
            color: isCurrentSession 
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isCurrentSession ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(session.createdAt, context),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (isCurrentSession)
              Text(
                Localizations.localeOf(context).languageCode == 'ar' ? '● الجلسة الحالية' : '● Current Session',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'rename':
                _showRenameDialog(context, session, chatProvider);
                break;
              case 'delete':
                _showDeleteConfirmation(context, session.id, chatProvider);
                break;
              case 'export':
                await _showSessionExportDialog(context, session, chatProvider);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  const Icon(Icons.download, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تصدير الجلسة' : 'Export Session', style: const TextStyle(color: Colors.blue)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة تسمية' : 'Rename'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {
          print('🔄 [DRAWER] محاولة تحميل الجلسة: ${session.title} | Attempting to load session: ${session.title}');
          try {
            await chatProvider.loadSession(session.id);
            Navigator.pop(context);
            print('✅ [DRAWER] تم تحميل الجلسة بنجاح | Session loaded successfully');
          } catch (e) {
            print('❌ [DRAWER] خطأ في تحميل الجلسة: $e | Error loading session: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'خطأ في تحميل المحادثة: $e' : 'Error loading conversation: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays < 1) {
      if (diff.inHours < 1) {
        return Localizations.localeOf(context).languageCode == 'ar' ? '${diff.inMinutes} دقيقة' : '${diff.inMinutes} min';
      }
      return Localizations.localeOf(context).languageCode == 'ar' ? '${diff.inHours} ساعة' : '${diff.inHours} hr';
    } else if (diff.inDays < 7) {
      return Localizations.localeOf(context).languageCode == 'ar' ? '${diff.inDays} يوم' : '${diff.inDays} day';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String sessionId,
    ChatProvider chatProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تأكيد الحذف' : 'Confirm Delete'),
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar' ? 'هل أنت متأكد من حذف هذه المحادثة؟ لا يمكن التراجع عن هذا الإجراء.' : 'Are you sure you want to delete this conversation? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              chatProvider.deleteSession(sessionId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    ChatSessionModel session,
    ChatProvider chatProvider,
  ) {
    final controller = TextEditingController(text: session.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إعادة تسمية المحادثة' : 'Rename Conversation'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: Localizations.localeOf(context).languageCode == 'ar' ? 'اسم المحادثة الجديد' : 'New conversation name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement rename functionality
              Navigator.pop(context);
            },
            child: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'حول التطبيق' : 'About App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Atlas AI'),
            const SizedBox(height: 8),
            Text(isArabic ? 'الإصدار: 1.0.0' : 'Version: 1.0.0'),
            const SizedBox(height: 8),
            Text(isArabic ? 'تطوير: Mohamed S AL-Romaihi' : 'Developer: Mohamed S AL-Romaihi'),
            const SizedBox(height: 8),
            Text(isArabic ? 'مساعد ذكي يدعم اللغة العربية مع ميزات متقدمة.' : 'Intelligent assistant supporting Arabic with advanced features.'),
            const SizedBox(height: 8),
            Text(isArabic ? 'الموقع: www.atlasai.com' : 'Website: www.atlasai.com'),
            const SizedBox(height: 8),
            Text(isArabic ? 'البريد الإلكتروني: alromaihi2224@gmail.com' : 'Email: alromaihi2224@gmail.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'موافق' : 'OK'),
          ),
        ],
      ),
    );
  }

  /// عرض حوار تصدير المحادثات
  void _showExportDialog(
    BuildContext context,
    ChatProvider chatProvider,
    bool exportSelected,
    ChatSelectionProvider? selectionProvider,
    List<MessageModel> messagesToExport,
  ) {
    String dialogTitle;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    if (exportSelected && selectionProvider != null) {
      // تصدير الرسائل المحددة
      dialogTitle = isArabic 
          ? 'تصدير الرسائل المحددة (${messagesToExport.length})'
          : 'Export Selected Messages (${messagesToExport.length})';
    } else {
      // تصدير جميع الرسائل
      dialogTitle = isArabic 
          ? 'تصدير جميع المحادثات'
          : 'Export All Conversations';
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: ChatExportDialog(
            messages: messagesToExport,
            chatTitle: dialogTitle,
          ),
        ),
      ),
    );
  }

  /// عرض حوار تصدير الجلسة الحالية
  void _showCurrentSessionExportDialog(
    BuildContext context,
    ChatProvider chatProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: ChatExportDialog(
            messages: chatProvider.messages,
            chatTitle: Localizations.localeOf(context).languageCode == 'ar'
                ? 'الجلسة الحالية - ${DateTime.now().toString().split(' ')[0]}'
                : 'Current Session - ${DateTime.now().toString().split(' ')[0]}',
          ),
        ),
      ),
    );
  }

  /// عرض حوار تصدير جلسة محددة
  Future<void> _showSessionExportDialog(
    BuildContext context,
    ChatSessionModel session,
    ChatProvider chatProvider,
  ) async {
    try {
      // تحميل رسائل الجلسة المحددة
      final sessionMessages = await chatProvider.getSessionMessages(session.id);
      
      if (!context.mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: ChatExportDialog(
              messages: sessionMessages,
              chatTitle: '${session.title} - ${_formatDate(session.createdAt, context)}',
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'خطأ في تحميل الجلسة للتصدير: $e'
                : 'Error loading session for export: $e'
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
