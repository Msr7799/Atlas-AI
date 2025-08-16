import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/message_model.dart';
import '../../generated/l10n/app_localizations.dart';

class ThinkingProcessWidget extends StatelessWidget {
  final ThinkingProcessModel thinkingProcess;
  final bool isExpanded;
  final VoidCallback? onToggleExpanded;

  const ThinkingProcessWidget({
    super.key,
    required this.thinkingProcess,
    this.isExpanded = true,
    this.onToggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 400, // حد أقصى للارتفاع لتجنب overflow
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // استخدام أقل مساحة ممكنة
          children: [
          // Header
          InkWell(
            onTap: onToggleExpanded,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.psychology,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      Localizations.localeOf(context).languageCode == 'ar' ? 'عملية التفكير' : 'Thinking Process',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: thinkingProcess.isComplete 
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      thinkingProcess.isComplete ? (Localizations.localeOf(context).languageCode == 'ar' ? 'مكتملة' : 'Complete') : (Localizations.localeOf(context).languageCode == 'ar' ? 'جارية' : 'In Progress'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: thinkingProcess.isComplete 
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onToggleExpanded != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Content
          if (isExpanded) ...[
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                  // Steps
                  ..._buildSteps(context),
                  
                  // Timeline info
                  if (thinkingProcess.completedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            Localizations.localeOf(context).languageCode == 'ar' ? 'اكتملت في ${_formatDuration(thinkingProcess.completedAt!.difference(thinkingProcess.startedAt), context)}' : 'Completed in ${_formatDuration(thinkingProcess.completedAt!.difference(thinkingProcess.startedAt), context)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
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
          ],
        ],
      ),
    ),
    ).animate()
     .fadeIn(duration: 300.ms)
     .slideY(begin: 0.3, end: 0);
  }

  List<Widget> _buildSteps(BuildContext context) {
    final theme = Theme.of(context);
    
    return thinkingProcess.steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      final isLast = index == thinkingProcess.steps.length - 1;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step number with connecting line
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: step.isRevision 
                        ? Colors.orange.withOpacity(0.2)
                        : theme.colorScheme.primary.withOpacity(0.2),
                    border: Border.all(
                      color: step.isRevision 
                          ? Colors.orange
                          : theme.colorScheme.primary,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${step.stepNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: step.isRevision 
                            ? Colors.orange.shade700
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 20,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            
            // Step content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.message,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (step.isRevision && step.revisesStep != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'ar' ? 'تنقيح للخطوة ${step.revisesStep}' : 'Revision of step ${step.revisesStep}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatTime(step.timestamp),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: (index * 100).ms)
       .fadeIn(duration: 300.ms)
       .slideX(begin: 0.3, end: 0);
    }).toList();
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (duration.inSeconds < 60) {
      return isArabic ? '${duration.inSeconds} ثانية' : '${duration.inSeconds} seconds';
    } else if (duration.inMinutes < 60) {
      return isArabic ? '${duration.inMinutes} دقيقة' : '${duration.inMinutes} minutes';
    } else {
      return isArabic ? '${duration.inHours} ساعة و ${duration.inMinutes % 60} دقيقة' : '${duration.inHours} hours and ${duration.inMinutes % 60} minutes';
    }
  }
}
