import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';

class TrainingProgressWidget extends StatelessWidget {
  const TrainingProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط التقدم الرئيسي
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            provider.isTraining
                                ? Icons.play_circle_filled
                                : Icons.check_circle,
                            color: provider.isTraining
                                ? Colors.orange
                                : Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.isTraining
                                  ? '🔥 التدريب قيد التشغيل'
                                  : provider.trainingProgress >= 1.0
                                  ? '✅ تم الانتهاء من التدريب'
                                  : '⏸️ التدريب متوقف',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // شريط التقدم
                      LinearProgressIndicator(
                        value: provider.trainingProgress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          provider.trainingProgress >= 1.0
                              ? Colors.green
                              : provider.isTraining
                              ? Colors.blue
                              : Colors.orange,
                        ),
                        minHeight: 8,
                      ),

                      const SizedBox(height: 12),

                      // نسبة التقدم والخطوة الحالية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(provider.trainingProgress * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              provider.currentStep,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // إحصائيات التدريب
              if (provider.isTraining || provider.trainingProgress > 0) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.analytics, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'إحصائيات التدريب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // معلومات الحالة
                        _buildStatRow(
                          'الحالة',
                          provider.isTraining ? 'قيد التشغيل' : 'متوقف',
                          provider.isTraining ? Colors.green : Colors.orange,
                        ),

                        _buildStatRow(
                          'الخطوة الحالية',
                          provider.currentStep,
                          Colors.blue,
                        ),

                        if (provider.errorMessage.isNotEmpty)
                          _buildStatRow(
                            'رسالة الخطأ',
                            provider.errorMessage,
                            Colors.red,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // معلومات النموذج والبيانات
              FutureBuilder<Map<String, dynamic>>(
                future: provider.getDatasetInfo(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final data = snapshot.data!;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.dataset, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'معلومات البيانات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildStatRow(
                              'إجمالي الخلايا',
                              '${data['json_cells'] ?? 0}',
                              Colors.blue,
                            ),

                            _buildStatRow(
                              'خلايا الكود',
                              '${data['json_code_cells'] ?? 0}',
                              Colors.green,
                            ),

                            _buildStatRow(
                              'حجم Parquet',
                              '${(data['parquet_size_mb'] ?? 0).toStringAsFixed(2)} MB',
                              Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 16),

              // نتائج التدريب (إذا اكتمل)
              if (provider.trainingProgress >= 1.0) ...[
                FutureBuilder<Map<String, dynamic>?>(
                  future: provider.evaluateModel(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      final evaluation = snapshot.data!;
                      return Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'نتائج التدريب',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              _buildStatRow(
                                'وقت التدريب',
                                '${(evaluation['total_training_time_minutes'] ?? 0).toStringAsFixed(1)} دقيقة',
                                Colors.blue,
                              ),

                              _buildStatRow(
                                'عينات التدريب',
                                '${evaluation['train_dataset_size'] ?? 0}',
                                Colors.green,
                              ),

                              _buildStatRow(
                                'Loss النهائي',
                                '${(evaluation['training_loss'] ?? 0).toStringAsFixed(4)}',
                                Colors.orange,
                              ),

                              _buildStatRow(
                                'النموذج المستخدم',
                                evaluation['model_name'] ?? 'غير محدد',
                                Colors.purple,
                              ),

                              const SizedBox(height: 16),

                              // أزرار الإجراءات
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final path = await provider
                                            .exportTrainedModel();
                                        if (path != null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'تم تصدير النموذج: $path',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(Icons.file_download),
                                      label: const Text('تصدير النموذج'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
