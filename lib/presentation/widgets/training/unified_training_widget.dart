import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/training_provider.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Widget موحد لجميع وظائف التدريب
class UnifiedTrainingWidget extends StatefulWidget {
  const UnifiedTrainingWidget({super.key});

  @override
  State<UnifiedTrainingWidget> createState() => _UnifiedTrainingWidgetState();
}

class _UnifiedTrainingWidgetState extends State<UnifiedTrainingWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingProvider>(
      builder: (context, training, child) {
        return Column(
          children: [
            // Header مع معلومات سريعة
            _buildHeader(training),
            
            // Tabs
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: const Icon(Icons.settings), text: Localizations.localeOf(context).languageCode == 'ar' ? 'الإعدادات' : 'Settings'),
                Tab(icon: const Icon(Icons.trending_up), text: Localizations.localeOf(context).languageCode == 'ar' ? 'التقدم' : 'Progress'),
                Tab(icon: const Icon(Icons.history), text: Localizations.localeOf(context).languageCode == 'ar' ? 'السجلات' : 'Logs'),
              ],
            ),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildConfigTab(training),
                  _buildProgressTab(training),
                  _buildLogsTab(training),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(TrainingProvider training) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Status Icon
          CircleAvatar(
            backgroundColor: _getStatusColor(training.status),
            child: Icon(
              _getStatusIcon(training.status),
              color: Colors.white,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Localizations.localeOf(context).languageCode == 'ar' 
                      ? 'حالة التدريب: ${_getStatusText(training.status, true)}'
                      : 'Training Status: ${_getStatusText(training.status, false)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (training.isTraining)
                  Text(Localizations.localeOf(context).languageCode == 'ar' 
                      ? 'التقدم: ${(training.progress * 100).toInt()}%'
                      : 'Progress: ${(training.progress * 100).toInt()}%'),
                if (training.currentEpoch > 0)
                  Text(Localizations.localeOf(context).languageCode == 'ar' 
                      ? 'الحقبة: ${training.currentEpoch}/${training.totalEpochs}'
                      : 'Epoch: ${training.currentEpoch}/${training.totalEpochs}'),
              ],
            ),
          ),
          
          // Quick Actions
          Row(
            children: [
              if (!training.isTraining)
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: training.canStartTraining ? training.startTraining : null,
                  tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'بدء التدريب' : 'Start Training',
                ),
              if (training.isTraining)
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: training.pauseTraining,
                  tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'إيقاف مؤقت' : 'Pause Training',
                ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: training.isTraining ? training.stopTraining : null,
                tooltip: Localizations.localeOf(context).languageCode == 'ar' ? 'إيقاف التدريب' : 'Stop Training',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTab(TrainingProvider training) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'اختيار النموذج' : 'Model Selection',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: training.selectedModel,
                    decoration: InputDecoration(
                      labelText: Localizations.localeOf(context).languageCode == 'ar' ? 'النموذج الأساسي' : 'Base Model',
                      border: const OutlineInputBorder(),
                    ),
                    items: training.availableModels.map((model) {
                      return DropdownMenuItem(value: model, child: Text(model));
                    }).toList(),
                    onChanged: training.setSelectedModel,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Training Parameters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'معاملات التدريب' : 'Training Parameters',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 16),
                  
                  // Learning Rate
                  Text(Localizations.localeOf(context).languageCode == 'ar' 
                      ? 'معدل التعلم: ${training.learningRate.toStringAsFixed(6)}'
                      : 'Learning Rate: ${training.learningRate.toStringAsFixed(6)}'),
                  Slider(
                    value: training.learningRate,
                    min: 0.00001,
                    max: 0.01,
                    divisions: 100,
                    onChanged: training.setLearningRate,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Batch Size
                  Text(Localizations.localeOf(context).languageCode == 'ar' 
                      ? 'حجم الدفعة: ${training.batchSize}'
                      : 'Batch Size: ${training.batchSize}'),
                  Slider(
                    value: training.batchSize.toDouble(),
                    min: 1,
                    max: 64,
                    divisions: 63,
                    onChanged: (value) => training.setBatchSize(value.toInt()),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Epochs
                  Text(Localizations.localeOf(context).languageCode == 'ar' 
                      ? 'عدد الحقب: ${training.totalEpochs}'
                      : 'Epochs: ${training.totalEpochs}'),
                  Slider(
                    value: training.totalEpochs.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    onChanged: (value) => training.setTotalEpochs(value.toInt()),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Dataset
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'مجموعة البيانات' : 'Dataset',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 8),
                  
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'رفع ملف البيانات' : 'Upload Dataset File'),
                    subtitle: Text(training.datasetPath.isEmpty 
                        ? (Localizations.localeOf(context).languageCode == 'ar' ? 'لم يتم اختيار ملف' : 'No file selected')
                        : training.datasetPath),
                    trailing: const Icon(Icons.folder_open),
                    onTap: training.selectDataset,
                  ),
                  
                  if (training.datasetInfo.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        Localizations.localeOf(context).languageCode == 'ar' 
                            ? 'معلومات البيانات: ${training.datasetInfo}'
                            : 'Dataset Info: ${training.datasetInfo}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab(TrainingProvider training) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall Progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'التقدم الإجمالي' : 'Overall Progress',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 16),
                  
                  LinearProgressIndicator(
                    value: training.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                  ),
                  
                  const SizedBox(height: 8),
                  Text('${(training.progress * 100).toInt()}%'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Metrics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Localizations.localeOf(context).languageCode == 'ar' ? 'المقاييس' : 'Metrics',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard('Loss', training.currentLoss.toStringAsFixed(4), Colors.red),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard('Accuracy', '${(training.currentAccuracy * 100).toInt()}%', Colors.green),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          Localizations.localeOf(context).languageCode == 'ar' ? 'الوقت المتبقي' : 'Time Remaining',
                          training.estimatedTimeRemaining, 
                          Colors.blue
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard(
                          Localizations.localeOf(context).languageCode == 'ar' ? 'السرعة' : 'Speed',
                          '${training.samplesPerSecond.toStringAsFixed(1)}/s', 
                          Colors.orange
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Chart placeholder
          if (training.isTraining)
            Card(
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'ar' 
                        ? 'رسم بياني للتقدم\n(سيتم إضافته لاحقاً)'
                        : 'Progress Chart\n(Coming Soon)'
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogsTab(TrainingProvider training) {
    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تحديث' : 'Refresh'),
                onPressed: training.refreshLogs,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.clear),
                label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'مسح' : 'Clear'),
                onPressed: training.clearLogs,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: Text(Localizations.localeOf(context).languageCode == 'ar' ? 'تصدير' : 'Export'),
                onPressed: training.exportLogs,
              ),
            ],
          ),
        ),
        
        // Logs
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: training.logs.length,
              itemBuilder: (context, index) {
                final log = training.logs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    log,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'training': return Colors.blue;
      case 'completed': return Colors.green;
      case 'error': return Colors.red;
      case 'paused': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'training': return Icons.play_arrow;
      case 'completed': return Icons.check;
      case 'error': return Icons.error;
      case 'paused': return Icons.pause;
      default: return Icons.stop;
    }
  }

  String _getStatusText(String status, bool isArabic) {
    if (isArabic) {
      switch (status) {
        case 'training': return 'قيد التدريب';
        case 'completed': return 'مكتمل';
        case 'error': return 'خطأ';
        case 'paused': return 'متوقف مؤقتاً';
        default: return 'متوقف';
      }
    } else {
      switch (status) {
        case 'training': return 'Training';
        case 'completed': return 'Completed';
        case 'error': return 'Error';
        case 'paused': return 'Paused';
        default: return 'Stopped';
      }
    }
  }
}
