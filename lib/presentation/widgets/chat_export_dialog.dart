import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_selection_provider.dart';
import '../../data/models/message_model.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/services/chat_export_service.dart';
import '../../generated/l10n/app_localizations.dart';

class ChatExportDialog extends StatefulWidget {
  final List<MessageModel> messages;
  final String chatTitle;

  const ChatExportDialog({
    super.key,
    required this.messages,
    required this.chatTitle,
  });

  @override
  State<ChatExportDialog> createState() => _ChatExportDialogState();
}

class _ChatExportDialogState extends State<ChatExportDialog> {
  String _selectedFormat = 'json';
  String _exportType = 'full'; // 'full', 'selected', 'all'
  bool _isExporting = false;

  Map<String, String> get _formats => {
    'json': Localizations.localeOf(context).languageCode == 'ar' ? 'JSON (للبرمجة)' : 'JSON (for programming)',
    'txt': Localizations.localeOf(context).languageCode == 'ar' ? 'نص عادي' : 'Plain Text',
    'markdown': 'Markdown',
  };

  Map<String, String> get _exportTypes => {
    'full': Localizations.localeOf(context).languageCode == 'ar' ? 'المحادثة الكاملة' : 'Full Conversation',
    'selected': Localizations.localeOf(context).languageCode == 'ar' ? 'الرسائل المحددة فقط' : 'Selected Messages Only',
    'all': Localizations.localeOf(context).languageCode == 'ar' ? 'جميع المحادثات' : 'All Conversations',
  };

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: ResponsiveHelper.getResponsiveConstraints(
            context,
            mobile: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              minWidth: 280, // حد أدنى للعرض لضمان سهولة الاستخدام // Minimum width to ensure usability
            ),
            tablet: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            desktop: const BoxConstraints(maxWidth: 800, maxHeight: 800),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withOpacity(0.95),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                _buildContent(),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.9),
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.download,
            color: Theme.of(context).colorScheme.primary.computeLuminance() > 0.5
                ? Colors.black
                : Colors.white,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? 'تصدير المحادثة' : 'Export Conversation',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' ? 'حفظ ومشاركة المحادثات' : 'Save and share conversations',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    color: (Theme.of(context).colorScheme.primary.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.primary.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: ResponsiveHelper.getResponsivePadding(
          context,
          mobile: const EdgeInsets.all(16),
          tablet: const EdgeInsets.all(20),
          desktop: const EdgeInsets.all(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            SizedBox(
              height: ResponsiveHelper.getResponsiveHeight(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            _buildExportTypeSelection(),
            SizedBox(
              height: ResponsiveHelper.getResponsiveHeight(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            _buildFormatSelection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<ChatSelectionProvider>(
      builder: (context, selectionProvider, child) {
        final stats = selectionProvider.hasSelection
            ? selectionProvider.getSelectedMessagesStats(widget.messages)
            : selectionProvider.getChatStats(widget.messages);

        return Container(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(12),
            tablet: const EdgeInsets.all(16),
            desktop: const EdgeInsets.all(20),
          ),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    color: Theme.of(context).colorScheme.primary,
                    size: ResponsiveHelper.getResponsiveIconSize(context),
                  ),
                  SizedBox(
                    width: ResponsiveHelper.getResponsiveWidth(
                      context,
                      mobile: 6,
                      tablet: 8,
                      desktop: 10,
                    ),
                  ),
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'إحصائيات المحادثة' : 'Conversation Statistics',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 16,
                        desktop: 18,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: ResponsiveHelper.getResponsiveHeight(
                  context,
                  mobile: 8,
                  tablet: 12,
                  desktop: 16,
                ),
              ),
              _buildStatRow(
                Localizations.localeOf(context).languageCode == 'ar' ? 'إجمالي الرسائل' : 'Total Messages', 
                '${stats['total_messages']}'
              ),
              _buildStatRow(
                Localizations.localeOf(context).languageCode == 'ar' ? 'رسائل المستخدم' : 'User Messages', 
                '${stats['user_messages']}'
              ),
              _buildStatRow(
                Localizations.localeOf(context).languageCode == 'ar' ? 'رسائل المساعد' : 'Assistant Messages', 
                '${stats['assistant_messages']}'
              ),
              _buildStatRow(
                Localizations.localeOf(context).languageCode == 'ar' ? 'إجمالي الأحرف' : 'Total Characters', 
                '${stats['total_characters']}'
              ),
              _buildStatRow(
                Localizations.localeOf(context).languageCode == 'ar' ? 'متوسط طول الرسالة' : 'Average Message Length',
                Localizations.localeOf(context).languageCode == 'ar' ? '${stats['average_message_length']} حرف' : '${stats['average_message_length']} chars',
              ),
              _buildStatRow(
                Localizations.localeOf(context).languageCode == 'ar' ? 'مدة المحادثة' : 'Conversation Duration',
                Localizations.localeOf(context).languageCode == 'ar' ? '${stats['chat_duration_minutes']} دقيقة' : '${stats['chat_duration_minutes']} minutes',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.symmetric(vertical: 3),
        tablet: const EdgeInsets.symmetric(vertical: 4),
        desktop: const EdgeInsets.symmetric(vertical: 5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'ar' ? 'نوع التصدير' : 'Export Type',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(
          height: ResponsiveHelper.getResponsiveHeight(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
        ),
        Consumer<ChatSelectionProvider>(
          builder: (context, selectionProvider, child) {
            return Column(
              children: _exportTypes.entries.map((entry) {
                final isDisabled =
                    entry.key == 'selected' && !selectionProvider.hasSelection;

                return RadioListTile<String>(
                  value: entry.key,
                  groupValue: _exportType,
                  onChanged: isDisabled
                      ? null
                      : (value) {
                          setState(() {
                            _exportType = value!;
                          });
                        },
                  title: Text(
                    entry.value,
                    style: TextStyle(
                      color: isDisabled
                          ? Theme.of(context).disabledColor
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle:
                      entry.key == 'selected' && !selectionProvider.hasSelection
                      ? Text(
                          Localizations.localeOf(context).languageCode == 'ar' ? 'يجب تحديد رسائل أولاً' : 'Must select messages first',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        )
                      : null,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localizations.localeOf(context).languageCode == 'ar' ? 'تنسيق الملف' : 'File Format',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(
          height: ResponsiveHelper.getResponsiveHeight(
            context,
            mobile: 8,
            tablet: 12,
            desktop: 16,
          ),
        ),
        Column(
          children: _formats.entries.map((entry) {
            return RadioListTile<String>(
              value: entry.key,
              groupValue: _selectedFormat,
              onChanged: (value) {
                setState(() {
                  _selectedFormat = value!;
                });
              },
              title: Text(
                entry.value,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 13,
                    tablet: 14,
                    desktop: 15,
                  ),
                ),
              ),
              subtitle: Text(
                _getFormatDescription(entry.key),
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 11,
                    tablet: 12,
                    desktop: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getFormatDescription(String format) {
    switch (format) {
      case 'json':
        return Localizations.localeOf(context).languageCode == 'ar' ? 'تنسيق مُنظم للبرمجة والتحليل' : 'Structured format for programming and analysis';
      case 'txt':
        return Localizations.localeOf(context).languageCode == 'ar' ? 'نص بسيط قابل للقراءة' : 'Simple readable text';
      case 'markdown':
        return Localizations.localeOf(context).languageCode == 'ar' ? 'تنسيق Markdown مع هيكلة جميلة' : 'Markdown format with beautiful structure';
      default:
        return '';
    }
  }

  Widget _buildActionButtons() {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ResponsiveHelper.isMobile(context)
          ? Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.cancel,
                      size: ResponsiveHelper.getResponsiveIconSize(context),
                    ),
                    label: Text(
                      Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _handleSaveToDevice,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.save,
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                            ),
                          ),
                    label: Text(
                      _isExporting 
                        ? (Localizations.localeOf(context).languageCode == 'ar' ? 'جاري الحفظ...' : 'Saving...')
                        : (Localizations.localeOf(context).languageCode == 'ar' ? 'حفظ' : 'Save'),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _handleShare,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.share,
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                            ),
                          ),
                    label: Text(
                      _isExporting 
                        ? (Localizations.localeOf(context).languageCode == 'ar' ? 'جاري المشاركة...' : 'Sharing...')
                        : (Localizations.localeOf(context).languageCode == 'ar' ? 'مشاركة' : 'Share'),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.cancel,
                      size: ResponsiveHelper.getResponsiveIconSize(context),
                    ),
                    label: Text(
                      Localizations.localeOf(context).languageCode == 'ar' ? 'إلغاء' : 'Cancel',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _handleSaveToDevice,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.save,
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                            ),
                          ),
                    label: Text(
                      _isExporting 
                        ? (Localizations.localeOf(context).languageCode == 'ar' ? 'جاري الحفظ...' : 'Saving...')
                        : (Localizations.localeOf(context).languageCode == 'ar' ? 'حفظ' : 'Save'),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isExporting ? null : _handleShare,
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.share,
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                            ),
                          ),
                    label: Text(
                      _isExporting 
                        ? (Localizations.localeOf(context).languageCode == 'ar' ? 'جاري المشاركة...' : 'Sharing...')
                        : (Localizations.localeOf(context).languageCode == 'ar' ? 'مشاركة' : 'Share'),
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _handleSaveToDevice() async {
    setState(() {
      _isExporting = true;
    });

    try {
      String content;
      String filename;

      switch (_exportType) {
        case 'selected':
          final selectionProvider = context.read<ChatSelectionProvider>();
          final selectedMessages = selectionProvider.getSelectedMessages(widget.messages);
          if (selectedMessages.isEmpty) {
            throw Exception(Localizations.localeOf(context).languageCode == 'ar' ? 'لم يتم تحديد أي رسائل للتصدير' : 'No messages selected for export');
          }
          content = await ChatExportService.exportSingleChat(
            messages: selectedMessages,
            chatTitle: Localizations.localeOf(context).languageCode == 'ar' ? '${widget.chatTitle} (رسائل محددة)' : '${widget.chatTitle} (Selected Messages)',
            format: _selectedFormat,
          );
          filename = '${widget.chatTitle}_selected';
          break;
        case 'all':
          final selectionProvider = context.read<ChatSelectionProvider>();
          if (selectionProvider.availableChats.isEmpty) {
            throw Exception(Localizations.localeOf(context).languageCode == 'ar' ? 'لا توجد محادثات متاحة للتصدير' : 'No conversations available for export');
          }
          content = await ChatExportService.exportMultipleChats(
            chats: selectionProvider.availableChats,
            format: _selectedFormat,
          );
          filename = 'all_chats';
          break;
        default:
          if (widget.messages.isEmpty) {
            throw Exception(Localizations.localeOf(context).languageCode == 'ar' ? 'لا توجد رسائل للتصدير' : 'No messages to export');
          }
          content = await ChatExportService.exportSingleChat(
            messages: widget.messages,
            chatTitle: widget.chatTitle,
            format: _selectedFormat,
          );
          filename = widget.chatTitle;
      }

      final filePath = await ChatExportService.saveToFile(
        content: content,
        filename: filename,
        format: _selectedFormat,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تم حفظ الملف في: $filePath' : 'File saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'فشل في حفظ الملف: $e' : 'Failed to save file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _handleShare() async {
    setState(() {
      _isExporting = true;
    });

    try {
      String content;
      String filename;

      switch (_exportType) {
        case 'selected':
          final selectionProvider = context.read<ChatSelectionProvider>();
          final selectedMessages = selectionProvider.getSelectedMessages(widget.messages);
          if (selectedMessages.isEmpty) {
            throw Exception(Localizations.localeOf(context).languageCode == 'ar' ? 'لم يتم تحديد أي رسائل للمشاركة' : 'No messages selected for sharing');
          }
          content = await ChatExportService.exportSingleChat(
            messages: selectedMessages,
            chatTitle: Localizations.localeOf(context).languageCode == 'ar' ? '${widget.chatTitle} (رسائل محددة)' : '${widget.chatTitle} (Selected Messages)',
            format: _selectedFormat,
          );
          filename = '${widget.chatTitle}_selected';
          break;
        case 'all':
          final selectionProvider = context.read<ChatSelectionProvider>();
          if (selectionProvider.availableChats.isEmpty) {
            throw Exception(Localizations.localeOf(context).languageCode == 'ar' ? 'لا توجد محادثات متاحة للمشاركة' : 'No conversations available for sharing');
          }
          content = await ChatExportService.exportMultipleChats(
            chats: selectionProvider.availableChats,
            format: _selectedFormat,
          );
          filename = 'all_chats';
          break;
        default:
          if (widget.messages.isEmpty) {
            throw Exception(Localizations.localeOf(context).languageCode == 'ar' ? 'لا توجد رسائل للمشاركة' : 'No messages to share');
          }
          content = await ChatExportService.exportSingleChat(
            messages: widget.messages,
            chatTitle: widget.chatTitle,
            format: _selectedFormat,
          );
          filename = widget.chatTitle;
      }

      await ChatExportService.shareChat(
        content: content,
        filename: filename,
        format: _selectedFormat,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'فشل في مشاركة الملف: $e' : 'Failed to share file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
