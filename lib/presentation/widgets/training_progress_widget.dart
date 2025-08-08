import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';
import '../../core/utils/responsive_helper.dart';

class TrainingProgressWidget extends StatelessWidget {
  const TrainingProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(16),
            tablet: const EdgeInsets.all(20),
            desktop: const EdgeInsets.all(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط التقدم الرئيسي
              Card(
                child: Padding(
                  padding: ResponsiveHelper.getResponsivePadding(
                    context,
                    mobile: const EdgeInsets.all(20),
                    tablet: const EdgeInsets.all(24),
                    desktop: const EdgeInsets.all(28),
                  ),
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
                            size: ResponsiveHelper.getResponsiveIconSize(
                              context,
                              mobile: 28,
                              tablet: 32,
                              desktop: 36,
                            ),
                          ),
                          SizedBox(
                            width: ResponsiveHelper.getResponsiveWidth(
                              context,
                              mobile: 12,
                              tablet: 16,
                              desktop: 20,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              provider.isTraining
                                  ? '🔥 التدريب قيد التشغيل'
                                  : provider.trainingProgress >= 1.0
                                  ? '✅ تم الانتهاء من التدريب'
                                  : '⏸️ التدريب متوقف',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 20,
                                      tablet: 22,
                                      desktop: 24,
                                    ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveHeight(
                          context,
                          mobile: 16,
                          tablet: 20,
                          desktop: 24,
                        ),
                      ),

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
                        minHeight: ResponsiveHelper.getResponsiveHeight(
                          context,
                          mobile: 8,
                          tablet: 10,
                          desktop: 12,
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveHelper.getResponsiveHeight(
                          context,
                          mobile: 12,
                          tablet: 16,
                          desktop: 20,
                        ),
                      ),

                      // نسبة التقدم والخطوة الحالية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(provider.trainingProgress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 18,
                                tablet: 20,
                                desktop: 22,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              provider.currentStep,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 14,
                                      tablet: 16,
                                      desktop: 18,
                                    ),
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
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: const EdgeInsets.all(16),
                      tablet: const EdgeInsets.all(20),
                      desktop: const EdgeInsets.all(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: Colors.blue,
                              size: ResponsiveHelper.getResponsiveIconSize(
                                context,
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
                            Text(
                              'إحصائيات التدريب',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      mobile: 18,
                                      tablet: 20,
                                      desktop: 22,
                                    ),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // معلومات الحالة
                        _buildStatRow(
                          context,
                          'الحالة',
                          provider.isTraining ? 'قيد التشغيل' : 'متوقف',
                          provider.isTraining ? Colors.green : Colors.orange,
                        ),

                        _buildStatRow(
                          context,
                          'الخطوة الحالية',
                          provider.currentStep,
                          Colors.blue,
                        ),

                        if (provider.errorMessage.isNotEmpty)
                          _buildStatRow(
                            context,
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
                              context,
                              'إجمالي الخلايا',
                              '${data['json_cells'] ?? 0}',
                              Colors.blue,
                            ),

                            _buildStatRow(
                              context,
                              'خلايا الكود',
                              '${data['json_code_cells'] ?? 0}',
                              Colors.green,
                            ),

                            _buildStatRow(
                              context,
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
                                context,
                                'وقت التدريب',
                                '${(evaluation['total_training_time_minutes'] ?? 0).toStringAsFixed(1)} دقيقة',
                                Colors.blue,
                              ),

                              _buildStatRow(
                                context,
                                'عينات التدريب',
                                '${evaluation['train_dataset_size'] ?? 0}',
                                Colors.green,
                              ),

                              _buildStatRow(
                                context,
                                'Loss النهائي',
                                '${(evaluation['training_loss'] ?? 0).toStringAsFixed(4)}',
                                Colors.orange,
                              ),

                              _buildStatRow(
                                context,
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

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.symmetric(vertical: 8),
        tablet: const EdgeInsets.symmetric(vertical: 10),
        desktop: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 4,
              tablet: 5,
              desktop: 6,
            ),
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 2,
                    tablet: 3,
                    desktop: 4,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 16,
                      tablet: 17,
                      desktop: 18,
                    ),
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
