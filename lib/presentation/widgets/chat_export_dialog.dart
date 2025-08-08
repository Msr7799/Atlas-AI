import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/chat_selection_provider.dart';
import '../../data/models/message_model.dart';
import '../../core/utils/responsive_helper.dart';

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

  final Map<String, String> _formats = {
    'json': 'JSON (للبرمجة)',
    'txt': 'نص عادي',
    'markdown': 'Markdown',
  };

  final Map<String, String> _exportTypes = {
    'full': 'المحادثة الكاملة',
    'selected': 'الرسائل المحددة فقط',
    'all': 'جميع المحادثات',
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
              maxHeight: MediaQuery.of(context).size.height * 0.8,
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
            AppTheme.gradientStart.withOpacity(0.8),
            AppTheme.gradientEnd.withOpacity(0.6),
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.download,
            color: Colors.white,
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
                  'تصدير المحادثة',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'حفظ ومشاركة المحادثات',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Colors.white,
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
                    'إحصائيات المحادثة',
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
              _buildStatRow('إجمالي الرسائل', '${stats['total_messages']}'),
              _buildStatRow('رسائل المستخدم', '${stats['user_messages']}'),
              _buildStatRow('رسائل المساعد', '${stats['assistant_messages']}'),
              _buildStatRow('إجمالي الأحرف', '${stats['total_characters']}'),
              _buildStatRow(
                'متوسط طول الرسالة',
                '${stats['average_message_length']} حرف',
              ),
              _buildStatRow(
                'مدة المحادثة',
                '${stats['chat_duration_minutes']} دقيقة',
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
          'نوع التصدير',
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
                          'يجب تحديد رسائل أولاً',
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
          'تنسيق الملف',
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
        return 'تنسيق مُنظم للبرمجة والتحليل';
      case 'txt':
        return 'نص بسيط قابل للقراءة';
      case 'markdown':
        return 'تنسيق Markdown مع هيكلة جميلة';
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
                      'إلغاء',
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
                      _isExporting ? 'جاري الحفظ...' : 'حفظ',
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
                      _isExporting ? 'جاري المشاركة...' : 'مشاركة',
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
                      'إلغاء',
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
                      _isExporting ? 'جاري الحفظ...' : 'حفظ',
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
                      _isExporting ? 'جاري المشاركة...' : 'مشاركة',
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
      final selectionProvider = context.read<ChatSelectionProvider>();
      String content;
      String filename;

      switch (_exportType) {
        case 'selected':
          content = await selectionProvider.exportSelectedMessages(
            allMessages: widget.messages,
            chatTitle: widget.chatTitle,
            format: _selectedFormat,
          );
          filename = '${widget.chatTitle}_selected';
          break;
        case 'all':
          content = await selectionProvider.exportAllChats(
            format: _selectedFormat,
          );
          filename = 'all_chats';
          break;
        default:
          content = await selectionProvider.exportFullChat(
            messages: widget.messages,
            chatTitle: widget.chatTitle,
            format: _selectedFormat,
          );
          filename = widget.chatTitle;
      }

      final filePath = await selectionProvider.saveToFile(
        content: content,
        filename: filename,
        format: _selectedFormat,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ الملف في: $filePath'),
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
            content: Text('فشل في حفظ الملف: $e'),
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
      final selectionProvider = context.read<ChatSelectionProvider>();
      String content;
      String filename;

      switch (_exportType) {
        case 'selected':
          content = await selectionProvider.exportSelectedMessages(
            allMessages: widget.messages,
            chatTitle: widget.chatTitle,
            format: _selectedFormat,
          );
          filename = '${widget.chatTitle}_selected';
          break;
        case 'all':
          content = await selectionProvider.exportAllChats(
            format: _selectedFormat,
          );
          filename = 'all_chats';
          break;
        default:
          content = await selectionProvider.exportFullChat(
            messages: widget.messages,
            chatTitle: widget.chatTitle,
            format: _selectedFormat,
          );
          filename = widget.chatTitle;
      }

      await selectionProvider.shareChat(
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
            content: Text('فشل في مشاركة الملف: $e'),
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
