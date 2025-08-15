import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/training_provider.dart';

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
              tabs: const [
                Tab(icon: Icon(Icons.settings), text: 'الإعدادات'),
                Tab(icon: Icon(Icons.trending_up), text: 'التقدم'),
                Tab(icon: Icon(Icons.history), text: 'السجلات'),
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
                  'حالة التدريب: ${_getStatusText(training.status)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (training.isTraining)
                  Text('التقدم: ${(training.progress * 100).toInt()}%'),
                if (training.currentEpoch > 0)
                  Text('الحقبة: ${training.currentEpoch}/${training.totalEpochs}'),
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
                  tooltip: 'بدء التدريب',
                ),
              if (training.isTraining)
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: training.pauseTraining,
                  tooltip: 'إيقاف مؤقت',
                ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: training.isTraining ? training.stopTraining : null,
                tooltip: 'إيقاف التدريب',
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
                  const Text('اختيار النموذج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: training.selectedModel,
                    decoration: const InputDecoration(
                      labelText: 'النموذج الأساسي',
                      border: OutlineInputBorder(),
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
                  const Text('معاملات التدريب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  // Learning Rate
                  Text('معدل التعلم: ${training.learningRate.toStringAsFixed(6)}'),
                  Slider(
                    value: training.learningRate,
                    min: 0.00001,
                    max: 0.01,
                    divisions: 100,
                    onChanged: training.setLearningRate,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Batch Size
                  Text('حجم الدفعة: ${training.batchSize}'),
                  Slider(
                    value: training.batchSize.toDouble(),
                    min: 1,
                    max: 64,
                    divisions: 63,
                    onChanged: (value) => training.setBatchSize(value.toInt()),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Epochs
                  Text('عدد الحقب: ${training.totalEpochs}'),
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
                  const Text('مجموعة البيانات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('رفع ملف البيانات'),
                    subtitle: Text(training.datasetPath.isEmpty ? 'لم يتم اختيار ملف' : training.datasetPath),
                    trailing: const Icon(Icons.folder_open),
                    onTap: training.selectDataset,
                  ),
                  
                  if (training.datasetInfo.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'معلومات البيانات: ${training.datasetInfo}',
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
                  const Text('التقدم الإجمالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  const Text('المقاييس', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        child: _buildMetricCard('الوقت المتبقي', training.estimatedTimeRemaining, Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMetricCard('السرعة', '${training.samplesPerSecond.toStringAsFixed(1)}/s', Colors.orange),
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
                child: const Center(
                  child: Text('رسم بياني للتقدم\n(سيتم إضافته لاحقاً)'),
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
                label: const Text('تحديث'),
                onPressed: training.refreshLogs,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('مسح'),
                onPressed: training.clearLogs,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('تصدير'),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'training': return 'قيد التدريب';
      case 'completed': return 'مكتمل';
      case 'error': return 'خطأ';
      case 'paused': return 'متوقف مؤقتاً';
      default: return 'متوقف';
    }
  }
}
