import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/training_task_type.dart';
import '../../providers/training_provider.dart';

class TaskSelectionWidget extends StatelessWidget {
  const TaskSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.task_alt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? 'اختيار نوع المهمة'
                          : 'Select Task Type',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // شبكة المهام المتاحة
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: provider.supportedTasks.length,
                  itemBuilder: (context, index) {
                    final task = provider.supportedTasks[index];
                    final isSelected = provider.selectedTask == task;
                    
                    return _TaskCard(
                      task: task,
                      isSelected: isSelected,
                      onTap: () => provider.setSelectedTask(task),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // وصف المهمة المختارة
                if (provider.taskDescription.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Localizations.localeOf(context).languageCode == 'ar'
                              ? 'وصف المهمة:'
                              : 'Task Description:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          provider.taskDescription,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // الأعمدة المطلوبة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? 'الأعمدة المطلوبة في البيانات:'
                            : 'Required Data Columns:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: provider.getRequiredDataColumns().map((column) {
                          return Chip(
                            label: Text(
                              column,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // النماذج المقترحة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Localizations.localeOf(context).languageCode == 'ar'
                            ? 'النماذج المقترحة:'
                            : 'Recommended Models:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: provider.getRecommendedModelsForTask().map((model) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              model,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TrainingTaskType task;
  final bool isSelected;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getTaskIcon() {
    switch (task) {
      case TrainingTaskType.sentimentAnalysis:
        return Icons.sentiment_satisfied;
      case TrainingTaskType.dialectLearning:
        return Icons.language;
      case TrainingTaskType.textClassification:
        return Icons.category;
      case TrainingTaskType.languageModeling:
        return Icons.model_training;
      case TrainingTaskType.questionAnswering:
        return Icons.quiz;
      case TrainingTaskType.textSummarization:
        return Icons.summarize;
      case TrainingTaskType.namedEntityRecognition:
        return Icons.person_search;
      case TrainingTaskType.conversationalAI:
        return Icons.chat;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: isSelected ? 8 : 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                : Theme.of(context).colorScheme.surface,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getTaskIcon(),
                size: 32,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(height: 8),
              Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? task.arabicName
                    : task.englishName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
