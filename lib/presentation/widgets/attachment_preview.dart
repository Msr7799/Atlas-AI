import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';

class AttachmentPreview extends StatelessWidget {
  final List<AttachmentModel> attachments;
  final Function(String) onRemove;

  const AttachmentPreview({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_file,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                Localizations.localeOf(context).languageCode == 'ar' ? 'ملفات مرفقة (${attachments.length})' : 'Attached files (${attachments.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...attachments.map((attachment) => _buildAttachmentItem(context, attachment)),
        ],
      ),
    );
  }

  Widget _buildAttachmentItem(BuildContext context, AttachmentModel attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(attachment.type),
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_formatFileSize(attachment.size)} • ${attachment.type.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => onRemove(attachment.id),
            tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'إزالة الملف' : 'Remove file',
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'txt':
      case 'md':
        return Icons.description;
      case 'json':
      case 'yaml':
      case 'yml':
        return Icons.data_object;
      case 'xml':
        return Icons.code;
      case 'csv':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
