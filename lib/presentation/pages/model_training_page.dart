import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';
import '../widgets/training_progress_widget.dart';
import '../widgets/training_config_widget.dart';
import '../widgets/training_logs_widget.dart';

class ModelTrainingPage extends StatefulWidget {
  const ModelTrainingPage({super.key});

  @override
  State<ModelTrainingPage> createState() => _ModelTrainingPageState();
}

class _ModelTrainingPageState extends State<ModelTrainingPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // تهيئة خدمة التدريب
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrainingProvider>().initializeTraining();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 تدريب النموذج المتقدم'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'الإعدادات'),
            Tab(icon: Icon(Icons.analytics), text: 'التقدم'),
            Tab(icon: Icon(Icons.terminal), text: 'السجلات'),
          ],
        ),
      ),
      body: Column(
        children: [
          // شريط حالة التدريب
          Consumer<TrainingProvider>(
            builder: (context, provider, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: provider.isTraining
                        ? [Colors.orange.shade100, Colors.orange.shade50]
                        : [Colors.green.shade100, Colors.green.shade50],
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      provider.isTraining
                          ? Icons.play_circle_filled
                          : Icons.check_circle,
                      color: provider.isTraining ? Colors.orange : Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.isTraining
                                ? '🔥 التدريب قيد التشغيل...'
                                : '✅ النظام جاهز للتدريب',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (provider.isTraining)
                            Text(
                              '${(provider.trainingProgress * 100).toStringAsFixed(1)}% مكتمل',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (provider.isTraining)
                      ElevatedButton.icon(
                        onPressed: () => provider.stopTraining(),
                        icon: const Icon(Icons.stop),
                        label: const Text('إيقاف'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          // محتوى التبويبات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                TrainingConfigWidget(),
                TrainingProgressWidget(),
                TrainingLogsWidget(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<TrainingProvider>(
        builder: (context, provider, child) {
          if (provider.isTraining) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () => _showStartTrainingDialog(context),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.rocket_launch),
            label: const Text('🚀 بدء التدريب'),
          );
        },
      ),
    );
  }

  void _showStartTrainingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚀 بدء التدريب'),
        content: const Text(
          'هل أنت متأكد من بدء عملية تدريب النموذج؟\n\n'
          'قد تستغرق العملية عدة ساعات حسب حجم البيانات وقوة الجهاز.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TrainingProvider>().startTraining();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('بدء التدريب'),
          ),
        ],
      ),
    );
  }
}
