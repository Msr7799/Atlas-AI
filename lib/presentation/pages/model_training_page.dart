import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';
import '../widgets/training_progress_widget.dart';
import '../widgets/training_config_widget.dart';
import '../widgets/training_logs_widget.dart';
import '../../core/utils/responsive_helper.dart';

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
    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '🔥 تدريب النموذج المتقدم',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 18,
                  tablet: 20,
                  desktop: 22,
                ),
              ),
            ),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              isScrollable: ResponsiveHelper.isMobile(context),
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.settings,
                    size: ResponsiveHelper.getResponsiveIconSize(context),
                  ),
                  text: 'الإعدادات',
                ),
                Tab(
                  icon: Icon(
                    Icons.analytics,
                    size: ResponsiveHelper.getResponsiveIconSize(context),
                  ),
                  text: 'التقدم',
                ),
                Tab(
                  icon: Icon(
                    Icons.terminal,
                    size: ResponsiveHelper.getResponsiveIconSize(context),
                  ),
                  text: 'السجلات',
                ),
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
                    padding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: const EdgeInsets.all(12),
                      tablet: const EdgeInsets.all(16),
                      desktop: const EdgeInsets.all(20),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: provider.isTraining
                            ? [Colors.orange.shade100, Colors.orange.shade50]
                            : [Colors.green.shade100, Colors.green.shade50],
                      ),
                    ),
                    child: ResponsiveHelper.isMobile(context)
                        ? Column(
                            children: [
                              _buildStatusIcon(provider),
                              const SizedBox(height: 8),
                              _buildStatusText(provider, context),
                              if (provider.isTraining) ...[
                                const SizedBox(height: 12),
                                _buildStopButton(provider),
                              ],
                            ],
                          )
                        : Row(
                            children: [
                              _buildStatusIcon(provider),
                              SizedBox(
                                width: ResponsiveHelper.getResponsiveWidth(
                                  context,
                                  mobile: 8,
                                  tablet: 12,
                                  desktop: 16,
                                ),
                              ),
                              Expanded(
                                child: _buildStatusText(provider, context),
                              ),
                              if (provider.isTraining)
                                _buildStopButton(provider),
                            ],
                          ),
                  );
                },
              ),

              // محتوى التبويبات
              Expanded(
                child: Padding(
                  padding: ResponsiveHelper.getResponsivePadding(
                    context,
                    mobile: const EdgeInsets.all(8),
                    tablet: const EdgeInsets.all(12),
                    desktop: const EdgeInsets.all(16),
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      TrainingConfigWidget(),
                      TrainingProgressWidget(),
                      TrainingLogsWidget(),
                    ],
                  ),
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
                icon: Icon(
                  Icons.rocket_launch,
                  size: ResponsiveHelper.getResponsiveIconSize(context),
                ),
                label: Text(
                  '🚀 بدء التدريب',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 16,
                      desktop: 18,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon(TrainingProvider provider) {
    return Icon(
      provider.isTraining ? Icons.play_circle_filled : Icons.check_circle,
      color: provider.isTraining ? Colors.orange : Colors.green,
      size: ResponsiveHelper.getResponsiveIconSize(
        context,
        mobile: 24,
        tablet: 28,
        desktop: 32,
      ),
    );
  }

  Widget _buildStatusText(TrainingProvider provider, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.isTraining
              ? '🔥 التدريب قيد التشغيل...'
              : '✅ النظام جاهز للتدريب',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
          ),
        ),
        if (provider.isTraining)
          Text(
            '${(provider.trainingProgress * 100).toStringAsFixed(1)}% مكتمل',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 14,
                desktop: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStopButton(TrainingProvider provider) {
    return ElevatedButton.icon(
      onPressed: () => provider.stopTraining(),
      icon: Icon(
        Icons.stop,
        size: ResponsiveHelper.getResponsiveIconSize(context),
      ),
      label: Text(
        'إيقاف',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: ResponsiveHelper.getResponsivePadding(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          desktop: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  void _showStartTrainingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🚀 بدء التدريب',
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
        ),
        content: ConstrainedBox(
          constraints: ResponsiveHelper.getResponsiveConstraints(
            context,
            mobile: const BoxConstraints(maxWidth: 300),
            tablet: const BoxConstraints(maxWidth: 400),
            desktop: const BoxConstraints(maxWidth: 500),
          ),
          child: Text(
            'هل أنت متأكد من بدء عملية تدريب النموذج؟\n\n'
            'قد تستغرق العملية عدة ساعات حسب حجم البيانات وقوة الجهاز.',
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TrainingProvider>().startTraining();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: ResponsiveHelper.getResponsivePadding(
                context,
                mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tablet: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                desktop: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            child: Text(
              'بدء التدريب',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
