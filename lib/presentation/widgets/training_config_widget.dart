import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';
import '../../core/utils/responsive_helper.dart';

class TrainingConfigWidget extends StatelessWidget {
  const TrainingConfigWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        final config = provider.trainingConfig;

        return ResponsiveBuilder(
          builder: (context, constraints, deviceType) {
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
                  // قسم النموذج
                  _buildSectionCard(
                    context,
                    title: '🤖 إعدادات النموذج',
                    children: [
                      _buildConfigDropdown(
                        label: 'نموذج التدريب',
                        value: config['model_name'],
                        items: const [
                          'microsoft/DialoGPT-medium',
                          'microsoft/DialoGPT-large',
                          'gpt2',
                          'gpt2-medium',
                          'distilgpt2',
                        ],
                        onChanged: (value) => provider.updateTrainingConfig({
                          'model_name': value,
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildConfigSlider(
                        label: 'عدد العصور (Epochs)',
                        value: config['epochs'].toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        onChanged: (value) => provider.updateTrainingConfig({
                          'epochs': value.round(),
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // قسم البيانات
                  _buildSectionCard(
                    context,
                    title: '📊 إعدادات البيانات',
                    children: [
                      _buildConfigSlider(
                        label: 'حجم الدفعة (Batch Size)',
                        value: config['batch_size'].toDouble(),
                        min: 1,
                        max: 16,
                        divisions: 15,
                        onChanged: (value) => provider.updateTrainingConfig({
                          'batch_size': value.round(),
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildConfigSlider(
                        label: 'الطول الأقصى للنص',
                        value: config['max_length'].toDouble(),
                        min: 128,
                        max: 1024,
                        divisions: 7,
                        onChanged: (value) => provider.updateTrainingConfig({
                          'max_length': value.round(),
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // قسم التحسين
                  _buildSectionCard(
                    context,
                    title: '⚡ إعدادات التحسين',
                    children: [
                      _buildConfigSlider(
                        label: 'معدل التعلم',
                        value: config['learning_rate'],
                        min: 1e-6,
                        max: 1e-3,
                        divisions: 100,
                        onChanged: (value) => provider.updateTrainingConfig({
                          'learning_rate': value,
                        }),
                        formatter: (value) => value.toStringAsExponential(1),
                      ),
                      const SizedBox(height: 16),
                      _buildConfigSlider(
                        label: 'خطوات الإحماء',
                        value: config['warmup_steps'].toDouble(),
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        onChanged: (value) => provider.updateTrainingConfig({
                          'warmup_steps': value.round(),
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // قسم الأداء
                  _buildSectionCard(
                    context,
                    title: '🚀 إعدادات الأداء',
                    children: [
                      SwitchListTile(
                        title: const Text('تفعيل FP16'),
                        subtitle: const Text(
                          'تقليل استخدام الذاكرة وتسريع التدريب',
                        ),
                        value: config['fp16'],
                        onChanged: (value) =>
                            provider.updateTrainingConfig({'fp16': value}),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: const Text('استخدام CUDA'),
                        subtitle: const Text('التدريب على GPU إذا كان متاحاً'),
                        value: config['use_cuda'],
                        onChanged: (value) =>
                            provider.updateTrainingConfig({'use_cuda': value}),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // قسم السجلات
                  _buildSectionCard(
                    context,
                    title: '📝 إعدادات السجلات',
                    children: [
                      _buildConfigSlider(
                        label: 'خطوات التسجيل',
                        value: config['logging_steps'].toDouble(),
                        min: 10,
                        max: 500,
                        divisions: 49,
                        onChanged: (value) => provider.updateTrainingConfig({
                          'logging_steps': value.round(),
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildConfigSlider(
                        label: 'خطوات الحفظ',
                        value: config['save_steps'].toDouble(),
                        min: 100,
                        max: 2000,
                        divisions: 19,
                        onChanged: (value) => provider.updateTrainingConfig({
                          'save_steps': value.round(),
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // معلومات البيانات
                  FutureBuilder<Map<String, dynamic>>(
                    future: provider.getDatasetInfo(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.info_outline, color: Colors.blue),
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
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'إجمالي الخلايا',
                                '${data['json_cells'] ?? 0}',
                              ),
                              _buildInfoRow(
                                'خلايا الكود',
                                '${data['json_code_cells'] ?? 0}',
                              ),
                              _buildInfoRow(
                                'حجم Parquet',
                                '${(data['parquet_size_mb'] ?? 0).toStringAsFixed(2)} MB',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
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
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: ResponsiveHelper.getResponsiveHeight(
                context,
                mobile: 16,
                tablet: 20,
                desktop: 24,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildConfigDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: items.map((item) {
            return DropdownMenuItem(value: item, child: Text(item));
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildConfigSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    String Function(double)? formatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              formatter?.call(value) ?? value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
